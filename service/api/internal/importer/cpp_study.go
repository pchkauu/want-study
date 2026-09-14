package importer

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

const (
	SourceRevision   = "828752ff65d8b202d386e70d7bade74380fdf2d0"
	rootReadmeHash   = "4fc6b1239165a24aae19dcc18c9259e14a487f530c85da13e946eb7cdecc60ed"
	courseReadmeHash = "b1bc0adce3e40a92fdbcb2e284a8664f62f4190590e884fd83893b36cdfa3d92"
	mainFileHash     = "527e610de25ae829b41374b108d57bf5b02d836add2f6b848e76166e5a64ce5e"
)

var lessonHeading = regexp.MustCompile(`(?m)^#### (1\.[1-4])(?: 📚)? (.+)$`)

type Warning struct {
	Line   int
	Reason string
}

type Task struct {
	Prompt string
	Done   bool
}

type Lesson struct {
	Position       string
	Title          string
	Status         string
	Note           string
	Tasks          []Task
	CodeFile       string
	SourcePosition int
}

type Snapshot struct {
	RepositoryPath string
	Lessons        []Lesson
	Warnings       []Warning
}

func Load(repositoryPath string) (*Snapshot, error) {
	root, err := filepath.EvalSymlinks(repositoryPath)
	if err != nil {
		return nil, fmt.Errorf("resolve repository: %w", err)
	}
	root, err = filepath.Abs(root)
	if err != nil {
		return nil, fmt.Errorf("resolve repository root: %w", err)
	}
	rootReadme, err := readVerified(root, "README.md", rootReadmeHash)
	if err != nil {
		return nil, err
	}
	if !strings.Contains(string(rootReadme), "# C/C++") {
		return nil, errors.New("unexpected root README")
	}
	courseReadme, err := readVerified(root, "stepik/193691/README.md", courseReadmeHash)
	if err != nil {
		return nil, err
	}
	mainFile, err := readVerified(root, "stepik/193691/source_code/1/4/main.c", mainFileHash)
	if err != nil {
		return nil, err
	}
	snapshot, err := Parse(string(courseReadme), string(mainFile))
	if err != nil {
		return nil, err
	}
	snapshot.RepositoryPath = root
	return snapshot, nil
}

func readVerified(root, relativePath, expectedHash string) ([]byte, error) {
	target := filepath.Join(root, filepath.FromSlash(relativePath))
	relative, err := filepath.Rel(root, target)
	if err != nil || relative == ".." || strings.HasPrefix(relative, ".."+string(filepath.Separator)) {
		return nil, errors.New("legacy path escapes repository")
	}
	info, err := os.Lstat(target)
	if err != nil {
		return nil, fmt.Errorf("read legacy file %s: %w", relativePath, err)
	}
	if info.Mode()&os.ModeSymlink != 0 || !info.Mode().IsRegular() {
		return nil, fmt.Errorf("legacy file %s is not a regular file", relativePath)
	}
	content, err := os.ReadFile(target)
	if err != nil {
		return nil, fmt.Errorf("read legacy file %s: %w", relativePath, err)
	}
	hash := sha256.Sum256(content)
	if hex.EncodeToString(hash[:]) != expectedHash {
		return nil, fmt.Errorf("legacy file %s differs from snapshot", relativePath)
	}
	return content, nil
}

