import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/validation.dart';

final class CodeFileV1 extends Equatable {
  final String id;
  final String studyId;
  final String lessonId;
  final String? homeworkTaskId;
  final String relativePath;
  final String language;
  final String content;
  final int version;

  const CodeFileV1._({
    required this.id,
    required this.studyId,
    required this.lessonId,
    required this.homeworkTaskId,
    required this.relativePath,
    required this.language,
    required this.content,
    required this.version,
  });

  factory CodeFileV1({
    required String id,
    required String studyId,
    required String lessonId,
    required String relativePath,
    String? homeworkTaskId,
    String language = '',
    String content = '',
    int version = 1,
  }) {
    return CodeFileV1._(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      homeworkTaskId: homeworkTaskId,
      relativePath: StudyValidationV1.relativePath(relativePath),
      language: language,
      content: StudyValidationV1.content('content', content),
      version: StudyValidationV1.version('version', version),
    );
  }

  CodeFileV1 copyWith({
    String? Function()? homeworkTaskId,
    String? relativePath,
    String? language,
    String? content,
    int? version,
  }) {
    return CodeFileV1(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      homeworkTaskId: homeworkTaskId == null
          ? this.homeworkTaskId
          : homeworkTaskId(),
      relativePath: relativePath ?? this.relativePath,
      language: language ?? this.language,
      content: content ?? this.content,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'CodeFileV1(id: $id, lessonId: $lessonId, version: $version)';
}
