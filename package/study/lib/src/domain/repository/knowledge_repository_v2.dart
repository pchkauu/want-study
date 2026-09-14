import 'package:study/src/domain/_barrel.dart';

abstract interface class KnowledgeRepositoryV2 {
  const KnowledgeRepositoryV2();

  Future<ConceptV1> createConcept(ConceptV1 concept);

  Future<ConceptV1> updateConcept(ConceptV1 concept);

  Future<ConceptV1> archiveConcept(ConceptV1 concept);

  Future<ConceptV1> restoreConcept(ConceptV1 concept);

  Future<ConceptV1> addAlias(ConceptV1 concept, ConceptAliasV1 alias);

  Future<ConceptV1> removeAlias(ConceptV1 concept, ConceptAliasV1 alias);

  Future<ConceptV1> linkBlock(ConceptV1 concept, NoteBlockV1 block);

  Future<ConceptV1> unlinkBlock(ConceptV1 concept, NoteBlockV1 block);

  Future<ConceptRelationV1> putRelation(ConceptRelationV1 relation);

  Future<ConceptRelationV1> deleteRelation(ConceptRelationV1 relation);

  Future<List<ConceptV1>> searchConcepts({
    required StudyV1 study,
    required ConceptSearchV1 search,
  });

  Future<ConceptGraphV1> getGraph({
    required StudyV1 study,
    ConceptV1? selectedConcept,
  });
}
