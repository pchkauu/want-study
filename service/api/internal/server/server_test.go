package server

import (
	"context"
	"net"
	"strings"
	"testing"

	healthv1 "github.com/pchkauu/want-study/service/api/internal/proto/grpc/health/v1"
	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/test/bufconn"
)

func TestTypedValidationErrorAndHealth(t *testing.T) {
	listener := bufconn.Listen(1024 * 1024)
	grpcServer := grpc.NewServer()
	Register(grpcServer, New(nil))
	go func() {
		_ = grpcServer.Serve(listener)
	}()
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

	health, err := healthv1.NewHealthClient(connection).Check(context.Background(), &healthv1.HealthCheckRequest{})
	if err != nil || health.Status != healthv1.HealthCheckResponse_SERVING {
		t.Fatalf("health check: response=%v error=%v", health, err)
	}
	_, err = wantstudyv1.NewStudyCatalogServiceClient(connection).CreateStudy(
		context.Background(),
		&wantstudyv1.CreateStudyRequest{Id: "not-a-uuid", Title: "Study"},
	)
	value, ok := status.FromError(err)
	if !ok || value.Code() != codes.InvalidArgument {
		t.Fatalf("expected InvalidArgument, got %v", err)
	}
	found := false
	for _, detail := range value.Details() {
		if info, isInfo := detail.(*errdetails.ErrorInfo); isInfo && info.Reason == "VALIDATION_FAILED" {
			found = true
		}
	}
	if !found {
		t.Fatalf("ErrorInfo reason was not returned")
	}
}

func TestRenderSnapshotIsSortedAndDeterministic(t *testing.T) {
	snapshot := &exportSnapshot{
		study: &wantstudyv1.Study{Id: "study", Title: "C/C++", Goal: "Learn", ContentRevision: 7},
		sources: []*wantstudyv1.SourceNode{{
			Source: &wantstudyv1.LearningSource{Id: "source", Title: "Course", ExportSlug: "course"},
			Lessons: []*wantstudyv1.Lesson{{
				Id: "lesson", Title: "First", ExportSlug: "first", Status: wantstudyv1.LessonStatus_LESSON_STATUS_PLANNED,
			}},
		}},
		workspace: map[string]*wantstudyv1.LessonWorkspace{
			"lesson": {
				Lesson: &wantstudyv1.Lesson{Id: "lesson", Title: "First", ExportSlug: "first", Status: wantstudyv1.LessonStatus_LESSON_STATUS_PLANNED},
				Blocks: []*wantstudyv1.NoteBlock{{Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_TEXT, Markdown: "Note"}},
			},
		},
	}

	first, err := renderSnapshot(snapshot)
	if err != nil {
		t.Fatalf("render: %v", err)
	}
	second, err := renderSnapshot(snapshot)
	if err != nil {
		t.Fatalf("second render: %v", err)
	}
	if len(first) != len(second) || len(first) != 5 {
		t.Fatalf("unexpected file count: %d", len(first))
	}
	for index := range first {
		if first[index].path != second[index].path ||
			first[index].hash != second[index].hash ||
			string(first[index].content) != string(second[index].content) {
			t.Fatalf("render differs at index %d", index)
		}
		if index > 0 && first[index-1].path >= first[index].path {
			t.Fatalf("paths are not sorted")
		}
		if strings.Contains(string(first[index].content), "2026-") {
			t.Fatalf("export contains current time")
		}
	}
}
