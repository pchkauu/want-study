import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/model/validation.dart';

final class HomeworkTaskV1 extends Equatable {
  final String id;
  final String studyId;
  final String lessonId;
  final String promptMarkdown;
  final String solutionMarkdown;
  final HomeworkStatusV1 status;
  final DateTime? dueAt;
  final int position;
  final int version;

  const HomeworkTaskV1._({
    required this.id,
    required this.studyId,
    required this.lessonId,
    required this.promptMarkdown,
    required this.solutionMarkdown,
    required this.status,
    required this.dueAt,
    required this.position,
    required this.version,
  });

  factory HomeworkTaskV1({
    required String id,
    required String studyId,
    required String lessonId,
    required int position,
    String promptMarkdown = '',
    String solutionMarkdown = '',
    HomeworkStatusV1 status = HomeworkStatusV1.todo,
    DateTime? dueAt,
    int version = 1,
  }) {
    return HomeworkTaskV1._(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      promptMarkdown: StudyValidationV1.content(
        'promptMarkdown',
        promptMarkdown,
      ),
      solutionMarkdown: StudyValidationV1.content(
        'solutionMarkdown',
        solutionMarkdown,
      ),
      status: status,
      dueAt: dueAt?.toUtc(),
      position: StudyValidationV1.position('position', position),
      version: StudyValidationV1.version('version', version),
    );
  }

  HomeworkTaskV1 copyWith({
    String? promptMarkdown,
    String? solutionMarkdown,
    HomeworkStatusV1? status,
    DateTime? Function()? dueAt,
    int? position,
    int? version,
  }) {
    return HomeworkTaskV1(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      promptMarkdown: promptMarkdown ?? this.promptMarkdown,
      solutionMarkdown: solutionMarkdown ?? this.solutionMarkdown,
      status: status ?? this.status,
      dueAt: dueAt == null ? this.dueAt : dueAt(),
      position: position ?? this.position,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'HomeworkTaskV1(id: $id, lessonId: $lessonId, status: $status, '
      'position: $position, version: $version)';
}
