import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:equatable/equatable.dart';
import 'package:study/src/application/safe_call.dart';
import 'package:study/src/domain/error/study_error.dart';
import 'package:study/src/domain/model/code_file.dart';
import 'package:study/src/domain/model/homework_task.dart';
import 'package:study/src/domain/model/lesson_workspace.dart';
import 'package:study/src/domain/model/note_block.dart';
import 'package:study/src/domain/model/reorder_item.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/repository/lesson_content_repository.dart';

enum LessonEditorLoadStateV1 { initial, loading, ready, failed }

sealed class LessonEditorEventV1 {
  const LessonEditorEventV1();
}

final class LessonEditorStartedV1 extends LessonEditorEventV1 {
  final String lessonId;

  const LessonEditorStartedV1(this.lessonId);
}

final class LessonEditorBlockChangedV1 extends LessonEditorEventV1 {
  final NoteBlockV1 block;

  const LessonEditorBlockChangedV1(this.block);
}

final class LessonEditorBlockAddedV1 extends LessonEditorEventV1 {
  final NoteBlockV1 block;

  const LessonEditorBlockAddedV1(this.block);
}

final class LessonEditorTaskChangedV1 extends LessonEditorEventV1 {
  final HomeworkTaskV1 task;

  const LessonEditorTaskChangedV1(this.task);
}

final class LessonEditorTaskAddedV1 extends LessonEditorEventV1 {
  final HomeworkTaskV1 task;

  const LessonEditorTaskAddedV1(this.task);
}

final class LessonEditorFileChangedV1 extends LessonEditorEventV1 {
  final CodeFileV1 file;

  const LessonEditorFileChangedV1(this.file);
}

final class LessonEditorFileAddedV1 extends LessonEditorEventV1 {
  final CodeFileV1 file;

  const LessonEditorFileAddedV1(this.file);
}

final class LessonEditorItemDeletedV1 extends LessonEditorEventV1 {
  final Object item;

  const LessonEditorItemDeletedV1(this.item);
}

final class LessonEditorItemMoveRequestedV1 extends LessonEditorEventV1 {
  final Object item;
  final int offset;

  const LessonEditorItemMoveRequestedV1(this.item, this.offset);
}

final class LessonEditorRetrySaveV1 extends LessonEditorEventV1 {
  const LessonEditorRetrySaveV1();
}

final class LessonEditorDiscardV1 extends LessonEditorEventV1 {
  const LessonEditorDiscardV1();
}

final class LessonEditorNavigationRequestedV1 extends LessonEditorEventV1 {
  const LessonEditorNavigationRequestedV1();
}

final class _LessonEditorSaveBlockV1 extends LessonEditorEventV1 {
  final String blockId;
  final int draftRevision;

  const _LessonEditorSaveBlockV1(this.blockId, this.draftRevision);
}

sealed class LessonEditorEffectV1 {
  const LessonEditorEffectV1();
}

final class LessonEditorFailureEffectV1 extends LessonEditorEffectV1 {
  final String errorIdentifier;

  const LessonEditorFailureEffectV1(this.errorIdentifier);

  @override
  String toString() => 'LessonEditorFailureEffectV1($errorIdentifier)';
}

final class LessonEditorDraftDecisionEffectV1 extends LessonEditorEffectV1 {
  const LessonEditorDraftDecisionEffectV1();

  @override
  String toString() => 'LessonEditorDraftDecisionEffectV1';
}

final class LessonEditorNavigateEffectV1 extends LessonEditorEffectV1 {
  const LessonEditorNavigateEffectV1();

  @override
  String toString() => 'LessonEditorNavigateEffectV1';
}

final class LessonEditorStateV1 extends Equatable {
  final LessonEditorLoadStateV1 loadState;
  final LessonWorkspaceV1? workspace;
  final SaveStateV1 saveState;
  final int draftRevision;
  final String? errorIdentifier;

  const LessonEditorStateV1({
    this.loadState = LessonEditorLoadStateV1.initial,
    this.workspace,
    this.saveState = SaveStateV1.clean,
    this.draftRevision = 0,
    this.errorIdentifier,
  });

  LessonEditorStateV1 copyWith({
    LessonEditorLoadStateV1? loadState,
    LessonWorkspaceV1? Function()? workspace,
    SaveStateV1? saveState,
    int? draftRevision,
    String? Function()? errorIdentifier,
  }) {
    return LessonEditorStateV1(
      loadState: loadState ?? this.loadState,
      workspace: workspace == null ? this.workspace : workspace(),
      saveState: saveState ?? this.saveState,
      draftRevision: draftRevision ?? this.draftRevision,
      errorIdentifier: errorIdentifier == null
          ? this.errorIdentifier
          : errorIdentifier(),
    );
  }

  @override
  List<Object?> get props => [
    loadState,
    workspace,
    saveState,
    draftRevision,
    errorIdentifier,
  ];
}

