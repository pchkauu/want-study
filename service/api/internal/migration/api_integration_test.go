package migration_test

import (
	"context"
	"fmt"
	"io"
	"net"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pchkauu/want-study/service/api/internal/importer"
	"github.com/pchkauu/want-study/service/api/internal/migration"
	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
	"github.com/pchkauu/want-study/service/api/internal/server"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/test/bufconn"
)

func TestCatalogProgressStatusAndExport(t *testing.T) {
	databaseURL := os.Getenv("WANT_STUDY_TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("WANT_STUDY_TEST_DATABASE_URL is not set")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()
	migrationPath := filepath.Join("..", "..", "..", "..", "db", "migration")
	if err := migration.Down(ctx, databaseURL, migrationPath); err != nil {
		t.Fatalf("initial down: %v", err)
	}
	if err := migration.Up(ctx, databaseURL, migrationPath); err != nil {
		t.Fatalf("up: %v", err)
	}
	t.Cleanup(func() {
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cleanupCancel()
		_ = migration.Down(cleanupCtx, databaseURL, migrationPath)
	})

	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect pool: %v", err)
	}
	t.Cleanup(pool.Close)
	connection := integrationConnection(t, server.New(pool))

	catalog := wantstudyv1.NewStudyCatalogServiceClient(connection)
	content := wantstudyv1.NewLessonContentServiceClient(connection)
	knowledge := wantstudyv1.NewKnowledgeServiceClient(connection)
	export := wantstudyv1.NewExportServiceClient(connection)
	const (
		studyID   = "00000000-0000-4000-8000-000000000001"
		sourceID  = "00000000-0000-4000-8000-000000000002"
		sectionID = "00000000-0000-4000-8000-000000000003"
		lessonID  = "00000000-0000-4000-8000-000000000004"
		taskID    = "00000000-0000-4000-8000-000000000005"
		conceptID = "00000000-0000-4000-8000-000000000006"
	)
	createStudy := &wantstudyv1.CreateStudyRequest{Id: studyID, Title: "C/C++", Goal: "Learn"}
	study, err := catalog.CreateStudy(ctx, createStudy)
	if err != nil {
		t.Fatalf("create study: %v", err)
	}
	repeated, err := catalog.CreateStudy(ctx, createStudy)
	if err != nil || repeated.Id != study.Id {
		t.Fatalf("repeat create: value=%v error=%v", repeated, err)
	}
	_, err = catalog.CreateStudy(ctx, &wantstudyv1.CreateStudyRequest{Id: studyID, Title: "Other"})
	assertCode(t, err, codes.AlreadyExists)

	_, err = catalog.CreateLearningSource(ctx, &wantstudyv1.CreateLearningSourceRequest{
		Id: sourceID, StudyId: studyID, Type: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_COURSE,
		Title: "Course", ExportSlug: "course", Position: 0,
	})
	if err != nil {
		t.Fatalf("create source: %v", err)
	}
	_, err = catalog.CreateSection(ctx, &wantstudyv1.CreateSectionRequest{
		Id: sectionID, StudyId: studyID, SourceId: sourceID, Title: "Section", Position: 0,
	})
	if err != nil {
		t.Fatalf("create section: %v", err)
	}
	lesson, err := catalog.CreateLesson(ctx, &wantstudyv1.CreateLessonRequest{
		Id: lessonID, StudyId: studyID, SourceId: sourceID, SectionId: stringPointer(sectionID),
		Title: "Lesson", ExportSlug: "lesson", Position: 0,
		Status: wantstudyv1.LessonStatus_LESSON_STATUS_PLANNED,
	})
	if err != nil {
		t.Fatalf("create lesson: %v", err)
	}
	task, err := content.CreateHomeworkTask(ctx, &wantstudyv1.CreateHomeworkTaskRequest{
		Task: &wantstudyv1.HomeworkTask{
			Id: taskID, StudyId: studyID, LessonId: lessonID, PromptMarkdown: "Task",
			Status: wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_TODO, Position: 0,
		},
	})
	if err != nil {
		t.Fatalf("create task: %v", err)
	}
	conceptRequest := &wantstudyv1.CreateConceptRequest{Concept: &wantstudyv1.Concept{
		Id: conceptID, StudyId: studyID, Title: "C language", ExportSlug: "c-language",
		Aliases: []string{"C", "C language"},
	}}
	concept, err := knowledge.CreateConcept(ctx, conceptRequest)
	if err != nil || len(concept.GetAliases()) != 2 {
		t.Fatalf("create concept aliases: value=%v error=%v", concept, err)
	}
	repeatedConcept, err := knowledge.CreateConcept(ctx, conceptRequest)
	if err != nil || repeatedConcept.GetId() != conceptID {
		t.Fatalf("repeat concept create: value=%v error=%v", repeatedConcept, err)
	}
	concept.Aliases = []string{"C", "C17"}
	concept, err = knowledge.UpdateConcept(ctx, &wantstudyv1.UpdateConceptRequest{
		Concept: concept, ExpectedVersion: concept.Version,
	})
	if err != nil || len(concept.GetAliases()) != 2 {
		t.Fatalf("update concept aliases: value=%v error=%v", concept, err)
	}
	search, err := knowledge.SearchConcepts(ctx, &wantstudyv1.SearchConceptsRequest{
		StudyId: studyID, Query: "C17",
	})
	if err != nil || len(search.GetConcepts()) != 1 || search.GetConcepts()[0].GetId() != conceptID {
		t.Fatalf("search concept alias: value=%v error=%v", search, err)
	}

	lesson, err = catalog.ChangeLessonStatus(ctx, &wantstudyv1.ChangeLessonStatusRequest{
		Id: lessonID, ExpectedVersion: lesson.Version,
		Status: wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING,
	})
	if err != nil || lesson.StartedAtEpochMillis == nil || lesson.MasteredAtEpochMillis != nil {
		t.Fatalf("start lesson: value=%v error=%v", lesson, err)
	}
	_, err = catalog.ChangeLessonStatus(ctx, &wantstudyv1.ChangeLessonStatusRequest{
		Id: lessonID, ExpectedVersion: lesson.Version,
		Status: wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED,
	})
	assertReason(t, err, codes.FailedPrecondition, "OPEN_HOMEWORK")
	lesson, err = catalog.ChangeLessonStatus(ctx, &wantstudyv1.ChangeLessonStatusRequest{
		Id: lessonID, ExpectedVersion: lesson.Version, AcknowledgeOpenHomework: true,
		Status: wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED,
	})
	if err != nil || lesson.MasteredAtEpochMillis == nil {
		t.Fatalf("master lesson: value=%v error=%v", lesson, err)
	}

	dashboard, err := catalog.GetDashboard(ctx, &wantstudyv1.GetDashboardRequest{StudyId: studyID})
	if err != nil || dashboard.Material.Completed != 1 || dashboard.Material.Total != 1 ||
		dashboard.Homework.Completed != 0 || dashboard.Homework.Total != 1 {
		t.Fatalf("initial dashboard: value=%v error=%v", dashboard, err)
	}
	task.Status = wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_DONE
	_, err = content.UpdateHomeworkTask(ctx, &wantstudyv1.UpdateHomeworkTaskRequest{
		Task: task, ExpectedVersion: task.Version,
	})
	if err != nil {
		t.Fatalf("complete task: %v", err)
	}
	dashboard, err = catalog.GetDashboard(ctx, &wantstudyv1.GetDashboardRequest{StudyId: studyID})
	if err != nil || dashboard.Homework.Completed != 1 || dashboard.Homework.Total != 1 {
		t.Fatalf("completed dashboard: value=%v error=%v", dashboard, err)
	}

	updated, err := catalog.UpdateStudy(ctx, &wantstudyv1.UpdateStudyRequest{
		Id: studyID, Title: "C/C++", Goal: "Learn deeply", ExpectedVersion: study.Version,
	})
	if err != nil || updated.Version != study.Version+1 {
		t.Fatalf("update study: value=%v error=%v", updated, err)
	}
	_, err = catalog.UpdateStudy(ctx, &wantstudyv1.UpdateStudyRequest{
		Id: studyID, Title: "C/C++", Goal: "Stale", ExpectedVersion: study.Version,
	})
	assertReason(t, err, codes.Aborted, "VERSION_CONFLICT")
	dashboard, err = catalog.GetDashboard(ctx, &wantstudyv1.GetDashboardRequest{StudyId: studyID})
	if err != nil {
		t.Fatalf("refresh dashboard: %v", err)
	}

	stream, err := export.RenderStudyExport(ctx, &wantstudyv1.RenderStudyExportRequest{
		StudyId: studyID, ExpectedContentRevision: &dashboard.StudyRevision,
	})
	if err != nil {
		t.Fatalf("open export: %v", err)
	}
	first, err := stream.Recv()
	if err != nil || first.GetHeader() == nil {
		t.Fatalf("export header: value=%v error=%v", first, err)
	}
	previousPath := ""
	fileCount := 0
	for {
		chunk, receiveErr := stream.Recv()
		if receiveErr == io.EOF {
			break
		}
		if receiveErr != nil {
			t.Fatalf("receive export: %v", receiveErr)
		}
		file := chunk.GetFile()
		if file == nil || file.Path <= previousPath {
			t.Fatalf("unsorted export file: %v", file)
		}
		previousPath = file.Path
		fileCount++
	}
	if int32(fileCount) != first.GetHeader().FileCount {
		t.Fatalf("header file count=%d, received=%d", first.GetHeader().FileCount, fileCount)
	}

	importSnapshot := &importer.Snapshot{RepositoryPath: "/tmp/cpp-study-test"}
	for lessonIndex, taskCount := range []int{9, 8, 0, 6} {
		lesson := importer.Lesson{
			Position: fmt.Sprintf("1.%d", lessonIndex+1), Title: "Imported lesson",
			Status: "homework", Note: "Imported note", SourcePosition: lessonIndex,
		}
		if lessonIndex == 2 {
			lesson.Status = "mastered"
		}
		if lessonIndex == 3 {
			lesson.CodeFile = "int main(void) {}\n"
		}
		for taskIndex := range taskCount {
			lesson.Tasks = append(lesson.Tasks, importer.Task{
				Prompt: "Imported task", Done: lessonIndex == 0 && taskIndex == 0,
			})
		}
		importSnapshot.Lessons = append(importSnapshot.Lessons, lesson)
	}
	importedStudyID, err := importer.Apply(ctx, pool, importSnapshot)
	if err != nil {
		t.Fatalf("apply importer: %v", err)
	}
	var taskCount, doneCount, fileCountStored int
	if err = pool.QueryRow(ctx, `
		SELECT count(*), count(*) FILTER (WHERE status = 'done')
		FROM homework_tasks WHERE study_id = $1`, importedStudyID).Scan(&taskCount, &doneCount); err != nil {
		t.Fatalf("count imported tasks: %v", err)
	}
	if err = pool.QueryRow(ctx, `SELECT count(*) FROM code_files WHERE study_id = $1`, importedStudyID).Scan(&fileCountStored); err != nil {
		t.Fatalf("count imported files: %v", err)
	}
	if taskCount != 23 || doneCount != 1 || fileCountStored != 1 {
		t.Fatalf("imported counts: tasks=%d done=%d files=%d", taskCount, doneCount, fileCountStored)
	}
	if _, err = importer.Apply(ctx, pool, importSnapshot); err == nil {
		t.Fatal("repeated import succeeded")
	}
	rollbackSnapshot := &importer.Snapshot{
		RepositoryPath: "/tmp/cpp-study-rollback",
		Lessons:        []importer.Lesson{{Position: "1.1", Title: "Invalid", Status: "invalid"}},
	}
	if _, err = importer.Apply(ctx, pool, rollbackSnapshot); err == nil {
		t.Fatal("invalid import succeeded")
	}
	var rolledBack int
	if err = pool.QueryRow(ctx, `SELECT count(*) FROM studies WHERE local_repository_path = $1`, rollbackSnapshot.RepositoryPath).Scan(&rolledBack); err != nil || rolledBack != 0 {
		t.Fatalf("import rollback: studies=%d error=%v", rolledBack, err)
	}
}

