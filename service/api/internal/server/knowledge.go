package server

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
	"google.golang.org/grpc/codes"
)

const conceptColumns = `id, study_id, title, description_markdown, export_slug, version, archived_at`
const qualifiedConceptColumns = `c.id, c.study_id, c.title, c.description_markdown, c.export_slug, c.version, c.archived_at`

func scanConcept(row scanner) (*wantstudyv1.Concept, error) {
	value := &wantstudyv1.Concept{}
	var archivedAt *time.Time
	if err := row.Scan(&value.Id, &value.StudyId, &value.Title, &value.DescriptionMarkdown, &value.ExportSlug, &value.Version, &archivedAt); err != nil {
		return nil, err
	}
	value.Archived = archivedAt != nil
	return value, nil
}

func validateConcept(value *wantstudyv1.Concept, create bool) error {
	if value == nil {
		return invalid("concept", "is required")
	}
	if err := requireID("concept.id", value.GetId()); err != nil {
		return err
	}
	if err := requireID("concept.study_id", value.GetStudyId()); err != nil {
		return err
	}
	if err := requireTitle("concept.title", value.GetTitle()); err != nil {
		return err
	}
	if len(value.GetDescriptionMarkdown()) > contentLimit {
		return invalid("concept.description_markdown", "must not exceed 1 MiB")
	}
	if _, err := normalizeAliases(value.GetAliases()); err != nil {
		return err
	}
	if create {
		return requireSlug("concept.export_slug", value.GetExportSlug())
	}
	return nil
}

