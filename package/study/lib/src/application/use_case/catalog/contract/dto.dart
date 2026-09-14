import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class CatalogLoadParamsV1 extends Equatable {
  final StudyV1? preferredStudy;

  const CatalogLoadParamsV1({this.preferredStudy});

  @override
  List<Object?> get props => [preferredStudy?.id];
}

final class CatalogMutationParamsV1 extends Equatable {
  final StudyV1? selectedStudy;
  final CatalogMutationV1 mutation;

  const CatalogMutationParamsV1({
    required this.selectedStudy,
    required this.mutation,
  });

  @override
  List<Object?> get props => [selectedStudy?.id, mutation];
}

final class CatalogPickRepositoryParamsV1 extends Equatable {
  const CatalogPickRepositoryParamsV1();

  @override
  List<Object?> get props => const [];
}

final class CatalogSnapshotV1 extends Equatable {
  final List<StudyV1> study;
  final StudyV1? selectedStudy;
  final MaterialTreeV1? tree;
  final StudyProgressV1? progress;

  CatalogSnapshotV1({
    Iterable<StudyV1> study = const [],
    this.selectedStudy,
    this.tree,
    this.progress,
  }) : study = List.unmodifiable(study);

  CatalogSnapshotV1 copyWith({
    Iterable<StudyV1>? study,
    StudyV1? Function()? selectedStudy,
    MaterialTreeV1? Function()? tree,
    StudyProgressV1? Function()? progress,
  }) => CatalogSnapshotV1(
    study: study ?? this.study,
    selectedStudy: selectedStudy == null ? this.selectedStudy : selectedStudy(),
    tree: tree == null ? this.tree : tree(),
    progress: progress == null ? this.progress : progress(),
  );

  @override
  List<Object?> get props => [
    [for (final value in study) _studyState(value)],
    if (selectedStudy == null) null else _studyState(selectedStudy!),
    tree,
    progress,
  ];
}

sealed class CatalogMutationV1 extends Equatable {
  const CatalogMutationV1();
}

final class CatalogCreateStudyV1 extends CatalogMutationV1 {
  final StudyV1 study;

  const CatalogCreateStudyV1(this.study);

  @override
  List<Object?> get props => [_studyState(study)];
}

final class CatalogUpdateStudyV1 extends CatalogMutationV1 {
  final StudyV1 study;

  const CatalogUpdateStudyV1(this.study);

  @override
  List<Object?> get props => [_studyState(study)];
}

final class CatalogArchiveStudyV1 extends CatalogMutationV1 {
  final StudyV1 study;

  const CatalogArchiveStudyV1(this.study);

  @override
  List<Object?> get props => [_studyState(study)];
}

final class CatalogCreateSourceV1 extends CatalogMutationV1 {
  final LearningSourceV1 source;

  const CatalogCreateSourceV1(this.source);

  @override
  List<Object?> get props => [_sourceState(source)];
}

final class CatalogUpdateSourceV1 extends CatalogMutationV1 {
  final LearningSourceV1 source;

  const CatalogUpdateSourceV1(this.source);

  @override
  List<Object?> get props => [_sourceState(source)];
}

final class CatalogArchiveSourceV1 extends CatalogMutationV1 {
  final LearningSourceV1 source;

  const CatalogArchiveSourceV1(this.source);

  @override
  List<Object?> get props => [_sourceState(source)];
}

final class CatalogCreateSectionV1 extends CatalogMutationV1 {
  final SectionV1 section;

  const CatalogCreateSectionV1(this.section);

  @override
  List<Object?> get props => [_sectionState(section)];
}

final class CatalogUpdateSectionV1 extends CatalogMutationV1 {
  final SectionV1 section;

  const CatalogUpdateSectionV1(this.section);

  @override
  List<Object?> get props => [_sectionState(section)];
}

final class CatalogArchiveSectionV1 extends CatalogMutationV1 {
  final SectionV1 section;

  const CatalogArchiveSectionV1(this.section);

  @override
  List<Object?> get props => [_sectionState(section)];
}

final class CatalogCreateLessonV1 extends CatalogMutationV1 {
  final LessonV1 lesson;

  const CatalogCreateLessonV1(this.lesson);

  @override
  List<Object?> get props => [_lessonState(lesson)];
}

final class CatalogUpdateLessonV1 extends CatalogMutationV1 {
  final LessonV1 lesson;

  const CatalogUpdateLessonV1(this.lesson);

  @override
  List<Object?> get props => [_lessonState(lesson)];
}

final class CatalogArchiveLessonV1 extends CatalogMutationV1 {
  final LessonV1 lesson;

  const CatalogArchiveLessonV1(this.lesson);

  @override
  List<Object?> get props => [_lessonState(lesson)];
}

final class CatalogChangeLessonStatusV1 extends CatalogMutationV1 {
  final LessonStatusChangeV1 change;

  const CatalogChangeLessonStatusV1(this.change);

  @override
  List<Object?> get props => [change];
}

final class CatalogReorderMaterialV1 extends CatalogMutationV1 {
  final StudyV1 study;
  final List<ReorderItemV1> source;
  final List<ReorderItemV1> section;
  final List<ReorderItemV1> lesson;

  CatalogReorderMaterialV1({
    required this.study,
    Iterable<ReorderItemV1> source = const [],
    Iterable<ReorderItemV1> section = const [],
    Iterable<ReorderItemV1> lesson = const [],
  }) : source = List.unmodifiable(source),
       section = List.unmodifiable(section),
       lesson = List.unmodifiable(lesson);

  @override
  List<Object?> get props => [_studyState(study), source, section, lesson];
}

Object _studyState(StudyV1 value) => (
  value.id,
  value.title,
  value.goal,
  value.localRepositoryPath,
  value.version,
  value.contentRevision,
  value.isArchived,
);

Object _sourceState(LearningSourceV1 value) => (
  value.id,
  value.studyId,
  value.type,
  value.title,
  value.author,
  value.url,
  value.exportSlug,
  value.position,
  value.version,
  value.isArchived,
);

Object _sectionState(SectionV1 value) => (
  value.id,
  value.studyId,
  value.sourceId,
  value.title,
  value.position,
  value.version,
  value.isArchived,
);

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
