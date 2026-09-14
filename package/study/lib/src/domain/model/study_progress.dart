import 'package:equatable/equatable.dart';
import 'package:study/src/domain/error/study_error.dart';

final class ProgressIndicatorV1 extends Equatable {
  final int completed;
  final int total;

  const ProgressIndicatorV1._({required this.completed, required this.total});

  factory ProgressIndicatorV1({required int completed, required int total}) {
    if (completed < 0 || total < 0 || completed > total) {
      throw const ValidationErrorV1('progress');
    }
    return ProgressIndicatorV1._(completed: completed, total: total);
  }

  double get fraction => total == 0 ? 0 : completed / total;

  @override
  List<Object?> get props => [completed, total];
}

final class StudyProgressV1 extends Equatable {
  final ProgressIndicatorV1 material;
  final ProgressIndicatorV1 homework;
  final Map<String, int> lessonStatusCount;
  final int studyRevision;

  StudyProgressV1({
    required this.material,
    required this.homework,
    required Map<String, int> lessonStatusCount,
    required this.studyRevision,
  }) : lessonStatusCount = Map.unmodifiable(lessonStatusCount);

  @override
  List<Object?> get props => [
    material,
    homework,
    lessonStatusCount,
    studyRevision,
  ];
}
