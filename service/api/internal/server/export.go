package server

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sort"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5"
	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

const exportLimit = 50 * 1024 * 1024

type renderedFile struct {
	path    string
	content []byte
	hash    string
}

type exportSnapshot struct {
	study     *wantstudyv1.Study
	sources   []*wantstudyv1.SourceNode
	workspace map[string]*wantstudyv1.LessonWorkspace
	concepts  []*wantstudyv1.Concept
	relations []*wantstudyv1.ConceptRelation
	material  progressCount
	homework  progressCount
}

type progressCount struct {
	completed int
	total     int
}

type manifestFile struct {
	Path   string `json:"path"`
	SHA256 string `json:"sha256"`
}

type manifest struct {
	FormatVersion int            `json:"formatVersion"`
	StudyID       string         `json:"studyId"`
	StudyRevision int64          `json:"studyRevision"`
	Files         []manifestFile `json:"files"`
}

func (services *Services) RenderStudyExport(request *wantstudyv1.RenderStudyExportRequest, stream grpc.ServerStreamingServer[wantstudyv1.ExportChunk]) error {
	if err := requireID("study_id", request.GetStudyId()); err != nil {
		return err
	}
	ctx := stream.Context()
	tx, err := services.pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly})
	if err != nil {
		return mapDatabaseError(err)
	}
	defer tx.Rollback(ctx)
	snapshot, err := loadExportSnapshot(ctx, tx, request.GetStudyId())
	if err != nil {
		return mapDatabaseError(err)
	}
	if request.ExpectedContentRevision != nil && request.GetExpectedContentRevision() != snapshot.study.ContentRevision {
		return conflict("study/"+request.GetStudyId()+"/content", request.GetExpectedContentRevision())
	}
	files, err := renderSnapshot(snapshot)
	if err != nil {
		return statusError(codes.Internal, "EXPORT_FAILED", "study export failed")
	}
	var totalBytes int64
	for _, file := range files {
		totalBytes += int64(len(file.content))
	}
	if totalBytes > exportLimit {
		return statusError(codes.ResourceExhausted, "EXPORT_TOO_LARGE", "export snapshot exceeds 50 MiB")
	}
	header := &wantstudyv1.ExportHeader{StudyId: snapshot.study.Id, StudyRevision: snapshot.study.ContentRevision, TotalBytes: totalBytes, FileCount: int32(len(files))}
	if err = stream.Send(&wantstudyv1.ExportChunk{Value: &wantstudyv1.ExportChunk_Header{Header: header}}); err != nil {
		return status.Error(codes.Unavailable, "export stream unavailable")
	}
	for _, file := range files {
		chunk := &wantstudyv1.ExportFile{Path: file.path, Content: file.content, Sha256: file.hash}
		if err = stream.Send(&wantstudyv1.ExportChunk{Value: &wantstudyv1.ExportChunk_File{File: chunk}}); err != nil {
			return status.Error(codes.Unavailable, "export stream unavailable")
		}
	}
	return nil
}

