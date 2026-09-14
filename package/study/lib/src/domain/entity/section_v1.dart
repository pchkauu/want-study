import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class SectionV1 extends Equatable {
  final String id;
  final String studyId;
  final String sourceId;
  final String title;
  final int position;
  final int version;
  final bool isArchived;

  const SectionV1._({
    required this.id,
    required this.studyId,
    required this.sourceId,
    required this.title,
    required this.position,
    required this.version,
    required this.isArchived,
  });

  factory SectionV1({
    required String id,
    required String studyId,
    required String sourceId,
    required String title,
    required int position,
    int version = 1,
    bool isArchived = false,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty ||
        normalizedTitle.runes.length > StudyConstV1.maxTitleLength) {
      throw const ValidationErrorV1('title');
    }
    if (position < 0) throw const ValidationErrorV1('position');
    if (version < 1) throw const ValidationErrorV1('version');
    return SectionV1._(
      id: id,
      studyId: studyId,
      sourceId: sourceId,
      title: normalizedTitle,
      position: position,
      version: version,
      isArchived: isArchived,
    );
  }

  SectionV1 copyWith({
    String? id,
    String? studyId,
    String? sourceId,
    String? title,
    int? position,
    int? version,
    bool? isArchived,
  }) => SectionV1(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    sourceId: sourceId ?? this.sourceId,
    title: title ?? this.title,
    position: position ?? this.position,
    version: version ?? this.version,
    isArchived: isArchived ?? this.isArchived,
  );

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'SectionV1(id: $id, studyId: $studyId, sourceId: $sourceId, '
      'titleLength: ${title.length}, position: $position, version: $version, '
      'isArchived: $isArchived)';

  String toDebugString() =>
      'SectionV1(id: $id, studyId: $studyId, sourceId: $sourceId, '
      'title: <redacted>, titleLength: ${title.length}, position: $position, '
      'version: $version, isArchived: $isArchived)';
}
