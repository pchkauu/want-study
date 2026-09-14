import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

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
    final parts = relativePath.split('/');
    if (relativePath.isEmpty ||
        relativePath.startsWith('/') ||
        relativePath.contains(r'\') ||
        parts.any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw const ValidationErrorV1('relativePath');
    }
    if (utf8.encode(content).length > StudyConstV1.maxContentBytes) {
      throw const ValidationErrorV1('content');
    }
    if (version < 1) throw const ValidationErrorV1('version');
    return CodeFileV1._(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      homeworkTaskId: homeworkTaskId,
      relativePath: relativePath,
      language: language,
      content: content,
      version: version,
    );
  }

  CodeFileV1 copyWith({
    String? id,
    String? studyId,
    String? lessonId,
    String? Function()? homeworkTaskId,
    String? relativePath,
    String? language,
    String? content,
    int? version,
  }) => CodeFileV1(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    lessonId: lessonId ?? this.lessonId,
    homeworkTaskId: homeworkTaskId == null
        ? this.homeworkTaskId
        : homeworkTaskId(),
    relativePath: relativePath ?? this.relativePath,
    language: language ?? this.language,
    content: content ?? this.content,
    version: version ?? this.version,
  );

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'CodeFileV1(id: $id, lessonId: $lessonId, version: $version)';

  String toDebugString() =>
      'CodeFileV1(id: $id, studyId: $studyId, lessonId: $lessonId, '
      'homeworkTaskId: $homeworkTaskId, relativePath: <redacted>, '
      'relativePathLength: ${relativePath.length}, language: $language, '
      'content: <redacted>, contentBytes: ${utf8.encode(content).length}, '
      'version: $version)';
}