func loadExportSnapshot(ctx context.Context, tx pgx.Tx, studyID string) (*exportSnapshot, error) {
	study, err := scanStudy(tx.QueryRow(ctx, `SELECT `+studyColumns+` FROM studies WHERE id = $1`, studyID))
	if err != nil {
		return nil, err
	}
	result := &exportSnapshot{study: study, workspace: make(map[string]*wantstudyv1.LessonWorkspace)}
	rows, err := tx.Query(ctx, `SELECT `+sourceColumns+` FROM learning_sources WHERE study_id = $1 AND archived_at IS NULL ORDER BY position, id`, studyID)
	if err != nil {
		return nil, err
	}
	sources := make([]*wantstudyv1.LearningSource, 0)
	for rows.Next() {
		source, scanErr := scanSource(rows)
		if scanErr != nil {
			rows.Close()
			return nil, scanErr
		}
		sources = append(sources, source)
	}
	rows.Close()
	for _, source := range sources {
		node, loadErr := loadExportSource(ctx, tx, source)
		if loadErr != nil {
			return nil, loadErr
		}
		result.sources = append(result.sources, node)
	}
	for _, node := range result.sources {
		for _, lesson := range node.Lessons {
			workspace, loadErr := loadExportWorkspace(ctx, tx, lesson)
			if loadErr != nil {
				return nil, loadErr
			}
			result.workspace[lesson.Id] = workspace
		}
	}
	if err = tx.QueryRow(ctx, `
		SELECT count(*) FILTER (WHERE l.status = 'mastered'), count(*)
		FROM lessons l JOIN learning_sources s ON s.id = l.source_id AND s.archived_at IS NULL
		WHERE l.study_id = $1 AND l.archived_at IS NULL`, studyID).Scan(&result.material.completed, &result.material.total); err != nil {
		return nil, err
	}
	if err = tx.QueryRow(ctx, `
		SELECT count(*) FILTER (WHERE t.status = 'done'), count(*)
		FROM homework_tasks t
		JOIN lessons l ON l.id = t.lesson_id AND l.archived_at IS NULL
		JOIN learning_sources s ON s.id = l.source_id AND s.archived_at IS NULL
		WHERE t.study_id = $1`, studyID).Scan(&result.homework.completed, &result.homework.total); err != nil {
		return nil, err
	}
	conceptRows, err := tx.Query(ctx, `SELECT `+conceptColumns+` FROM concepts WHERE study_id = $1 AND archived_at IS NULL ORDER BY lower(title), id`, studyID)
	if err != nil {
		return nil, err
	}
	for conceptRows.Next() {
		concept, scanErr := scanConcept(conceptRows)
		if scanErr != nil {
			conceptRows.Close()
			return nil, scanErr
		}
		result.concepts = append(result.concepts, concept)
	}
	conceptRows.Close()
	for _, concept := range result.concepts {
		if err = hydrateExportConcept(ctx, tx, concept); err != nil {
			return nil, err
		}
	}
	relationRows, err := tx.Query(ctx, `SELECT `+relationColumns+` FROM concept_relations WHERE study_id = $1 ORDER BY relation_type, source_concept_id, target_concept_id, id`, studyID)
	if err != nil {
		return nil, err
	}
	for relationRows.Next() {
		relation, scanErr := scanRelation(relationRows)
		if scanErr != nil {
			relationRows.Close()
			return nil, scanErr
		}
		result.relations = append(result.relations, relation)
	}
	relationRows.Close()
	return result, nil
}

func loadExportSource(ctx context.Context, tx pgx.Tx, source *wantstudyv1.LearningSource) (*wantstudyv1.SourceNode, error) {
	node := &wantstudyv1.SourceNode{Source: source}
	rows, err := tx.Query(ctx, `SELECT `+sectionColumns+` FROM sections WHERE source_id = $1 AND archived_at IS NULL ORDER BY position, id`, source.Id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		section, scanErr := scanSection(rows)
		if scanErr != nil {
			rows.Close()
			return nil, scanErr
		}
		node.Sections = append(node.Sections, section)
	}
	rows.Close()
	rows, err = tx.Query(ctx, `SELECT `+lessonColumns+` FROM lessons WHERE source_id = $1 AND archived_at IS NULL ORDER BY position, id`, source.Id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		lesson, scanErr := scanLesson(rows)
		if scanErr != nil {
			rows.Close()
			return nil, scanErr
		}
		node.Lessons = append(node.Lessons, lesson)
	}
	rows.Close()
	return node, nil
}

func loadExportWorkspace(ctx context.Context, tx pgx.Tx, lesson *wantstudyv1.Lesson) (*wantstudyv1.LessonWorkspace, error) {
	result := &wantstudyv1.LessonWorkspace{Lesson: lesson}
	rows, err := tx.Query(ctx, `SELECT `+blockColumns+` FROM note_blocks WHERE lesson_id = $1 ORDER BY position, id`, lesson.Id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		value, scanErr := scanBlock(rows)
		if scanErr != nil {
			rows.Close()
			return nil, scanErr
		}
		result.Blocks = append(result.Blocks, value)
	}
	rows.Close()
	rows, err = tx.Query(ctx, `SELECT `+taskColumns+` FROM homework_tasks WHERE lesson_id = $1 ORDER BY position, id`, lesson.Id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		value, scanErr := scanTask(rows)
		if scanErr != nil {
			rows.Close()
			return nil, scanErr
		}
		result.Tasks = append(result.Tasks, value)
	}
	rows.Close()
	rows, err = tx.Query(ctx, `SELECT `+fileColumns+` FROM code_files WHERE lesson_id = $1 ORDER BY relative_path, id`, lesson.Id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		value, scanErr := scanFile(rows)
		if scanErr != nil {
			rows.Close()
			return nil, scanErr
		}
		result.Files = append(result.Files, value)
	}
	rows.Close()
	rows, err = tx.Query(ctx, `
		SELECT DISTINCT bc.concept_id FROM block_concepts bc
		JOIN note_blocks b ON b.id = bc.block_id WHERE b.lesson_id = $1 ORDER BY bc.concept_id`, lesson.Id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		var conceptID string
		if err = rows.Scan(&conceptID); err != nil {
			rows.Close()
			return nil, err
		}
		result.ConceptIds = append(result.ConceptIds, conceptID)
	}
	rows.Close()
	return result, nil
}

