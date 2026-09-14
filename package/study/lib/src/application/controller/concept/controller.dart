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
  var _studyEpoch = 0;

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
    final epoch = ++_studyEpoch;
    emit(
      state.copyWith(
        loadState: ConceptLoadStateV1.loading,
        study: () => event.study,
        graph: () => null,
        selectedConcept: () => null,
        search: ConceptSearchV1(archiveScope: ArchiveScopeV1.includeArchived),
        searchResult: const [],
        failure: () => null,
      ),
    );
    await _load(event.study, null, epoch, emit);
  }

  Future<void> _onSelected(
    ConceptSelectedV1 event,
    Emitter<ConceptStateV1> emit,
  ) async {
    final study = state.study;
    if (study == null || event.concept.studyId != study.id) return;
    final epoch = _studyEpoch;
    emit(state.copyWith(selectedConcept: () => event.concept));
    await _load(study, event.concept, epoch, emit);
  }

  Future<void> _onSearch(
    ConceptSearchChangedV1 event,
    Emitter<ConceptStateV1> emit,
  ) async {
    final study = state.study;
    if (study == null) return;
    final epoch = _studyEpoch;
    final search = ConceptSearchV1(
      query: event.query,
      archiveScope: ArchiveScopeV1.includeArchived,
    );
    final result = await _useCase.searchV1(
      params: ConceptSearchParamsV1(study: study, search: search),
    );
    if (!_isCurrent(study.id, epoch, emit)) return;
    await result.fold(
      (error) => _emitFailure(
        error,
        emit,
        'ConceptControllerV1.search():',
        isCurrent: () => _isCurrent(study.id, epoch, emit),
      ),
      (value) async {
        if (!_isCurrent(study.id, epoch, emit)) return;
        emit(
          state.copyWith(
            search: search,
            searchResult: value.concept,
            failure: () => null,
          ),
        );
      },
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
    final studyId = state.study?.id;
    switch (event) {
      case ConceptCreatedV1(:final concept):
        return concept.studyId == studyId ? ConceptCreateV1(concept) : null;
      case ConceptUpdatedV1(:final concept):
        if (concept.studyId != studyId) return null;
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
        if (concept.studyId != studyId) return null;
        final current = graph?.concept
            .where((value) => value.id == concept.id)
            .firstOrNull;
        if (current == null || current.isArchived != concept.isArchived) {
          return null;
        }
        return ConceptArchiveV1(current);
      case ConceptRelationAddedV1(:final relation):
        return relation.studyId == studyId
            ? ConceptPutRelationV1(relation)
            : null;
      case ConceptRelationDeletedV1(:final relation):
        if (relation.studyId != studyId) return null;
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
    final epoch = _studyEpoch;
    final result = await _useCase.mutateV1(
      params: ConceptMutationParamsV1(
        study: study,
        selectedConcept: state.selectedConcept,
        mutation: mutation,
      ),
    );
    if (!_isCurrent(study.id, epoch, emit)) return;
    await result.fold(
      (error) => _emitFailure(
        error,
        emit,
        'ConceptControllerV1.mutate():',
        isCurrent: () => _isCurrent(study.id, epoch, emit),
      ),
      (value) async {
        if (!_isCurrent(study.id, epoch, emit)) return;
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
    int epoch,
    Emitter<ConceptStateV1> emit,
  ) async {
    final result = await _useCase.loadV1(
      params: ConceptLoadParamsV1(
        study: study,
        selectedConcept: selectedConcept,
      ),
    );
    if (!_isCurrent(study.id, epoch, emit)) return;
    await result.fold(
      (error) => _emitFailure(
        error,
        emit,
        'ConceptControllerV1.load():',
        isCurrent: () => _isCurrent(study.id, epoch, emit),
      ),
      (value) async {
        if (!_isCurrent(study.id, epoch, emit)) return;
        emit(
          state.copyWith(
            loadState: ConceptLoadStateV1.ready,
            graph: () => value.graph,
            selectedConcept: () => value.selectedConcept,
            failure: () => null,
          ),
        );
      },
    );
  }

  Future<void> _emitFailure(
    DomainError error,
    Emitter<ConceptStateV1> emit,
    String operation, {
    bool Function()? isCurrent,
  }) async {
    if (emit.isDone || !(isCurrent?.call() ?? true)) return;
    await _reporter.reportDomainError(
      context: StudyErrorContextV1(
        operation: operation,
        layer: StudyErrorLayerV1.controller,
      ),
      error: error,
      stackTrace: error.stackTrace ?? StackTrace.current,
    );
    if (emit.isDone || !(isCurrent?.call() ?? true)) return;
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

  bool _isCurrent(String studyId, int epoch, Emitter<ConceptStateV1> emit) =>
      !emit.isDone && _studyEpoch == epoch && state.study?.id == studyId;

  static void _requireForeground() {
    if (!LaunchMode.isForeground) {
      throw StateError('ConceptControllerV1 requires foreground launch mode.');
    }
  }
}
