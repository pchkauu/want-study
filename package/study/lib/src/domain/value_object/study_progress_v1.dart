import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class StudyProgressV1 extends Equatable {
  final ProgressIndicatorV1 material;
  final ProgressIndicatorV1 homework;
  final Map<String, int> lessonStatusCount;
  final int studyRevision;

  const StudyProgressV1._({
    required this.material,
    required this.homework,
    required this.lessonStatusCount,
    required this.studyRevision,
  });

  factory StudyProgressV1({
    required ProgressIndicatorV1 material,
    required ProgressIndicatorV1 homework,
    required Map<String, int> lessonStatusCount,
    required int studyRevision,
  }) {
    final statusCount = Map<String, int>.unmodifiable(lessonStatusCount);
    if (studyRevision < 1) throw const ValidationErrorV1('studyRevision');
    if (statusCount.keys.any((value) => value.trim().isEmpty) ||
        statusCount.values.any((value) => value < 0)) {
      throw const ValidationErrorV1('lessonStatusCount');
    }
    return StudyProgressV1._(
      material: material,
      homework: homework,
      lessonStatusCount: statusCount,
      studyRevision: studyRevision,
    );
  }

  StudyProgressV1 copyWith({
    ProgressIndicatorV1? material,
    ProgressIndicatorV1? homework,
    Map<String, int>? lessonStatusCount,
    int? studyRevision,
  }) => StudyProgressV1(
    material: material ?? this.material,
    homework: homework ?? this.homework,
    lessonStatusCount: lessonStatusCount ?? this.lessonStatusCount,
    studyRevision: studyRevision ?? this.studyRevision,
  );

  @override
  List<Object?> get props => [
    material,
    homework,
    lessonStatusCount,
    studyRevision,
  ];

  @override
  String toString() =>
      'StudyProgressV1(material: $material, homework: $homework, '
      'statusCount: ${lessonStatusCount.length}, studyRevision: $studyRevision)';

  String toDebugString() => toString();
}
