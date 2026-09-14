import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/model/validation.dart';

final class NoteBlockV1 extends Equatable {
  final String id;
  final String studyId;
  final String lessonId;
  final NoteBlockTypeV1 type;
  final String markdown;
  final String sourceUrl;
  final String sourcePosition;
  final int position;
  final int version;

  const NoteBlockV1._({
    required this.id,
    required this.studyId,
    required this.lessonId,
    required this.type,
    required this.markdown,
    required this.sourceUrl,
    required this.sourcePosition,
    required this.position,
    required this.version,
  });

  factory NoteBlockV1({
    required String id,
    required String studyId,
    required String lessonId,
    required NoteBlockTypeV1 type,
    required int position,
    String markdown = '',
    String sourceUrl = '',
    String sourcePosition = '',
    int version = 1,
  }) {
    return NoteBlockV1._(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      type: type,
      markdown: StudyValidationV1.content('markdown', markdown),
      sourceUrl: sourceUrl,
      sourcePosition: sourcePosition,
      position: StudyValidationV1.position('position', position),
      version: StudyValidationV1.version('version', version),
    );
  }

  NoteBlockV1 copyWith({
    NoteBlockTypeV1? type,
    String? markdown,
    String? sourceUrl,
    String? sourcePosition,
    int? position,
    int? version,
  }) {
    return NoteBlockV1(
      id: id,
      studyId: studyId,
      lessonId: lessonId,
      type: type ?? this.type,
      markdown: markdown ?? this.markdown,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourcePosition: sourcePosition ?? this.sourcePosition,
      position: position ?? this.position,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'NoteBlockV1(id: $id, lessonId: $lessonId, type: $type, '
      'position: $position, version: $version)';
}
