import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class LearningSourceV1 extends Equatable {
  final String id;
  final String studyId;
  final LearningSourceTypeV1 type;
  final String title;
  final String author;
  final String url;
  final String exportSlug;
  final int position;
  final int version;
  final bool isArchived;

  const LearningSourceV1._({
    required this.id,
    required this.studyId,
    required this.type,
    required this.title,
    required this.author,
    required this.url,
    required this.exportSlug,
    required this.position,
    required this.version,
    required this.isArchived,
  });

  factory LearningSourceV1({
    required String id,
    required String studyId,
    required LearningSourceTypeV1 type,
    required String title,
    required String exportSlug,
    required int position,
    String author = '',
    String url = '',
    int version = 1,
    bool isArchived = false,
  }) {
    final normalizedTitle = _title('title', title);
    _validateSlug('exportSlug', exportSlug);
    _validatePosition('position', position);
    _validateVersion('version', version);
    return LearningSourceV1._(
      id: id,
      studyId: studyId,
      type: type,
      title: normalizedTitle,
      author: author,
      url: url,
      exportSlug: exportSlug,
      position: position,
      version: version,
      isArchived: isArchived,
    );
  }

  LearningSourceV1 copyWith({
    String? id,
    String? studyId,
    LearningSourceTypeV1? type,
    String? title,
    String? author,
    String? url,
    String? exportSlug,
    int? position,
    int? version,
    bool? isArchived,
  }) => LearningSourceV1(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    type: type ?? this.type,
    title: title ?? this.title,
    author: author ?? this.author,
    url: url ?? this.url,
    exportSlug: exportSlug ?? this.exportSlug,
    position: position ?? this.position,
    version: version ?? this.version,
    isArchived: isArchived ?? this.isArchived,
  );

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'LearningSourceV1(id: $id, studyId: $studyId, type: $type, '
      'titleLength: ${title.length}, position: $position, version: $version, '
      'isArchived: $isArchived)';

  String toDebugString() =>
      'LearningSourceV1(id: $id, studyId: $studyId, type: $type, '
      'title: <redacted>, titleLength: ${title.length}, author: <redacted>, '
      'authorLength: ${author.length}, hasUrl: ${url.isNotEmpty}, '
      'exportSlug: $exportSlug, position: $position, version: $version, '
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

void _validateSlug(String field, String value) {
  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value)) {
    throw ValidationErrorV1(field);
  }
}

void _validatePosition(String field, int value) {
  if (value < 0) throw ValidationErrorV1(field);
}

void _validateVersion(String field, int value) {
  if (value < 1) throw ValidationErrorV1(field);
}
