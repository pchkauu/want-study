import 'package:equatable/equatable.dart';
import 'package:study/src/domain/error/study_error.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/model/validation.dart';

final class LessonV1 extends Equatable {
  final String id;
  final String studyId;
  final String sourceId;
  final String? sectionId;
  final String title;
  final String url;
  final String sourcePosition;
  final String exportSlug;
  final int position;
  final LessonStatusV1 status;
  final DateTime? startedAt;
  final DateTime? masteredAt;
  final int version;
  final bool isArchived;

  const LessonV1._({
    required this.id,
    required this.studyId,
    required this.sourceId,
    required this.sectionId,
    required this.title,
    required this.url,
    required this.sourcePosition,
    required this.exportSlug,
    required this.position,
    required this.status,
    required this.startedAt,
    required this.masteredAt,
    required this.version,
    required this.isArchived,
  });

  factory LessonV1({
    required String id,
    required String studyId,
    required String sourceId,
    required String title,
    required String exportSlug,
    required int position,
    String? sectionId,
    String url = '',
    String sourcePosition = '',
    LessonStatusV1 status = LessonStatusV1.planned,
    DateTime? startedAt,
    DateTime? masteredAt,
    int version = 1,
    bool isArchived = false,
  }) {
    if (status != LessonStatusV1.planned && startedAt == null) {
      throw const ValidationErrorV1('startedAt');
    }
    if ((status == LessonStatusV1.mastered) != (masteredAt != null)) {
      throw const ValidationErrorV1('masteredAt');
    }
    return LessonV1._(
      id: id,
      studyId: studyId,
      sourceId: sourceId,
      sectionId: sectionId,
      title: StudyValidationV1.title('title', title),
      url: url,
      sourcePosition: sourcePosition,
      exportSlug: StudyValidationV1.slug('exportSlug', exportSlug),
      position: StudyValidationV1.position('position', position),
      status: status,
      startedAt: startedAt?.toUtc(),
      masteredAt: masteredAt?.toUtc(),
      version: StudyValidationV1.version('version', version),
      isArchived: isArchived,
    );
  }

  LessonV1 copyWith({
    String? Function()? sectionId,
    String? title,
    String? url,
    String? sourcePosition,
    int? position,
    LessonStatusV1? status,
    DateTime? Function()? startedAt,
    DateTime? Function()? masteredAt,
    int? version,
    bool? isArchived,
  }) {
    return LessonV1(
      id: id,
      studyId: studyId,
      sourceId: sourceId,
      sectionId: sectionId == null ? this.sectionId : sectionId(),
      title: title ?? this.title,
      url: url ?? this.url,
      sourcePosition: sourcePosition ?? this.sourcePosition,
      exportSlug: exportSlug,
      position: position ?? this.position,
      status: status ?? this.status,
      startedAt: startedAt == null ? this.startedAt : startedAt(),
      masteredAt: masteredAt == null ? this.masteredAt : masteredAt(),
      version: version ?? this.version,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'LessonV1(id: $id, studyId: $studyId, sourceId: $sourceId, '
      'titleLength: ${title.length}, status: $status, position: $position, '
      'version: $version, isArchived: $isArchived)';
}
