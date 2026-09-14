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
    on<ConceptCreatedV1>(_onCreated, transformer: sequential());
    on<ConceptUpdatedV1>(_onUpdated, transformer: sequential());
    on<ConceptArchiveChangedV1>(_onArchiveChanged, transformer: sequential());
    on<ConceptRelationAddedV1>(_onRelationAdded, transformer: sequential());
    on<ConceptRelationDeletedV1>(_onRelationDeleted, transformer: sequential());
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

  Future<void> _onCreated(
    ConceptCreatedV1 event,
    Emitter<ConceptStateV1> emit,
  ) => _mutate(ConceptCreateV1(event.concept), emit);

  Future<void> _onUpdated(
    ConceptUpdatedV1 event,
    Emitter<ConceptStateV1> emit,
  ) => _mutate(ConceptUpdateV1(event.concept), emit);

  Future<void> _onArchiveChanged(
    ConceptArchiveChangedV1 event,
    Emitter<ConceptStateV1> emit,
  ) => _mutate(ConceptArchiveV1(event.concept), emit);

  Future<void> _onRelationAdded(
    ConceptRelationAddedV1 event,
    Emitter<ConceptStateV1> emit,
  ) => _mutate(ConceptPutRelationV1(event.relation), emit);

  Future<void> _onRelationDeleted(
    ConceptRelationDeletedV1 event,
    Emitter<ConceptStateV1> emit,
  ) => _mutate(ConceptDeleteRelationV1(event.relation), emit);

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
        add(ConceptSearchChangedV1(state.search.query));
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
