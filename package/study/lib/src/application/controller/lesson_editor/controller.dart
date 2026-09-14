import 'dart:async';

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
import 'package:study/src/config/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

part 'effect.dart';
part 'event.dart';
part 'state.dart';

@lazySingleton
final class LessonEditorControllerV2
    extends
        BlocWithEffects<
          LessonEditorEventV2,
          LessonEditorStateV2,
          LessonEditorEffectV2
        > {
  final LessonEditorUseCase _useCase;
  final StudyErrorReporterV2 _reporter;
  final Duration autosaveDelay;
  Timer? _autosaveTimer;
  LessonV1? _lesson;
  String? _lastChangedBlockId;
  final Map<String, int> _storedBlockVersion = {};

  LessonEditorControllerV2(
    this._useCase,
    this._reporter, {
    required Config config,
  }) : autosaveDelay = config.autosaveDelay,
       super(const LessonEditorStateV2()) {
    _configure();
  }

  LessonEditorControllerV2.withAutosaveDelay(
    this._useCase,
    this._reporter,
    this.autosaveDelay,
  ) : super(const LessonEditorStateV2()) {
    _configure();
  }

  void _configure() {
    _requireForeground();
    on<LessonEditorStartedV2>(_onStarted, transformer: restartable());
    on<LessonEditorBlockChangedV2>(_onBlockChanged, transformer: sequential());
    on<_LessonEditorSaveBlockV2>(_onSaveBlock, transformer: sequential());
    on<LessonEditorRetrySaveV2>(_onRetrySave, transformer: sequential());
    on<LessonEditorDiscardV2>(_onDiscard, transformer: restartable());
    on<LessonEditorNavigationRequestedV2>(_onNavigationRequested);
    on<LessonEditorBlockAddedV2>(_onBlockAdded, transformer: sequential());
    on<LessonEditorTaskChangedV2>(_onTaskChanged, transformer: sequential());
    on<LessonEditorTaskAddedV2>(_onTaskAdded, transformer: sequential());
    on<LessonEditorFileChangedV2>(_onFileChanged, transformer: sequential());
    on<LessonEditorFileAddedV2>(_onFileAdded, transformer: sequential());
    on<LessonEditorBlockDeletedV2>(_onBlockDeleted, transformer: sequential());
    on<LessonEditorTaskDeletedV2>(_onTaskDeleted, transformer: sequential());
    on<LessonEditorFileDeletedV2>(_onFileDeleted, transformer: sequential());
    on<LessonEditorBlockMoveRequestedV2>(
      _onBlockMove,
      transformer: sequential(),
    );
    on<LessonEditorTaskMoveRequestedV2>(_onTaskMove, transformer: sequential());
  }

  Future<List<ConceptV1>> searchConcept({
    required StudyV1 study,
    required String query,
  }) async {
    final result = await _useCase.searchConceptV1(
      params: LessonConceptSearchParamsV1(
        study: study,
        search: ConceptSearchV1(query: query),
      ),
    );
    return result.fold((error) async {
      await _report(error, 'LessonEditorControllerV2.searchConcept():');
      emitEffect(LessonEditorFailureEffectV2(studyFailureKindV1(error)));
      return const <ConceptV1>[];
    }, (value) => value.concept);
  }

  Future<ConceptV1?> changeBlockConcept({
    required ConceptV1 concept,
    required NoteBlockV1 block,
    required bool link,
  }) async {
    final result = await _useCase.changeBlockConceptV1(
      params: LessonBlockConceptParamsV1(
        concept: concept,
        block: block,
        action: link
            ? ConceptBlockLinkActionV1.link
            : ConceptBlockLinkActionV1.unlink,
      ),
    );
    return result.fold((error) async {
      await _report(error, 'LessonEditorControllerV2.changeBlockConcept():');
      emitEffect(LessonEditorFailureEffectV2(studyFailureKindV1(error)));
      return null;
    }, (value) => value.concept);
  }

  Future<void> _onStarted(
    LessonEditorStartedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    _lesson = event.lesson;
    _autosaveTimer?.cancel();
    emit(state.copyWith(loadState: LessonEditorLoadStateV2.loading));
    final result = await _useCase.loadV1(
      params: LessonWorkspaceParamsV1(event.lesson),
    );
    await result.fold(
      (error) => _emitFailure(error, emit, 'LessonEditorControllerV2.load():'),
      (value) async => emit(_loadedState(value.workspace)),
    );
  }

  void _onBlockChanged(
    LessonEditorBlockChangedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    final workspace = state.workspace;
    if (workspace == null) return;
    final blocks = [
      for (final block in workspace.block)
        if (block.id == event.block.id) event.block else block,
    ];
    final revision = state.draftRevision + 1;
    _lastChangedBlockId = event.block.id;
    emit(
      state.copyWith(
        workspace: () => workspace.copyWith(block: blocks),
        saveState: SaveStateV1.dirty,
        draftRevision: revision,
        failure: () => null,
      ),
    );
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(
      autosaveDelay,
      () => add(_LessonEditorSaveBlockV2(event.block.id, revision)),
    );
  }

  Future<void> _onSaveBlock(
    _LessonEditorSaveBlockV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final workspace = state.workspace;
    if (workspace == null) return;
    final draft = workspace.block
        .where((item) => item.id == event.blockId)
        .firstOrNull;
    if (draft == null) return;
    final block = draft.copyWith(
      version: _storedBlockVersion[draft.id] ?? draft.version,
    );
    emit(state.copyWith(saveState: SaveStateV1.saving));
    final result = await _useCase.saveBlockV1(
      params: LessonSaveBlockParamsV1(block),
    );
    await result.fold(
      (error) async {
        await _emitFailure(
          error,
          emit,
          'LessonEditorControllerV2.saveBlock():',
          saveState: error is ConflictErrorV1
              ? SaveStateV1.conflict
              : SaveStateV1.failed,
        );
      },
      (value) async {
        final stored = value.block;
        _storedBlockVersion[stored.id] = stored.version;
        final currentWorkspace = state.workspace;
        if (currentWorkspace == null) return;
        final blocks = [
          for (final current in currentWorkspace.block)
            if (current.id == stored.id)
              current.copyWith(version: stored.version)
            else
              current,
        ];
        emit(
          state.copyWith(
            workspace: () => currentWorkspace.copyWith(block: blocks),
            saveState: state.draftRevision != event.draftRevision
                ? SaveStateV1.dirty
                : SaveStateV1.saved,
            failure: () => null,
          ),
        );
      },
    );
  }

  void _onRetrySave(
    LessonEditorRetrySaveV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    final blockId = _lastChangedBlockId;
    if (state.workspace != null && blockId != null) {
      add(_LessonEditorSaveBlockV2(blockId, state.draftRevision));
    }
  }

  Future<void> _onDiscard(
    LessonEditorDiscardV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final lesson = _lesson;
    if (lesson != null) await _onStarted(LessonEditorStartedV2(lesson), emit);
  }

  void _onNavigationRequested(
    LessonEditorNavigationRequestedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    if ({
      SaveStateV1.dirty,
      SaveStateV1.saving,
      SaveStateV1.failed,
      SaveStateV1.conflict,
    }.contains(state.saveState)) {
      emitEffect(const LessonEditorDraftDecisionEffectV2());
      return;
    }
    emitEffect(const LessonEditorNavigateEffectV2());
  }

  Future<void> _onBlockAdded(
    LessonEditorBlockAddedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _mutate(LessonCreateBlockV1(event.block), emit);

  Future<void> _onTaskChanged(
    LessonEditorTaskChangedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _mutate(LessonUpdateTaskV1(event.task), emit);

  Future<void> _onTaskAdded(
    LessonEditorTaskAddedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _mutate(LessonCreateTaskV1(event.task), emit);

  Future<void> _onFileChanged(
    LessonEditorFileChangedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _mutate(LessonUpdateFileV1(event.file), emit);

  Future<void> _onFileAdded(
    LessonEditorFileAddedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _mutate(LessonCreateFileV1(event.file), emit);

  Future<void> _onBlockDeleted(
    LessonEditorBlockDeletedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    if (event.block.id == _lastChangedBlockId) {
      _autosaveTimer?.cancel();
      _lastChangedBlockId = null;
    }
    return _mutate(LessonDeleteBlockV1(event.block), emit);
  }

  Future<void> _onTaskDeleted(
    LessonEditorTaskDeletedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _mutate(LessonDeleteTaskV1(event.task), emit);

  Future<void> _onFileDeleted(
    LessonEditorFileDeletedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _mutate(LessonDeleteFileV1(event.file), emit);

  Future<void> _onBlockMove(
    LessonEditorBlockMoveRequestedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _moveBlock(event.block, event.offset, emit);

  Future<void> _onTaskMove(
    LessonEditorTaskMoveRequestedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) => _moveTask(event.task, event.offset, emit);

  Future<void> _moveBlock(
    NoteBlockV1 block,
    int offset,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final items = state.workspace?.block;
    if (items == null || offset.abs() != 1) return;
    final index = items.indexWhere((value) => value.id == block.id);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= items.length) return;
    await _mutate(
      LessonReorderContentV1(
        block: [
          _blockReorder(items[index], items[target].position),
          _blockReorder(items[target], items[index].position),
        ],
      ),
      emit,
    );
  }

  Future<void> _moveTask(
    HomeworkTaskV1 task,
    int offset,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final items = state.workspace?.task;
    if (items == null || offset.abs() != 1) return;
    final index = items.indexWhere((value) => value.id == task.id);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= items.length) return;
    await _mutate(
      LessonReorderContentV1(
        task: [
          _taskReorder(items[index], items[target].position),
          _taskReorder(items[target], items[index].position),
        ],
      ),
      emit,
    );
  }

  ReorderItemV1 _blockReorder(NoteBlockV1 block, int position) => ReorderItemV1(
    id: block.id,
    position: position,
    expectedVersion: block.version,
  );

  ReorderItemV1 _taskReorder(HomeworkTaskV1 task, int position) =>
      ReorderItemV1(
        id: task.id,
        position: position,
        expectedVersion: task.version,
      );

  Future<void> _mutate(
    LessonMutationV1 mutation,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final lesson = _lesson;
    if (lesson == null) return;
    emit(state.copyWith(saveState: SaveStateV1.saving));
    final result = await _useCase.mutateV1(
      params: LessonMutationParamsV1(lesson: lesson, mutation: mutation),
    );
    await result.fold(
      (error) =>
          _emitFailure(error, emit, 'LessonEditorControllerV2.mutate():'),
      (value) async => emit(
        _loadedState(value.workspace).copyWith(saveState: SaveStateV1.saved),
      ),
    );
  }

  LessonEditorStateV2 _loadedState(LessonWorkspaceV1 workspace) {
    _lesson = workspace.lesson;
    _storedBlockVersion
      ..clear()
      ..addEntries(
        workspace.block.map((block) => MapEntry(block.id, block.version)),
      );
    return state.copyWith(
      loadState: LessonEditorLoadStateV2.ready,
      workspace: () => workspace,
      saveState: SaveStateV1.clean,
      failure: () => null,
    );
  }

  Future<void> _emitFailure(
    DomainError error,
    Emitter<LessonEditorStateV2> emit,
    String operation, {
    SaveStateV1 saveState = SaveStateV1.failed,
  }) async {
    await _report(error, operation);
    final failure = studyFailureKindV1(error);
    emit(
      state.copyWith(
        loadState: state.workspace == null
            ? LessonEditorLoadStateV2.failed
            : state.loadState,
        saveState: saveState,
        failure: () => failure,
      ),
    );
    emitEffect(LessonEditorFailureEffectV2(failure));
  }

  Future<void> _report(DomainError error, String operation) =>
      _reporter.reportDomainError(
        context: StudyErrorContextV1(
          operation: operation,
          layer: StudyErrorLayerV1.controller,
        ),
        error: error,
        stackTrace: error.stackTrace ?? StackTrace.current,
      );

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }

  static void _requireForeground() {
    if (!LaunchMode.isForeground) {
      throw StateError(
        'LessonEditorControllerV2 requires foreground launch mode.',
      );
    }
  }
}
