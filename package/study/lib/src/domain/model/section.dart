import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/validation.dart';

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
    return SectionV1._(
      id: id,
      studyId: studyId,
      sourceId: sourceId,
      title: StudyValidationV1.title('title', title),
      position: StudyValidationV1.position('position', position),
      version: StudyValidationV1.version('version', version),
      isArchived: isArchived,
    );
  }

  SectionV1 copyWith({
    String? title,
    int? position,
    int? version,
    bool? isArchived,
  }) {
    return SectionV1(
      id: id,
      studyId: studyId,
      sourceId: sourceId,
      title: title ?? this.title,
      position: position ?? this.position,
      version: version ?? this.version,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'SectionV1(id: $id, studyId: $studyId, sourceId: $sourceId, '
      'titleLength: ${title.length}, position: $position, version: $version, '
      'isArchived: $isArchived)';
}
