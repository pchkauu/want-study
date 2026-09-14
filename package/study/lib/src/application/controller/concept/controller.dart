import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:domain_error/domain_error.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:study/src/application/controller/failure/_barrel.dart';
import 'package:study/src/application/service/_barrel.dart';
import 'package:study/src/application/use_case/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

part 'effect.dart';
part 'event.dart';
part 'state.dart';

@lazySingleton
final class ConceptControllerV1
    extends BlocWithEffects<ConceptEventV1, ConceptStateV1, ConceptEffectV1> {
  final ConceptUseCase _useCase;
  final StudyErrorReporterV2 _reporter;

  ConceptControllerV1(this._useCase, this._reporter) : super(ConceptStateV1()) {
    _requireForeground();
    on<ConceptStartedV1>(_onStarted, transformer: restartable());
    on<ConceptSelectedV1>(_onSelected, transformer: restartable());
    on<ConceptSearchChangedV1>(_onSearch, transformer: restartable());
    on<_ConceptMutationQueuedV1>(_onMutationQueued, transformer: sequential());
    on<ConceptCreatedV1>(_queueMutation);
    on<ConceptUpdatedV1>(_queueMutation);
    on<ConceptArchiveChangedV1>(_queueMutation);
    on<ConceptRelationAddedV1>(_queueMutation);
    on<ConceptRelationDeletedV1>(_queueMutation);
  }

  Future<void> _onStarted(
    ConceptStartedV1 event,
    Emitter<ConceptStateV1> emit,
  ) async {
    emit(
      state.copyWith(
        loadState: ConceptLoadStateV1.loading,
        study: () => event.study,
        selectedConcept: () => null,
      ),
    );
    await _load(event.study, null, emit);
  }

  Future<void> _onSelected(
    ConceptSelectedV1 event,
    Emitter<ConceptStateV1> emit,
  ) async {
    final study = state.study;
    if (study == null) return;
    emit(state.copyWith(selectedConcept: () => event.concept));
    await _load(study, event.concept, emit);
  }

  Future<void> _onSearch(
    ConceptSearchChangedV1 event,
    Emitter<ConceptStateV1> emit,
  ) async {
    final study = state.study;
    if (study == null) return;
    final search = ConceptSearchV1(
      query: event.query,
      archiveScope: ArchiveScopeV1.includeArchived,
    );
    final result = await _useCase.searchV1(
      params: ConceptSearchParamsV1(study: study, search: search),
    );
    await result.fold(
      (error) => _emitFailure(error, emit, 'ConceptControllerV1.search():'),
      (value) async => emit(
        state.copyWith(
          search: search,
          searchResult: value.concept,
          failure: () => null,
        ),
      ),
    );
  }

  void _queueMutation(ConceptEventV1 event, Emitter<ConceptStateV1> emit) {
    add(_ConceptMutationQueuedV1(event));
  }

  Future<void> _onMutationQueued(
    _ConceptMutationQueuedV1 queued,
    Emitter<ConceptStateV1> emit,
  ) async {
    final mutation = _mutationFor(queued.event);
    if (mutation != null) await _mutate(mutation, emit);
  }

  ConceptMutationV1? _mutationFor(ConceptEventV1 event) {
    final graph = state.graph;
    switch (event) {
      case ConceptCreatedV1(:final concept):
        return ConceptCreateV1(concept);
      case ConceptUpdatedV1(:final concept):
        final current = graph?.concept
            .where((value) => value.id == concept.id)
            .firstOrNull;
        return current == null
            ? null
            : ConceptUpdateV1(
                concept.copyWith(
                  version: current.version,
                  isArchived: current.isArchived,
                ),
              );
      case ConceptArchiveChangedV1(:final concept):
        final current = graph?.concept
            .where((value) => value.id == concept.id)
            .firstOrNull;
        if (current == null || current.isArchived != concept.isArchived) {
          return null;
        }
        return ConceptArchiveV1(current);
      case ConceptRelationAddedV1(:final relation):
        return ConceptPutRelationV1(relation);
      case ConceptRelationDeletedV1(:final relation):
        final current = graph?.relation
            .where((value) => value.id == relation.id)
            .firstOrNull;
        return current == null ? null : ConceptDeleteRelationV1(current);
      default:
        return null;
    }
  }

  Future<void> _mutate(
    ConceptMutationV1 mutation,
    Emitter<ConceptStateV1> emit,
  ) async {
    final study = state.study;
    if (study == null) return;
    final result = await _useCase.mutateV1(
      params: ConceptMutationParamsV1(
        study: study,
        selectedConcept: state.selectedConcept,
        mutation: mutation,
      ),
    );
    await result.fold(
      (error) => _emitFailure(error, emit, 'ConceptControllerV1.mutate():'),
      (value) async {
        emit(
          state.copyWith(
            loadState: ConceptLoadStateV1.ready,
            graph: () => value.graph,
            selectedConcept: () => value.selectedConcept,
            failure: () => null,
          ),
        );
        if (!isClosed) add(ConceptSearchChangedV1(state.search.query));
      },
    );
  }

  Future<void> _load(
    StudyV1 study,
    ConceptV1? selectedConcept,
    Emitter<ConceptStateV1> emit,
  ) async {
    final result = await _useCase.loadV1(
      params: ConceptLoadParamsV1(
        study: study,
        selectedConcept: selectedConcept,
      ),
    );
    await result.fold(
      (error) => _emitFailure(error, emit, 'ConceptControllerV1.load():'),
      (value) async => emit(
        state.copyWith(
          loadState: ConceptLoadStateV1.ready,
          graph: () => value.graph,
          selectedConcept: () => value.selectedConcept,
          failure: () => null,
        ),
      ),
    );
  }

  Future<void> _emitFailure(
    DomainError error,
    Emitter<ConceptStateV1> emit,
    String operation,
  ) async {
    await _reporter.reportDomainError(
      context: StudyErrorContextV1(
        operation: operation,
        layer: StudyErrorLayerV1.controller,
      ),
      error: error,
      stackTrace: error.stackTrace ?? StackTrace.current,
    );
    final failure = studyFailureKindV1(error);
    emit(
      state.copyWith(
        loadState: state.graph == null
            ? ConceptLoadStateV1.failed
            : state.loadState,
        failure: () => failure,
      ),
    );
    emitEffect(ConceptFailureEffectV1(failure));
  }

  static void _requireForeground() {
    if (!LaunchMode.isForeground) {
      throw StateError('ConceptControllerV1 requires foreground launch mode.');
    }
  }
}
