part of 'controller.dart';

sealed class ConceptEventV1 extends Equatable {
  const ConceptEventV1();
}

final class ConceptStartedV1 extends ConceptEventV1 {
  final StudyV1 study;

  const ConceptStartedV1(this.study);

  @override
  List<Object?> get props => [study.id, study.version];
}

final class ConceptSelectedV1 extends ConceptEventV1 {
  final ConceptV1 concept;

  const ConceptSelectedV1(this.concept);

  @override
  List<Object?> get props => [concept.id, concept.version];
}

final class ConceptSearchChangedV1 extends ConceptEventV1 {
  final String query;

  const ConceptSearchChangedV1(this.query);

  @override
  List<Object?> get props => [
    query.length,
    Object.hashAll([query]),
  ];
}

final class ConceptCreatedV1 extends ConceptEventV1 {
  final ConceptV1 concept;

  const ConceptCreatedV1(this.concept);

  @override
  List<Object?> get props => [
    concept.id,
    concept.version,
    _conceptEventHash(concept),
  ];
}

final class ConceptUpdatedV1 extends ConceptEventV1 {
  final ConceptV1 concept;

  const ConceptUpdatedV1(this.concept);

  @override
  List<Object?> get props => [
    concept.id,
    concept.version,
    _conceptEventHash(concept),
  ];
}

final class ConceptArchiveChangedV1 extends ConceptEventV1 {
  final ConceptV1 concept;

  const ConceptArchiveChangedV1(this.concept);

  @override
  List<Object?> get props => [concept.id, concept.version, concept.isArchived];
}

final class ConceptRelationAddedV1 extends ConceptEventV1 {
  final ConceptRelationV1 relation;

  const ConceptRelationAddedV1(this.relation);

  @override
  List<Object?> get props => [relation.id, relation.version];
}

final class ConceptRelationDeletedV1 extends ConceptEventV1 {
  final ConceptRelationV1 relation;

  const ConceptRelationDeletedV1(this.relation);

  @override
  List<Object?> get props => [relation.id, relation.version];
}

final class _ConceptMutationQueuedV1 extends ConceptEventV1 {
  final ConceptEventV1 event;

  const _ConceptMutationQueuedV1(this.event);

  @override
  List<Object?> get props => [event];
}

int _conceptEventHash(ConceptV1 value) => Object.hashAll([
  value.studyId,
  value.title,
  value.descriptionMarkdown,
  value.exportSlug,
  Object.hashAll(value.aliases),
  Object.hashAll(value.blockIds),
  value.version,
  value.isArchived,
]);
