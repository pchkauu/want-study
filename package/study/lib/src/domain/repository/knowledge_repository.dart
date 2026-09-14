import 'package:study/src/domain/model/concept.dart';
import 'package:study/src/domain/model/concept_graph.dart';
import 'package:study/src/domain/model/concept_relation.dart';

abstract interface class KnowledgeRepositoryV1 {
  Future<ConceptV1> createConcept(ConceptV1 concept);

  Future<ConceptV1> updateConcept(ConceptV1 concept);

  Future<ConceptV1> archiveConcept(ConceptV1 concept);

  Future<ConceptV1> restoreConcept(ConceptV1 concept);

  Future<ConceptV1> addAlias(ConceptV1 concept, String alias);

  Future<ConceptV1> removeAlias(ConceptV1 concept, String alias);

  Future<ConceptV1> linkBlock(ConceptV1 concept, String blockId);

  Future<ConceptV1> unlinkBlock(ConceptV1 concept, String blockId);

  Future<ConceptRelationV1> putRelation(ConceptRelationV1 relation);

  Future<void> deleteRelation(
    ConceptRelationV1 relation, {
    required bool confirmed,
  });

  Future<List<ConceptV1>> searchConcepts(
    String studyId,
    String query, {
    bool includeArchived = false,
    int limit = 50,
  });

  Future<ConceptGraphV1> getGraph(String studyId, {String? selectedConceptId});
}
