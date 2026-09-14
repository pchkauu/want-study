import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

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
    if (utf8.encode(promptMarkdown).length > StudyConstV1.maxContentBytes) {
      throw const ValidationErrorV1('promptMarkdown');
    }
    if (utf8.encode(solutionMarkdown).length > StudyConstV1.maxContentBytes) {
      throw const ValidationErrorV1('solutionMarkdown');
    }
    if (position < 0) throw const ValidationErrorV1('position');
    if (version < 1) throw const ValidationErrorV1('version');
    return HomeworkTaskV1._(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      promptMarkdown: promptMarkdown,
      solutionMarkdown: solutionMarkdown,
      status: status,
      dueAt: dueAt?.toUtc(),
      position: position,
      version: version,
    );
  }

  HomeworkTaskV1 copyWith({
    String? id,
    String? studyId,
    String? lessonId,
    String? promptMarkdown,
    String? solutionMarkdown,
    HomeworkStatusV1? status,
    DateTime? Function()? dueAt,
    int? position,
    int? version,
  }) => HomeworkTaskV1(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    lessonId: lessonId ?? this.lessonId,
    promptMarkdown: promptMarkdown ?? this.promptMarkdown,
    solutionMarkdown: solutionMarkdown ?? this.solutionMarkdown,
    status: status ?? this.status,
    dueAt: dueAt == null ? this.dueAt : dueAt(),
    position: position ?? this.position,
    version: version ?? this.version,
  );

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'HomeworkTaskV1(id: $id, lessonId: $lessonId, status: $status, '
      'position: $position, version: $version)';

  String toDebugString() =>
      'HomeworkTaskV1(id: $id, studyId: $studyId, lessonId: $lessonId, '
      'promptMarkdown: <redacted>, '
      'promptBytes: ${utf8.encode(promptMarkdown).length}, '
      'solutionMarkdown: <redacted>, '
      'solutionBytes: ${utf8.encode(solutionMarkdown).length}, status: $status, '
      'dueAt: $dueAt, position: $position, version: $version)';
}