func hydrateExportConcept(ctx context.Context, tx pgx.Tx, concept *wantstudyv1.Concept) error {
	rows, err := tx.Query(ctx, `SELECT alias FROM concept_aliases WHERE concept_id = $1 ORDER BY lower(alias), alias`, concept.Id)
	if err != nil {
		return err
	}
	for rows.Next() {
		var alias string
		if err = rows.Scan(&alias); err != nil {
			rows.Close()
			return err
		}
		concept.Aliases = append(concept.Aliases, alias)
	}
	rows.Close()
	rows, err = tx.Query(ctx, `SELECT block_id FROM block_concepts WHERE concept_id = $1 ORDER BY block_id`, concept.Id)
	if err != nil {
		return err
	}
	for rows.Next() {
		var blockID string
		if err = rows.Scan(&blockID); err != nil {
			rows.Close()
			return err
		}
		concept.BlockIds = append(concept.BlockIds, blockID)
	}
	rows.Close()
	return nil
}

func renderSnapshot(snapshot *exportSnapshot) ([]renderedFile, error) {
	files := make([]renderedFile, 0)
	files = append(files, newRenderedFile("README.md", renderRoot(snapshot)))
	conceptByID := make(map[string]*wantstudyv1.Concept, len(snapshot.concepts))
	for _, concept := range snapshot.concepts {
		conceptByID[concept.Id] = concept
	}
	lessonByBlock := make(map[string]*wantstudyv1.Lesson)
	lessonPathByID := make(map[string]string)
	for _, node := range snapshot.sources {
		sourcePath := "source/" + node.Source.ExportSlug
		files = append(files, newRenderedFile(sourcePath+"/README.md", renderSource(node)))
		for _, lesson := range node.Lessons {
			lessonPath := sourcePath + "/lesson/" + lesson.ExportSlug
			lessonPathByID[lesson.Id] = lessonPath
			workspace := snapshot.workspace[lesson.Id]
			for _, block := range workspace.Blocks {
				lessonByBlock[block.Id] = lesson
			}
			files = append(files, newRenderedFile(lessonPath+"/README.md", renderLesson(workspace, conceptByID)))
			for _, codeFile := range workspace.Files {
				files = append(files, newRenderedFile(lessonPath+"/file/"+codeFile.RelativePath, codeFile.Content))
			}
		}
	}
	files = append(files, newRenderedFile("concept/README.md", renderConceptIndex(snapshot.concepts)))
	for _, concept := range snapshot.concepts {
		files = append(files, newRenderedFile("concept/"+concept.ExportSlug+".md", renderConcept(concept, snapshot.relations, conceptByID, lessonByBlock, lessonPathByID)))
	}
	sort.Slice(files, func(left, right int) bool { return files[left].path < files[right].path })
	manifestValue := manifest{FormatVersion: 1, StudyID: snapshot.study.Id, StudyRevision: snapshot.study.ContentRevision}
	for _, file := range files {
		manifestValue.Files = append(manifestValue.Files, manifestFile{Path: file.path, SHA256: file.hash})
	}
	manifestBytes, err := json.MarshalIndent(manifestValue, "", "  ")
	if err != nil {
		return nil, err
	}
	manifestBytes = append(manifestBytes, '\n')
	files = append(files, newRenderedFile(".want-study/manifest.json", string(manifestBytes)))
	sort.Slice(files, func(left, right int) bool { return files[left].path < files[right].path })
	return files, nil
}

func newRenderedFile(filePath, content string) renderedFile {
	content = strings.ReplaceAll(content, "\r\n", "\n")
	content = strings.ReplaceAll(content, "\r", "\n")
	if !strings.HasSuffix(content, "\n") {
		content += "\n"
	}
	bytes := []byte(content)
	digest := sha256.Sum256(bytes)
	return renderedFile{path: filePath, content: bytes, hash: hex.EncodeToString(digest[:])}
}

