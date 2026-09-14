import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:study/src/application/service/_barrel.dart';
import 'package:study/src/application/use_case/concept/contract/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

@lazySingleton
final class ConceptUseCase {
  final KnowledgeRepositoryV2 _repository;
  final StudyUseCaseExecutor _executor;

  const ConceptUseCase(this._repository, this._executor);

  FutureResult<ConceptGraphResultV1> loadV1({
    required ConceptLoadParamsV1 params,
  }) {
    const op = 'ConceptUseCase.loadV1():';
    return _executor.call(
      operation: op,
      body: () => _load(params.study, params.selectedConcept),
    );
  }

  FutureResult<ConceptSearchResultV1> searchV1({
    required ConceptSearchParamsV1 params,
  }) {
    const op = 'ConceptUseCase.searchV1():';
    return _executor.call(
      operation: op,
      body: () async => ConceptSearchResultV1(
        await _repository.searchConcepts(
          study: params.study,
          search: params.search,
        ),
      ),
    );
  }

  FutureResult<ConceptGraphResultV1> mutateV1({
    required ConceptMutationParamsV1 params,
  }) {
    const op = 'ConceptUseCase.mutateV1():';
    return _executor.call(operation: op, body: () => _mutate(params));
  }

  Future<ConceptGraphResultV1> _mutate(ConceptMutationParamsV1 params) async {
    var selected = params.selectedConcept;
    switch (params.mutation) {
      case ConceptCreateV1(:final concept):
        selected = await _repository.createConcept(concept);
      case ConceptUpdateV1(:final concept):
        selected = await _repository.updateConcept(concept);
      case ConceptArchiveV1(:final concept):
        selected = concept.isArchived
            ? await _repository.restoreConcept(concept)
            : await _repository.archiveConcept(concept);
      case ConceptAddAliasV1(:final concept, :final alias):
        selected = await _repository.addAlias(concept, alias);
      case ConceptRemoveAliasV1(:final concept, :final alias):
        selected = await _repository.removeAlias(concept, alias);
      case ConceptPutRelationV1(:final relation):
        await _repository.putRelation(relation);
      case ConceptDeleteRelationV1(:final relation):
        await _repository.deleteRelation(relation);
    }
    return _load(params.study, selected);
  }

  Future<ConceptGraphResultV1> _load(
    StudyV1 study,
    ConceptV1? selectedConcept,
  ) async {
    final graph = await _repository.getGraph(
      study: study,
      selectedConcept: selectedConcept,
    );
    final selected = selectedConcept == null
        ? null
        : graph.concept
              .where((value) => value.id == selectedConcept.id)
              .firstOrNull;
    return ConceptGraphResultV1(graph: graph, selectedConcept: selected);
  }
}
