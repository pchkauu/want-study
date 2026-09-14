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
import 'package:study/src/domain/_barrel.dart';

part 'effect.dart';
part 'event.dart';
part 'state.dart';

@lazySingleton
final class CatalogControllerV2
    extends BlocWithEffects<CatalogEventV2, CatalogStateV2, CatalogEffectV2> {
  final CatalogUseCase _useCase;
  final StudyErrorReporterV2 _reporter;
  Future<void>? _initFuture;

  CatalogControllerV2(this._useCase, this._reporter) : super(CatalogStateV2()) {
    _requireForeground();
    on<_CatalogStartedV2>(_onStarted, transformer: restartable());
    on<CatalogStudySelectedV2>(_onSelected, transformer: restartable());
    on<CatalogStudyCreatedV2>(_onStudyCreated, transformer: sequential());
    on<CatalogStudyUpdatedV2>(_onStudyUpdated, transformer: sequential());
    on<CatalogStudyArchiveChangedV2>(
      _onStudyArchiveChanged,
      transformer: sequential(),
    );
    on<CatalogSourceCreatedV2>(_onSourceCreated, transformer: sequential());
    on<CatalogSourceUpdatedV2>(_onSourceUpdated, transformer: sequential());
    on<CatalogSourceArchiveChangedV2>(
      _onSourceArchiveChanged,
      transformer: sequential(),
    );
    on<CatalogSectionCreatedV2>(_onSectionCreated, transformer: sequential());
    on<CatalogSectionUpdatedV2>(_onSectionUpdated, transformer: sequential());
    on<CatalogSectionArchiveChangedV2>(
      _onSectionArchiveChanged,
      transformer: sequential(),
    );
    on<CatalogLessonCreatedV2>(_onLessonCreated, transformer: sequential());
    on<CatalogLessonUpdatedV2>(_onLessonUpdated, transformer: sequential());
    on<CatalogLessonArchiveChangedV2>(
      _onLessonArchiveChanged,
      transformer: sequential(),
    );
    on<CatalogSourceMoveRequestedV2>(_onSourceMove, transformer: sequential());
    on<CatalogSectionMoveRequestedV2>(
      _onSectionMove,
      transformer: sequential(),
    );
    on<CatalogLessonMoveRequestedV2>(_onLessonMove, transformer: sequential());
    on<CatalogLessonStatusChangedV2>(
      _onLessonStatusChanged,
      transformer: sequential(),
    );
  }

  Future<void> init() => _initFuture ??= _initialize();

  void reload() => add(const _CatalogStartedV2());

  Future<RepositorySelectionV1> pickRepository() async {
    final result = await _useCase.pickRepositoryV1(
      params: const CatalogPickRepositoryParamsV1(),
    );
    return result.fold((error) async {
      await _report(error, 'CatalogControllerV2.pickRepository():');
      emitEffect(CatalogFailureEffectV2(studyFailureKindV1(error)));
      return const RepositorySelectionV1.cancelled();
    }, (selection) => selection);
  }

  Future<void> _initialize() async {
    if (state.loadState != CatalogLoadStateV2.initial) return;
    final complete = stream.firstWhere(
      (value) =>
          value.loadState == CatalogLoadStateV2.ready ||
          value.loadState == CatalogLoadStateV2.failed,
    );
    add(const _CatalogStartedV2());
    await complete;
  }

  Future<void> _onStarted(
    _CatalogStartedV2 event,
    Emitter<CatalogStateV2> emit,
  ) async {
    emit(state.copyWith(loadState: CatalogLoadStateV2.loading));
    final result = await _useCase.loadV1(
      params: CatalogLoadParamsV1(preferredStudy: state.selectedStudy),
    );
    await result.fold(
      (error) => _emitFailure(error, emit, 'CatalogControllerV2.load():'),
      (snapshot) async => emit(_readyState(snapshot)),
    );
  }

  Future<void> _onSelected(
    CatalogStudySelectedV2 event,
    Emitter<CatalogStateV2> emit,
  ) async {
    emit(state.copyWith(loadState: CatalogLoadStateV2.loading));
    final result = await _useCase.loadV1(
      params: CatalogLoadParamsV1(preferredStudy: event.study),
    );
    await result.fold(
      (error) => _emitFailure(error, emit, 'CatalogControllerV2.select():'),
      (snapshot) async => emit(_readyState(snapshot)),
    );
  }

  Future<void> _onStudyCreated(
    CatalogStudyCreatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogCreateStudyV1(event.study), emit);

  Future<void> _onStudyUpdated(
    CatalogStudyUpdatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogUpdateStudyV1(event.study), emit);

  Future<void> _onStudyArchiveChanged(
    CatalogStudyArchiveChangedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogArchiveStudyV1(event.study), emit);

  Future<void> _onSourceCreated(
    CatalogSourceCreatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogCreateSourceV1(event.source), emit);

  Future<void> _onSourceUpdated(
    CatalogSourceUpdatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogUpdateSourceV1(event.source), emit);

  Future<void> _onSourceArchiveChanged(
    CatalogSourceArchiveChangedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogArchiveSourceV1(event.source), emit);

  Future<void> _onSectionCreated(
    CatalogSectionCreatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogCreateSectionV1(event.section), emit);

  Future<void> _onSectionUpdated(
    CatalogSectionUpdatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogUpdateSectionV1(event.section), emit);

  Future<void> _onSectionArchiveChanged(
    CatalogSectionArchiveChangedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogArchiveSectionV1(event.section), emit);

  Future<void> _onLessonCreated(
    CatalogLessonCreatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogCreateLessonV1(event.lesson), emit);

  Future<void> _onLessonUpdated(
    CatalogLessonUpdatedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogUpdateLessonV1(event.lesson), emit);

  Future<void> _onLessonArchiveChanged(
    CatalogLessonArchiveChangedV2 event,
    Emitter<CatalogStateV2> emit,
  ) => _mutate(CatalogArchiveLessonV1(event.lesson), emit);

  Future<void> _onSourceMove(
    CatalogSourceMoveRequestedV2 event,
    Emitter<CatalogStateV2> emit,
  ) async {
    final tree = state.tree;
    if (tree == null) return;
    final reorder = _moveItems(
      item: event.source,
      items: tree.source.map((node) => node.source).toList(),
      offset: event.offset,
      id: (value) => value.id,
      position: (value) => value.position,
      version: (value) => value.version,
    );
    if (reorder == null) return;
    await _mutate(
      CatalogReorderMaterialV1(study: tree.study, source: reorder),
      emit,
    );
  }

  Future<void> _onSectionMove(
    CatalogSectionMoveRequestedV2 event,
    Emitter<CatalogStateV2> emit,
  ) async {
    final tree = state.tree;
    if (tree == null) return;
    final reorder = _moveItems(
      item: event.section,
      items: tree.source
          .where((node) => node.source.id == event.section.sourceId)
          .expand((node) => node.section)
          .toList(),
      offset: event.offset,
      id: (value) => value.id,
      position: (value) => value.position,
      version: (value) => value.version,
    );
    if (reorder == null) return;
    await _mutate(
      CatalogReorderMaterialV1(study: tree.study, section: reorder),
      emit,
    );
  }

  Future<void> _onLessonMove(
    CatalogLessonMoveRequestedV2 event,
    Emitter<CatalogStateV2> emit,
  ) async {
    final tree = state.tree;
    if (tree == null) return;
    final reorder = _moveItems(
      item: event.lesson,
      items: tree.source
          .where((node) => node.source.id == event.lesson.sourceId)
          .expand((node) => node.lesson)
          .where((lesson) => lesson.sectionId == event.lesson.sectionId)
          .toList(),
      offset: event.offset,
      id: (value) => value.id,
      position: (value) => value.position,
      version: (value) => value.version,
    );
    if (reorder == null) return;
    await _mutate(
      CatalogReorderMaterialV1(study: tree.study, lesson: reorder),
      emit,
    );
  }

  Future<void> _onLessonStatusChanged(
    CatalogLessonStatusChangedV2 event,
    Emitter<CatalogStateV2> emit,
  ) async {
    final result = await _useCase.mutateV1(
      params: CatalogMutationParamsV1(
        selectedStudy: state.selectedStudy,
        mutation: CatalogChangeLessonStatusV1(event.change),
      ),
    );
    await result.fold((error) async {
      if (error is OpenHomeworkErrorV1) {
        await _report(error, 'CatalogControllerV2.changeStatus():');
        emitEffect(ConfirmOpenHomeworkEffectV2(event.change.lesson.id));
        return;
      }
      await _emitFailure(error, emit, 'CatalogControllerV2.changeStatus():');
    }, (snapshot) async => emit(_readyState(snapshot)));
  }

  List<ReorderItemV1>? _moveItems<T>({
    required T item,
    required List<T> items,
    required int offset,
    required String Function(T value) id,
    required int Function(T value) position,
    required int Function(T value) version,
  }) {
    if (offset.abs() != 1) return null;
    final index = items.indexWhere((value) => value == item);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= items.length) return null;
    return [
      ReorderItemV1(
        id: id(items[index]),
        position: position(items[target]),
        expectedVersion: version(items[index]),
      ),
      ReorderItemV1(
        id: id(items[target]),
        position: position(items[index]),
        expectedVersion: version(items[target]),
      ),
    ];
  }

  Future<void> _mutate(
    CatalogMutationV1 mutation,
    Emitter<CatalogStateV2> emit,
  ) async {
    final result = await _useCase.mutateV1(
      params: CatalogMutationParamsV1(
        selectedStudy: state.selectedStudy,
        mutation: mutation,
      ),
    );
    await result.fold(
      (error) => _emitFailure(error, emit, 'CatalogControllerV2.mutate():'),
      (snapshot) async => emit(_readyState(snapshot)),
    );
  }

  CatalogStateV2 _readyState(CatalogSnapshotV1 snapshot) => state.copyWith(
    loadState: CatalogLoadStateV2.ready,
    study: snapshot.study,
    selectedStudy: () => snapshot.selectedStudy,
    tree: () => snapshot.tree,
    progress: () => snapshot.progress,
    failure: () => null,
  );

  Future<void> _emitFailure(
    DomainError error,
    Emitter<CatalogStateV2> emit,
    String operation,
  ) async {
    await _report(error, operation);
    final failure = studyFailureKindV1(error);
    emit(
      state.copyWith(
        loadState: CatalogLoadStateV2.failed,
        failure: () => failure,
      ),
    );
    emitEffect(CatalogFailureEffectV2(failure));
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

  static void _requireForeground() {
    if (!LaunchMode.isForeground) {
      throw StateError('CatalogControllerV2 requires foreground launch mode.');
    }
  }
}
