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
  final Map<String, Timer> _autosaveTimer = {};
  final Map<String, int> _blockRevision = {};
  final Set<String> _dirtyBlockId = {};
  LessonV1? _lesson;
  final Map<String, int> _storedBlockVersion = {};
  _LessonEditorWriteV2? _failedWrite;
  SaveStateV1? _failedSaveState;
  var _queuedWriteCount = 0;
  var _writeEpoch = 0;

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
    on<LessonEditorBlockChangedV2>(_onBlockChanged);
    on<_LessonEditorWriteV2>(_onWrite, transformer: sequential());
    on<LessonEditorRetrySaveV2>(_onRetrySave);
    on<LessonEditorDiscardV2>(_onDiscard);
    on<LessonEditorNavigationRequestedV2>(_onNavigationRequested);
    on<LessonEditorBlockAddedV2>(_queueMutation);
    on<LessonEditorTaskChangedV2>(_queueMutation);
    on<LessonEditorTaskAddedV2>(_queueMutation);
    on<LessonEditorFileChangedV2>(_queueMutation);
    on<LessonEditorFileAddedV2>(_queueMutation);
    on<LessonEditorBlockDeletedV2>(_queueMutation);
    on<LessonEditorTaskDeletedV2>(_queueMutation);
    on<LessonEditorFileDeletedV2>(_queueMutation);
    on<LessonEditorBlockMoveRequestedV2>(_queueMutation);
    on<LessonEditorTaskMoveRequestedV2>(_queueMutation);
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
    _resetDrafts();
    final epoch = _writeEpoch;
    _lesson = event.lesson;
    emit(state.copyWith(loadState: LessonEditorLoadStateV2.loading));
    final result = await _useCase.loadV1(
      params: LessonWorkspaceParamsV1(event.lesson),
    );
    await result.fold(
      (error) async {
        if (epoch == _writeEpoch && !emit.isDone) {
          await _emitFailure(
            error,
            emit,
            'LessonEditorControllerV2.load():',
            epoch: epoch,
          );
        }
      },
      (value) async {
        if (epoch == _writeEpoch && !emit.isDone) {
          emit(_loadedState(value.workspace));
        }
      },
    );
  }

  void _onBlockChanged(
    LessonEditorBlockChangedV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    final workspace = state.workspace;
    if (workspace == null) return;
    if (!workspace.block.any((block) => block.id == event.block.id)) return;
    final blocks = [
      for (final block in workspace.block)
        if (block.id == event.block.id) event.block else block,
    ];
    final revision = state.draftRevision + 1;
    _blockRevision[event.block.id] = revision;
    _dirtyBlockId.add(event.block.id);
    emit(
      state.copyWith(
        workspace: () => workspace.copyWith(block: blocks),
        saveState: SaveStateV1.dirty,
        draftRevision: revision,
        failure: () => null,
      ),
    );
    _autosaveTimer.remove(event.block.id)?.cancel();
    _autosaveTimer[event.block.id] = Timer(autosaveDelay, () {
      _autosaveTimer.remove(event.block.id);
      _queueWrite(
        _LessonEditorSaveBlockV2(
          epoch: _writeEpoch,
          blockId: event.block.id,
          draftRevision: revision,
        ),
      );
    });
  }

  Future<void> _onWrite(
    _LessonEditorWriteV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    if (event.epoch != _writeEpoch) return;
    emit(state.copyWith(saveState: SaveStateV1.saving));
    final succeeded = switch (event) {
      _LessonEditorSaveBlockV2() => await _saveBlock(event, emit),
      _LessonEditorMutationV2() => await _mutate(event, emit),
      _LessonEditorReloadV2() => await _reloadAfterDiscard(event, emit),
    };
    if (event.epoch != _writeEpoch) return;
    if (succeeded && _failedWrite == event) {
      _failedWrite = null;
      _failedSaveState = null;
    } else if (!succeeded && _failedWrite == null) {
      _failedWrite = event;
      _failedSaveState = state.saveState;
    }
    _finishWrite(emit, succeeded: succeeded);
  }

  Future<bool> _saveBlock(
    _LessonEditorSaveBlockV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final workspace = state.workspace;
    if (workspace == null) return true;
    final draft = workspace.block
        .where((item) => item.id == event.blockId)
        .firstOrNull;
    if (draft == null) return true;
    final block = draft.copyWith(
      version: _storedBlockVersion[draft.id] ?? draft.version,
    );
    final result = await _useCase.saveBlockV1(
      params: LessonSaveBlockParamsV1(block),
    );
    return result.fold(
      (error) async {
        if (event.epoch != _writeEpoch) return true;
        await _emitFailure(
          error,
          emit,
          'LessonEditorControllerV2.saveBlock():',
          epoch: event.epoch,
          saveState: error is ConflictErrorV1
              ? SaveStateV1.conflict
              : SaveStateV1.failed,
        );
        return false;
      },
      (value) async {
        if (event.epoch != _writeEpoch) return true;
        final stored = value.block;
        _storedBlockVersion[stored.id] = stored.version;
        final currentWorkspace = state.workspace;
        if (currentWorkspace == null) return true;
        final blocks = [
          for (final current in currentWorkspace.block)
            if (current.id == stored.id)
              current.copyWith(version: stored.version)
            else
              current,
        ];
        if (_blockRevision[stored.id] == event.draftRevision) {
          _dirtyBlockId.remove(stored.id);
        }
        emit(
          state.copyWith(
            workspace: () => currentWorkspace.copyWith(block: blocks),
            failure: () => null,
          ),
        );
        return true;
      },
    );
  }

  void _onRetrySave(
    LessonEditorRetrySaveV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    final failed = _failedWrite;
    if (failed != null) {
      _queueWrite(_withCurrentEpoch(failed));
      return;
    }
    for (final blockId in _dirtyBlockId) {
      _autosaveTimer.remove(blockId)?.cancel();
      _queueWrite(
        _LessonEditorSaveBlockV2(
          epoch: _writeEpoch,
          blockId: blockId,
          draftRevision: _blockRevision[blockId] ?? state.draftRevision,
        ),
      );
    }
  }

  void _onDiscard(
    LessonEditorDiscardV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    _resetDrafts();
    _queueWrite(_LessonEditorReloadV2(epoch: _writeEpoch));
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

  void _queueMutation(
    LessonEditorEventV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) {
    _queueWrite(_LessonEditorMutationV2(epoch: _writeEpoch, event: event));
    emit(state.copyWith(saveState: SaveStateV1.saving));
  }

  void _queueWrite(_LessonEditorWriteV2 event) {
    _queuedWriteCount++;
    add(event);
  }

  _LessonEditorWriteV2 _withCurrentEpoch(_LessonEditorWriteV2 event) =>
      switch (event) {
        _LessonEditorSaveBlockV2(:final blockId, :final draftRevision) =>
          _LessonEditorSaveBlockV2(
            epoch: _writeEpoch,
            blockId: blockId,
            draftRevision: draftRevision,
          ),
        _LessonEditorMutationV2(:final event) => _LessonEditorMutationV2(
          epoch: _writeEpoch,
          event: event,
        ),
        _LessonEditorReloadV2() => _LessonEditorReloadV2(epoch: _writeEpoch),
      };

  Future<bool> _mutate(
    _LessonEditorMutationV2 queued,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final lesson = _lesson;
    final mutation = _mutationFor(queued.event);
    if (lesson == null || mutation == null) return true;
    final result = await _useCase.mutateV1(
      params: LessonMutationParamsV1(lesson: lesson, mutation: mutation),
    );
    return result.fold(
      (error) async {
        if (queued.epoch != _writeEpoch) return true;
        await _emitFailure(
          error,
          emit,
          'LessonEditorControllerV2.mutate():',
          epoch: queued.epoch,
          saveState: error is ConflictErrorV1
              ? SaveStateV1.conflict
              : SaveStateV1.failed,
        );
        return false;
      },
      (value) async {
        if (queued.epoch != _writeEpoch) return true;
        emit(
          state.copyWith(
            loadState: LessonEditorLoadStateV2.ready,
            workspace: () => _mergeWorkspace(value.workspace),
            failure: () => null,
          ),
        );
        return true;
      },
    );
  }

  LessonMutationV1? _mutationFor(LessonEditorEventV2 event) {
    final workspace = state.workspace;
    if (workspace == null) return null;
    switch (event) {
      case LessonEditorBlockAddedV2(:final block):
        return LessonCreateBlockV1(block);
      case LessonEditorTaskAddedV2(:final task):
        return LessonCreateTaskV1(task);
      case LessonEditorFileAddedV2(:final file):
        return LessonCreateFileV1(file);
      case LessonEditorTaskChangedV2(:final task):
        final current = workspace.task
            .where((value) => value.id == task.id)
            .firstOrNull;
        return current == null
            ? null
            : LessonUpdateTaskV1(
                task.copyWith(
                  position: current.position,
                  version: current.version,
                ),
              );
      case LessonEditorFileChangedV2(:final file):
        final current = workspace.file
            .where((value) => value.id == file.id)
            .firstOrNull;
        return current == null
            ? null
            : LessonUpdateFileV1(file.copyWith(version: current.version));
      case LessonEditorBlockDeletedV2(:final block):
        final current = workspace.block
            .where((value) => value.id == block.id)
            .firstOrNull;
        if (current == null) return null;
        _autosaveTimer.remove(block.id)?.cancel();
        _blockRevision.remove(block.id);
        _dirtyBlockId.remove(block.id);
        return LessonDeleteBlockV1(current);
      case LessonEditorTaskDeletedV2(:final task):
        final current = workspace.task
            .where((value) => value.id == task.id)
            .firstOrNull;
        return current == null ? null : LessonDeleteTaskV1(current);
      case LessonEditorFileDeletedV2(:final file):
        final current = workspace.file
            .where((value) => value.id == file.id)
            .firstOrNull;
        return current == null ? null : LessonDeleteFileV1(current);
      case LessonEditorBlockMoveRequestedV2(:final block, :final offset):
        return _blockMove(block.id, offset, workspace.block);
      case LessonEditorTaskMoveRequestedV2(:final task, :final offset):
        return _taskMove(task.id, offset, workspace.task);
      default:
        return null;
    }
  }

  LessonMutationV1? _blockMove(
    String blockId,
    int offset,
    List<NoteBlockV1> items,
  ) {
    if (offset.abs() != 1) return null;
    final index = items.indexWhere((value) => value.id == blockId);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= items.length) return null;
    return LessonReorderContentV1(
      block: [
        _blockReorder(items[index], items[target].position),
        _blockReorder(items[target], items[index].position),
      ],
    );
  }

  LessonMutationV1? _taskMove(
    String taskId,
    int offset,
    List<HomeworkTaskV1> items,
  ) {
    if (offset.abs() != 1) return null;
    final index = items.indexWhere((value) => value.id == taskId);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= items.length) return null;
    return LessonReorderContentV1(
      task: [
        _taskReorder(items[index], items[target].position),
        _taskReorder(items[target], items[index].position),
      ],
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

  Future<bool> _reloadAfterDiscard(
    _LessonEditorReloadV2 event,
    Emitter<LessonEditorStateV2> emit,
  ) async {
    final lesson = _lesson;
    if (lesson == null) return true;
    emit(state.copyWith(loadState: LessonEditorLoadStateV2.loading));
    final result = await _useCase.loadV1(
      params: LessonWorkspaceParamsV1(lesson),
    );
    return result.fold(
      (error) async {
        if (event.epoch != _writeEpoch) return true;
        await _emitFailure(
          error,
          emit,
          'LessonEditorControllerV2.discard():',
          epoch: event.epoch,
        );
        return false;
      },
      (value) async {
        if (event.epoch != _writeEpoch) return true;
        emit(_loadedState(value.workspace));
        return true;
      },
    );
  }

  LessonWorkspaceV1 _mergeWorkspace(LessonWorkspaceV1 stored) {
    final current = state.workspace;
    final draft = <String, NoteBlockV1>{
      for (final block in current?.block ?? const <NoteBlockV1>[])
        if (_dirtyBlockId.contains(block.id)) block.id: block,
    };
    final storedId = stored.block.map((block) => block.id).toSet();
    final removed = _dirtyBlockId.difference(storedId);
    for (final id in removed) {
      _autosaveTimer.remove(id)?.cancel();
      _blockRevision.remove(id);
      _dirtyBlockId.remove(id);
    }
    final block = [
      for (final storedBlock in stored.block)
        if (draft[storedBlock.id] case final currentDraft?)
          currentDraft.copyWith(
            position: storedBlock.position,
            version: storedBlock.version,
          )
        else
          storedBlock,
    ];
    _lesson = stored.lesson;
    _storedBlockVersion
      ..clear()
      ..addEntries(
        stored.block.map((value) => MapEntry(value.id, value.version)),
      );
    return stored.copyWith(block: block);
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

  void _finishWrite(
    Emitter<LessonEditorStateV2> emit, {
    bool succeeded = true,
  }) {
    if (_queuedWriteCount > 0) _queuedWriteCount--;
    if (!succeeded || emit.isDone) return;
    final failedState = _failedWrite == null ? null : _failedSaveState;
    final saveState =
        failedState ??
        (_queuedWriteCount > 0
            ? SaveStateV1.saving
            : _dirtyBlockId.isNotEmpty
            ? SaveStateV1.dirty
            : SaveStateV1.saved);
    emit(state.copyWith(saveState: saveState));
  }

  void _resetDrafts() {
    for (final timer in _autosaveTimer.values) {
      timer.cancel();
    }
    _autosaveTimer.clear();
    _blockRevision.clear();
    _dirtyBlockId.clear();
    _storedBlockVersion.clear();
    _failedWrite = null;
    _failedSaveState = null;
    _queuedWriteCount = 0;
    _writeEpoch++;
  }

  Future<void> _emitFailure(
    DomainError error,
    Emitter<LessonEditorStateV2> emit,
    String operation, {
    int? epoch,
    SaveStateV1 saveState = SaveStateV1.failed,
  }) async {
    if (emit.isDone || (epoch != null && epoch != _writeEpoch)) return;
    await _report(error, operation);
    if (emit.isDone || (epoch != null && epoch != _writeEpoch)) return;
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
    _resetDrafts();
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
