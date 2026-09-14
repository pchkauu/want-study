package server

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/url"
	"sort"
	"strings"
	"time"

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
			files = append(files, newRenderedFile(lessonPath+"/README.md", renderLesson(workspace, node.Source, conceptByID)))
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
	fmt.Fprintf(&output, "# 📚 %s\n\n", markdownInline(snapshot.study.Title))
	if strings.TrimSpace(snapshot.study.Goal) != "" {
		output.WriteString("> [!NOTE]\n> **Learning goal**\n>\n")
		writeBlockquote(&output, snapshot.study.Goal)
		output.WriteByte('\n')
	}
	output.WriteString("## 📈 Progress\n\n")
	output.WriteString("| Area | Completed | Result |\n")
	output.WriteString("| :-- | --: | --: |\n")
	fmt.Fprintf(&output, "| 📖 Lessons | %d of %d | **%d%%** |\n", snapshot.material.completed, snapshot.material.total, percent(snapshot.material))
	fmt.Fprintf(&output, "| ✅ Homework | %d of %d | **%d%%** |\n\n", snapshot.homework.completed, snapshot.homework.total, percent(snapshot.homework))

	status := lessonStatusCounts(snapshot.sources)
	output.WriteString("## 🧭 Lesson status\n\n")
	output.WriteString("| 🗓️ Planned | 📖 Studying | 🧩 Homework | ✅ Mastered |\n")
	output.WriteString("| --: | --: | --: | --: |\n")
	fmt.Fprintf(&output, "| %d | %d | %d | %d |\n\n", status.planned, status.studying, status.homework, status.mastered)

	output.WriteString("## 🎓 Sources\n\n")
	if len(snapshot.sources) == 0 {
		output.WriteString("> No sources yet.\n\n")
	}
	if len(snapshot.sources) > 0 {
		output.WriteString("| Source | Type | Lessons | Mastered |\n")
		output.WriteString("| :-- | :-- | --: | --: |\n")
	}
	for _, node := range snapshot.sources {
		mastered := 0
		for _, lesson := range node.Lessons {
			if lesson.Status == wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED {
				mastered++
			}
		}
		fmt.Fprintf(&output, "| [%s](source/%s/README.md) | %s | %d | %d |\n", markdownInline(node.Source.Title), node.Source.ExportSlug, sourceTypeLabel(node.Source.Type), len(node.Lessons), mastered)
	}
	output.WriteString("\n[🧠 Open concept map](concept/README.md)\n")
	return output.String()
}

type lessonStatusSummary struct {
	planned  int
	studying int
	homework int
	mastered int
}

func lessonStatusCounts(sources []*wantstudyv1.SourceNode) lessonStatusSummary {
	var result lessonStatusSummary
	for _, source := range sources {
		for _, lesson := range source.Lessons {
			switch lesson.Status {
			case wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING:
				result.studying++
			case wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK:
				result.homework++
			case wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED:
				result.mastered++
			default:
				result.planned++
			}
		}
	}
	return result
}

func percent(value progressCount) int {
	if value.total == 0 {
		return 0
	}
	return value.completed * 100 / value.total
}

