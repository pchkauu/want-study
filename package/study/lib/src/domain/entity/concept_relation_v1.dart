import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ConceptRelationV1 extends Equatable {
  final String id;
  final String studyId;
  final String sourceConceptId;
  final String targetConceptId;
  final ConceptRelationTypeV1 type;
  final int version;

  const ConceptRelationV1._({
    required this.id,
    required this.studyId,
    required this.sourceConceptId,
    required this.targetConceptId,
    required this.type,
    required this.version,
  });

  factory ConceptRelationV1({
    required String id,
    required String studyId,
    required String sourceConceptId,
    required String targetConceptId,
    required ConceptRelationTypeV1 type,
    int version = 1,
  }) {
    if (sourceConceptId == targetConceptId) {
      throw const ValidationErrorV1('targetConceptId');
    }
    if (version < 1) throw const ValidationErrorV1('version');
    var source = sourceConceptId;
    var target = targetConceptId;
    if ((type == ConceptRelationTypeV1.relatedTo ||
            type == ConceptRelationTypeV1.contrastsWith) &&
        source.compareTo(target) > 0) {
      source = targetConceptId;
      target = sourceConceptId;
    }
    return ConceptRelationV1._(
      id: id,
      studyId: studyId,
      sourceConceptId: source,
      targetConceptId: target,
      type: type,
      version: version,
    );
  }

  ConceptRelationV1 copyWith({
    String? id,
    String? studyId,
    String? sourceConceptId,
    String? targetConceptId,
    ConceptRelationTypeV1? type,
    int? version,
  }) => ConceptRelationV1(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    sourceConceptId: sourceConceptId ?? this.sourceConceptId,
    targetConceptId: targetConceptId ?? this.targetConceptId,
    type: type ?? this.type,
    version: version ?? this.version,
  );

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'ConceptRelationV1(id: $id, type: $type, version: $version)';

  String toDebugString() =>
      'ConceptRelationV1(id: $id, studyId: $studyId, '
      'sourceConceptId: $sourceConceptId, targetConceptId: $targetConceptId, '
      'type: $type, version: $version)';
}
