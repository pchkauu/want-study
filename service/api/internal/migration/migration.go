package migration

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/jackc/pgx/v5"
)

const tableSQL = `
CREATE TABLE IF NOT EXISTS schema_migrations (
    version text PRIMARY KEY,
    applied_at timestamptz NOT NULL DEFAULT now()
)`

func Up(ctx context.Context, databaseURL, migrationPath string) error {
	conn, err := pgx.Connect(ctx, databaseURL)
	if err != nil {
		return fmt.Errorf("connect for migration: %w", err)
	}
	defer conn.Close(ctx)

	if _, err = conn.Exec(ctx, tableSQL); err != nil {
		return fmt.Errorf("create migration table: %w", err)
	}

	files, err := migrationFiles(migrationPath, ".up.sql")
	if err != nil {
		return err
	}
	for _, file := range files {
		version := strings.SplitN(filepath.Base(file), "_", 2)[0]
		var applied bool
		if err = conn.QueryRow(ctx, "SELECT EXISTS (SELECT 1 FROM schema_migrations WHERE version = $1)", version).Scan(&applied); err != nil {
			return fmt.Errorf("check migration %s: %w", version, err)
		}
		if applied {
			continue
		}
		body, readErr := os.ReadFile(file)
		if readErr != nil {
			return fmt.Errorf("read migration %s: %w", file, readErr)
		}
		tx, beginErr := conn.Begin(ctx)
		if beginErr != nil {
			return fmt.Errorf("begin migration %s: %w", version, beginErr)
		}
		_, execErr := tx.Conn().PgConn().Exec(ctx, string(body)).ReadAll()
		if execErr == nil {
			_, execErr = tx.Exec(ctx, "INSERT INTO schema_migrations (version) VALUES ($1)", version)
		}
		if execErr != nil {
			_ = tx.Rollback(ctx)
			return fmt.Errorf("apply migration %s: %w", version, execErr)
		}
		if err = tx.Commit(ctx); err != nil {
			return fmt.Errorf("commit migration %s: %w", version, err)
		}
	}
	return nil
}

func Down(ctx context.Context, databaseURL, migrationPath string) error {
	conn, err := pgx.Connect(ctx, databaseURL)
	if err != nil {
		return fmt.Errorf("connect for migration: %w", err)
	}
	defer conn.Close(ctx)

	if _, err = conn.Exec(ctx, tableSQL); err != nil {
		return fmt.Errorf("create migration table: %w", err)
	}
	files, err := migrationFiles(migrationPath, ".down.sql")
	if err != nil {
		return err
	}
	sort.Sort(sort.Reverse(sort.StringSlice(files)))
	for _, file := range files {
		version := strings.SplitN(filepath.Base(file), "_", 2)[0]
		var applied bool
		if err = conn.QueryRow(ctx, "SELECT EXISTS (SELECT 1 FROM schema_migrations WHERE version = $1)", version).Scan(&applied); err != nil {
			return fmt.Errorf("check migration %s: %w", version, err)
		}
		if !applied {
			continue
		}
		body, readErr := os.ReadFile(file)
		if readErr != nil {
			return fmt.Errorf("read migration %s: %w", file, readErr)
		}
		tx, beginErr := conn.Begin(ctx)
		if beginErr != nil {
			return fmt.Errorf("begin migration %s: %w", version, beginErr)
		}
		_, execErr := tx.Conn().PgConn().Exec(ctx, string(body)).ReadAll()
		if execErr == nil {
			_, execErr = tx.Exec(ctx, "DELETE FROM schema_migrations WHERE version = $1", version)
		}
		if execErr != nil {
			_ = tx.Rollback(ctx)
			return fmt.Errorf("revert migration %s: %w", version, execErr)
		}
		if err = tx.Commit(ctx); err != nil {
			return fmt.Errorf("commit migration %s: %w", version, err)
		}
	}
	return nil
}

func migrationFiles(path, suffix string) ([]string, error) {
	entries, err := os.ReadDir(path)
	if err != nil {
		return nil, fmt.Errorf("read migration path: %w", err)
	}
	files := make([]string, 0, len(entries))
	for _, entry := range entries {
		if !entry.IsDir() && strings.HasSuffix(entry.Name(), suffix) {
			files = append(files, filepath.Join(path, entry.Name()))
		}
	}
	sort.Strings(files)
	return files, nil
}