func renderSource(node *wantstudyv1.SourceNode) string {
	var output strings.Builder
	output.WriteString("[← Back to study](../../README.md)\n\n")
	fmt.Fprintf(&output, "# 🎓 %s\n\n", markdownInline(node.Source.Title))
	metadata := []string{sourceTypeLabel(node.Source.Type)}
	if strings.TrimSpace(node.Source.Author) != "" {
		metadata = append(metadata, "**Author:** "+markdownInline(node.Source.Author))
	}
	if node.Source.Url != "" {
		if link, ok := externalLink("Open source ↗", node.Source.Url); ok {
			metadata = append(metadata, link)
		} else {
			metadata = append(metadata, "**Address:** "+markdownCode(node.Source.Url))
		}
	}
	fmt.Fprintf(&output, "> %s\n\n", strings.Join(metadata, " · "))

	mastered := 0
	for _, lesson := range node.Lessons {
		if lesson.Status == wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED {
			mastered++
		}
	}
	output.WriteString("## 📊 Progress\n\n")
	fmt.Fprintf(&output, "**Lessons mastered:** %d / %d · **Progress:** %d%%\n\n", mastered, len(node.Lessons), percent(progressCount{completed: mastered, total: len(node.Lessons)}))
	output.WriteString("## 📑 Curriculum\n\n")
	lessonsBySection := make(map[string][]*wantstudyv1.Lesson)
	for _, lesson := range node.Lessons {
		lessonsBySection[lesson.GetSectionId()] = append(lessonsBySection[lesson.GetSectionId()], lesson)
	}
	for _, section := range node.Sections {
		if len(lessonsBySection[section.Id]) == 0 {
			continue
		}
		fmt.Fprintf(&output, "### %s\n\n", markdownInline(section.Title))
		renderLessonList(&output, lessonsBySection[section.Id])
	}
	if lessons := lessonsBySection[""]; len(lessons) > 0 {
		output.WriteString("### Uncategorized\n\n")
		renderLessonList(&output, lessons)
	}
	if len(node.Lessons) == 0 {
		output.WriteString("> No lessons yet.\n")
	}
	return output.String()
}

func renderLessonList(output *strings.Builder, lessons []*wantstudyv1.Lesson) {
	output.WriteString("| Position | Lesson | Status |\n")
	output.WriteString("| :-- | :-- | :-- |\n")
	for _, lesson := range lessons {
		position := lesson.SourcePosition
		if position == "" {
			position = "—"
		}
		fmt.Fprintf(output, "| %s | [%s](lesson/%s/README.md) | %s |\n", markdownInline(position), markdownInline(lesson.Title), lesson.ExportSlug, lessonStatusDisplay(lesson.Status))
	}
	output.WriteByte('\n')
}

