package server

import (
	"context"
	"errors"
	"path"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
	"google.golang.org/grpc/codes"
)

const contentLimit = 1048576

func noteTypeToDatabase(value wantstudyv1.NoteBlockType) (string, error) {
	switch value {
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_TEXT:
		return "text", nil
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_DEFINITION:
		return "definition", nil
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_CLAIM:
		return "claim", nil
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUOTE:
		return "quote", nil
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_EXAMPLE:
		return "example", nil
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUESTION:
		return "question", nil
	case wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_SUMMARY:
		return "summary", nil
	default:
		return "", invalid("block.type", "must be specified")
	}
}

func noteTypeFromDatabase(value string) wantstudyv1.NoteBlockType {
	switch value {
	case "text":
		return wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_TEXT
	case "definition":
		return wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_DEFINITION
	case "claim":
		return wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_CLAIM
	case "quote":
		return wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUOTE
	case "example":
		return wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_EXAMPLE
	case "question":
		return wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUESTION
	default:
		return wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_SUMMARY
	}
}

const blockColumns = `id, study_id, lesson_id, block_type, markdown, source_url, source_position, position, version`

func scanBlock(row scanner) (*wantstudyv1.NoteBlock, error) {
	value := &wantstudyv1.NoteBlock{}
	var blockType string
	if err := row.Scan(&value.Id, &value.StudyId, &value.LessonId, &blockType, &value.Markdown, &value.SourceUrl, &value.SourcePosition, &value.Position, &value.Version); err != nil {
		return nil, err
	}
	value.Type = noteTypeFromDatabase(blockType)
	return value, nil
}

func validateBlock(value *wantstudyv1.NoteBlock) (string, error) {
	if value == nil {
		return "", invalid("block", "is required")
	}
	if err := requireID("block.id", value.GetId()); err != nil {
		return "", err
	}
	if err := requireID("block.study_id", value.GetStudyId()); err != nil {
		return "", err
	}
	if err := requireID("block.lesson_id", value.GetLessonId()); err != nil {
		return "", err
	}
	if len(value.GetMarkdown()) > contentLimit {
		return "", invalid("block.markdown", "must not exceed 1 MiB")
	}
	if err := requirePosition("block.position", value.GetPosition()); err != nil {
		return "", err
	}
	return noteTypeToDatabase(value.GetType())
}

func (services *Services) CreateNoteBlock(ctx context.Context, request *wantstudyv1.CreateNoteBlockRequest) (*wantstudyv1.NoteBlock, error) {
	value := request.GetBlock()
	blockType, err := validateBlock(value)
	if err != nil {
		return nil, err
	}
	tag, err := services.pool.Exec(ctx, `
		INSERT INTO note_blocks (id, study_id, lesson_id, block_type, markdown, source_url, source_position, position)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8) ON CONFLICT (id) DO NOTHING`,
		value.Id, value.StudyId, value.LessonId, blockType, value.Markdown, value.SourceUrl, value.SourcePosition, value.Position)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getBlock(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && !equalBlockCreate(stored, value) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "block id already contains different data")
	}
	return stored, nil
}

func equalBlockCreate(stored, requested *wantstudyv1.NoteBlock) bool {
	return stored.StudyId == requested.StudyId && stored.LessonId == requested.LessonId && stored.Type == requested.Type && stored.Markdown == requested.Markdown && stored.SourceUrl == requested.SourceUrl && stored.SourcePosition == requested.SourcePosition && stored.Position == requested.Position
}

func (services *Services) getBlock(ctx context.Context, id string) (*wantstudyv1.NoteBlock, error) {
	return scanBlock(services.pool.QueryRow(ctx, `SELECT `+blockColumns+` FROM note_blocks WHERE id = $1`, id))
}

