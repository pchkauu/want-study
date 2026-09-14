import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/code_file.dart';
import 'package:study/src/domain/model/homework_task.dart';
import 'package:study/src/domain/model/lesson.dart';
import 'package:study/src/domain/model/note_block.dart';

final class LessonWorkspaceV1 extends Equatable {
  final LessonV1 lesson;
  final List<NoteBlockV1> block;
  final List<HomeworkTaskV1> task;
  final List<CodeFileV1> file;
  final List<String> conceptId;

  LessonWorkspaceV1({
    required this.lesson,
    Iterable<NoteBlockV1> block = const [],
    Iterable<HomeworkTaskV1> task = const [],
    Iterable<CodeFileV1> file = const [],
    Iterable<String> conceptId = const [],
  }) : block = List.unmodifiable(block),
       task = List.unmodifiable(task),
       file = List.unmodifiable(file),
       conceptId = List.unmodifiable(conceptId);

  LessonWorkspaceV1 copyWith({
    LessonV1? lesson,
    Iterable<NoteBlockV1>? block,
    Iterable<HomeworkTaskV1>? task,
    Iterable<CodeFileV1>? file,
    Iterable<String>? conceptId,
  }) {
    return LessonWorkspaceV1(
      lesson: lesson ?? this.lesson,
      block: block ?? this.block,
      task: task ?? this.task,
      file: file ?? this.file,
      conceptId: conceptId ?? this.conceptId,
    );
  }

  @override
  List<Object?> get props => [
    _lessonState(lesson),
    [for (final value in block) _blockState(value)],
    [for (final value in task) _taskState(value)],
    [for (final value in file) _fileState(value)],
    conceptId,
  ];

  @override
  String toString() =>
      'LessonWorkspaceV1(lesson: ${lesson.id}, block: ${block.length}, '
      'task: ${task.length}, file: ${file.length}, '
      'conceptId: ${conceptId.length})';

  String toDebugString() => toString();
}

Object _lessonState(LessonV1 value) => (
  value.id,
  value.studyId,
  value.sourceId,
  value.sectionId,
  value.title,
  value.url,
  value.sourcePosition,
  value.exportSlug,
  value.position,
  value.status,
  value.startedAt,
  value.masteredAt,
  value.version,
  value.isArchived,
);

Object _blockState(NoteBlockV1 value) => (
  value.id,
  value.studyId,
  value.lessonId,
  value.type,
  value.markdown,
  value.sourceUrl,
  value.sourcePosition,
  value.position,
  value.version,
);

Object _taskState(HomeworkTaskV1 value) => (
  value.id,
  value.studyId,
  value.lessonId,
  value.promptMarkdown,
  value.solutionMarkdown,
  value.status,
  value.dueAt,
  value.position,
  value.version,
);

Object _fileState(CodeFileV1 value) => (
  value.id,
  value.studyId,
  value.lessonId,
  value.homeworkTaskId,
  value.relativePath,
  value.language,
  value.content,
  value.version,
);