func renderLesson(workspace *wantstudyv1.LessonWorkspace, source *wantstudyv1.LearningSource, conceptByID map[string]*wantstudyv1.Concept) string {
	lesson := workspace.Lesson
	var output strings.Builder
	fmt.Fprintf(&output, "[← %s](../../README.md) · [Back to study](../../../../README.md)\n\n", markdownInline(source.Title))
	fmt.Fprintf(&output, "# 📝 %s\n\n", markdownInline(lesson.Title))
	metadata := []string{lessonStatusDisplay(lesson.Status)}
	if lesson.SourcePosition != "" {
		metadata = append(metadata, "**Position:** "+markdownInline(lesson.SourcePosition))
	}
	if lesson.StartedAtEpochMillis != nil {
		metadata = append(metadata, "**Started:** "+formatDate(lesson.GetStartedAtEpochMillis()))
	}
	if lesson.MasteredAtEpochMillis != nil {
		metadata = append(metadata, "**Mastered:** "+formatDate(lesson.GetMasteredAtEpochMillis()))
	}
	if lesson.Url != "" {
		if link, ok := externalLink("Open lesson ↗", lesson.Url); ok {
			metadata = append(metadata, link)
		} else {
			metadata = append(metadata, "**Address:** "+markdownCode(lesson.Url))
		}
	}
	fmt.Fprintf(&output, "> %s\n\n", strings.Join(metadata, " · "))
	output.WriteString("## ✍️ Notes\n\n")
	visibleBlocks := 0
	for _, block := range workspace.Blocks {
		if strings.TrimSpace(block.Markdown) == "" {
			continue
		}
		visibleBlocks++
		if heading := blockHeading(block.Type); heading != "" {
			fmt.Fprintf(&output, "### %s\n\n", heading)
		}
		output.WriteString(block.Markdown)
		if !strings.HasSuffix(block.Markdown, "\n") {
			output.WriteByte('\n')
		}
		output.WriteByte('\n')
		if block.SourceUrl != "" || block.SourcePosition != "" {
			parts := make([]string, 0, 2)
			if block.SourcePosition != "" {
				parts = append(parts, "**Position:** "+markdownInline(block.SourcePosition))
			}
			if block.SourceUrl != "" {
				if link, ok := externalLink("Open source ↗", block.SourceUrl); ok {
					parts = append(parts, link)
				} else {
					parts = append(parts, "**Address:** "+markdownCode(block.SourceUrl))
				}
			}
			fmt.Fprintf(&output, "> **Block source** · %s\n\n", strings.Join(parts, " · "))
		}
	}
	if visibleBlocks == 0 {
		output.WriteString("> No notes yet.\n\n")
	}
	if len(workspace.Tasks) > 0 {
		done := 0
		for _, task := range workspace.Tasks {
			if task.Status == wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_DONE {
				done++
			}
		}
		output.WriteString("## ✅ Homework\n\n")
		fmt.Fprintf(&output, "**Tasks completed:** %d / %d\n\n", done, len(workspace.Tasks))
		for index, task := range workspace.Tasks {
			mark := "⬜"
			if task.Status == wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_DONE {
				mark = "✅"
			}
			fmt.Fprintf(&output, "### %s Task %d\n\n", mark, index+1)
			if task.DueAtEpochMillis != nil {
				fmt.Fprintf(&output, "**Due:** %s\n\n", formatDate(task.GetDueAtEpochMillis()))
			}
			output.WriteString(task.PromptMarkdown)
			if !strings.HasSuffix(task.PromptMarkdown, "\n") {
				output.WriteByte('\n')
			}
			output.WriteByte('\n')
			if strings.TrimSpace(task.SolutionMarkdown) != "" {
				output.WriteString("<details>\n<summary><strong>Show solution</strong></summary>\n\n")
				output.WriteString(task.SolutionMarkdown)
				if !strings.HasSuffix(task.SolutionMarkdown, "\n") {
					output.WriteByte('\n')
				}
				output.WriteString("\n</details>\n\n")
			}
		}
	}
	if len(workspace.Files) > 0 {
		output.WriteString("## 💻 Files\n\n")
		output.WriteString("| File | Language | Linked to |\n")
		output.WriteString("| :-- | :-- | :-- |\n")
		taskIndex := make(map[string]int, len(workspace.Tasks))
		for index, task := range workspace.Tasks {
			taskIndex[task.Id] = index + 1
		}
		for _, file := range workspace.Files {
			owner := "Lesson"
			if index := taskIndex[file.GetHomeworkTaskId()]; index > 0 {
				owner = fmt.Sprintf("Task %d", index)
			}
			language := markdownInline(file.Language)
			if language == "" {
				language = "—"
			}
			fmt.Fprintf(&output, "| [%s](file/%s) | %s | %s |\n", markdownInline(file.RelativePath), encodeRelativePath(file.RelativePath), language, owner)
		}
		output.WriteByte('\n')
	}
	if len(workspace.ConceptIds) > 0 {
		concepts := make([]*wantstudyv1.Concept, 0, len(workspace.ConceptIds))
		for _, conceptID := range workspace.ConceptIds {
			if concept := conceptByID[conceptID]; concept != nil {
				concepts = append(concepts, concept)
			}
		}
		sort.Slice(concepts, func(left, right int) bool {
			return strings.ToLower(concepts[left].Title) < strings.ToLower(concepts[right].Title)
		})
		if len(concepts) > 0 {
			output.WriteString("## 🧠 Concepts\n\n")
			for _, concept := range concepts {
				fmt.Fprintf(&output, "- [%s](../../../../concept/%s.md)\n", markdownInline(concept.Title), concept.ExportSlug)
			}
		}
	}
	return output.String()
}

