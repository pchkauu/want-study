package migration_test

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/pchkauu/want-study/service/api/internal/migration"
)

func TestUpDownUp(t *testing.T) {
	databaseURL := os.Getenv("WANT_STUDY_TEST_DATABASE_URL")
	if databaseURL == "" {
		t.Skip("WANT_STUDY_TEST_DATABASE_URL is not set")
	}
	migrationPath := filepath.Join("..", "..", "..", "..", "db", "migration")
	ctx := context.Background()

	if err := migration.Down(ctx, databaseURL, migrationPath); err != nil {
		t.Fatalf("initial down: %v", err)
	}
	if err := migration.Up(ctx, databaseURL, migrationPath); err != nil {
		t.Fatalf("first up: %v", err)
	}
	assertSchema(t, ctx, databaseURL)
	if err := migration.Down(ctx, databaseURL, migrationPath); err != nil {
		t.Fatalf("down: %v", err)
	}
	if err := migration.Up(ctx, databaseURL, migrationPath); err != nil {
		t.Fatalf("second up: %v", err)
	}
	assertSchema(t, ctx, databaseURL)
}

func assertSchema(t *testing.T, ctx context.Context, databaseURL string) {
	t.Helper()
	connection, err := pgx.Connect(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	defer connection.Close(ctx)
	var count int
	if err = connection.QueryRow(ctx, `
		SELECT count(*) FROM information_schema.tables
		WHERE table_schema = 'public' AND table_name IN
		('studies', 'learning_sources', 'sections', 'lessons', 'note_blocks',
		 'homework_tasks', 'code_files', 'concepts', 'concept_aliases',
		 'block_concepts', 'concept_relations', 'import_runs')`).Scan(&count); err != nil {
		t.Fatalf("inspect schema: %v", err)
	}
	if count != 12 {
		t.Fatalf("expected 12 domain tables, got %d", count)
	}
}
