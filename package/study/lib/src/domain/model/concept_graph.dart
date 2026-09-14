import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/concept.dart';
import 'package:study/src/domain/model/concept_relation.dart';

final class ConceptGraphV1 extends Equatable {
  final List<ConceptV1> concept;
  final List<ConceptRelationV1> relation;
  final bool isTruncated;

  ConceptGraphV1({
    Iterable<ConceptV1> concept = const [],
    Iterable<ConceptRelationV1> relation = const [],
    this.isTruncated = false,
  }) : concept = List.unmodifiable(concept),
       relation = List.unmodifiable(relation);

  @override
  List<Object?> get props => [
    [for (final value in concept) _conceptState(value)],
    [for (final value in relation) _relationState(value)],
    isTruncated,
  ];

  @override
  String toString() =>
      'ConceptGraphV1(concept: ${concept.length}, '
      'relation: ${relation.length}, isTruncated: $isTruncated)';

  String toDebugString() => toString();
}

Object _conceptState(ConceptV1 value) => [
  value.id,
  value.studyId,
  value.title,
  value.descriptionMarkdown,
  value.exportSlug,
  value.aliases,
  value.blockIds,
  value.version,
  value.isArchived,
];

Object _relationState(ConceptRelationV1 value) => (
  value.id,
  value.studyId,
  value.sourceConceptId,
  value.targetConceptId,
  value.type,
  value.version,
);
