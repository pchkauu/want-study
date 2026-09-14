package importer

import (
	"fmt"
	"strings"
	"testing"
)

func TestParseCppStudySnapshot(t *testing.T) {
	counts := []int{9, 8, 0, 6}
	var input strings.Builder
	for lessonIndex, taskCount := range counts {
		position := fmt.Sprintf("1.%d", lessonIndex+1)
		fmt.Fprintf(&input, "#### %s Lesson %d\n", position, lessonIndex+1)
		input.WriteString("Дата прохождения: 09.03.2025, 14.06.5785\n\n")
		if taskCount > 0 {
			input.WriteString("##### 🔬 Домашнее задание\n\n")
			for taskIndex := range taskCount {
				mark := " "
				if lessonIndex == 0 && taskIndex == 0 {
					mark = "x"
				}
				prompt := fmt.Sprintf("Task %d", taskIndex+1)
				if lessonIndex == 1 && taskIndex == 0 {
					prompt = "[broken]([https://example.test](https://example.test))"
				}
				fmt.Fprintf(&input, "- [%s] %s\n", mark, prompt)
			}
			input.WriteString("\n##### 🏆 Выполненные задания\n\n")
			input.WriteString("💫 Дедлайн: 13.02.2025 (13.06.5785)\n\n")
		}
		input.WriteString("##### 📝 Конспект\n\nOriginal note\n\n---\n")
	}

	snapshot, err := Parse(input.String(), "int main(void) {}\n")
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	if len(snapshot.Lessons) != 4 || countTasks(snapshot.Lessons) != 23 || countDone(snapshot.Lessons) != 1 {
		t.Fatalf("unexpected counts: lessons=%d tasks=%d done=%d", len(snapshot.Lessons), countTasks(snapshot.Lessons), countDone(snapshot.Lessons))
	}
	if snapshot.Lessons[2].Status != "mastered" || snapshot.Lessons[3].CodeFile == "" {
		t.Fatalf("status or code file mapping failed")
	}
	if !strings.Contains(snapshot.Lessons[0].Note, "5785") || len(snapshot.Warnings) == 0 {
		t.Fatalf("source anomalies were not preserved and reported")
	}
}
