package server

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
)

func TestRenderSnapshotGolden(t *testing.T) {
	files, err := renderSnapshot(exportGoldenSnapshot())
	if err != nil {
		t.Fatalf("render snapshot: %v", err)
	}
	second, err := renderSnapshot(exportGoldenSnapshot())
	if err != nil {
		t.Fatalf("render snapshot again: %v", err)
	}
	if exportGoldenText(files) != exportGoldenText(second) {
		t.Fatal("consecutive renders differ")
	}
	assertExportManifest(t, files)

	for _, file := range files {
		if !strings.HasSuffix(file.path, ".md") {
			continue
		}
		content := string(file.content)
		if strings.Contains(content, "lesson-studying") || strings.Contains(content, "block-definition") || strings.Contains(content, "id:") {
			t.Fatalf("%s contains an internal identifier", file.path)
		}
		for _, oldLabel := range []string{
			"> **Цель обучения**",
			"## 📈 Прогресс",
			"## 🧭 Статус занятий",
			"## 🎓 Источники",
			"[← К обучению]",
			"## 📑 Программа",
			"| Позиция | Урок | Статус |",
			"## ✍️ Конспект",
			"> **Источник блока**",
			"## ✅ Домашняя работа",
			"<strong>Показать решение</strong>",
			"## 💻 Файлы",
			"## 🧠 Понятия",
			"## 🔗 Связи",
			"## 📍 Где встречается",
		} {
			if strings.Contains(content, oldLabel) {
				t.Fatalf("%s contains old template label %q", file.path, oldLabel)
			}
		}
	}
	root := exportFileContent(t, files, "README.md")
	lesson := exportFileContent(t, files, "source/stepik-cpp/lesson/ownership/README.md")
	if !strings.Contains(root, "Разобраться в системном программировании.") || !strings.Contains(lesson, "Короткое введение с **акцентом**.") {
		t.Fatal("user-authored Markdown was not preserved")
	}
	if strings.Count(lesson, "### 🧪 Example") != 1 {
		t.Fatal("empty note block was rendered")
	}
	if strings.Contains(lesson, "](<legacy address>)") || !strings.Contains(lesson, "legacy address") {
		t.Fatal("invalid URL was not preserved as plain text")
	}
	source := exportFileContent(t, files, "source/stepik-cpp/README.md")
	if strings.Contains(source, "Дополнительно") {
		t.Fatal("empty source section was rendered")
	}

	got := exportGoldenText(files)
	want, err := os.ReadFile(filepath.Join("testdata", "export.golden"))
	if err != nil {
		t.Fatalf("read golden: %v", err)
	}
	if got != string(want) {
		index := firstDifference(got, string(want))
		start := max(0, index-40)
		gotEnd := min(len(got), index+80)
		wantEnd := min(len(want), index+80)
		t.Fatalf("export differs from golden at byte %d: got %q, want %q", index, got[start:gotEnd], want[start:wantEnd])
	}
}

func TestExportEnglishLabels(t *testing.T) {
	statusCases := []struct {
		name  string
		value wantstudyv1.LessonStatus
		want  string
	}{
		{name: "planned", value: wantstudyv1.LessonStatus_LESSON_STATUS_PLANNED, want: "Planned"},
		{name: "studying", value: wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING, want: "Studying"},
		{name: "homework", value: wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK, want: "Homework"},
		{name: "mastered", value: wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED, want: "Mastered"},
	}
	for _, test := range statusCases {
		t.Run("status/"+test.name, func(t *testing.T) {
			if got := lessonStatusLabel(test.value); got != test.want {
				t.Fatalf("lessonStatusLabel() = %q, want %q", got, test.want)
			}
		})
	}

	sourceCases := []struct {
		name  string
		value wantstudyv1.LearningSourceType
		want  string
	}{
		{name: "course", value: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_COURSE, want: "Course"},
		{name: "book", value: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_BOOK, want: "Book"},
		{name: "article", value: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_ARTICLE, want: "Article"},
		{name: "video", value: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_VIDEO, want: "Video"},
		{name: "other", value: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_OTHER, want: "Other"},
	}
	for _, test := range sourceCases {
		t.Run("source/"+test.name, func(t *testing.T) {
			if got := sourceTypeLabel(test.value); got != test.want {
				t.Fatalf("sourceTypeLabel() = %q, want %q", got, test.want)
			}
		})
	}

	blockCases := []struct {
		name  string
		value wantstudyv1.NoteBlockType
		want  string
	}{
		{name: "text", value: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_TEXT, want: ""},
		{name: "definition", value: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_DEFINITION, want: "📘 Definition"},
		{name: "claim", value: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_CLAIM, want: "💡 Claim"},
		{name: "quote", value: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUOTE, want: "💬 Quote"},
		{name: "example", value: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_EXAMPLE, want: "🧪 Example"},
		{name: "question", value: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUESTION, want: "❓ Question"},
		{name: "summary", value: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_SUMMARY, want: "🧭 Summary"},
	}
	for _, test := range blockCases {
		t.Run("block/"+test.name, func(t *testing.T) {
			if got := blockHeading(test.value); got != test.want {
				t.Fatalf("blockHeading() = %q, want %q", got, test.want)
			}
		})
	}

	relationCases := []struct {
		name        string
		value       wantstudyv1.ConceptRelationType
		want        string
		wantReverse string
	}{
		{name: "related", value: wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_RELATED_TO, want: "Related to", wantReverse: "Related to"},
		{name: "part", value: wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PART_OF, want: "Part of", wantReverse: "Contains"},
		{name: "prerequisite", value: wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR, want: "Prerequisite for", wantReverse: "Depends on"},
		{name: "contrasts", value: wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_CONTRASTS_WITH, want: "Contrasts with", wantReverse: "Contrasts with"},
		{name: "applies", value: wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_APPLIES_TO, want: "Applies to", wantReverse: "Applied here"},
	}
	for _, test := range relationCases {
		t.Run("relation/"+test.name, func(t *testing.T) {
			if got := relationTypeLabel(test.value); got != test.want {
				t.Fatalf("relationTypeLabel() = %q, want %q", got, test.want)
			}
			if got := relationTypeReverseLabel(test.value); got != test.wantReverse {
				t.Fatalf("relationTypeReverseLabel() = %q, want %q", got, test.wantReverse)
			}
		})
	}

	date := time.Date(2026, time.September, 15, 1, 30, 0, 0, time.FixedZone("test", 3*60*60))
	if got, want := formatDate(date.UnixMilli()), "14 Sep 2026"; got != want {
		t.Fatalf("formatDate() = %q, want %q", got, want)
	}
}

