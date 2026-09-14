part of 'controller.dart';

sealed class LessonEditorEventV2 extends Equatable {
  const LessonEditorEventV2();
}

final class LessonEditorStartedV2 extends LessonEditorEventV2 {
  final LessonV1 lesson;

  const LessonEditorStartedV2(this.lesson);

  @override
  List<Object?> get props => [lesson.id, lesson.version];
}

final class LessonEditorBlockChangedV2 extends LessonEditorEventV2 {
  final NoteBlockV1 block;

  const LessonEditorBlockChangedV2(this.block);

  @override
  List<Object?> get props => [block.id, block.version, _blockEventHash(block)];
}

final class LessonEditorBlockAddedV2 extends LessonEditorEventV2 {
  final NoteBlockV1 block;

  const LessonEditorBlockAddedV2(this.block);

  @override
  List<Object?> get props => [block.id, block.version, _blockEventHash(block)];
}

final class LessonEditorTaskChangedV2 extends LessonEditorEventV2 {
  final HomeworkTaskV1 task;

  const LessonEditorTaskChangedV2(this.task);

  @override
  List<Object?> get props => [task.id, task.version, _taskEventHash(task)];
}

final class LessonEditorTaskAddedV2 extends LessonEditorEventV2 {
  final HomeworkTaskV1 task;

  const LessonEditorTaskAddedV2(this.task);

  @override
  List<Object?> get props => [task.id, task.version, _taskEventHash(task)];
}

final class LessonEditorFileChangedV2 extends LessonEditorEventV2 {
  final CodeFileV1 file;

  const LessonEditorFileChangedV2(this.file);

  @override
  List<Object?> get props => [file.id, file.version, _fileEventHash(file)];
}

final class LessonEditorFileAddedV2 extends LessonEditorEventV2 {
  final CodeFileV1 file;

  const LessonEditorFileAddedV2(this.file);

  @override
  List<Object?> get props => [file.id, file.version, _fileEventHash(file)];
}

final class LessonEditorBlockDeletedV2 extends LessonEditorEventV2 {
  final NoteBlockV1 block;

  const LessonEditorBlockDeletedV2(this.block);

  @override
  List<Object?> get props => [block.id, block.version];
}

final class LessonEditorTaskDeletedV2 extends LessonEditorEventV2 {
  final HomeworkTaskV1 task;

  const LessonEditorTaskDeletedV2(this.task);

  @override
  List<Object?> get props => [task.id, task.version];
}

final class LessonEditorFileDeletedV2 extends LessonEditorEventV2 {
  final CodeFileV1 file;

  const LessonEditorFileDeletedV2(this.file);

  @override
  List<Object?> get props => [file.id, file.version];
}

final class LessonEditorBlockMoveRequestedV2 extends LessonEditorEventV2 {
  final NoteBlockV1 block;
  final int offset;

  const LessonEditorBlockMoveRequestedV2(this.block, this.offset);

  @override
  List<Object?> get props => [block.id, block.version, offset];
}

final class LessonEditorTaskMoveRequestedV2 extends LessonEditorEventV2 {
  final HomeworkTaskV1 task;
  final int offset;

  const LessonEditorTaskMoveRequestedV2(this.task, this.offset);

  @override
  List<Object?> get props => [task.id, task.version, offset];
}

final class LessonEditorRetrySaveV2 extends LessonEditorEventV2 {
  const LessonEditorRetrySaveV2();

  @override
  List<Object?> get props => const [];
}

final class LessonEditorDiscardV2 extends LessonEditorEventV2 {
  const LessonEditorDiscardV2();

  @override
  List<Object?> get props => const [];
}

final class LessonEditorNavigationRequestedV2 extends LessonEditorEventV2 {
  const LessonEditorNavigationRequestedV2();

  @override
  List<Object?> get props => const [];
}

sealed class _LessonEditorWriteV2 extends LessonEditorEventV2 {
  final int epoch;

  const _LessonEditorWriteV2({required this.epoch});
}

final class _LessonEditorSaveBlockV2 extends _LessonEditorWriteV2 {
  final String blockId;
  final int draftRevision;

  const _LessonEditorSaveBlockV2({
    required super.epoch,
    required this.blockId,
    required this.draftRevision,
  });

  @override
  List<Object?> get props => [epoch, blockId, draftRevision];
}

final class _LessonEditorMutationV2 extends _LessonEditorWriteV2 {
  final LessonEditorEventV2 event;

  const _LessonEditorMutationV2({required super.epoch, required this.event});

  @override
  List<Object?> get props => [epoch, event];
}

final class _LessonEditorReloadV2 extends _LessonEditorWriteV2 {
  const _LessonEditorReloadV2({required super.epoch});

  @override
  List<Object?> get props => [epoch];
}

int _blockEventHash(NoteBlockV1 value) => Object.hash(
  value.studyId,
  value.lessonId,
  value.type,
  value.markdown,
  value.sourceUrl,
  value.sourcePosition,
  value.position,
  value.version,
);

int _taskEventHash(HomeworkTaskV1 value) => Object.hash(
  value.studyId,
  value.lessonId,
  value.promptMarkdown,
  value.solutionMarkdown,
  value.status,
  value.dueAt,
  value.position,
  value.version,
);

int _fileEventHash(CodeFileV1 value) => Object.hash(
  value.studyId,
  value.lessonId,
  value.homeworkTaskId,
  value.relativePath,
  value.language,
  value.content,
  value.version,
);
