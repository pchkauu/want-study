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
  var _loadEpoch = 0;
  String? _pendingStudyId;

  CatalogControllerV2(this._useCase, this._reporter) : super(CatalogStateV2()) {
    _requireForeground();
    on<_CatalogStartedV2>(_onStarted, transformer: restartable());
    on<CatalogStudySelectedV2>(_onSelected, transformer: restartable());
    on<_CatalogMutationQueuedV2>(_onMutationQueued, transformer: sequential());
    on<CatalogStudyCreatedV2>(_queueMutation);
    on<CatalogStudyUpdatedV2>(_queueMutation);
    on<CatalogStudyArchiveChangedV2>(_queueMutation);
    on<CatalogSourceCreatedV2>(_queueMutation);
    on<CatalogSourceUpdatedV2>(_queueMutation);
    on<CatalogSourceArchiveChangedV2>(_queueMutation);
    on<CatalogSectionCreatedV2>(_queueMutation);
    on<CatalogSectionUpdatedV2>(_queueMutation);
    on<CatalogSectionArchiveChangedV2>(_queueMutation);
    on<CatalogLessonCreatedV2>(_queueMutation);
    on<CatalogLessonUpdatedV2>(_queueMutation);
    on<CatalogLessonArchiveChangedV2>(_queueMutation);
    on<CatalogSourceMoveRequestedV2>(_queueMutation);
    on<CatalogSectionMoveRequestedV2>(_queueMutation);
    on<CatalogLessonMoveRequestedV2>(_queueMutation);
    on<CatalogLessonStatusChangedV2>(_queueMutation);
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
    final epoch = ++_loadEpoch;
    _pendingStudyId = state.selectedStudyId;
    emit(state.copyWith(loadState: CatalogLoadStateV2.loading));
    final result = await _useCase.loadV1(
      params: CatalogLoadParamsV1(preferredStudy: state.selectedStudy),
    );
    if (!_isCurrentLoad(epoch, emit)) return;
    await result.fold(
      (error) async {
        if (!_isCurrentLoad(epoch, emit)) return;
        _pendingStudyId = null;
        await _emitFailure(
          error,
          emit,
          'CatalogControllerV2.load():',
          isCurrent: () => _isCurrentLoad(epoch, emit),
        );
      },
      (snapshot) async {
        if (!_isCurrentLoad(epoch, emit)) return;
        _pendingStudyId = null;
        emit(_readyState(snapshot));
      },
    );
  }

  Future<void> _onSelected(
    CatalogStudySelectedV2 event,
    Emitter<CatalogStateV2> emit,
  ) async {
    if (event.study.id == _pendingStudyId ||
        (event.study.id == state.selectedStudyId && _pendingStudyId == null)) {
      return;
    }
    final epoch = ++_loadEpoch;
    _pendingStudyId = event.study.id;
    emit(state.copyWith(loadState: CatalogLoadStateV2.loading));
    final result = await _useCase.loadV1(
      params: CatalogLoadParamsV1(preferredStudy: event.study),
    );
    if (!_isCurrentLoad(epoch, emit)) return;
    await result.fold(
      (error) async {
        if (!_isCurrentLoad(epoch, emit)) return;
        _pendingStudyId = null;
        await _emitFailure(
          error,
          emit,
          'CatalogControllerV2.select():',
          isCurrent: () => _isCurrentLoad(epoch, emit),
        );
      },
      (snapshot) async {
        if (!_isCurrentLoad(epoch, emit)) return;
        _pendingStudyId = null;
        emit(_readyState(snapshot));
      },
    );
  }

  void _queueMutation(CatalogEventV2 event, Emitter<CatalogStateV2> emit) {
    add(_CatalogMutationQueuedV2(event));
  }

  Future<void> _onMutationQueued(
    _CatalogMutationQueuedV2 queued,
    Emitter<CatalogStateV2> emit,
  ) async {
    final mutation = _mutationFor(queued.event);
    if (mutation == null) return;
    if (mutation case CatalogChangeLessonStatusV1(:final change)) {
      await _changeLessonStatus(change, emit);
      return;
    }
    await _mutate(mutation, emit);
  }

  CatalogMutationV1? _mutationFor(CatalogEventV2 event) {
    final tree = state.tree;
    final studyId = state.selectedStudyId;
    switch (event) {
      case CatalogStudyCreatedV2(:final study):
        return CatalogCreateStudyV1(study);
      case CatalogStudyUpdatedV2(:final study):
        if (study.id != studyId) return null;
        final current = _study(study.id);
        return current == null
            ? null
            : CatalogUpdateStudyV1(
                study.copyWith(
                  version: current.version,
                  contentRevision: current.contentRevision,
                  isArchived: current.isArchived,
                ),
              );
      case CatalogStudyArchiveChangedV2(:final study):
        if (study.id != studyId) return null;
        final current = _study(study.id);
        if (current == null || current.isArchived != study.isArchived) {
          return null;
        }
        return CatalogArchiveStudyV1(current);
      case CatalogSourceCreatedV2(:final source):
        return source.studyId == studyId ? CatalogCreateSourceV1(source) : null;
      case CatalogSourceUpdatedV2(:final source):
        if (source.studyId != studyId) return null;
        final current = _source(source.id);
        return current == null
            ? null
            : CatalogUpdateSourceV1(
                source.copyWith(
                  position: current.position,
                  version: current.version,
                  isArchived: current.isArchived,
                ),
              );
      case CatalogSourceArchiveChangedV2(:final source):
        if (source.studyId != studyId) return null;
        final current = _source(source.id);
        if (current == null || current.isArchived != source.isArchived) {
          return null;
        }
        return CatalogArchiveSourceV1(current);
      case CatalogSectionCreatedV2(:final section):
        return section.studyId == studyId
            ? CatalogCreateSectionV1(section)
            : null;
      case CatalogSectionUpdatedV2(:final section):
        if (section.studyId != studyId) return null;
        final current = _section(section.id);
        return current == null
            ? null
            : CatalogUpdateSectionV1(
                section.copyWith(
                  position: current.position,
                  version: current.version,
                  isArchived: current.isArchived,
                ),
              );
      case CatalogSectionArchiveChangedV2(:final section):
        if (section.studyId != studyId) return null;
        final current = _section(section.id);
        if (current == null || current.isArchived != section.isArchived) {
          return null;
        }
        return CatalogArchiveSectionV1(current);
      case CatalogLessonCreatedV2(:final lesson):
        return lesson.studyId == studyId ? CatalogCreateLessonV1(lesson) : null;
      case CatalogLessonUpdatedV2(:final lesson):
        if (lesson.studyId != studyId) return null;
        final current = _lesson(lesson.id);
        return current == null
            ? null
            : CatalogUpdateLessonV1(
                lesson.copyWith(
                  position: current.position,
                  status: current.status,
                  startedAt: () => current.startedAt,
                  masteredAt: () => current.masteredAt,
                  version: current.version,
                  isArchived: current.isArchived,
                ),
              );
      case CatalogLessonArchiveChangedV2(:final lesson):
        if (lesson.studyId != studyId) return null;
        final current = _lesson(lesson.id);
        if (current == null || current.isArchived != lesson.isArchived) {
          return null;
        }
        return CatalogArchiveLessonV1(current);
      case CatalogLessonStatusChangedV2(:final change):
        if (change.lesson.studyId != studyId) return null;
        final current = _lesson(change.lesson.id);
        if (current == null || current.status == change.status) return null;
        return CatalogChangeLessonStatusV1(
          LessonStatusChangeV1(
            lesson: current,
            status: change.status,
            acknowledgeOpenHomework: change.acknowledgeOpenHomework,
          ),
        );
      case CatalogSourceMoveRequestedV2(:final source, :final offset):
        if (tree == null) return null;
        final current = _source(source.id);
        if (current == null) return null;
        final reorder = _moveItems(
          item: current,
          items: tree.source.map((node) => node.source).toList(),
          offset: offset,
          id: (value) => value.id,
          position: (value) => value.position,
          version: (value) => value.version,
        );
        return reorder == null
            ? null
            : CatalogReorderMaterialV1(study: tree.study, source: reorder);
      case CatalogSectionMoveRequestedV2(:final section, :final offset):
        if (tree == null) return null;
        final current = _section(section.id);
        if (current == null) return null;
        final reorder = _moveItems(
          item: current,
          items: tree.source
              .where((node) => node.source.id == current.sourceId)
              .expand((node) => node.section)
              .toList(),
          offset: offset,
          id: (value) => value.id,
          position: (value) => value.position,
          version: (value) => value.version,
        );
        return reorder == null
            ? null
            : CatalogReorderMaterialV1(study: tree.study, section: reorder);
      case CatalogLessonMoveRequestedV2(:final lesson, :final offset):
        if (tree == null) return null;
        final current = _lesson(lesson.id);
        if (current == null) return null;
        final reorder = _moveItems(
          item: current,
          items: tree.source
              .where((node) => node.source.id == current.sourceId)
              .expand((node) => node.lesson)
              .where((value) => value.sectionId == current.sectionId)
              .toList(),
          offset: offset,
          id: (value) => value.id,
          position: (value) => value.position,
          version: (value) => value.version,
        );
        return reorder == null
            ? null
            : CatalogReorderMaterialV1(study: tree.study, lesson: reorder);
      default:
        return null;
    }
  }

  Future<void> _changeLessonStatus(
    LessonStatusChangeV1 change,
    Emitter<CatalogStateV2> emit,
  ) async {
    final epoch = _loadEpoch;
    final studyId = state.selectedStudyId;
    final result = await _useCase.mutateV1(
      params: CatalogMutationParamsV1(
        selectedStudy: state.selectedStudy,
        mutation: CatalogChangeLessonStatusV1(change),
      ),
    );
    if (!_isCurrentMutation(epoch, studyId, emit)) return;
    await result.fold(
      (error) async {
        if (!_isCurrentMutation(epoch, studyId, emit)) return;
        if (error is OpenHomeworkErrorV1) {
          await _report(error, 'CatalogControllerV2.changeStatus():');
          if (!_isCurrentMutation(epoch, studyId, emit)) return;
          emitEffect(ConfirmOpenHomeworkEffectV2(change.lesson.id));
          return;
        }
        await _emitFailure(
          error,
          emit,
          'CatalogControllerV2.changeStatus():',
          isCurrent: () => _isCurrentMutation(epoch, studyId, emit),
        );
      },
      (snapshot) async {
        if (_isCurrentMutation(epoch, studyId, emit)) {
          emit(_readyState(snapshot));
        }
      },
    );
  }

  StudyV1? _study(String id) =>
      state.study.where((value) => value.id == id).firstOrNull;

  LearningSourceV1? _source(String id) => state.tree?.source
      .map((node) => node.source)
      .where((value) => value.id == id)
      .firstOrNull;

  SectionV1? _section(String id) => state.tree?.source
      .expand((node) => node.section)
      .where((value) => value.id == id)
      .firstOrNull;

  LessonV1? _lesson(String id) => state.tree?.source
      .expand((node) => node.lesson)
      .where((value) => value.id == id)
      .firstOrNull;

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
    final epoch = _loadEpoch;
    final studyId = state.selectedStudyId;
    final result = await _useCase.mutateV1(
      params: CatalogMutationParamsV1(
        selectedStudy: state.selectedStudy,
        mutation: mutation,
      ),
    );
    if (!_isCurrentMutation(epoch, studyId, emit)) return;
    await result.fold(
      (error) => _emitFailure(
        error,
        emit,
        'CatalogControllerV2.mutate():',
        isCurrent: () => _isCurrentMutation(epoch, studyId, emit),
      ),
      (snapshot) async {
        if (_isCurrentMutation(epoch, studyId, emit)) {
          emit(_readyState(snapshot));
        }
      },
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
    String operation, {
    bool Function()? isCurrent,
  }) async {
    if (emit.isDone || !(isCurrent?.call() ?? true)) return;
    await _report(error, operation);
    if (emit.isDone || !(isCurrent?.call() ?? true)) return;
    final failure = studyFailureKindV1(error);
    emit(
      state.copyWith(
        loadState: CatalogLoadStateV2.failed,
        failure: () => failure,
      ),
    );
    emitEffect(CatalogFailureEffectV2(failure));
  }

  bool _isCurrentLoad(int epoch, Emitter<CatalogStateV2> emit) =>
      !emit.isDone && _loadEpoch == epoch;

  bool _isCurrentMutation(
    int epoch,
    String? studyId,
    Emitter<CatalogStateV2> emit,
  ) => !emit.isDone && _loadEpoch == epoch && state.selectedStudyId == studyId;

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