func integrationConnection(t *testing.T, services *server.Services) *grpc.ClientConn {
	t.Helper()
	listener := bufconn.Listen(1024 * 1024)
	grpcServer := grpc.NewServer()
	server.Register(grpcServer, services)
	go func() { _ = grpcServer.Serve(listener) }()
	t.Cleanup(grpcServer.Stop)
	connection, err := grpc.NewClient(
		"passthrough:///bufnet",
		grpc.WithContextDialer(func(context.Context, string) (net.Conn, error) {
			return listener.Dial()
		}),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		t.Fatalf("create client: %v", err)
	}
	t.Cleanup(func() { _ = connection.Close() })
	return connection
}

func assertCode(t *testing.T, err error, code codes.Code) {
	t.Helper()
	if status.Code(err) != code {
		t.Fatalf("expected code %s, got %v", code, err)
	}
}

func assertReason(t *testing.T, err error, code codes.Code, reason string) {
	t.Helper()
	assertCode(t, err, code)
	value, _ := status.FromError(err)
	for _, detail := range value.Details() {
		if info, ok := detail.(*errdetails.ErrorInfo); ok && info.Reason == reason {
			return
		}
	}
	t.Fatalf("reason %s was not returned", reason)
}

func stringPointer(value string) *string { return &value }
