import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class LessonWorkspaceV1 extends Equatable {
  final LessonV1 lesson;
  final List<NoteBlockV1> block;
  final List<HomeworkTaskV1> task;
  final List<CodeFileV1> file;
  final List<String> conceptId;

  const LessonWorkspaceV1._({
    required this.lesson,
    required this.block,
    required this.task,
    required this.file,
    required this.conceptId,
  });

  factory LessonWorkspaceV1({
    required LessonV1 lesson,
    Iterable<NoteBlockV1> block = const [],
    Iterable<HomeworkTaskV1> task = const [],
    Iterable<CodeFileV1> file = const [],
    Iterable<String> conceptId = const [],
  }) {
    final blocks = List<NoteBlockV1>.unmodifiable(block);
    final tasks = List<HomeworkTaskV1>.unmodifiable(task);
    final files = List<CodeFileV1>.unmodifiable(file);
    final conceptIds = List<String>.unmodifiable(conceptId);
    if (blocks.any(
          (value) =>
              value.studyId != lesson.studyId || value.lessonId != lesson.id,
        ) ||
        blocks.map((value) => value.id).toSet().length != blocks.length) {
      throw const ValidationErrorV1('block');
    }
    if (tasks.any(
          (value) =>
              value.studyId != lesson.studyId || value.lessonId != lesson.id,
        ) ||
        tasks.map((value) => value.id).toSet().length != tasks.length) {
      throw const ValidationErrorV1('task');
    }
    if (files.any(
          (value) =>
              value.studyId != lesson.studyId || value.lessonId != lesson.id,
        ) ||
        files.map((value) => value.id).toSet().length != files.length) {
      throw const ValidationErrorV1('file');
    }
    final taskIds = tasks.map((value) => value.id).toSet();
    if (files.any(
      (value) =>
          value.homeworkTaskId != null &&
          !taskIds.contains(value.homeworkTaskId),
    )) {
      throw const ValidationErrorV1('homeworkTaskId');
    }
    if (conceptIds.any((value) => value.trim().isEmpty) ||
        conceptIds.toSet().length != conceptIds.length) {
      throw const ValidationErrorV1('conceptId');
    }
    return LessonWorkspaceV1._(
      lesson: lesson,
      block: blocks,
      task: tasks,
      file: files,
      conceptId: conceptIds,
    );
  }

  LessonWorkspaceV1 copyWith({
    LessonV1? lesson,
    Iterable<NoteBlockV1>? block,
    Iterable<HomeworkTaskV1>? task,
    Iterable<CodeFileV1>? file,
    Iterable<String>? conceptId,
  }) => LessonWorkspaceV1(
    lesson: lesson ?? this.lesson,
    block: block ?? this.block,
    task: task ?? this.task,
    file: file ?? this.file,
    conceptId: conceptId ?? this.conceptId,
  );

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