func renderConceptIndex(concepts []*wantstudyv1.Concept) string {
	var output strings.Builder
	output.WriteString("[← Back to study](../README.md)\n\n")
	output.WriteString("# 🧠 Concepts\n\n")
	fmt.Fprintf(&output, "**Total:** %d\n\n", len(concepts))
	if len(concepts) == 0 {
		output.WriteString("> No concepts yet.\n")
		return output.String()
	}
	items := append([]*wantstudyv1.Concept(nil), concepts...)
	sort.Slice(items, func(left, right int) bool {
		return strings.ToLower(items[left].Title) < strings.ToLower(items[right].Title)
	})
	output.WriteString("| Concept | Aliases |\n")
	output.WriteString("| :-- | :-- |\n")
	for _, concept := range items {
		aliases := "—"
		if len(concept.Aliases) > 0 {
			values := make([]string, 0, len(concept.Aliases))
			for _, alias := range concept.Aliases {
				values = append(values, markdownInline(alias))
			}
			aliases = strings.Join(values, ", ")
		}
		fmt.Fprintf(&output, "| [%s](%s.md) | %s |\n", markdownInline(concept.Title), concept.ExportSlug, aliases)
	}
	return output.String()
}

func renderConcept(concept *wantstudyv1.Concept, relations []*wantstudyv1.ConceptRelation, conceptByID map[string]*wantstudyv1.Concept, lessonByBlock map[string]*wantstudyv1.Lesson, lessonPathByID map[string]string) string {
	var output strings.Builder
	output.WriteString("[← All concepts](README.md) · [Back to study](../README.md)\n\n")
	fmt.Fprintf(&output, "# 🧠 %s\n\n", markdownInline(concept.Title))
	if len(concept.Aliases) > 0 {
		values := make([]string, 0, len(concept.Aliases))
		for _, alias := range concept.Aliases {
			values = append(values, markdownInline(alias))
		}
		fmt.Fprintf(&output, "> **Also known as:** %s\n\n", strings.Join(values, ", "))
	}
	if strings.TrimSpace(concept.DescriptionMarkdown) != "" {
		output.WriteString(concept.DescriptionMarkdown)
		if !strings.HasSuffix(concept.DescriptionMarkdown, "\n") {
			output.WriteByte('\n')
		}
		output.WriteByte('\n')
	} else {
		output.WriteString("> No description yet.\n\n")
	}
	groups := make(map[string][]*wantstudyv1.Concept)
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
			groups[direction] = append(groups[direction], other)
		}
	}
	output.WriteString("## 🔗 Relations\n\n")
	if len(groups) == 0 {
		output.WriteString("> No relations yet.\n\n")
	} else {
		labels := make([]string, 0, len(groups))
		for label := range groups {
			labels = append(labels, label)
		}
		sort.Strings(labels)
		for _, label := range labels {
			items := groups[label]
			sort.Slice(items, func(left, right int) bool {
				return strings.ToLower(items[left].Title) < strings.ToLower(items[right].Title)
			})
			fmt.Fprintf(&output, "### %s\n\n", label)
			for _, other := range items {
				fmt.Fprintf(&output, "- [%s](%s.md)\n", markdownInline(other.Title), other.ExportSlug)
			}
			output.WriteByte('\n')
		}
	}
	output.WriteString("## 📍 Mentioned in\n\n")
	seen := make(map[string]bool)
	lessons := make([]*wantstudyv1.Lesson, 0)
	for _, blockID := range concept.BlockIds {
		lesson := lessonByBlock[blockID]
		if lesson == nil || seen[lesson.Id] {
			continue
		}
		seen[lesson.Id] = true
		lessons = append(lessons, lesson)
	}
	sort.Slice(lessons, func(left, right int) bool {
		return strings.ToLower(lessons[left].Title) < strings.ToLower(lessons[right].Title)
	})
	if len(lessons) == 0 {
		output.WriteString("> Not mentioned in notes yet.\n")
	} else {
		for _, lesson := range lessons {
			fmt.Fprintf(&output, "- [%s](../%s/README.md)\n", markdownInline(lesson.Title), lessonPathByID[lesson.Id])
		}
	}
	return output.String()
}

