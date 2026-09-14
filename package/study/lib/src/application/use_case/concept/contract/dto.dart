import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ConceptLoadParamsV1 extends Equatable {
  final StudyV1 study;
  final ConceptV1? selectedConcept;

  const ConceptLoadParamsV1({required this.study, this.selectedConcept});

  @override
  List<Object?> get props => [study.id, selectedConcept?.id];
}

final class ConceptSearchParamsV1 extends Equatable {
  final StudyV1 study;
  final ConceptSearchV1 search;

  const ConceptSearchParamsV1({required this.study, required this.search});

  @override
  List<Object?> get props => [study.id, search];
}

final class ConceptMutationParamsV1 extends Equatable {
  final StudyV1 study;
  final ConceptV1? selectedConcept;
  final ConceptMutationV1 mutation;

  const ConceptMutationParamsV1({
    required this.study,
    required this.selectedConcept,
    required this.mutation,
  });

  @override
  List<Object?> get props => [study.id, selectedConcept?.id, mutation];
}

final class ConceptGraphResultV1 extends Equatable {
  final ConceptGraphV1 graph;
  final ConceptV1? selectedConcept;

  const ConceptGraphResultV1({
    required this.graph,
    required this.selectedConcept,
  });

  @override
  List<Object?> get props => [graph, selectedConcept?.id];
}

final class ConceptSearchResultV1 extends Equatable {
  final List<ConceptV1> concept;

  ConceptSearchResultV1(Iterable<ConceptV1> concept)
    : concept = List.unmodifiable(concept);

  @override
  List<Object?> get props => [
    [for (final value in concept) _conceptState(value)],
  ];
}

sealed class ConceptMutationV1 extends Equatable {
  const ConceptMutationV1();
}

final class ConceptCreateV1 extends ConceptMutationV1 {
  final ConceptV1 concept;

  const ConceptCreateV1(this.concept);

  @override
  List<Object?> get props => [_conceptState(concept)];
}

final class ConceptUpdateV1 extends ConceptMutationV1 {
  final ConceptV1 concept;

  const ConceptUpdateV1(this.concept);

  @override
  List<Object?> get props => [_conceptState(concept)];
}

final class ConceptArchiveV1 extends ConceptMutationV1 {
  final ConceptV1 concept;

  const ConceptArchiveV1(this.concept);

  @override
  List<Object?> get props => [_conceptState(concept)];
}

final class ConceptAddAliasV1 extends ConceptMutationV1 {
  final ConceptV1 concept;
  final ConceptAliasV1 alias;

  const ConceptAddAliasV1(this.concept, this.alias);

  @override
  List<Object?> get props => [_conceptState(concept), alias];
}

final class ConceptRemoveAliasV1 extends ConceptMutationV1 {
  final ConceptV1 concept;
  final ConceptAliasV1 alias;

  const ConceptRemoveAliasV1(this.concept, this.alias);

  @override
  List<Object?> get props => [_conceptState(concept), alias];
}

final class ConceptPutRelationV1 extends ConceptMutationV1 {
  final ConceptRelationV1 relation;

  const ConceptPutRelationV1(this.relation);

  @override
  List<Object?> get props => [_relationState(relation)];
}

final class ConceptDeleteRelationV1 extends ConceptMutationV1 {
  final ConceptRelationV1 relation;

  const ConceptDeleteRelationV1(this.relation);

  @override
  List<Object?> get props => [_relationState(relation)];
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