func renderRoot(snapshot *exportSnapshot) string {
	var output strings.Builder
	fmt.Fprintf(&output, "# %s\n\n", snapshot.study.Title)
	if snapshot.study.Goal != "" {
		fmt.Fprintf(&output, "%s\n\n", snapshot.study.Goal)
	}
	output.WriteString("## Прогресс\n\n")
	fmt.Fprintf(&output, "- Материал: %d/%d (%d%%)\n", snapshot.material.completed, snapshot.material.total, percent(snapshot.material))
	fmt.Fprintf(&output, "- Домашняя работа: %d/%d (%d%%)\n\n", snapshot.homework.completed, snapshot.homework.total, percent(snapshot.homework))
	output.WriteString("## Источники\n\n")
	for _, node := range snapshot.sources {
		fmt.Fprintf(&output, "- [%s](source/%s/README.md)\n", node.Source.Title, node.Source.ExportSlug)
	}
	return output.String()
}

func percent(value progressCount) int {
	if value.total == 0 {
		return 0
	}
	return value.completed * 100 / value.total
}

func renderSource(node *wantstudyv1.SourceNode) string {
	var output strings.Builder
	fmt.Fprintf(&output, "# %s\n\n", node.Source.Title)
	if node.Source.Author != "" {
		fmt.Fprintf(&output, "Автор: %s\n\n", node.Source.Author)
	}
	if node.Source.Url != "" {
		fmt.Fprintf(&output, "Источник: <%s>\n\n", node.Source.Url)
	}
	lessonsBySection := make(map[string][]*wantstudyv1.Lesson)
	for _, lesson := range node.Lessons {
		lessonsBySection[lesson.GetSectionId()] = append(lessonsBySection[lesson.GetSectionId()], lesson)
	}
	for _, section := range node.Sections {
		fmt.Fprintf(&output, "## %s\n\n", section.Title)
		renderLessonList(&output, lessonsBySection[section.Id])
	}
	if lessons := lessonsBySection[""]; len(lessons) > 0 {
		output.WriteString("## Без раздела\n\n")
		renderLessonList(&output, lessons)
	}
	return output.String()
}

func renderLessonList(output *strings.Builder, lessons []*wantstudyv1.Lesson) {
	for _, lesson := range lessons {
		position := lesson.SourcePosition
		if position != "" {
			position += " — "
		}
		fmt.Fprintf(output, "- [%s%s](lesson/%s/README.md) — %s\n", position, lesson.Title, lesson.ExportSlug, lessonStatusLabel(lesson.Status))
	}
	output.WriteByte('\n')
}

func renderLesson(workspace *wantstudyv1.LessonWorkspace, conceptByID map[string]*wantstudyv1.Concept) string {
	lesson := workspace.Lesson
	var output strings.Builder
	output.WriteString("---\n")
	fmt.Fprintf(&output, "id: %s\n", strconv.Quote(lesson.Id))
	fmt.Fprintf(&output, "status: %s\n", lessonStatusDatabaseValue(lesson.Status))
	fmt.Fprintf(&output, "sourcePosition: %s\n", strconv.Quote(lesson.SourcePosition))
	if lesson.Url != "" {
		fmt.Fprintf(&output, "url: %s\n", strconv.Quote(lesson.Url))
	}
	output.WriteString("---\n\n")
	fmt.Fprintf(&output, "# %s\n\n", lesson.Title)
	for _, block := range workspace.Blocks {
		if heading := blockHeading(block.Type); heading != "" {
			fmt.Fprintf(&output, "## %s\n\n", heading)
		}
		output.WriteString(block.Markdown)
		output.WriteString("\n\n")
		if block.SourceUrl != "" || block.SourcePosition != "" {
			fmt.Fprintf(&output, "Источник: %s %s\n\n", block.SourcePosition, block.SourceUrl)
		}
	}
	if len(workspace.Tasks) > 0 {
		output.WriteString("## Домашняя работа\n\n")
		for index, task := range workspace.Tasks {
			mark := " "
			if task.Status == wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_DONE {
				mark = "x"
			}
			fmt.Fprintf(&output, "### %d. [%s] Задание\n\n%s\n\n", index+1, mark, task.PromptMarkdown)
			if task.SolutionMarkdown != "" {
				output.WriteString("**Решение**\n\n")
				output.WriteString(task.SolutionMarkdown)
				output.WriteString("\n\n")
			}
		}
	}
	if len(workspace.Files) > 0 {
		output.WriteString("## Файлы\n\n")
		for _, file := range workspace.Files {
			fmt.Fprintf(&output, "- [%s](file/%s)\n", file.RelativePath, file.RelativePath)
		}
		output.WriteByte('\n')
	}
	if len(workspace.ConceptIds) > 0 {
		output.WriteString("## Понятия\n\n")
		for _, conceptID := range workspace.ConceptIds {
			if concept := conceptByID[conceptID]; concept != nil {
				fmt.Fprintf(&output, "- [%s](../../../../concept/%s.md)\n", concept.Title, concept.ExportSlug)
			}
		}
	}
	return output.String()
}

