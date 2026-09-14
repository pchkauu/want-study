import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ConceptGraphV1 extends Equatable {
  final List<ConceptV1> concept;
  final List<ConceptRelationV1> relation;
  final bool isTruncated;

  const ConceptGraphV1._({
    required this.concept,
    required this.relation,
    required this.isTruncated,
  });

  factory ConceptGraphV1({
    Iterable<ConceptV1> concept = const [],
    Iterable<ConceptRelationV1> relation = const [],
    bool isTruncated = false,
  }) {
    final concepts = List<ConceptV1>.unmodifiable(concept);
    final relations = List<ConceptRelationV1>.unmodifiable(relation);
    final conceptIds = concepts.map((value) => value.id).toSet();
    if (conceptIds.length != concepts.length) {
      throw const ValidationErrorV1('concept');
    }
    for (final value in relations) {
      if (!conceptIds.contains(value.sourceConceptId) ||
          !conceptIds.contains(value.targetConceptId)) {
        throw const ValidationErrorV1('relation');
      }
    }
    return ConceptGraphV1._(
      concept: concepts,
      relation: relations,
      isTruncated: isTruncated,
    );
  }

  ConceptGraphV1 copyWith({
    Iterable<ConceptV1>? concept,
    Iterable<ConceptRelationV1>? relation,
    bool? isTruncated,
  }) => ConceptGraphV1(
    concept: concept ?? this.concept,
    relation: relation ?? this.relation,
    isTruncated: isTruncated ?? this.isTruncated,
  );

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

Object _conceptState(ConceptV1 value) => (
  value.id,
  value.studyId,
  value.title,
  value.descriptionMarkdown,
  value.exportSlug,
  value.aliases,
  value.blockIds,
  value.version,
  value.isArchived,
);

Object _relationState(ConceptRelationV1 value) => (
  value.id,
  value.studyId,
  value.sourceConceptId,
  value.targetConceptId,
  value.type,
  value.version,
);