func firstDifference(left, right string) int {
	limit := min(len(left), len(right))
	for index := range limit {
		if left[index] != right[index] {
			return index
		}
	}
	return limit
}

func assertExportManifest(t *testing.T, files []renderedFile) {
	t.Helper()
	contentByPath := make(map[string]renderedFile, len(files))
	for index, file := range files {
		if index > 0 && files[index-1].path >= file.path {
			t.Fatalf("export paths are not sorted at %s", file.path)
		}
		contentByPath[file.path] = file
	}
	manifestFile, ok := contentByPath[".want-study/manifest.json"]
	if !ok {
		t.Fatal("manifest is missing")
	}
	var value manifest
	if err := json.Unmarshal(manifestFile.content, &value); err != nil {
		t.Fatalf("decode manifest: %v", err)
	}
	for _, entry := range value.Files {
		file, exists := contentByPath[entry.Path]
		if !exists || file.hash != entry.SHA256 {
			t.Fatalf("manifest hash mismatch for %s", entry.Path)
		}
	}
}

func exportFileContent(t *testing.T, files []renderedFile, path string) string {
	t.Helper()
	for _, file := range files {
		if file.path == path {
			return string(file.content)
		}
	}
	t.Fatalf("export file %s is missing", path)
	return ""
}

func exportGoldenText(files []renderedFile) string {
	var output strings.Builder
	for index, file := range files {
		fmt.Fprintf(&output, "===== %s =====\n%s", file.path, file.content)
		if index+1 < len(files) {
			output.WriteByte('\n')
		}
	}
	return strings.TrimRight(output.String(), "\n") + "\n"
}

