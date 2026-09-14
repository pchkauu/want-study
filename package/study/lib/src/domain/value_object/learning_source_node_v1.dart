import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class LearningSourceNodeV1 extends Equatable {
  final LearningSourceV1 source;
  final List<SectionV1> section;
  final List<LessonV1> lesson;

  const LearningSourceNodeV1._({
    required this.source,
    required this.section,
    required this.lesson,
  });

  factory LearningSourceNodeV1({
    required LearningSourceV1 source,
    Iterable<SectionV1> section = const [],
    Iterable<LessonV1> lesson = const [],
  }) {
    final sections = List<SectionV1>.unmodifiable(section);
    final lessons = List<LessonV1>.unmodifiable(lesson);
    if (sections.any(
          (value) =>
              value.studyId != source.studyId || value.sourceId != source.id,
        ) ||
        sections.map((value) => value.id).toSet().length != sections.length) {
      throw const ValidationErrorV1('section');
    }
    if (lessons.any(
          (value) =>
              value.studyId != source.studyId || value.sourceId != source.id,
        ) ||
        lessons.map((value) => value.id).toSet().length != lessons.length) {
      throw const ValidationErrorV1('lesson');
    }
    return LearningSourceNodeV1._(
      source: source,
      section: sections,
      lesson: lessons,
    );
  }

  LearningSourceNodeV1 copyWith({
    LearningSourceV1? source,
    Iterable<SectionV1>? section,
    Iterable<LessonV1>? lesson,
  }) => LearningSourceNodeV1(
    source: source ?? this.source,
    section: section ?? this.section,
    lesson: lesson ?? this.lesson,
  );

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
