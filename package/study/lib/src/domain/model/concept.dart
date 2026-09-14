import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/validation.dart';

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
    final normalizedAliases = <String>[];
    final aliasKeys = <String>{};
    for (final alias in aliases) {
      final normalized = StudyValidationV1.title('alias', alias);
      if (aliasKeys.add(normalized.toLowerCase())) {
        normalizedAliases.add(normalized);
      }
    }
    return ConceptV1._(
      id: id,
      studyId: studyId,
      title: StudyValidationV1.title('title', title),
      descriptionMarkdown: StudyValidationV1.content(
        'descriptionMarkdown',
        descriptionMarkdown,
      ),
      exportSlug: StudyValidationV1.slug('exportSlug', exportSlug),
      aliases: List.unmodifiable(normalizedAliases),
      blockIds: List.unmodifiable(blockIds.toSet()),
      version: StudyValidationV1.version('version', version),
      isArchived: isArchived,
    );
  }

  ConceptV1 copyWith({
    String? title,
    String? descriptionMarkdown,
    Iterable<String>? aliases,
    Iterable<String>? blockIds,
    int? version,
    bool? isArchived,
  }) {
    return ConceptV1(
      id: id,
      studyId: studyId,
      title: title ?? this.title,
      descriptionMarkdown: descriptionMarkdown ?? this.descriptionMarkdown,
      exportSlug: exportSlug,
      aliases: aliases ?? this.aliases,
      blockIds: blockIds ?? this.blockIds,
      version: version ?? this.version,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'ConceptV1(id: $id, studyId: $studyId, titleLength: ${title.length}, '
      'aliases: ${aliases.length}, blockIds: ${blockIds.length}, '
      'version: $version, isArchived: $isArchived)';
}