func exportGoldenSnapshot() *exportSnapshot {
	started := time.Date(2026, time.September, 12, 0, 0, 0, 0, time.UTC).UnixMilli()
	due := time.Date(2026, time.September, 14, 0, 0, 0, 0, time.UTC).UnixMilli()
	mastered := time.Date(2026, time.September, 13, 0, 0, 0, 0, time.UTC).UnixMilli()
	sectionBasics := &wantstudyv1.Section{Id: "section-basics", Title: "Основы | владение"}
	sectionPractice := &wantstudyv1.Section{Id: "section-practice", Title: "Практика"}
	sectionEmpty := &wantstudyv1.Section{Id: "section-empty", Title: "Дополнительно"}
	plannedLesson := &wantstudyv1.Lesson{Id: "lesson-planned", Title: "Подготовка [среды]", SectionId: stringPointer("section-basics"), ExportSlug: "setup", SourcePosition: "1.1", Status: wantstudyv1.LessonStatus_LESSON_STATUS_PLANNED}
	studyingLesson := &wantstudyv1.Lesson{Id: "lesson-studying", Title: "Владение | ресурсами", SectionId: stringPointer("section-basics"), ExportSlug: "ownership", SourcePosition: "1.2", Url: "https://example.com/lesson?q=c%2B%2B", Status: wantstudyv1.LessonStatus_LESSON_STATUS_STUDYING, StartedAtEpochMillis: &started}
	homeworkLesson := &wantstudyv1.Lesson{Id: "lesson-homework", Title: "Практическая работа", SectionId: stringPointer("section-practice"), ExportSlug: "practice", SourcePosition: "1.3", Status: wantstudyv1.LessonStatus_LESSON_STATUS_HOMEWORK}
	masteredLesson := &wantstudyv1.Lesson{Id: "lesson-mastered", Title: "Глава 1", ExportSlug: "chapter-1", Status: wantstudyv1.LessonStatus_LESSON_STATUS_MASTERED, StartedAtEpochMillis: &started, MasteredAtEpochMillis: &mastered, Url: "legacy address"}
	course := &wantstudyv1.LearningSource{Id: "source-course", Type: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_COURSE, Title: "Stepik | Системный C++", Author: "Сергей [Автор]", Url: "https://example.com/course", ExportSlug: "stepik-cpp"}
	book := &wantstudyv1.LearningSource{Id: "source-book", Type: wantstudyv1.LearningSourceType_LEARNING_SOURCE_TYPE_BOOK, Title: "Книга [C++]", Url: "legacy address", ExportSlug: "cpp-book"}
	taskID := "task-done"
	conceptRAII := &wantstudyv1.Concept{Id: "concept-raii", Title: "RAII | владение", DescriptionMarkdown: "Ресурс живёт столько же, сколько владеющий объект.", ExportSlug: "raii", Aliases: []string{"Resource Acquisition", "Управление | ресурсом"}, BlockIds: []string{"block-definition"}}
	conceptMove := &wantstudyv1.Concept{Id: "concept-move", Title: "Move [semantics]", ExportSlug: "move", BlockIds: []string{"block-claim"}}

	return &exportSnapshot{
		study: &wantstudyv1.Study{Id: "study-id", Title: "C | C++ [курс]", Goal: "Разобраться в системном программировании.\n\nСобрать учебный проект.", ContentRevision: 42},
		sources: []*wantstudyv1.SourceNode{
			{Source: course, Sections: []*wantstudyv1.Section{sectionBasics, sectionPractice, sectionEmpty}, Lessons: []*wantstudyv1.Lesson{plannedLesson, studyingLesson, homeworkLesson}},
			{Source: book, Lessons: []*wantstudyv1.Lesson{masteredLesson}},
		},
		workspace: map[string]*wantstudyv1.LessonWorkspace{
			"lesson-planned":  {Lesson: plannedLesson},
			"lesson-homework": {Lesson: homeworkLesson},
			"lesson-mastered": {Lesson: masteredLesson},
			"lesson-studying": {
				Lesson: studyingLesson,
				Blocks: []*wantstudyv1.NoteBlock{
					{Id: "block-text", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_TEXT, Markdown: "Короткое введение с **акцентом**."},
					{Id: "block-definition", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_DEFINITION, Markdown: "**RAII** связывает ресурс со временем жизни объекта."},
					{Id: "block-claim", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_CLAIM, Markdown: "Перемещение передаёт владение без копирования."},
					{Id: "block-quote", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUOTE, Markdown: "> Владение должно быть очевидным."},
					{Id: "block-example", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_EXAMPLE, Markdown: "```cpp\nauto value = std::make_unique<int>(42);\n```", SourcePosition: "12:30", SourceUrl: "https://example.com/video?t=750"},
					{Id: "block-question", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_QUESTION, Markdown: "Когда нужен `std::move`?", SourceUrl: "legacy address"},
					{Id: "block-summary", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_SUMMARY, Markdown: "Ресурс имеет одного явного владельца."},
					{Id: "block-empty", Type: wantstudyv1.NoteBlockType_NOTE_BLOCK_TYPE_EXAMPLE, Markdown: " \n "},
				},
				Tasks: []*wantstudyv1.HomeworkTask{
					{Id: taskID, Status: wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_DONE, DueAtEpochMillis: &due, PromptMarkdown: "Реализовать `Owner<T>`:\n\n- запретить копирование;\n- добавить перемещение.", SolutionMarkdown: "```cpp\nOwner(Owner&&) = default;\n```"},
					{Id: "task-todo", Status: wantstudyv1.HomeworkStatus_HOMEWORK_STATUS_TODO, PromptMarkdown: "Объяснить правило пяти."},
				},
				Files: []*wantstudyv1.CodeFile{
					{RelativePath: "solution/main.cpp", Language: "cpp", Content: "int main() {}", HomeworkTaskId: &taskID},
					{RelativePath: "notes/read me.txt", Language: "text", Content: "ownership notes"},
				},
				ConceptIds: []string{"concept-raii", "concept-move"},
			},
		},
		concepts: []*wantstudyv1.Concept{conceptRAII, conceptMove},
		relations: []*wantstudyv1.ConceptRelation{
			{SourceConceptId: "concept-raii", TargetConceptId: "concept-move", Type: wantstudyv1.ConceptRelationType_CONCEPT_RELATION_TYPE_PREREQUISITE_FOR},
		},
		material: progressCount{completed: 1, total: 4},
		homework: progressCount{completed: 1, total: 2},
	}
}

func stringPointer(value string) *string {
	return &value
}
