part of 'controller.dart';

sealed class CatalogEventV2 extends Equatable {
  const CatalogEventV2();
}

final class _CatalogStartedV2 extends CatalogEventV2 {
  const _CatalogStartedV2();

  @override
  List<Object?> get props => const [];
}

final class CatalogStudySelectedV2 extends CatalogEventV2 {
  final StudyV1 study;

  const CatalogStudySelectedV2(this.study);

  @override
  List<Object?> get props => [study.id];
}

final class CatalogStudyCreatedV2 extends CatalogEventV2 {
  final StudyV1 study;

  const CatalogStudyCreatedV2(this.study);

  @override
  List<Object?> get props => [study.id, study.version, _studyEventHash(study)];
}

final class CatalogStudyUpdatedV2 extends CatalogEventV2 {
  final StudyV1 study;

  const CatalogStudyUpdatedV2(this.study);

  @override
  List<Object?> get props => [study.id, study.version, _studyEventHash(study)];
}

final class CatalogStudyArchiveChangedV2 extends CatalogEventV2 {
  final StudyV1 study;

  const CatalogStudyArchiveChangedV2(this.study);

  @override
  List<Object?> get props => [study.id, study.version, study.isArchived];
}

final class CatalogSourceCreatedV2 extends CatalogEventV2 {
  final LearningSourceV1 source;

  const CatalogSourceCreatedV2(this.source);

  @override
  List<Object?> get props => [
    source.id,
    source.version,
    _sourceEventHash(source),
  ];
}

final class CatalogSourceUpdatedV2 extends CatalogEventV2 {
  final LearningSourceV1 source;

  const CatalogSourceUpdatedV2(this.source);

  @override
  List<Object?> get props => [
    source.id,
    source.version,
    _sourceEventHash(source),
  ];
}

final class CatalogSourceArchiveChangedV2 extends CatalogEventV2 {
  final LearningSourceV1 source;

  const CatalogSourceArchiveChangedV2(this.source);

  @override
  List<Object?> get props => [source.id, source.version, source.isArchived];
}

final class CatalogSectionCreatedV2 extends CatalogEventV2 {
  final SectionV1 section;

  const CatalogSectionCreatedV2(this.section);

  @override
  List<Object?> get props => [
    section.id,
    section.version,
    _sectionEventHash(section),
  ];
}

final class CatalogSectionUpdatedV2 extends CatalogEventV2 {
  final SectionV1 section;

  const CatalogSectionUpdatedV2(this.section);

  @override
  List<Object?> get props => [
    section.id,
    section.version,
    _sectionEventHash(section),
  ];
}

final class CatalogSectionArchiveChangedV2 extends CatalogEventV2 {
  final SectionV1 section;

  const CatalogSectionArchiveChangedV2(this.section);

  @override
  List<Object?> get props => [section.id, section.version, section.isArchived];
}

final class CatalogLessonCreatedV2 extends CatalogEventV2 {
  final LessonV1 lesson;

  const CatalogLessonCreatedV2(this.lesson);

  @override
  List<Object?> get props => [
    lesson.id,
    lesson.version,
    _lessonEventHash(lesson),
  ];
}

final class CatalogLessonUpdatedV2 extends CatalogEventV2 {
  final LessonV1 lesson;

  const CatalogLessonUpdatedV2(this.lesson);

  @override
  List<Object?> get props => [
    lesson.id,
    lesson.version,
    _lessonEventHash(lesson),
  ];
}

final class CatalogLessonArchiveChangedV2 extends CatalogEventV2 {
  final LessonV1 lesson;

  const CatalogLessonArchiveChangedV2(this.lesson);

  @override
  List<Object?> get props => [lesson.id, lesson.version, lesson.isArchived];
}

final class CatalogSourceMoveRequestedV2 extends CatalogEventV2 {
  final LearningSourceV1 source;
  final int offset;

  const CatalogSourceMoveRequestedV2(this.source, this.offset);

  @override
  List<Object?> get props => [source.id, source.version, offset];
}

final class CatalogSectionMoveRequestedV2 extends CatalogEventV2 {
  final SectionV1 section;
  final int offset;

  const CatalogSectionMoveRequestedV2(this.section, this.offset);

  @override
  List<Object?> get props => [section.id, section.version, offset];
}

final class CatalogLessonMoveRequestedV2 extends CatalogEventV2 {
  final LessonV1 lesson;
  final int offset;

  const CatalogLessonMoveRequestedV2(this.lesson, this.offset);

  @override
  List<Object?> get props => [lesson.id, lesson.version, offset];
}

final class CatalogLessonStatusChangedV2 extends CatalogEventV2 {
  final LessonStatusChangeV1 change;

  const CatalogLessonStatusChangedV2(this.change);

  @override
  List<Object?> get props => [change];
}

int _studyEventHash(StudyV1 value) => Object.hash(
  value.title,
  value.goal,
  value.localRepositoryPath,
  value.version,
  value.contentRevision,
  value.isArchived,
);

int _sourceEventHash(LearningSourceV1 value) => Object.hash(
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

int _sectionEventHash(SectionV1 value) => Object.hash(
  value.studyId,
  value.sourceId,
  value.title,
  value.position,
  value.version,
  value.isArchived,
);

int _lessonEventHash(LessonV1 value) => Object.hashAll([
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
]);
