package server

import (
	"context"
	"errors"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
	"google.golang.org/grpc/codes"
)

var slugPattern = regexp.MustCompile(`^[a-z0-9]+(?:-[a-z0-9]+)*$`)

type scanner interface {
	Scan(destinations ...any) error
}

func requireID(field, value string) error {
	if _, err := uuid.Parse(value); err != nil {
		return invalid(field, "must be a UUID")
	}
	return nil
}

func requireTitle(field, value string) error {
	length := len([]rune(strings.TrimSpace(value)))
	if length < 1 || length > 200 {
		return invalid(field, "must contain 1 to 200 characters")
	}
	return nil
}

func requireSlug(field, value string) error {
	if !slugPattern.MatchString(value) {
		return invalid(field, "must be stable lowercase ASCII words separated by hyphens")
	}
	return nil
}

func requirePosition(field string, value int32) error {
	if value < 0 {
		return invalid(field, "must not be negative")
	}
	return nil
}

func milliseconds(value time.Time) int64 {
	return value.UnixMilli()
}

func optionalMilliseconds(value *time.Time) *int64 {
	if value == nil {
		return nil
	}
	result := value.UnixMilli()
	return &result
}

func scanStudy(row scanner) (*wantstudyv1.Study, error) {
	value := &wantstudyv1.Study{}
	var archivedAt *time.Time
	var createdAt time.Time
	var updatedAt time.Time
	err := row.Scan(
		&value.Id,
		&value.Title,
		&value.Goal,
		&value.LocalRepositoryPath,
		&value.Version,
		&value.ContentRevision,
		&archivedAt,
		&createdAt,
		&updatedAt,
	)
	if err != nil {
		return nil, err
	}
	value.Archived = archivedAt != nil
	value.CreatedAtEpochMillis = milliseconds(createdAt)
	value.UpdatedAtEpochMillis = milliseconds(updatedAt)
	return value, nil
}

const studyColumns = `id, title, goal, local_repository_path, version, content_revision, archived_at, created_at, updated_at`

func (services *Services) CreateStudy(ctx context.Context, request *wantstudyv1.CreateStudyRequest) (*wantstudyv1.Study, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	if err := requireTitle("title", request.GetTitle()); err != nil {
		return nil, err
	}
	if len(request.GetGoal()) > 1048576 {
		return nil, invalid("goal", "must not exceed 1 MiB")
	}
	tag, err := services.pool.Exec(ctx, `
		INSERT INTO studies (id, title, goal, local_repository_path)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (id) DO NOTHING`,
		request.GetId(), strings.TrimSpace(request.GetTitle()), request.GetGoal(), request.GetLocalRepositoryPath())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	study, err := services.getStudy(ctx, request.GetId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && (study.Title != strings.TrimSpace(request.GetTitle()) || study.Goal != request.GetGoal() || study.LocalRepositoryPath != request.GetLocalRepositoryPath()) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "study id already contains different data")
	}
	return study, nil
}