func (services *Services) UpdateNoteBlock(ctx context.Context, request *wantstudyv1.UpdateNoteBlockRequest) (*wantstudyv1.NoteBlock, error) {
	value := request.GetBlock()
	blockType, err := validateBlock(value)
	if err != nil {
		return nil, err
	}
	stored, err := scanBlock(services.pool.QueryRow(ctx, `
		UPDATE note_blocks
		SET block_type = $2, markdown = $3, source_url = $4, source_position = $5, position = $6, version = version + 1, updated_at = now()
		WHERE id = $1 AND study_id = $7 AND lesson_id = $8 AND version = $9
		RETURNING `+blockColumns, value.Id, blockType, value.Markdown, value.SourceUrl, value.SourcePosition, value.Position, value.StudyId, value.LessonId, request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "note_blocks", value.Id, request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return stored, nil
}

func homeworkStatusToDatabase(value wantstudyv1.HomeworkStatus) (string, error) {
	switch value {
	case wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_TODO:
		return "todo", nil
	case wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_DONE:
		return "done", nil
	default:
		return "", invalid("task.status", "must be specified")
	}
}

func homeworkStatusFromDatabase(value string) wantstudyv1.HomeworkStatus {
	if value == "done" {
		return wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_DONE
	}
	return wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_TODO
}

const taskColumns = `id, study_id, lesson_id, prompt_markdown, solution_markdown, status, due_at, position, version`

func scanTask(row scanner) (*wantstudyv1.HomeworkTask, error) {
	value := &wantstudyv1.HomeworkTask{}
	var taskStatus string
	var dueAt *time.Time
	if err := row.Scan(&value.Id, &value.StudyId, &value.LessonId, &value.PromptMarkdown, &value.SolutionMarkdown, &taskStatus, &dueAt, &value.Position, &value.Version); err != nil {
		return nil, err
	}
	value.Status = homeworkStatusFromDatabase(taskStatus)
	value.DueAtEpochMillis = optionalMilliseconds(dueAt)
	return value, nil
}

func validateTask(value *wantstudyv1.HomeworkTask) (string, error) {
	if value == nil {
		return "", invalid("task", "is required")
	}
	if err := requireID("task.id", value.GetId()); err != nil {
		return "", err
	}
	if err := requireID("task.study_id", value.GetStudyId()); err != nil {
		return "", err
	}
	if err := requireID("task.lesson_id", value.GetLessonId()); err != nil {
		return "", err
	}
	if len(value.GetPromptMarkdown()) > contentLimit || len(value.GetSolutionMarkdown()) > contentLimit {
		return "", invalid("task.markdown", "each Markdown field must not exceed 1 MiB")
	}
	if err := requirePosition("task.position", value.GetPosition()); err != nil {
		return "", err
	}
	return homeworkStatusToDatabase(value.GetStatus())
}

func dueTime(value *wantstudyv1.HomeworkTask) any {
	if value.DueAtEpochMillis == nil {
		return nil
	}
	return time.UnixMilli(value.GetDueAtEpochMillis()).UTC()
}

func (services *Services) CreateHomeworkTask(ctx context.Context, request *wantstudyv1.CreateHomeworkTaskRequest) (*wantstudyv1.HomeworkTask, error) {
	value := request.GetTask()
	taskStatus, err := validateTask(value)
	if err != nil {
		return nil, err
	}
	tag, err := services.pool.Exec(ctx, `
		INSERT INTO homework_tasks (id, study_id, lesson_id, prompt_markdown, solution_markdown, status, due_at, position)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8) ON CONFLICT (id) DO NOTHING`,
		value.Id, value.StudyId, value.LessonId, value.PromptMarkdown, value.SolutionMarkdown, taskStatus, dueTime(value), value.Position)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getTask(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && !equalTaskCreate(stored, value) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "task id already contains different data")
	}
	return stored, nil
}

func equalTaskCreate(stored, requested *wantstudyv1.HomeworkTask) bool {
	return stored.StudyId == requested.StudyId && stored.LessonId == requested.LessonId && stored.PromptMarkdown == requested.PromptMarkdown && stored.SolutionMarkdown == requested.SolutionMarkdown && stored.Status == requested.Status && stored.GetDueAtEpochMillis() == requested.GetDueAtEpochMillis() && (stored.DueAtEpochMillis == nil) == (requested.DueAtEpochMillis == nil) && stored.Position == requested.Position
}

func (services *Services) getTask(ctx context.Context, id string) (*wantstudyv1.HomeworkTask, error) {
	return scanTask(services.pool.QueryRow(ctx, `SELECT `+taskColumns+` FROM homework_tasks WHERE id = $1`, id))
}

func (services *Services) UpdateHomeworkTask(ctx context.Context, request *wantstudyv1.UpdateHomeworkTaskRequest) (*wantstudyv1.HomeworkTask, error) {
	value := request.GetTask()
	taskStatus, err := validateTask(value)
	if err != nil {
		return nil, err
	}
	stored, err := scanTask(services.pool.QueryRow(ctx, `
		UPDATE homework_tasks
		SET prompt_markdown = $2, solution_markdown = $3, status = $4, due_at = $5, position = $6, version = version + 1, updated_at = now()
		WHERE id = $1 AND study_id = $7 AND lesson_id = $8 AND version = $9
		RETURNING `+taskColumns, value.Id, value.PromptMarkdown, value.SolutionMarkdown, taskStatus, dueTime(value), value.Position, value.StudyId, value.LessonId, request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "homework_tasks", value.Id, request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return stored, nil
}

const fileColumns = `id, study_id, lesson_id, homework_task_id, relative_path, language, content, version`

func scanFile(row scanner) (*wantstudyv1.CodeFile, error) {
	value := &wantstudyv1.CodeFile{}
	var taskID *string
	if err := row.Scan(&value.Id, &value.StudyId, &value.LessonId, &taskID, &value.RelativePath, &value.Language, &value.Content, &value.Version); err != nil {
		return nil, err
	}
	value.HomeworkTaskId = taskID
	return value, nil
}

func validateFile(value *wantstudyv1.CodeFile) error {
	if value == nil {
		return invalid("file", "is required")
	}
	if err := requireID("file.id", value.GetId()); err != nil {
		return err
	}
	if err := requireID("file.study_id", value.GetStudyId()); err != nil {
		return err
	}
	if err := requireID("file.lesson_id", value.GetLessonId()); err != nil {
		return err
	}
	if value.HomeworkTaskId != nil {
		if err := requireID("file.homework_task_id", value.GetHomeworkTaskId()); err != nil {
			return err
		}
	}
	relativePath := value.GetRelativePath()
	if relativePath == "" || relativePath == "." || path.IsAbs(relativePath) || path.Clean(relativePath) != relativePath || strings.Contains(relativePath, `\`) || strings.HasPrefix(relativePath, "../") {
		return invalid("file.relative_path", "must be a normalized relative POSIX path")
	}
	if len(value.GetContent()) > contentLimit {
		return invalid("file.content", "must not exceed 1 MiB")
	}
	return nil
}

func (services *Services) CreateCodeFile(ctx context.Context, request *wantstudyv1.CreateCodeFileRequest) (*wantstudyv1.CodeFile, error) {
	value := request.GetFile()
	if err := validateFile(value); err != nil {
		return nil, err
	}
	tag, err := services.pool.Exec(ctx, `
		INSERT INTO code_files (id, study_id, lesson_id, homework_task_id, relative_path, language, content)
		VALUES ($1, $2, $3, $4, $5, $6, $7) ON CONFLICT (id) DO NOTHING`,
		value.Id, value.StudyId, value.LessonId, value.HomeworkTaskId, value.RelativePath, value.Language, value.Content)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	stored, err := services.getFile(ctx, value.Id)
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() == 0 && !equalFileCreate(stored, value) {
		return nil, statusError(codes.AlreadyExists, "IDEMPOTENCY_CONFLICT", "file id already contains different data")
	}
	return stored, nil
}

func equalFileCreate(stored, requested *wantstudyv1.CodeFile) bool {
	return stored.StudyId == requested.StudyId && stored.LessonId == requested.LessonId && stored.GetHomeworkTaskId() == requested.GetHomeworkTaskId() && (stored.HomeworkTaskId == nil) == (requested.HomeworkTaskId == nil) && stored.RelativePath == requested.RelativePath && stored.Language == requested.Language && stored.Content == requested.Content
}

func (services *Services) getFile(ctx context.Context, id string) (*wantstudyv1.CodeFile, error) {
	return scanFile(services.pool.QueryRow(ctx, `SELECT `+fileColumns+` FROM code_files WHERE id = $1`, id))
}

func (services *Services) UpdateCodeFile(ctx context.Context, request *wantstudyv1.UpdateCodeFileRequest) (*wantstudyv1.CodeFile, error) {
	value := request.GetFile()
	if err := validateFile(value); err != nil {
		return nil, err
	}
	stored, err := scanFile(services.pool.QueryRow(ctx, `
		UPDATE code_files
		SET homework_task_id = $2, relative_path = $3, language = $4, content = $5, version = version + 1, updated_at = now()
		WHERE id = $1 AND study_id = $6 AND lesson_id = $7 AND version = $8
		RETURNING `+fileColumns, value.Id, value.HomeworkTaskId, value.RelativePath, value.Language, value.Content, value.StudyId, value.LessonId, request.GetExpectedVersion()))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, services.versionOrMissing(ctx, "code_files", value.Id, request.GetExpectedVersion())
	}
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	return stored, nil
}

func (services *Services) DeleteNoteBlock(ctx context.Context, request *wantstudyv1.DeleteContentRequest) (*wantstudyv1.DeleteContentResponse, error) {
	return services.deleteContent(ctx, "note_blocks", request)
}

func (services *Services) DeleteHomeworkTask(ctx context.Context, request *wantstudyv1.DeleteContentRequest) (*wantstudyv1.DeleteContentResponse, error) {
	return services.deleteContent(ctx, "homework_tasks", request)
}

func (services *Services) DeleteCodeFile(ctx context.Context, request *wantstudyv1.DeleteContentRequest) (*wantstudyv1.DeleteContentResponse, error) {
	return services.deleteContent(ctx, "code_files", request)
}

func (services *Services) deleteContent(ctx context.Context, table string, request *wantstudyv1.DeleteContentRequest) (*wantstudyv1.DeleteContentResponse, error) {
	if !request.GetConfirmed() {
		return nil, statusError(codes.FailedPrecondition, "CONFIRMATION_REQUIRED", "deletion requires confirmation")
	}
	if err := requireID("id", request.GetId()); err != nil {
		return nil, err
	}
	command := `DELETE FROM ` + table + ` WHERE id = $1 AND version = $2`
	tag, err := services.pool.Exec(ctx, command, request.GetId(), request.GetExpectedVersion())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	if tag.RowsAffected() != 1 {
		return nil, services.versionOrMissing(ctx, table, request.GetId(), request.GetExpectedVersion())
	}
	return &wantstudyv1.DeleteContentResponse{Id: request.GetId()}, nil
}

func (services *Services) GetLessonWorkspace(ctx context.Context, request *wantstudyv1.GetLessonWorkspaceRequest) (*wantstudyv1.LessonWorkspace, error) {
	if err := requireID("lesson_id", request.GetLessonId()); err != nil {
		return nil, err
	}
	lesson, err := services.getLesson(ctx, request.GetLessonId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	result := &wantstudyv1.LessonWorkspace{Lesson: lesson}
	blockRows, err := services.pool.Query(ctx, `SELECT `+blockColumns+` FROM note_blocks WHERE lesson_id = $1 ORDER BY position, id`, request.GetLessonId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for blockRows.Next() {
		value, scanErr := scanBlock(blockRows)
		if scanErr != nil {
			blockRows.Close()
			return nil, mapDatabaseError(scanErr)
		}
		result.Blocks = append(result.Blocks, value)
	}
	blockRows.Close()
	taskRows, err := services.pool.Query(ctx, `SELECT `+taskColumns+` FROM homework_tasks WHERE lesson_id = $1 ORDER BY position, id`, request.GetLessonId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for taskRows.Next() {
		value, scanErr := scanTask(taskRows)
		if scanErr != nil {
			taskRows.Close()
			return nil, mapDatabaseError(scanErr)
		}
		result.Tasks = append(result.Tasks, value)
	}
	taskRows.Close()
	fileRows, err := services.pool.Query(ctx, `SELECT `+fileColumns+` FROM code_files WHERE lesson_id = $1 ORDER BY relative_path, id`, request.GetLessonId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for fileRows.Next() {
		value, scanErr := scanFile(fileRows)
		if scanErr != nil {
			fileRows.Close()
			return nil, mapDatabaseError(scanErr)
		}
		result.Files = append(result.Files, value)
	}
	fileRows.Close()
	conceptRows, err := services.pool.Query(ctx, `
		SELECT DISTINCT bc.concept_id
		FROM block_concepts bc
		JOIN note_blocks b ON b.id = bc.block_id
		WHERE b.lesson_id = $1 ORDER BY bc.concept_id`, request.GetLessonId())
	if err != nil {
		return nil, mapDatabaseError(err)
	}
	for conceptRows.Next() {
		var conceptID string
		if err = conceptRows.Scan(&conceptID); err != nil {
			conceptRows.Close()
			return nil, mapDatabaseError(err)
		}
		result.ConceptIds = append(result.ConceptIds, conceptID)
	}
	conceptRows.Close()
	return result, nil
}

func (services *Services) ReorderLessonContent(ctx context.Context, request *wantstudyv1.ReorderLessonContentRequest) (*wantstudyv1.LessonWorkspace, error) {
	if err := requireID("lesson_id", request.GetLessonId()); err != nil {
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
	}{{"note_blocks", request.GetBlocks()}, {"homework_tasks", request.GetTasks()}} {
		for _, item := range group.items {
			if err = requireID("items.id", item.GetId()); err != nil {
				return nil, err
			}
			command := `UPDATE ` + group.table + ` SET position = $1, version = version + 1, updated_at = now() WHERE id = $2 AND lesson_id = $3 AND version = $4`
			tag, updateErr := tx.Exec(ctx, command, item.GetPosition(), item.GetId(), request.GetLessonId(), item.GetExpectedVersion())
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
	return services.GetLessonWorkspace(ctx, &wantstudyv1.GetLessonWorkspaceRequest{LessonId: request.GetLessonId()})
}
