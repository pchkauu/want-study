import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class StudyV1 extends Equatable {
  final String id;
  final String title;
  final String goal;
  final String localRepositoryPath;
  final int version;
  final int contentRevision;
  final bool isArchived;

  const StudyV1._({
    required this.id,
    required this.title,
    required this.goal,
    required this.localRepositoryPath,
    required this.version,
    required this.contentRevision,
    required this.isArchived,
  });

  factory StudyV1({
    required String id,
    required String title,
    String goal = '',
    String localRepositoryPath = '',
    int version = 1,
    int contentRevision = 1,
    bool isArchived = false,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty ||
        normalizedTitle.runes.length > StudyConstV1.maxTitleLength) {
      throw const ValidationErrorV1('title');
    }
    if (utf8.encode(goal).length > StudyConstV1.maxContentBytes) {
      throw const ValidationErrorV1('goal');
    }
    if (version < 1) {
      throw const ValidationErrorV1('version');
    }
    if (contentRevision < 1) {
      throw const ValidationErrorV1('contentRevision');
    }
    return StudyV1._(
      id: id,
      title: normalizedTitle,
      goal: goal,
      localRepositoryPath: localRepositoryPath,
      version: version,
      contentRevision: contentRevision,
      isArchived: isArchived,
    );
  }

  StudyV1 copyWith({
    String? id,
    String? title,
    String? goal,
    String? localRepositoryPath,
    int? version,
    int? contentRevision,
    bool? isArchived,
  }) => StudyV1(
    id: id ?? this.id,
    title: title ?? this.title,
    goal: goal ?? this.goal,
    localRepositoryPath: localRepositoryPath ?? this.localRepositoryPath,
    version: version ?? this.version,
    contentRevision: contentRevision ?? this.contentRevision,
    isArchived: isArchived ?? this.isArchived,
  );

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'StudyV1(id: $id, titleLength: ${title.length}, version: $version, '
      'contentRevision: $contentRevision, isArchived: $isArchived)';

  String toDebugString() =>
      'StudyV1(id: $id, title: <redacted>, titleLength: ${title.length}, '
      'goal: <redacted>, goalBytes: ${utf8.encode(goal).length}, '
      'hasLocalRepository: ${localRepositoryPath.isNotEmpty}, '
      'version: $version, contentRevision: $contentRevision, '
      'isArchived: $isArchived)';
}
