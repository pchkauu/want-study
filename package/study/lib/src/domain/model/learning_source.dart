import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/model/validation.dart';

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
    return LearningSourceV1._(
      id: id,
      studyId: studyId,
      type: type,
      title: StudyValidationV1.title('title', title),
      author: author,
      url: url,
      exportSlug: StudyValidationV1.slug('exportSlug', exportSlug),
      position: StudyValidationV1.position('position', position),
      version: StudyValidationV1.version('version', version),
      isArchived: isArchived,
    );
  }

  LearningSourceV1 copyWith({
    LearningSourceTypeV1? type,
    String? title,
    String? author,
    String? url,
    int? position,
    int? version,
    bool? isArchived,
  }) {
    return LearningSourceV1(
      id: id,
      studyId: studyId,
      type: type ?? this.type,
      title: title ?? this.title,
      author: author ?? this.author,
      url: url ?? this.url,
      exportSlug: exportSlug,
      position: position ?? this.position,
      version: version ?? this.version,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'LearningSourceV1(id: $id, studyId: $studyId, type: $type, '
      'titleLength: ${title.length}, position: $position, version: $version, '
      'isArchived: $isArchived)';
}