func (services *Services) GetStudy(ctx context.Context, request *wantstudyv1.GetStudyRequest) (*wantstudyv1.Study, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	study, err := services.getStudy(ctx, request.GetId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return study, nil
}

func (services *Services) getStudy(ctx context.Context, id string) (*wantstudyv1.Study, error) {
	return scanStudy(services.pool.QueryRow(ctx, `SELECT `+studyColumns+` FROM studies WHERE id = $1`, id))
}

func (services *Services) ListStudies(ctx context.Context, request *wantstudyv1.ListStudiesRequest) (*wantstudyv1.ListStudiesResponse, error) {
	rows, err := services.pool.Query(ctx, `
		SELECT `+studyColumns+`
		FROM studies
		WHERE $1 OR archived_at IS NULL
		ORDER BY archived_at NULLS FIRST, lower(title), id`, request.GetIncludeArchived())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer rows.Close()
	response := &wantstudyv1.ListStudiesResponse{}
	for rows.Next() {
		study, scanErr := scanStudy(rows)
		if scanErr != nil {
			return nil, mapDatabaseError(scanErr)
		}
		response.Studies = append(response.Studies, study)
	}
	if err = rows.Err(); err != nil {
		return nil, mapDatabaseError(err)
	}
	return response, nil
}

func (services *Services) UpdateStudy(ctx context.Context, request *wantstudyv1.UpdateStudyRequest) (*wantstudyv1.Study, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	if err := requireTitle("title", request.GetTitle()); err != nil {
		return nil, err
	}
	if request.GetExpectedVersion() < 1 {
		return nil, invalid("expected_version", "must be positive")
	}
	study, err := scanStudy(services.pool.QueryRow(ctx, `
		UPDATE studies
		SET title = $2, goal = $3, local_repository_path = $4, version = version + 1
		WHERE id = $1 AND version = $5
		RETURNING `+studyColumns,
		request.GetId(), strings.TrimSpace(request.GetTitle()), request.GetGoal(), request.GetLocalRepositoryPath(), request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "studies", request.GetId(), request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return study, nil
}

func (services *Services) ArchiveStudy(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Study, error) {
	return services.changeStudyArchive(ctx, request, true)
}

func (services *Services) RestoreStudy(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Study, error) {
	return services.changeStudyArchive(ctx, request, false)
}

func (services *Services) changeStudyArchive(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest, archived bool) (*wantstudyv1.Study, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	if request.GetExpectedVersion() < 1 {
		return nil, invalid("expected_version", "must be positive")
	}
	study, err := scanStudy(services.pool.QueryRow(ctx, `
		UPDATE studies
		SET archived_at = CASE WHEN $3 THEN now() ELSE NULL END, version = version + 1
		WHERE id = $1 AND version = $2
		RETURNING `+studyColumns, request.GetId(), request.GetExpectedVersion(), archived))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "studies", request.GetId(), request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return study, nil
}

func (services *Services) versionOrMissing(ctx context.Context, table, id string, expected int64) error {
	var exists bool
	query := `SELECT EXISTS (SELECT 1 FROM ` + table + ` WHERE id = $1)`
	if err := services.pool.QueryRow(ctx, query, id).Scan(&exists); err != nil {
		return mapDatabaseError(err)
	}
	if !exists {
		return notFound(strings.TrimSuffix(table, "s"))
	}
	return conflict(strings.TrimSuffix(table, "s")+"/"+id, expected)
}

func sourceTypeToDatabase(value wantstudyv1.LearningSourceType) (string, error) {
	switch value {
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_COURSE:
		return "course", nil
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_BOOK:
		return "book", nil
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_ARTICLE:
		return "article", nil
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_VIDEO:
		return "video", nil
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_OTHER:
		return "other", nil
	default:
		return "", invalid("type", "must be specified")
	}
}

func sourceTypeFromDatabase(value string) wantstudyv1.LearningSourceType {
	switch value {
	case "course":
		return wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_COURSE
	case "book":
		return wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_BOOK
	case "article":
		return wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_ARTICLE
	case "video":
		return wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_VIDEO
	default:
		return wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_OTHER
	}
}

const sourceColumns = `id, study_id, source_type, title, author, url, export_slug, position, version, archived_at`

func scanSource(row scanner) (*wantstudyv1.LearningSource, error) {
	value := &wantstudyv1.LearningSource{}
	var sourceType string
	var archivedAt *time.Time
	if err := row.Scan(&value.Id, &value.StudyId, &sourceType, &value.Title, &value.Author, &value.Url, &value.ExportSlug, &value.Position, &value.Version, &archivedAt); err != nil {
		return nil, err
	}
	value.Type = sourceTypeFromDatabase(sourceType)
	value.Archived = archivedAt != nil
	return value, nil
}

func validateSource(value *wantstudyv1.LearningSource, create bool) (string, error) {
	if value == nil {
		return "", invalid("source", "is required")
	}
	if err := requireID("source.id", value.GetId()); err != nil {
		return "", err
	}
	if err := requireID("source.study_id", value.GetStudyId()); err != nil {
		return "", err
	}
	if err := requireTitle("source.title", value.GetTitle()); err != nil {
		return "", err
	}
	if err := requirePosition("source.position", value.GetPosition()); err != nil {
		return "", err
	}
	if create {
		if err := requireSlug("source.export_slug", value.GetExportSlug()); err != nil {
			return "", err
		}
	}
	return sourceTypeToDatabase(value.GetType())
}

func (services *Services) CreateLearningSource(ctx context.Context, request *wantstudyv1.CreateLearningSourceRequest) (*wantstudyv1.LearningSource, error) {
	value := &wantstudyv1.LearningSource{Id: request.GetId(), StudyId: request.GetStudyId(), Type: request.GetType(), Title: request.GetTitle(), Author: request.GetAuthor(), Url: request.GetUrl(), ExportSlug: request.GetExportSlug(), Position: request.GetPosition()}
	sourceType, err := validateSource(value, true)
	if err != nil {
		return nil, err
	}
	tag, err := services.pool.Exec(ctx, `
		INSERT INTO learning_sources (id, study_id, source_type, title, author, url, export_slug, position)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (id) DO NOTHING`, value.Id, value.StudyId, sourceType, strings.TrimSpace(value.Title), value.Author, value.Url, value.ExportSlug, value.Position)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getSource(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && !equalSourceCreate(stored, value) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "source id already contains different data")
	}
	return stored, nil
}

func equalSourceCreate(stored, requested *wantstudyv1.LearningSource) bool {
	return stored.StudyId == requested.StudyId && stored.Type == requested.Type && stored.Title == strings.TrimSpace(requested.Title) && stored.Author == requested.Author && stored.Url == requested.Url && stored.ExportSlug == requested.ExportSlug && stored.Position == requested.Position
}

func (services *Services) getSource(ctx context.Context, id string) (*wantstudyv1.LearningSource, error) {
	return scanSource(services.pool.QueryRow(ctx, `SELECT `+sourceColumns+` FROM learning_sources WHERE id = $1`, id))
}

func (services *Services) UpdateLearningSource(ctx context.Context, request *wantstudyv1.UpdateLearningSourceRequest) (*wantstudyv1.LearningSource, error) {
	value := request.GetSource()
	sourceType, err := validateSource(value, false)
	if err != nil {
		return nil, err
	}
	if request.GetExpectedVersion() < 1 {
		return nil, invalid("expected_version", "must be positive")
	}
	stored, err := scanSource(services.pool.QueryRow(ctx, `
		UPDATE learning_sources
		SET source_type = $2, title = $3, author = $4, url = $5, position = $6, version = version + 1, updated_at = now()
		WHERE id = $1 AND study_id = $7 AND version = $8
		RETURNING `+sourceColumns, value.Id, sourceType, strings.TrimSpace(value.Title), value.Author, value.Url, value.Position, value.StudyId, request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "learning_sources", value.Id, request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return stored, nil
}

func (services *Services) ArchiveLearningSource(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.LearningSource, error) {
	return services.changeSourceArchive(ctx, request, true)
}

func (services *Services) RestoreLearningSource(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.LearningSource, error) {
	return services.changeSourceArchive(ctx, request, false)
}

func (services *Services) changeSourceArchive(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest, archived bool) (*wantstudyv1.LearningSource, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	value, err := scanSource(services.pool.QueryRow(ctx, `
		UPDATE learning_sources
		SET archived_at = CASE WHEN $3 THEN now() ELSE NULL END, version = version + 1, updated_at = now()
		WHERE id = $1 AND version = $2
		RETURNING `+sourceColumns, request.GetId(), request.GetExpectedVersion(), archived))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "learning_sources", request.GetId(), request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return value, nil
}

const sectionColumns = `id, study_id, source_id, title, position, version, archived_at`

func scanSection(row scanner) (*wantstudyv1.Section, error) {
	value := &wantstudyv1.Section{}
	var archivedAt *time.Time
	if err := row.Scan(&value.Id, &value.StudyId, &value.SourceId, &value.Title, &value.Position, &value.Version, &archivedAt); err != nil {
		return nil, err
	}
	value.Archived = archivedAt != nil
	return value, nil
}

func validateSection(value *wantstudyv1.Section) error {
	if value == nil {
		return invalid("section", "is required")
	}
	for _, item := range []struct{ field, id string }{
		{"section.id", value.GetId()},
		{"section.study_id", value.GetStudyId()},
		{"section.source_id", value.GetSourceId()},
	} {
		if err := requireID(item.field, item.id); err != nil {
			return err
		}
	}
	if err := requireTitle("section.title", value.GetTitle()); err != nil {
		return err
	}
	return requirePosition("section.position", value.GetPosition())
}

func (services *Services) CreateSection(ctx context.Context, request *wantstudyv1.CreateSectionRequest) (*wantstudyv1.Section, error) {
	value := &wantstudyv1.Section{Id: request.GetId(), StudyId: request.GetStudyId(), SourceId: request.GetSourceId(), Title: request.GetTitle(), Position: request.GetPosition()}
	if err := validateSection(value); err != nil {
		return nil, err
	}
	tag, err := services.pool.Exec(ctx, `INSERT INTO sections (id, study_id, source_id, title, position) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (id) DO NOTHING`, value.Id, value.StudyId, value.SourceId, strings.TrimSpace(value.Title), value.Position)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getSection(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && (stored.StudyId != value.StudyId || stored.SourceId != value.SourceId || stored.Title != strings.TrimSpace(value.Title) || stored.Position != value.Position) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "section id already contains different data")
	}
	return stored, nil
}

func (services *Services) getSection(ctx context.Context, id string) (*wantstudyv1.Section, error) {
	return scanSection(services.pool.QueryRow(ctx, `SELECT `+sectionColumns+` FROM sections WHERE id = $1`, id))
}

func (services *Services) UpdateSection(ctx context.Context, request *wantstudyv1.UpdateSectionRequest) (*wantstudyv1.Section, error) {
	value := request.GetSection()
	if err := validateSection(value); err != nil {
		return nil, err
	}
	stored, err := scanSection(services.pool.QueryRow(ctx, `
		UPDATE sections SET title = $2, position = $3, version = version + 1, updated_at = now()
		WHERE id = $1 AND study_id = $4 AND source_id = $5 AND version = $6
		RETURNING `+sectionColumns, value.Id, strings.TrimSpace(value.Title), value.Position, value.StudyId, value.SourceId, request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "sections", value.Id, request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return stored, nil
}

func (services *Services) ArchiveSection(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Section, error) {
	return services.changeSectionArchive(ctx, request, true)
}

func (services *Services) RestoreSection(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Section, error) {
	return services.changeSectionArchive(ctx, request, false)
}

func (services *Services) changeSectionArchive(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest, archived bool) (*wantstudyv1.Section, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	value, err := scanSection(services.pool.QueryRow(ctx, `
		UPDATE sections SET archived_at = CASE WHEN $3 THEN now() ELSE NULL END, version = version + 1, updated_at = now()
		WHERE id = $1 AND version = $2 RETURNING `+sectionColumns, request.GetId(), request.GetExpectedVersion(), archived))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "sections", request.GetId(), request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return value, nil
}

func lessonStatusToDatabase(value wantstudyv1.LessonStatus) (string, error) {
	switch value {
	case wantstudyv1.LessonStatus_LESSON_STATUS_PLANNED:
		return "planned", nil
	case wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING:
		return "studying", nil
	case wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK:
		return "homework", nil
	case wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED:
		return "mastered", nil
	default:
		return "", invalid("status", "must be specified")
	}
}

func lessonStatusFromDatabase(value string) wantstudyv1.LessonStatus {
	switch value {
	case "planned":
		return wantstudyv1.LessonStatus_LESSON_STATUS_PLANNED
	case "studying":
		return wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING
	case "homework":
		return wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK
	default:
		return wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED
	}
}

const lessonColumns = `id, study_id, source_id, section_id, title, url, source_position, export_slug, position, status, started_at, mastered_at, version, archived_at`

func scanLesson(row scanner) (*wantstudyv1.Lesson, error) {
	value := &wantstudyv1.Lesson{}
	var sectionID *string
	var statusValue string
	var startedAt *time.Time
	var masteredAt *time.Time
	var archivedAt *time.Time
	if err := row.Scan(&value.Id, &value.StudyId, &value.SourceId, &sectionID, &value.Title, &value.Url, &value.SourcePosition, &value.ExportSlug, &value.Position, &statusValue, &startedAt, &masteredAt, &value.Version, &archivedAt); err != nil {
		return nil, err
	}
	value.SectionId = sectionID
	value.Status = lessonStatusFromDatabase(statusValue)
	value.StartedAtEpochMillis = optionalMilliseconds(startedAt)
	value.MasteredAtEpochMillis = optionalMilliseconds(masteredAt)
	value.Archived = archivedAt != nil
	return value, nil
}

func validateLesson(value *wantstudyv1.Lesson, create bool) (string, error) {
	if value == nil {
		return "", invalid("lesson", "is required")
	}
	for _, item := range []struct{ field, id string }{
		{"lesson.id", value.GetId()},
		{"lesson.study_id", value.GetStudyId()},
		{"lesson.source_id", value.GetSourceId()},
	} {
		if err := requireID(item.field, item.id); err != nil {
			return "", err
		}
	}
	if value.SectionId != nil {
		if err := requireID("lesson.section_id", value.GetSectionId()); err != nil {
			return "", err
		}
	}
	if err := requireTitle("lesson.title", value.GetTitle()); err != nil {
		return "", err
	}
	if err := requirePosition("lesson.position", value.GetPosition()); err != nil {
		return "", err
	}
	if create {
		if err := requireSlug("lesson.export_slug", value.GetExportSlug()); err != nil {
			return "", err
		}
	}
	return lessonStatusToDatabase(value.GetStatus())
}

func (services *Services) CreateLesson(ctx context.Context, request *wantstudyv1.CreateLessonRequest) (*wantstudyv1.Lesson, error) {
	value := &wantstudyv1.Lesson{Id: request.GetId(), StudyId: request.GetStudyId(), SourceId: request.GetSourceId(), SectionId: request.SectionId, Title: request.GetTitle(), Url: request.GetUrl(), SourcePosition: request.GetSourcePosition(), ExportSlug: request.GetExportSlug(), Position: request.GetPosition(), Status: request.GetStatus()}
	statusValue, err := validateLesson(value, true)
	if err != nil {
		return nil, err
	}
	var startedAt any
	var masteredAt any
	if statusValue != "planned" {
		startedAt = time.Now().UTC()
	}
	if statusValue == "mastered" {
		masteredAt = time.Now().UTC()
	}
	tag, err := services.pool.Exec(ctx, `
		INSERT INTO lessons (id, study_id, source_id, section_id, title, url, source_position, export_slug, position, status, started_at, mastered_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		ON CONFLICT (id) DO NOTHING`, value.Id, value.StudyId, value.SourceId, value.SectionId, strings.TrimSpace(value.Title), value.Url, value.SourcePosition, value.ExportSlug, value.Position, statusValue, startedAt, masteredAt)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getLesson(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && !equalLessonCreate(stored, value) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "lesson id already contains different data")
	}
	return stored, nil
}

func equalLessonCreate(stored, requested *wantstudyv1.Lesson) bool {
	return stored.StudyId == requested.StudyId && stored.SourceId == requested.SourceId && stored.GetSectionId() == requested.GetSectionId() && stored.Title == strings.TrimSpace(requested.Title) && stored.Url == requested.Url && stored.SourcePosition == requested.SourcePosition && stored.ExportSlug == requested.ExportSlug && stored.Position == requested.Position && stored.Status == requested.Status
}

func (services *Services) getLesson(ctx context.Context, id string) (*wantstudyv1.Lesson, error) {
	return scanLesson(services.pool.QueryRow(ctx, `SELECT `+lessonColumns+` FROM lessons WHERE id = $1`, id))
}

func (services *Services) UpdateLesson(ctx context.Context, request *wantstudyv1.UpdateLessonRequest) (*wantstudyv1.Lesson, error) {
	value := request.GetLesson()
	if _, err := validateLesson(value, false); err != nil {
		return nil, err
	}
	stored, err := scanLesson(services.pool.QueryRow(ctx, `
		UPDATE lessons
		SET section_id = $2, title = $3, url = $4, source_position = $5, position = $6, version = version + 1, updated_at = now()
		WHERE id = $1 AND study_id = $7 AND source_id = $8 AND version = $9
		RETURNING `+lessonColumns, value.Id, value.SectionId, strings.TrimSpace(value.Title), value.Url, value.SourcePosition, value.Position, value.StudyId, value.SourceId, request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "lessons", value.Id, request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return stored, nil
}

func (services *Services) ArchiveLesson(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Lesson, error) {
	return services.changeLessonArchive(ctx, request, true)
}

func (services *Services) RestoreLesson(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest) (*wantstudyv1.Lesson, error) {
	return services.changeLessonArchive(ctx, request, false)
}

func (services *Services) changeLessonArchive(ctx context.Context, request *wantstudyv1.ChangeArchiveRequest, archived bool) (*wantstudyv1.Lesson, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	value, err := scanLesson(services.pool.QueryRow(ctx, `
		UPDATE lessons SET archived_at = CASE WHEN $3 THEN now() ELSE NULL END, version = version + 1, updated_at = now()
		WHERE id = $1 AND version = $2 RETURNING `+lessonColumns, request.GetId(), request.GetExpectedVersion(), archived))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "lessons", request.GetId(), request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return value, nil
}

func (services *Services) ChangeLessonStatus(ctx context.Context, request *wantstudyv1.ChangeLessonStatusRequest) (*wantstudyv1.Lesson, error) {
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	statusValue, err := lessonStatusToDatabase(request.GetStatus())
	if err != nil {
		return nil, err
	}
	if statusValue == "mastered" && !request.GetAcknowledgeOpenHomework() {
		var openTasks int
		if err = services.pool.QueryRow(ctx, `SELECT count(*) FROM homework_tasks WHERE lesson_id = $1 AND status = 'todo'`, request.GetId()).Scan(&openTasks); err != nil {
			return nil, mapDatabaseError(err)
		}
		if openTasks > 0 {
			detail := statusError(codes.FailedPrecondition, "OPEN_HOMEWORK", "open homework requires confirmation")
			return nil, detail
		}
	}
	value, err := scanLesson(services.pool.QueryRow(ctx, `
		UPDATE lessons
		SET status = $3,
		    started_at = CASE WHEN started_at IS NULL AND $3 <> 'planned' THEN now() ELSE started_at END,
		    mastered_at = CASE WHEN $3 = 'mastered' THEN now() ELSE NULL END,
		    version = version + 1,
		    updated_at = now()
		WHERE id = $1 AND version = $2
		RETURNING `+lessonColumns, request.GetId(), request.GetExpectedVersion(), statusValue))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "lessons", request.GetId(), request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return value, nil
}

func (services *Services) GetMaterialTree(ctx context.Context, request *wantstudyv1.GetMaterialTreeRequest) (*wantstudyv1.MaterialTree, error) {
	if err := requireID("study_id", request.GetStudyId()); err != nil {
		return nil, err
	}
	study, err := services.getStudy(ctx, request.GetStudyId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	sourceRows, err := services.pool.Query(ctx, `SELECT `+sourceColumns+` FROM learning_sources WHERE study_id = $1 AND ($2 OR archived_at IS NULL) ORDER BY position, id`, request.GetStudyId(), request.GetIncludeArchived())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer sourceRows.Close()
	result := &wantstudyv1.MaterialTree{Study: study}
	for sourceRows.Next() {
		source, scanErr := scanSource(sourceRows)
		if scanErr != nil {
			return nil, mapDatabaseError(scanErr)
		}
		node, nodeErr := services.loadSourceNode(ctx, source, request.GetIncludeArchived())
		if nodeErr != nil {
			return nil, nodeErr
		}
		result.Sources = append(result.Sources, node)
	}
	return result, nil
}

func (services *Services) loadSourceNode(ctx context.Context, source *wantstudyv1.LearningSource, includeArchived bool) (*wantstudyv1.SourceNode, error) {
	node := &wantstudyv1.SourceNode{Source: source}
	sectionRows, err := services.pool.Query(ctx, `SELECT `+sectionColumns+` FROM sections WHERE source_id = $1 AND ($2 OR archived_at IS NULL) ORDER BY position, id`, source.Id, includeArchived)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for sectionRows.Next() {
		section, scanErr := scanSection(sectionRows)
		if scanErr != nil {
			sectionRows.Close()
			return nil, mapDatabaseError(scanErr)
		}
		node.Sections = append(node.Sections, section)
	}
	sectionRows.Close()
	lessonRows, err := services.pool.Query(ctx, `SELECT `+lessonColumns+` FROM lessons WHERE source_id = $1 AND ($2 OR archived_at IS NULL) ORDER BY position, id`, source.Id, includeArchived)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer lessonRows.Close()
	for lessonRows.Next() {
		lesson, scanErr := scanLesson(lessonRows)
		if scanErr != nil {
			return nil, mapDatabaseError(scanErr)
		}
		node.Lessons = append(node.Lessons, lesson)
	}
	return node, nil
}

func (services *Services) ReorderMaterial(ctx context.Context, request *wantstudyv1.ReorderMaterialRequest) (*wantstudyv1.MaterialTree, error) {
	if err := requireID("study_id", request.GetStudyId()); err != nil {
		return nil, err
	}
	tx, err := services.pool.Begin(ctx)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	defer tx.Rollback(ctx)
	for _, group := range []struct {
		table string
		items []*wantstudyv1.ReorderItem
	}{{"learning_sources", request.GetSources()}, {"sections", request.GetSections()}, {"lessons", request.GetLessons()}} {
		for _, item := range group.items {
			if err = requireID("items.id", item.GetId()); err != nil {
				return nil, err
			}
			if item.GetPosition() < 0 || item.GetExpectedVersion() < 1 {
				return nil, invalid("items", "position must not be negative and expected_version must be positive")
			}
			command := `UPDATE ` + group.table + ` SET position = $1, version = version + 1, updated_at = now() WHERE id = $2 AND study_id = $3 AND version = $4`
			tag, updateErr := tx.Exec(ctx, command, item.GetPosition(), item.GetId(), request.GetStudyId(), item.GetExpectedVersion())
			if updateErr != nil {
				return nil, mapDatabaseError(updateErr)
			}
			if tag.RowsAffected() != 1 {
				return nil, conflict(group.table+"/"+item.GetId(), item.GetExpectedVersion())
			}
		}
	}
	if err = tx.Commit(ctx); err != nil {
		return nil, mapDatabaseError(err)
	}
	return services.GetMaterialTree(ctx, &wantstudyv1.GetMaterialTreeRequest{StudyId: request.GetStudyId()})
}

func (services *Services) GetDashboard(ctx context.Context, request *wantstudyv1.GetDashboardRequest) (*wantstudyv1.Dashboard, error) {
	if err := requireID("study_id", request.GetStudyId()); err != nil {
		return nil, err
	}
	response := &wantstudyv1.Dashboard{
		Material: &wantstudyv1.Progress{},
		Homework: &wantstudyv1.Progress{},
	}
	if err := services.pool.QueryRow(ctx, `
		SELECT count(*) FILTER (WHERE l.status = 'mastered'), count(*)
		FROM lessons l
		JOIN learning_sources s ON s.id = l.source_id AND s.archived_at IS NULL
		WHERE l.study_id = $1 AND l.archived_at IS NULL`, request.GetStudyId()).Scan(&response.Material.Completed, &response.Material.Total); err != nil {
		return nil, mapDatabaseError(err)
	}
	if err := services.pool.QueryRow(ctx, `
		SELECT count(*) FILTER (WHERE t.status = 'done'), count(*)
		FROM homework_tasks t
		JOIN lessons l ON l.id = t.lesson_id AND l.archived_at IS NULL
		JOIN learning_sources s ON s.id = l.source_id AND s.archived_at IS NULL
		WHERE t.study_id = $1`, request.GetStudyId()).Scan(&response.Homework.Completed, &response.Homework.Total); err != nil {
		return nil, mapDatabaseError(err)
	}
	rows, err := services.pool.Query(ctx, `
		SELECT l.status, count(*)
		FROM lessons l
		JOIN learning_sources s ON s.id = l.source_id AND s.archived_at IS NULL
		WHERE l.study_id = $1 AND l.archived_at IS NULL
		GROUP BY l.status ORDER BY l.status`, request.GetStudyId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for rows.Next() {
		var statusValue string
		item := &wantstudyv1.StatusCount{}
		if err = rows.Scan(&statusValue, &item.Count); err != nil {
			rows.Close()
			return nil, mapDatabaseError(err)
		}
		item.Status = lessonStatusFromDatabase(statusValue)
		response.LessonStatuses = append(response.LessonStatuses, item)
	}
	rows.Close()
	if err = services.pool.QueryRow(ctx, `SELECT content_revision FROM studies WHERE id = $1`, request.GetStudyId()).Scan(&response.StudyRevision); err != nil {
		return nil, mapDatabaseError(err)
	}
	return response, nil
}
