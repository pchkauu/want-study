import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class LessonStatusChangeV1 extends Equatable {
  final LessonV1 lesson;
  final LessonStatusV1 status;
  final bool acknowledgeOpenHomework;

  const LessonStatusChangeV1._({
    required this.lesson,
    required this.status,
    required this.acknowledgeOpenHomework,
  });

  factory LessonStatusChangeV1({
    required LessonV1 lesson,
    required LessonStatusV1 status,
    bool acknowledgeOpenHomework = false,
  }) => LessonStatusChangeV1._(
    lesson: lesson,
    status: status,
    acknowledgeOpenHomework: acknowledgeOpenHomework,
  );

  LessonStatusChangeV1 copyWith({
    LessonV1? lesson,
    LessonStatusV1? status,
    bool? acknowledgeOpenHomework,
  }) => LessonStatusChangeV1(
    lesson: lesson ?? this.lesson,
    status: status ?? this.status,
    acknowledgeOpenHomework:
        acknowledgeOpenHomework ?? this.acknowledgeOpenHomework,
  );

  @override
  List<Object?> get props => [lesson.id, status, acknowledgeOpenHomework];

  @override
  String toString() =>
      'LessonStatusChangeV1(lessonId: ${lesson.id}, status: $status, '
      'acknowledgeOpenHomework: $acknowledgeOpenHomework)';

  String toDebugString() => toString();
}