func (services *Services) hydrateConcept(ctx context.Context, value *wantstudyv1.Concept) (*wantstudyv1.Concept, error) {
	aliasRows, err := services.pool.Query(ctx, `SELECT alias FROM concept_aliases WHERE concept_id = $1 ORDER BY lower(alias), alias`, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for aliasRows.Next() {
		var alias string
		if err = aliasRows.Scan(&alias); err != nil {
			aliasRows.Close()
			return nil, mapDatabaseError(err)
		}
		value.Aliases = append(value.Aliases, alias)
	}
	aliasRows.Close()
	blockRows, err := services.pool.Query(ctx, `SELECT block_id FROM block_concepts WHERE concept_id = $1 ORDER BY block_id`, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for blockRows.Next() {
		var blockID string
		if err = blockRows.Scan(&blockID); err != nil {
			blockRows.Close()
			return nil, mapDatabaseError(err)
		}
		value.BlockIds = append(value.BlockIds, blockID)
	}
	blockRows.Close()
	return value, nil
}

func (services *Services) getConcept(ctx context.Context, id string) (*wantstudyv1.Concept, error) {
	value, err := scanConcept(services.pool.QueryRow(ctx, `SELECT `+conceptColumns+` FROM concepts WHERE id = $1`, id))
	if err != nil {
		return nil, err
	}
	return services.hydrateConcept(ctx, value)
}

func (services *Services) CreateConcept(ctx context.Context, request *wantstudyv1.CreateConceptRequest) (*wantstudyv1.Concept, error) {
	value := request.GetConcept()
	if err := validateConcept(value, true); err != nil {
		return nil, err
	}
	aliases, _ := normalizeAliases(value.GetAliases())
	tx, err := services.pool.Begin(ctx)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer tx.Rollback(ctx)
	tag, err := tx.Exec(ctx, `
		INSERT INTO concepts (id, study_id, title, description_markdown, export_slug)
		VALUES ($1, $2, $3, $4, $5) ON CONFLICT (id) DO NOTHING`,
		value.Id, value.StudyId, strings.TrimSpace(value.Title), value.DescriptionMarkdown, value.ExportSlug)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 1 {
		if err = insertConceptAliases(ctx, tx, value.StudyId, value.Id, aliases); err != nil {
			return nil, mapDatabaseError(err)
		}
	}
	if err = tx.Commit(ctx); err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getConcept(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && (stored.StudyId != value.StudyId || stored.Title != strings.TrimSpace(value.Title) || stored.DescriptionMarkdown != value.DescriptionMarkdown || stored.ExportSlug != value.ExportSlug || !sameStrings(stored.Aliases, aliases)) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "concept id already contains different data")
	}
	return stored, nil
}

func (services *Services) UpdateConcept(ctx context.Context, request *wantstudyv1.UpdateConceptRequest) (*wantstudyv1.Concept, error) {
	value := request.GetConcept()
	if err := validateConcept(value, false); err != nil {
		return nil, err
	}
	aliases, _ := normalizeAliases(value.GetAliases())
	tx, err := services.pool.Begin(ctx)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer tx.Rollback(ctx)
	_, err = scanConcept(tx.QueryRow(ctx, `
		UPDATE concepts
		SET title = $2, description_markdown = $3, version = version + 1, updated_at = now()
		WHERE id = $1 AND study_id = $4 AND version = $5
		RETURNING `+conceptColumns, value.Id, strings.TrimSpace(value.Title), value.DescriptionMarkdown, value.StudyId, request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		_ = tx.Rollback(ctx)
		return nil, services.versionOrMissing(ctx, "concepts", value.Id, request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if _, err = tx.Exec(ctx, `DELETE FROM concept_aliases WHERE concept_id = $1`, value.Id); err != nil {
		return nil, mapDatabaseError(err)
	}
	if err = insertConceptAliases(ctx, tx, value.StudyId, value.Id, aliases); err != nil {
		return nil, mapDatabaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getConcept(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return stored, nil
}

func normalizeAliases(values []string) ([]string, error) {
	result := make([]string, 0, len(values))
	seen := make(map[string]struct{}, len(values))
	for _, value := range values {
		alias := strings.TrimSpace(value)
		if err := validateAlias(alias); err != nil {
			return nil, err
		}
		key := strings.ToLower(alias)
		if _, exists := seen[key]; exists {
			continue
		}
		seen[key] = struct{}{}
		result = append(result, alias)
	}
	return result, nil
}

func insertConceptAliases(ctx context.Context, tx pgx.Tx, studyID, conceptID string, aliases []string) error {
	for _, alias := range aliases {
		if _, err := tx.Exec(ctx, `INSERT INTO concept_aliases (study_id, concept_id, alias) VALUES ($1, $2, $3)`, studyID, conceptID, alias); err != nil {
			return err
		}
	}
	return nil
}

func sameStrings(left, right []string) bool {
	if len(left) != len(right) {
		return false
	}
	values := make(map[string]struct{}, len(left))
	for _, value := range left {
		values[value] = struct{}{}
	}
	for _, value := range right {
		if _, exists := values[value]; !exists {
			return false
		}
	}
	return true
}

func (services *Services) ArchiveConcept(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Concept, error) {
	return services.changeConceptArchive(ctx, request, true)
}

func (services *Services) RestoreConcept(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Concept, error) {
	return services.changeConceptArchive(ctx, request, false)
}

func (services *Services) changeConceptArchive(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest, archived bool) (*wantstudyv1.Concept, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	stored, err := scanConcept(services.pool.QueryRow(ctx, `
		UPDATE concepts
		SET archived_at = CASE WHEN $3 THEN now() ELSE NULL END, version = version + 1, updated_at = now()
		WHERE id = $1 AND version = $2 RETURNING `+conceptColumns, request.GetId(), request.GetExpectedVersion(), archived))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "concepts", request.GetId(), request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return services.hydrateConcept(ctx, stored)
}

func validateAlias(value string) error {
	return requireTitle("alias", value)
}

func (services *Services) AddConceptAlias(ctx context.Context, request *wantstudyv1.ChangeConceptAliasRequest) (*wantstudyv1.Concept, error) {
	if err := validateAlias(request.GetAlias()); err != nil {
		return nil, err
	}
	return services.changeConceptSet(ctx, request.GetConceptId(), request.GetExpectedVersion(), `INSERT INTO concept_aliases (study_id, concept_id, alias) SELECT study_id, id, $2 FROM concepts WHERE id = $1`, strings.TrimSpace(request.GetAlias()))
}

func (services *Services) RemoveConceptAlias(ctx context.Context, request *wantstudyv1.ChangeConceptAliasRequest) (*wantstudyv1.Concept, error) {
	if err := validateAlias(request.GetAlias()); err != nil {
		return nil, err
	}
	return services.changeConceptSet(ctx, request.GetConceptId(), request.GetExpectedVersion(), `DELETE FROM concept_aliases WHERE concept_id = $1 AND alias = $2`, strings.TrimSpace(request.GetAlias()))
}

func (services *Services) LinkBlockConcept(ctx context.Context, request *wantstudyv1.ChangeBlockConceptRequest) (*wantstudyv1.Concept, error) {
	if err := requireID("block_id", request.GetBlockId()); err != nil {
		return nil, err
	}
	return services.changeConceptSet(ctx, request.GetConceptId(), request.GetExpectedVersion(), `INSERT INTO block_concepts (study_id, block_id, concept_id) SELECT c.study_id, $2, c.id FROM concepts c WHERE c.id = $1`, request.GetBlockId())
}

func (services *Services) UnlinkBlockConcept(ctx context.Context, request *wantstudyv1.ChangeBlockConceptRequest) (*wantstudyv1.Concept, error) {
	if err := requireID("block_id", request.GetBlockId()); err != nil {
		return nil, err
	}
	return services.changeConceptSet(ctx, request.GetConceptId(), request.GetExpectedVersion(), `DELETE FROM block_concepts WHERE concept_id = $1 AND block_id = $2`, request.GetBlockId())
}

func (services *Services) changeConceptSet(ctx context.Context, conceptID string, expectedVersion int64, command string, argument string) (*wantstudyv1.Concept, error) {
	if err := requireID("concept_id", conceptID); err != nil {
		return nil, err
	}
	tx, err := services.pool.Begin(ctx)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer tx.Rollback(ctx)
	tag, err := tx.Exec(ctx, `UPDATE concepts SET version = version + 1, updated_at = now() WHERE id = $1 AND version = $2`, conceptID, expectedVersion)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() != 1 {
		return nil, conflict("concept/"+conceptID, expectedVersion)
	}
	if _, err = tx.Exec(ctx, command, conceptID, argument); err != nil {
		return nil, mapDatabaseError(err)
	}
	if err = tx.Commit(ctx); err != nil {
		return nil, mapDatabaseError(err)
	}
	return services.getConcept(ctx, conceptID)
}

func relationTypeToDatabase(value wantstudyv1.ConceptRelationType) (string, bool, error) {
	switch value {
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_RELATED_TO:
		return "relatedTo", true, nil
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PART_OF:
		return "partOf", false, nil
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR:
		return "prerequisiteFor", false, nil
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_CONTRASTS_WITH:
		return "contrastsWith", true, nil
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_APPLIES_TO:
		return "appliesTo", false, nil
	default:
		return "", false, invalid("relation.type", "must be specified")
	}
}

func relationTypeFromDatabase(value string) wantstudyv1.ConceptRelationType {
	switch value {
	case "relatedTo":
		return wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_RELATED_TO
	case "partOf":
		return wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PART_OF
	case "prerequisiteFor":
		return wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR
	case "contrastsWith":
		return wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_CONTRASTS_WITH
	default:
		return wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_APPLIES_TO
	}
}

const relationColumns = `id, study_id, source_concept_id, target_concept_id, relation_type, version`

func scanRelation(row scanner) (*wantstudyv1.ConceptRelation, error) {
	value := &wantstudyv1.ConceptRelation{}
	var relationType string
	if err := row.Scan(&value.Id, &value.StudyId, &value.SourceConceptId, &value.TargetConceptId, &relationType, &value.Version); err != nil {
		return nil, err
	}
	value.Type = relationTypeFromDatabase(relationType)
	return value, nil
}

func (services *Services) PutConceptRelation(ctx context.Context, request *wantstudyv1.PutConceptRelationRequest) (*wantstudyv1.ConceptRelation, error) {
	value := request.GetRelation()
	if value == nil {
		return nil, invalid("relation", "is required")
	}
	for _, item := range []struct{ field, id string }{
		{"relation.id", value.GetId()},
		{"relation.study_id", value.GetStudyId()},
		{"relation.source_concept_id", value.GetSourceConceptId()},
		{"relation.target_concept_id", value.GetTargetConceptId()},
	} {
		if err := requireID(item.field, item.id); err != nil {
			return nil, err
		}
	}
	if value.GetSourceConceptId() == value.GetTargetConceptId() {
		return nil, invalid("relation", "self-references are not allowed")
	}
	relationType, symmetric, err := relationTypeToDatabase(value.GetType())
	if err != nil {
		return nil, err
	}
	sourceID := value.GetSourceConceptId()
	targetID := value.GetTargetConceptId()
	if symmetric && sourceID > targetID {
		sourceID, targetID = targetID, sourceID
	}
	tag, err := services.pool.Exec(ctx, `
		INSERT INTO concept_relations (id, study_id, source_concept_id, target_concept_id, relation_type)
		VALUES ($1, $2, $3, $4, $5) ON CONFLICT (id) DO NOTHING`, value.Id, value.StudyId, sourceID, targetID, relationType)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := scanRelation(services.pool.QueryRow(ctx, `SELECT `+relationColumns+` FROM concept_relations WHERE id = $1`, value.Id))
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && (stored.StudyId != value.StudyId || stored.SourceConceptId != sourceID || stored.TargetConceptId != targetID || stored.Type != value.Type) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "relation id already contains different data")
	}
	return stored, nil
}

func (services *Services) DeleteConceptRelation(ctx context.Context, request *wantstudyv1.DeleteConceptRelationRequest) (*wantstudyv1.DeleteConceptRelationResponse, error) {
	if !request.GetConfirmed() {
		return nil, statusError(codes.FailedPrecondition, "CONFIRMATION_REQUIRED", "deletion requires confirmation")
	}
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	tag, err := services.pool.Exec(ctx, `DELETE FROM concept_relations WHERE id = $1 AND version = $2`, request.GetId(), request.GetExpectedVersion())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() != 1 {
		return nil, services.versionOrMissing(ctx, "concept_relations", request.GetId(), request.GetExpectedVersion())
	}
	return &wantstudyv1.DeleteConceptRelationResponse{Id: request.GetId()}, nil
}

func (services *Services) SearchConcepts(ctx context.Context, request *wantstudyv1.SearchConceptsRequest) (*wantstudyv1.SearchConceptsResponse, error) {
	if err := requireID("study_id", request.GetStudyId()); err != nil {
		return nil, err
	}
	limit := request.GetLimit()
	if limit <= 0 {
		limit = 50
	}
	if limit > 100 {
		limit = 100
	}
	query := "%" + request.GetQuery() + "%"
	rows, err := services.pool.Query(ctx, `
		SELECT DISTINCT `+qualifiedConceptColumns+`
		FROM concepts c
		LEFT JOIN concept_aliases a ON a.concept_id = c.id
		WHERE c.study_id = $1 AND ($2 OR c.archived_at IS NULL) AND (c.title ILIKE $3 OR a.alias ILIKE $3)
		ORDER BY c.title, c.id LIMIT $4`, request.GetStudyId(), request.GetIncludeArchived(), query, limit)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer rows.Close()
	response := &wantstudyv1.SearchConceptsResponse{}
	for rows.Next() {
		value, scanErr := scanConcept(rows)
		if scanErr != nil {
			return nil, mapDatabaseError(scanErr)
		}
		value, scanErr = services.hydrateConcept(ctx, value)
		if scanErr != nil {
			return nil, scanErr
		}
		response.Concepts = append(response.Concepts, value)
	}
	return response, nil
}

func (services *Services) GetConceptGraph(ctx context.Context, request *wantstudyv1.GetConceptGraphRequest) (*wantstudyv1.ConceptGraph, error) {
	if err := requireID("study_id", request.GetStudyId()); err != nil {
		return nil, err
	}
	var total int
	if err := services.pool.QueryRow(ctx, `SELECT count(*) FROM concepts WHERE study_id = $1 AND archived_at IS NULL`, request.GetStudyId()).Scan(&total); err != nil {
		return nil, mapDatabaseError(err)
	}
	ids := make([]string, 0)
	truncated := total > 300
	if !truncated {
		rows, err := services.pool.Query(ctx, `SELECT id FROM concepts WHERE study_id = $1 AND archived_at IS NULL ORDER BY id`, request.GetStudyId())
		if err != nil {
			return nil, mapDatabaseError(err)
		}
		for rows.Next() {
			var id string
			if err = rows.Scan(&id); err != nil {
				rows.Close()
				return nil, mapDatabaseError(err)
			}
			ids = append(ids, id)
		}
		rows.Close()
	} else {
		if request.SelectedConceptId == nil {
			return nil, invalid("selected_concept_id", "is required when the graph has more than 300 concepts")
		}
		if err := requireID("selected_concept_id", request.GetSelectedConceptId()); err != nil {
			return nil, err
		}
		rows, err := services.pool.Query(ctx, `
			WITH RECURSIVE reach(id, depth, visited) AS (
				SELECT $2::uuid, 0, ARRAY[$2::uuid]
				UNION ALL
				SELECT CASE WHEN r.source_concept_id = reach.id THEN r.target_concept_id ELSE r.source_concept_id END,
				       reach.depth + 1,
				       visited || CASE WHEN r.source_concept_id = reach.id THEN r.target_concept_id ELSE r.source_concept_id END
				FROM reach
				JOIN concept_relations r ON r.study_id = $1 AND (r.source_concept_id = reach.id OR r.target_concept_id = reach.id)
				WHERE reach.depth < 2
				  AND NOT (CASE WHEN r.source_concept_id = reach.id THEN r.target_concept_id ELSE r.source_concept_id END = ANY(visited))
			)
			SELECT DISTINCT reach.id FROM reach JOIN concepts c ON c.id = reach.id WHERE c.archived_at IS NULL ORDER BY reach.id`, request.GetStudyId(), request.GetSelectedConceptId())
		if err != nil {
			return nil, mapDatabaseError(err)
		}
		for rows.Next() {
			var id string
			if err = rows.Scan(&id); err != nil {
				rows.Close()
				return nil, mapDatabaseError(err)
			}
			ids = append(ids, id)
		}
		rows.Close()
	}
	result := &wantstudyv1.ConceptGraph{Truncated: truncated}
	for _, id := range ids {
		value, err := services.getConcept(ctx, id)
		if err != nil {
			return nil, mapDatabaseError(err)
		}
		result.Concepts = append(result.Concepts, value)
	}
	if len(ids) == 0 {
		return result, nil
	}
	relationRows, err := services.pool.Query(ctx, `
		SELECT `+relationColumns+` FROM concept_relations
		WHERE study_id = $1 AND source_concept_id = ANY($2::uuid[]) AND target_concept_id = ANY($2::uuid[])
		ORDER BY relation_type, source_concept_id, target_concept_id, id`, request.GetStudyId(), ids)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer relationRows.Close()
	for relationRows.Next() {
		value, scanErr := scanRelation(relationRows)
		if scanErr != nil {
			return nil, mapDatabaseError(scanErr)
		}
		result.Relations = append(result.Relations, value)
	}
	return result, nil
}