final class LessonEditorBlocV1
    extends
        BlocWithEffects<
          LessonEditorEventV1,
          LessonEditorStateV1,
          LessonEditorEffectV1
        > {
  final LessonContentRepositoryV1 repository;
  final Duration autosaveDelay;
  Timer? _autosaveTimer;
  String? _lessonId;
  String? _lastChangedBlockId;
  final Map<String, int> _storedBlockVersion = {};

  LessonEditorBlocV1({required this.repository, required this.autosaveDelay})
    : super(const LessonEditorStateV1()) {
    on<LessonEditorStartedV1>(_onStarted, transformer: restartable());
    on<LessonEditorBlockChangedV1>(_onBlockChanged);
    on<_LessonEditorSaveBlockV1>(_onSaveBlock, transformer: sequential());
    on<LessonEditorRetrySaveV1>(_onRetrySave);
    on<LessonEditorDiscardV1>(_onDiscard, transformer: restartable());
    on<LessonEditorNavigationRequestedV1>(_onNavigationRequested);
    on<LessonEditorBlockAddedV1>(_onBlockAdded, transformer: sequential());
    on<LessonEditorTaskChangedV1>(_onTaskChanged, transformer: sequential());
    on<LessonEditorTaskAddedV1>(_onTaskAdded, transformer: sequential());
    on<LessonEditorFileChangedV1>(_onFileChanged, transformer: sequential());
    on<LessonEditorFileAddedV1>(_onFileAdded, transformer: sequential());
    on<LessonEditorItemDeletedV1>(_onItemDeleted, transformer: sequential());
    on<LessonEditorItemMoveRequestedV1>(
      _onItemMoveRequested,
      transformer: sequential(),
    );
  }

  Future<void> _onStarted(
    LessonEditorStartedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    _lessonId = event.lessonId;
    _autosaveTimer?.cancel();
    emit(state.copyWith(loadState: LessonEditorLoadStateV1.loading));
    final result = await studySafeCallV1(
      'lesson.load',
      () => repository.getWorkspace(event.lessonId),
    );
    result.fold(
      (error) => _emitFailure(error, emit),
      (workspace) => emit(_loadedState(workspace)),
    );
  }

  void _onBlockChanged(
    LessonEditorBlockChangedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) {
    final workspace = state.workspace;
    if (workspace == null) {
      return;
    }
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
        errorIdentifier: () => null,
      ),
    );
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(
      autosaveDelay,
      () => add(_LessonEditorSaveBlockV1(event.block.id, revision)),
    );
  }

  Future<void> _onSaveBlock(
    _LessonEditorSaveBlockV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    final workspace = state.workspace;
    if (workspace == null) {
      return;
    }
    final draft = workspace.block
        .where((item) => item.id == event.blockId)
        .firstOrNull;
    if (draft == null) {
      return;
    }
    final storedVersion = _storedBlockVersion[draft.id] ?? draft.version;
    final block = draft.copyWith(version: storedVersion);
    emit(state.copyWith(saveState: SaveStateV1.saving));
    final result = await studySafeCallV1(
      'lesson.saveBlock',
      () => repository.updateBlock(block),
    );
    result.fold(
      (error) {
        final saveState = error is ConflictErrorV1
            ? SaveStateV1.conflict
            : SaveStateV1.failed;
        _emitFailure(error, emit, saveState: saveState);
      },
      (stored) {
        _storedBlockVersion[stored.id] = stored.version;
        final currentWorkspace = state.workspace;
        if (currentWorkspace == null) {
          return;
        }
        final currentBlocks = [
          for (final current in currentWorkspace.block)
            if (current.id == stored.id)
              current.copyWith(version: stored.version)
            else
              current,
        ];
        final hasNewDraft = state.draftRevision != event.draftRevision;
        emit(
          state.copyWith(
            workspace: () => currentWorkspace.copyWith(block: currentBlocks),
            saveState: hasNewDraft ? SaveStateV1.dirty : SaveStateV1.saved,
            errorIdentifier: () => null,
          ),
        );
      },
    );
  }

  LessonEditorStateV1 _loadedState(LessonWorkspaceV1 workspace) {
    _storedBlockVersion
      ..clear()
      ..addEntries(
        workspace.block.map((block) => MapEntry(block.id, block.version)),
      );
    return state.copyWith(
      loadState: LessonEditorLoadStateV1.ready,
      workspace: () => workspace,
      saveState: SaveStateV1.clean,
      errorIdentifier: () => null,
    );
  }

  void _onRetrySave(
    LessonEditorRetrySaveV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) {
    final workspace = state.workspace;
    final blockId = _lastChangedBlockId;
    if (workspace == null || blockId == null) {
      return;
    }
    add(_LessonEditorSaveBlockV1(blockId, state.draftRevision));
  }

  Future<void> _onDiscard(
    LessonEditorDiscardV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    final lessonId = _lessonId;
    if (lessonId != null) {
      await _onStarted(LessonEditorStartedV1(lessonId), emit);
    }
  }

  void _onNavigationRequested(
    LessonEditorNavigationRequestedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) {
    if (state.saveState == SaveStateV1.dirty ||
        state.saveState == SaveStateV1.saving ||
        state.saveState == SaveStateV1.failed ||
        state.saveState == SaveStateV1.conflict) {
      emitEffect(const LessonEditorDraftDecisionEffectV1());
      return;
    }
    emitEffect(const LessonEditorNavigateEffectV1());
  }

  Future<void> _onBlockAdded(
    LessonEditorBlockAddedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    await _writeAndReload(
      'lesson.createBlock',
      () => repository.createBlock(event.block),
      emit,
    );
  }

  Future<void> _onTaskChanged(
    LessonEditorTaskChangedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    await _writeAndReload(
      'lesson.updateTask',
      () => repository.updateTask(event.task),
      emit,
    );
  }

  Future<void> _onTaskAdded(
    LessonEditorTaskAddedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    await _writeAndReload(
      'lesson.createTask',
      () => repository.createTask(event.task),
      emit,
    );
  }

  Future<void> _onFileChanged(
    LessonEditorFileChangedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    await _writeAndReload(
      'lesson.updateFile',
      () => repository.updateFile(event.file),
      emit,
    );
  }

  Future<void> _onFileAdded(
    LessonEditorFileAddedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    await _writeAndReload(
      'lesson.createFile',
      () => repository.createFile(event.file),
      emit,
    );
  }

  Future<void> _onItemDeleted(
    LessonEditorItemDeletedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    if (event.item case final NoteBlockV1 block
        when block.id == _lastChangedBlockId) {
      _autosaveTimer?.cancel();
      _lastChangedBlockId = null;
    }
    await _writeAndReload(
      'lesson.deleteItem',
      () => switch (event.item) {
        final NoteBlockV1 item => repository.deleteBlock(item, confirmed: true),
        final HomeworkTaskV1 item => repository.deleteTask(
          item,
          confirmed: true,
        ),
        final CodeFileV1 item => repository.deleteFile(item, confirmed: true),
        _ => throw const ValidationErrorV1('item'),
      },
      emit,
    );
  }

  Future<void> _onItemMoveRequested(
    LessonEditorItemMoveRequestedV1 event,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    final workspace = state.workspace;
    if (workspace == null || event.offset.abs() != 1) {
      return;
    }
    final items = switch (event.item) {
      NoteBlockV1() => workspace.block.cast<Object>(),
      HomeworkTaskV1() => workspace.task.cast<Object>(),
      _ => const <Object>[],
    };
    final index = items.indexWhere((item) => item == event.item);
    final target = index + event.offset;
    if (index < 0 || target < 0 || target >= items.length) {
      return;
    }
    final first = _contentReorderItem(
      items[index],
      _itemPosition(items[target]),
    );
    final second = _contentReorderItem(
      items[target],
      _itemPosition(items[index]),
    );
    await _writeAndReload(
      'lesson.reorderContent',
      () => repository.reorderContent(
        lessonId: workspace.lesson.id,
        block: event.item is NoteBlockV1 ? [first, second] : const [],
        task: event.item is HomeworkTaskV1 ? [first, second] : const [],
      ),
      emit,
    );
  }

  ReorderItemV1 _contentReorderItem(Object item, int position) => ReorderItemV1(
    id: switch (item) {
      final NoteBlockV1 value => value.id,
      final HomeworkTaskV1 value => value.id,
      _ => throw const ValidationErrorV1('item'),
    },
    position: position,
    expectedVersion: switch (item) {
      final NoteBlockV1 value => value.version,
      final HomeworkTaskV1 value => value.version,
      _ => throw const ValidationErrorV1('item'),
    },
  );

  int _itemPosition(Object item) => switch (item) {
    final NoteBlockV1 value => value.position,
    final HomeworkTaskV1 value => value.position,
    _ => throw const ValidationErrorV1('item'),
  };

  Future<void> _writeAndReload<T>(
    String operation,
    Future<T> Function() call,
    Emitter<LessonEditorStateV1> emit,
  ) async {
    emit(state.copyWith(saveState: SaveStateV1.saving));
    final result = await studySafeCallV1(operation, call);
    await result.fold((error) async => _emitFailure(error, emit), (_) async {
      final lessonId = _lessonId;
      if (lessonId == null) {
        return;
      }
      final loadResult = await studySafeCallV1(
        'lesson.reload',
        () => repository.getWorkspace(lessonId),
      );
      loadResult.fold(
        (error) => _emitFailure(error, emit),
        (workspace) => emit(
          state.copyWith(
            workspace: () => workspace,
            saveState: SaveStateV1.saved,
            errorIdentifier: () => null,
          ),
        ),
      );
    });
  }

  void _emitFailure(
    Object error,
    Emitter<LessonEditorStateV1> emit, {
    SaveStateV1 saveState = SaveStateV1.failed,
  }) {
    final identifier = error is StudyErrorV1
        ? error.typeIdentifier
        : 'UnexpectedErrorV1';
    emit(
      state.copyWith(
        loadState: state.workspace == null
            ? LessonEditorLoadStateV1.failed
            : state.loadState,
        saveState: saveState,
        errorIdentifier: () => identifier,
      ),
    );
    emitEffect(LessonEditorFailureEffectV1(identifier));
  }

  @override
  Future<void> close() {
    _autosaveTimer?.cancel();
    return super.close();
  }
}