func lessonStatusLabel(value wantstudyv1.LessonStatus) string {
	switch value {
	case wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING:
		return "Studying"
	case wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK:
		return "Homework"
	case wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED:
		return "Mastered"
	default:
		return "Planned"
	}
}

func lessonStatusDisplay(value wantstudyv1.LessonStatus) string {
	icon := "🗓️"
	switch value {
	case wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING:
		icon = "📖"
	case wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK:
		icon = "🧩"
	case wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED:
		icon = "✅"
	}
	return icon + " " + lessonStatusLabel(value)
}

func sourceTypeLabel(value wantstudyv1.LearningSourceType) string {
	switch value {
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_COURSE:
		return "Course"
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_BOOK:
		return "Book"
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_ARTICLE:
		return "Article"
	case wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_VIDEO:
		return "Video"
	default:
		return "Other"
	}
}

func blockHeading(value wantstudyv1.NoteBlockType) string {
	switch value {
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_DEFINITION:
		return "📘 Definition"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_CLAIM:
		return "💡 Claim"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUOTE:
		return "💬 Quote"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_EXAMPLE:
		return "🧪 Example"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUESTION:
		return "❓ Question"
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_SUMMARY:
		return "🧭 Summary"
	default:
		return ""
	}
}

func relationTypeLabel(value wantstudyv1.ConceptRelationType) string {
	switch value {
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_RELATED_TO:
		return "Related to"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PART_OF:
		return "Part of"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR:
		return "Prerequisite for"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_CONTRASTS_WITH:
		return "Contrasts with"
	default:
		return "Applies to"
	}
}

func relationTypeReverseLabel(value wantstudyv1.ConceptRelationType) string {
	switch value {
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PART_OF:
		return "Contains"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR:
		return "Depends on"
	case wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_APPLIES_TO:
		return "Applied here"
	default:
		return relationTypeLabel(value)
	}
}

func markdownInline(value string) string {
	value = strings.Join(strings.Fields(value), " ")
	replacer := strings.NewReplacer(
		`\`, `\\`,
		"`", `\`+"`",
		"*", `\*`,
		"_", `\_`,
		"[", `\[`,
		"]", `\]`,
		"#", `\#`,
		"|", `\|`,
		"<", "&lt;",
		">", "&gt;",
	)
	return replacer.Replace(value)
}

func markdownCode(value string) string {
	value = strings.Join(strings.Fields(value), " ")
	delimiter := "`"
	for strings.Contains(value, delimiter) {
		delimiter += "`"
	}
	padding := ""
	if strings.HasPrefix(value, "`") || strings.HasSuffix(value, "`") {
		padding = " "
	}
	return delimiter + padding + value + padding + delimiter
}

func externalLink(label, value string) (string, bool) {
	value = strings.TrimSpace(value)
	parsed, err := url.ParseRequestURI(value)
	if err != nil || parsed.Host == "" || !strings.EqualFold(parsed.Scheme, "http") && !strings.EqualFold(parsed.Scheme, "https") {
		return "", false
	}
	destination := strings.ReplaceAll(parsed.String(), ">", "%3E")
	return fmt.Sprintf("[%s](<%s>)", markdownInline(label), destination), true
}

func encodeRelativePath(value string) string {
	parts := strings.Split(value, "/")
	for index, part := range parts {
		parts[index] = url.PathEscape(part)
	}
	return strings.Join(parts, "/")
}

func formatDate(epochMillis int64) string {
	return time.UnixMilli(epochMillis).UTC().Format("02 Jan 2006")
}

func writeBlockquote(output *strings.Builder, value string) {
	for _, line := range strings.Split(value, "\n") {
		output.WriteByte('>')
		if line != "" {
			output.WriteByte(' ')
			output.WriteString(line)
		}
		output.WriteByte('\n')
	}
}