func renderConceptIndex(concepts []*wantstudyv1.Concept) string {
	var output strings.Builder
	output.WriteString("# Понятия\n\n")
	for _, concept := range concepts {
		fmt.Fprintf(&output, "- [%s](%s.md)\n", concept.Title, concept.ExportSlug)
	}
	return output.String()
}

func renderConcept(concept *wantstudyv1.Concept, relations []*wantstudyv1.ConceptRelation, conceptByID map[string]*wantstudyv1.Concept, lessonByBlock map[string]*wantstudyv1.Lesson, lessonPathByID map[string]string) string {
	var output strings.Builder
	fmt.Fprintf(&output, "# %s\n\n", concept.Title)
	if len(concept.Aliases) > 0 {
		fmt.Fprintf(&output, "Псевдонимы: %s\n\n", strings.Join(concept.Aliases, ", "))
	}
	if concept.DescriptionMarkdown != "" {
		output.WriteString(concept.DescriptionMarkdown)
		output.WriteString("\n\n")
	}
	output.WriteString("## Связи\n\n")
	for _, relation := range relations {
		var otherID string
		var direction string
		switch concept.Id {
		case relation.SourceConceptId:
			otherID = relation.TargetConceptId
			direction = relationTypeLabel(relation.Type)
		case relation.TargetConceptId:
			otherID = relation.SourceConceptId
			direction = relationTypeReverseLabel(relation.Type)
		default:
			continue
		}
		if other := conceptByID[otherID]; other != nil {
			fmt.Fprintf(&output, "- %s [%s](%s.md)\n", direction, other.Title, other.ExportSlug)
		}
	}
	output.WriteString("\n## Упоминания\n\n")
	seen := make(map[string]bool)
	for _, blockID := range concept.BlockIds {
		lesson := lessonByBlock[blockID]
		if lesson == nil || seen[lesson.Id] {
			continue
		}
		seen[lesson.Id] = true
		fmt.Fprintf(&output, "- [%s](../%s/README.md)\n", lesson.Title, lessonPathByID[lesson.Id])
	}
	return output.String()
}

func lessonStatusDatabaseValue(value wantstudyv1.LessonStatus) string {
	statusValue, err := lessonStatusToDatabase(value)
	if err != nil {
		return "planned"
	}
	return statusValue
}

func lessonStatusLabel(value wantstudyv1.LessonStatus) string {
	switch value {
	case wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING:
		return "изучается"
	case wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK:
		return "домашняя работа"
	case wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED:
		return "освоен"
	default:
		return "запланирован"
	}
}

func blockHeading(value wantstudyv1.NoteBlockType) string {
	switch value {
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_DEFINITION:
		return "Определение"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_CLAIM:
		return "Тезис"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUOTE:
		return "Цитата"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_EXAMPLE:
		return "Пример"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUESTION:
		return "Вопрос"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_SUMMARY:
		return "Итог"
	default:
		return ""
	}
}

func relationTypeLabel(value wantstudyv1.ConceptRelationType) string {
	switch value {
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_RELATED_TO:
		return "связано с"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PART_OF:
		return "часть"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR:
		return "предпосылка для"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_CONTRASTS_WITH:
		return "противопоставляется"
	default:
		return "применяется к"
	}
}

func relationTypeReverseLabel(value wantstudyv1.ConceptRelationType) string {
	switch value {
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PART_OF:
		return "содержит"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR:
		return "зависит от"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_APPLIES_TO:
		return "область применения для"
	default:
		return relationTypeLabel(value)
	}
}
