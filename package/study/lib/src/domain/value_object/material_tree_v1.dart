import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class MaterialTreeV1 extends Equatable {
  final StudyV1 study;
  final List<LearningSourceNodeV1> source;

  const MaterialTreeV1._({required this.study, required this.source});

  factory MaterialTreeV1({
    required StudyV1 study,
    Iterable<LearningSourceNodeV1> source = const [],
  }) {
    final sources = List<LearningSourceNodeV1>.unmodifiable(source);
    if (sources.any((value) => value.source.studyId != study.id) ||
        sources.map((value) => value.source.id).toSet().length !=
            sources.length) {
      throw const ValidationErrorV1('source');
    }
    return MaterialTreeV1._(study: study, source: sources);
  }

  MaterialTreeV1 copyWith({
    StudyV1? study,
    Iterable<LearningSourceNodeV1>? source,
  }) =>
      MaterialTreeV1(study: study ?? this.study, source: source ?? this.source);

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