func Parse(courseReadme, mainFile string) (*Snapshot, error) {
	matches := lessonHeading.FindAllStringSubmatchIndex(courseReadme, -1)
	if len(matches) != 4 {
		return nil, fmt.Errorf("expected 4 lessons, got %d", len(matches))
	}
	result := &Snapshot{Lessons: make([]Lesson, 0, len(matches))}
	for index, match := range matches {
		end := len(courseReadme)
		if index+1 < len(matches) {
			end = matches[index+1][0]
		}
		position := courseReadme[match[2]:match[3]]
		segment := courseReadme[match[1]:end]
		lesson := Lesson{
			Position:       position,
			Title:          strings.TrimSpace(courseReadme[match[4]:match[5]]),
			Status:         "homework",
			Tasks:          parseTasks(segment),
			Note:           parseNote(segment),
			SourcePosition: index,
		}
		if position == "1.3" {
			lesson.Status = "mastered"
		}
		if position == "1.4" {
			lesson.CodeFile = mainFile
		}
		result.Lessons = append(result.Lessons, lesson)
	}
	if countTasks(result.Lessons) != 23 {
		return nil, fmt.Errorf("expected 23 tasks, got %d", countTasks(result.Lessons))
	}
	if countDone(result.Lessons) != 1 {
		return nil, fmt.Errorf("expected one completed task, got %d", countDone(result.Lessons))
	}
	result.Warnings = detectWarnings(courseReadme)
	return result, nil
}

func parseTasks(segment string) []Task {
	start := strings.Index(segment, "##### 🔬 Домашнее задание")
	if start < 0 {
		return nil
	}
	body := segment[start:]
	if end := strings.Index(body, "##### 🏆"); end >= 0 {
		body = body[:end]
	}
	result := make([]Task, 0)
	for _, line := range strings.Split(body, "\n") {
		done := strings.HasPrefix(line, "- [x] ")
		if done || strings.HasPrefix(line, "- [ ] ") {
			result = append(result, Task{Prompt: line[6:], Done: done})
		}
	}
	return result
}

func parseNote(segment string) string {
	lines := strings.Split(segment, "\n")
	metadata := make([]string, 0, 2)
	for _, line := range lines {
		if strings.HasPrefix(line, "Дата прохождения:") || strings.HasPrefix(line, "💫 Дедлайн:") {
			metadata = append(metadata, strings.TrimRight(line, " \t"))
		}
	}
	content := ""
	if marker := strings.Index(segment, "##### 📝 Конспект"); marker >= 0 {
		content = segment[marker+len("##### 📝 Конспект"):]
	} else {
		for _, line := range lines {
			if strings.HasPrefix(line, "✅ ") {
				content = line
				break
			}
		}
	}
	content = strings.TrimSpace(content)
	content = strings.TrimSuffix(content, "\n\n---")
	parts := append(metadata, strings.TrimSpace(content))
	return strings.TrimSpace(strings.Join(parts, "\n\n"))
}

func detectWarnings(content string) []Warning {
	result := make([]Warning, 0)
	for index, line := range strings.Split(content, "\n") {
		reason := ""
		switch {
		case strings.Contains(line, "]([http"):
			reason = "некорректная Markdown-ссылка сохранена без изменений"
		case strings.Contains(line, "5785") && strings.HasPrefix(line, "💫 Дедлайн:"):
			reason = "подозрительный срок сохранён исходным текстом"
		case strings.Contains(line, "5785"):
			reason = "подозрительная дата сохранена исходным текстом"
		}
		if reason != "" {
			result = append(result, Warning{Line: index + 1, Reason: reason})
		}
	}
	return result
}

func countTasks(lessons []Lesson) int {
	result := 0
	for _, lesson := range lessons {
		result += len(lesson.Tasks)
	}
	return result
}

func countDone(lessons []Lesson) int {
	result := 0
	for _, lesson := range lessons {
		for _, task := range lesson.Tasks {
			if task.Done {
				result++
			}
		}
	}
	return result
}

