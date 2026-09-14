import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/learning_source.dart';
import 'package:study/src/domain/model/lesson.dart';
import 'package:study/src/domain/model/section.dart';
import 'package:study/src/domain/model/study.dart';

final class LearningSourceNodeV1 extends Equatable {
  final LearningSourceV1 source;
  final List<SectionV1> section;
  final List<LessonV1> lesson;

  LearningSourceNodeV1({
    required this.source,
    Iterable<SectionV1> section = const [],
    Iterable<LessonV1> lesson = const [],
  }) : section = List.unmodifiable(section),
       lesson = List.unmodifiable(lesson);

  @override
  List<Object?> get props => [
    _sourceState(source),
    [for (final value in section) _sectionState(value)],
    [for (final value in lesson) _lessonState(value)],
  ];

  @override
  String toString() =>
      'LearningSourceNodeV1(sourceId: ${source.id}, '
      'section: ${section.length}, lesson: ${lesson.length})';

  String toDebugString() => toString();
}

final class MaterialTreeV1 extends Equatable {
  final StudyV1 study;
  final List<LearningSourceNodeV1> source;

  MaterialTreeV1({
    required this.study,
    Iterable<LearningSourceNodeV1> source = const [],
  }) : source = List.unmodifiable(source);

  @override
  List<Object?> get props => [_studyState(study), source];

  @override
  String toString() =>
      'MaterialTreeV1(studyId: ${study.id}, source: ${source.length})';

  String toDebugString() => toString();
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
