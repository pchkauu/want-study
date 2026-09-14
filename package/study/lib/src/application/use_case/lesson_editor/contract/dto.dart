import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class LessonWorkspaceParamsV1 extends Equatable {
  final LessonV1 lesson;

  const LessonWorkspaceParamsV1(this.lesson);

  @override
  List<Object?> get props => [lesson.id];
}

final class LessonMutationParamsV1 extends Equatable {
  final LessonV1 lesson;
  final LessonMutationV1 mutation;

  const LessonMutationParamsV1({required this.lesson, required this.mutation});

  @override
  List<Object?> get props => [lesson.id, mutation];
}

final class LessonSaveBlockParamsV1 extends Equatable {
  final NoteBlockV1 block;

  const LessonSaveBlockParamsV1(this.block);

  @override
  List<Object?> get props => [_blockState(block)];
}

final class LessonConceptSearchParamsV1 extends Equatable {
  final StudyV1 study;
  final ConceptSearchV1 search;

  const LessonConceptSearchParamsV1({
    required this.study,
    required this.search,
  });

  @override
  List<Object?> get props => [study.id, search];
}

enum ConceptBlockLinkActionV1 { link, unlink }

final class LessonBlockConceptParamsV1 extends Equatable {
  final ConceptV1 concept;
  final NoteBlockV1 block;
  final ConceptBlockLinkActionV1 action;

  const LessonBlockConceptParamsV1({
    required this.concept,
    required this.block,
    required this.action,
  });

  @override
  List<Object?> get props => [concept.id, _blockState(block), action];
}

final class LessonWorkspaceResultV1 extends Equatable {
  final LessonWorkspaceV1 workspace;

  const LessonWorkspaceResultV1(this.workspace);

  @override
  List<Object?> get props => [workspace];
}

final class LessonBlockSaveResultV1 extends Equatable {
  final NoteBlockV1 block;

  const LessonBlockSaveResultV1(this.block);

  @override
  List<Object?> get props => [_blockState(block)];
}

final class LessonConceptSearchResultV1 extends Equatable {
  final List<ConceptV1> concept;

  LessonConceptSearchResultV1(Iterable<ConceptV1> concept)
    : concept = List.unmodifiable(concept);

  @override
  List<Object?> get props => [
    [for (final value in concept) _conceptState(value)],
  ];
}

final class LessonBlockConceptResultV1 extends Equatable {
  final ConceptV1 concept;

  const LessonBlockConceptResultV1(this.concept);

  @override
  List<Object?> get props => [_conceptState(concept)];
}

sealed class LessonMutationV1 extends Equatable {
  const LessonMutationV1();
}

final class LessonCreateBlockV1 extends LessonMutationV1 {
  final NoteBlockV1 block;

  const LessonCreateBlockV1(this.block);

  @override
  List<Object?> get props => [_blockState(block)];
}

final class LessonDeleteBlockV1 extends LessonMutationV1 {
  final NoteBlockV1 block;

  const LessonDeleteBlockV1(this.block);

  @override
  List<Object?> get props => [_blockState(block)];
}

final class LessonCreateTaskV1 extends LessonMutationV1 {
  final HomeworkTaskV1 task;

  const LessonCreateTaskV1(this.task);

  @override
  List<Object?> get props => [_taskState(task)];
}

final class LessonUpdateTaskV1 extends LessonMutationV1 {
  final HomeworkTaskV1 task;

  const LessonUpdateTaskV1(this.task);

  @override
  List<Object?> get props => [_taskState(task)];
}

final class LessonDeleteTaskV1 extends LessonMutationV1 {
  final HomeworkTaskV1 task;

  const LessonDeleteTaskV1(this.task);

  @override
  List<Object?> get props => [_taskState(task)];
}

final class LessonCreateFileV1 extends LessonMutationV1 {
  final CodeFileV1 file;

  const LessonCreateFileV1(this.file);

  @override
  List<Object?> get props => [_fileState(file)];
}

final class LessonUpdateFileV1 extends LessonMutationV1 {
  final CodeFileV1 file;

  const LessonUpdateFileV1(this.file);

  @override
  List<Object?> get props => [_fileState(file)];
}

final class LessonDeleteFileV1 extends LessonMutationV1 {
  final CodeFileV1 file;

  const LessonDeleteFileV1(this.file);

  @override
  List<Object?> get props => [_fileState(file)];
}

final class LessonReorderContentV1 extends LessonMutationV1 {
  final List<ReorderItemV1> block;
  final List<ReorderItemV1> task;

  LessonReorderContentV1({
    Iterable<ReorderItemV1> block = const [],
    Iterable<ReorderItemV1> task = const [],
  }) : block = List.unmodifiable(block),
       task = List.unmodifiable(task);

  @override
  List<Object?> get props => [block, task];
}

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

Object _conceptState(ConceptV1 value) => (
  value.id,
  value.studyId,
  value.title,
  value.descriptionMarkdown,
  value.exportSlug,
  value.aliases,
  value.blockIds,
  value.version,
  value.isArchived,
);