func Apply(ctx context.Context, pool *pgxpool.Pool, snapshot *Snapshot) (string, error) {
	tx, err := pool.BeginTx(ctx, pgx.TxOptions{IsoLevel: pgx.Serializable})
	if err != nil {
		return "", fmt.Errorf("begin import: %w", err)
	}
	defer tx.Rollback(ctx)
	var exists bool
	if err = tx.QueryRow(ctx, `SELECT EXISTS(SELECT 1 FROM import_runs WHERE repository_path = $1 AND source_revision = $2)`, snapshot.RepositoryPath, SourceRevision).Scan(&exists); err != nil {
		return "", fmt.Errorf("check previous import: %w", err)
	}
	if exists {
		return "", errors.New("repository snapshot was already imported")
	}
	var studyID string
	if err = tx.QueryRow(ctx, `
		INSERT INTO studies (id, title, goal, local_repository_path)
		VALUES (uuidv7(), 'C/C++', 'Самообучение C и C++', $1)
		RETURNING id`, snapshot.RepositoryPath).Scan(&studyID); err != nil {
		return "", fmt.Errorf("insert study: %w", err)
	}
	var sourceID string
	if err = tx.QueryRow(ctx, `
		INSERT INTO learning_sources (id, study_id, source_type, title, author, url, export_slug, position)
		VALUES (uuidv7(), $1, 'course', 'Добрый, добрый C, C++ с Сергеем Балакиревым', 'Сергей Балакирев', 'https://stepik.org/course/193691', 'stepik-193691', 0)
		RETURNING id`, studyID).Scan(&sourceID); err != nil {
		return "", fmt.Errorf("insert source: %w", err)
	}
	var sectionID string
	if err = tx.QueryRow(ctx, `
		INSERT INTO sections (id, study_id, source_id, title, position)
		VALUES (uuidv7(), $1, $2, '1. Первое знакомство', 0)
		RETURNING id`, studyID, sourceID).Scan(&sectionID); err != nil {
		return "", fmt.Errorf("insert section: %w", err)
	}
	startedAt := time.Date(2025, time.March, 9, 0, 0, 0, 0, time.UTC)
	for _, lesson := range snapshot.Lessons {
		var lessonID string
		var masteredAt *time.Time
		if lesson.Status == "mastered" {
			masteredAt = &startedAt
		}
		if err = tx.QueryRow(ctx, `
			INSERT INTO lessons (id, study_id, source_id, section_id, title, source_position, export_slug, position, status, started_at, mastered_at)
			VALUES (uuidv7(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
			RETURNING id`, studyID, sourceID, sectionID, lesson.Title, lesson.Position, strings.ReplaceAll(lesson.Position, ".", "-"), lesson.SourcePosition, lesson.Status, startedAt, masteredAt).Scan(&lessonID); err != nil {
			return "", fmt.Errorf("insert lesson %s: %w", lesson.Position, err)
		}
		if _, err = tx.Exec(ctx, `
			INSERT INTO note_blocks (id, study_id, lesson_id, block_type, markdown, position)
			VALUES (uuidv7(), $1, $2, 'text', $3, 0)`, studyID, lessonID, lesson.Note); err != nil {
			return "", fmt.Errorf("insert lesson note %s: %w", lesson.Position, err)
		}
		for position, task := range lesson.Tasks {
			status := "todo"
			if task.Done {
				status = "done"
			}
			if _, err = tx.Exec(ctx, `
				INSERT INTO homework_tasks (id, study_id, lesson_id, prompt_markdown, status, position)
				VALUES (uuidv7(), $1, $2, $3, $4, $5)`, studyID, lessonID, task.Prompt, status, position); err != nil {
				return "", fmt.Errorf("insert lesson task %s: %w", lesson.Position, err)
			}
		}
		if lesson.CodeFile != "" {
			if _, err = tx.Exec(ctx, `
				INSERT INTO code_files (id, study_id, lesson_id, relative_path, language, content)
				VALUES (uuidv7(), $1, $2, 'main.c', 'c', $3)`, studyID, lessonID, lesson.CodeFile); err != nil {
				return "", fmt.Errorf("insert lesson file %s: %w", lesson.Position, err)
			}
		}
	}
	if _, err = tx.Exec(ctx, `
		INSERT INTO import_runs (study_id, repository_path, source_revision, warning_count)
		VALUES ($1, $2, $3, $4)`, studyID, snapshot.RepositoryPath, SourceRevision, len(snapshot.Warnings)); err != nil {
		return "", fmt.Errorf("record import: %w", err)
	}
	if err = tx.Commit(ctx); err != nil {
		return "", fmt.Errorf("commit import: %w", err)
	}
	return studyID, nil
}
