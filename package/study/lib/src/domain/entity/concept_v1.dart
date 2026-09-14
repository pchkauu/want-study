import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ConceptV1 extends Equatable {
  final String id;
  final String studyId;
  final String title;
  final String descriptionMarkdown;
  final String exportSlug;
  final List<String> aliases;
  final List<String> blockIds;
  final int version;
  final bool isArchived;

  const ConceptV1._({
    required this.id,
    required this.studyId,
    required this.title,
    required this.descriptionMarkdown,
    required this.exportSlug,
    required this.aliases,
    required this.blockIds,
    required this.version,
    required this.isArchived,
  });

  factory ConceptV1({
    required String id,
    required String studyId,
    required String title,
    required String exportSlug,
    String descriptionMarkdown = '',
    Iterable<String> aliases = const [],
    Iterable<String> blockIds = const [],
    int version = 1,
    bool isArchived = false,
  }) {
    final normalizedTitle = _title('title', title);
    if (utf8.encode(descriptionMarkdown).length >
        StudyConstV1.maxContentBytes) {
      throw const ValidationErrorV1('descriptionMarkdown');
    }
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(exportSlug)) {
      throw const ValidationErrorV1('exportSlug');
    }
    if (version < 1) throw const ValidationErrorV1('version');
    final normalizedAliases = <String>[];
    final keys = <String>{};
    for (final alias in aliases) {
      final normalized = _title('alias', alias);
      if (keys.add(normalized.toLowerCase())) normalizedAliases.add(normalized);
    }
    return ConceptV1._(
      id: id,
      studyId: studyId,
      title: normalizedTitle,
      descriptionMarkdown: descriptionMarkdown,
      exportSlug: exportSlug,
      aliases: List.unmodifiable(normalizedAliases),
      blockIds: List.unmodifiable(blockIds.toSet()),
      version: version,
      isArchived: isArchived,
    );
  }

  ConceptV1 copyWith({
    String? id,
    String? studyId,
    String? title,
    String? descriptionMarkdown,
    String? exportSlug,
    Iterable<String>? aliases,
    Iterable<String>? blockIds,
    int? version,
    bool? isArchived,
  }) => ConceptV1(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    title: title ?? this.title,
    descriptionMarkdown: descriptionMarkdown ?? this.descriptionMarkdown,
    exportSlug: exportSlug ?? this.exportSlug,
    aliases: aliases ?? this.aliases,
    blockIds: blockIds ?? this.blockIds,
    version: version ?? this.version,
    isArchived: isArchived ?? this.isArchived,
  );

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'ConceptV1(id: $id, studyId: $studyId, titleLength: ${title.length}, '
      'aliases: ${aliases.length}, blockIds: ${blockIds.length}, '
      'version: $version, isArchived: $isArchived)';

  String toDebugString() =>
      'ConceptV1(id: $id, studyId: $studyId, title: <redacted>, '
      'titleLength: ${title.length}, descriptionMarkdown: <redacted>, '
      'descriptionBytes: ${utf8.encode(descriptionMarkdown).length}, '
      'exportSlug: $exportSlug, aliases: ${aliases.length}, '
      'blockIds: ${blockIds.length}, version: $version, '
      'isArchived: $isArchived)';
}

String _title(String field, String value) {
  final normalized = value.trim();
  if (normalized.isEmpty ||
      normalized.runes.length > StudyConstV1.maxTitleLength) {
    throw ValidationErrorV1(field);
  }
  return normalized;
}
