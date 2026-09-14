import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:equatable/equatable.dart';
import 'package:study/src/application/safe_call.dart';
import 'package:study/src/domain/error/study_error.dart';
import 'package:study/src/domain/model/learning_source.dart';
import 'package:study/src/domain/model/lesson.dart';
import 'package:study/src/domain/model/material_tree.dart';
import 'package:study/src/domain/model/reorder_item.dart';
import 'package:study/src/domain/model/section.dart';
import 'package:study/src/domain/model/study.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/model/study_progress.dart';
import 'package:study/src/domain/repository/study_repository.dart';

enum CatalogLoadStateV1 { initial, loading, ready, failed }

sealed class CatalogEventV1 {
  const CatalogEventV1();
}

final class CatalogStartedV1 extends CatalogEventV1 {
  const CatalogStartedV1();
}

final class CatalogStudySelectedV1 extends CatalogEventV1 {
  final String studyId;

  const CatalogStudySelectedV1(this.studyId);
}

final class CatalogStudyCreatedV1 extends CatalogEventV1 {
  final StudyV1 study;

  const CatalogStudyCreatedV1(this.study);
}

final class CatalogSourceCreatedV1 extends CatalogEventV1 {
  final LearningSourceV1 source;

  const CatalogSourceCreatedV1(this.source);
}

final class CatalogSectionCreatedV1 extends CatalogEventV1 {
  final SectionV1 section;

  const CatalogSectionCreatedV1(this.section);
}

final class CatalogLessonCreatedV1 extends CatalogEventV1 {
  final LessonV1 lesson;

  const CatalogLessonCreatedV1(this.lesson);
}

final class CatalogItemUpdatedV1 extends CatalogEventV1 {
  final Object item;

  const CatalogItemUpdatedV1(this.item);
}

final class CatalogItemArchiveChangedV1 extends CatalogEventV1 {
  final Object item;

  const CatalogItemArchiveChangedV1(this.item);
}

final class CatalogItemMoveRequestedV1 extends CatalogEventV1 {
  final Object item;
  final int offset;

  const CatalogItemMoveRequestedV1(this.item, this.offset);
}

final class CatalogLessonStatusChangedV1 extends CatalogEventV1 {
  final LessonV1 lesson;
  final LessonStatusV1 status;
  final bool acknowledgeOpenHomework;

  const CatalogLessonStatusChangedV1({
    required this.lesson,
    required this.status,
    this.acknowledgeOpenHomework = false,
  });
}

sealed class CatalogEffectV1 {
  const CatalogEffectV1();
}

final class CatalogFailureEffectV1 extends CatalogEffectV1 {
  final String errorIdentifier;

  const CatalogFailureEffectV1(this.errorIdentifier);

  @override
  String toString() => 'CatalogFailureEffectV1($errorIdentifier)';
}

final class ConfirmOpenHomeworkEffectV1 extends CatalogEffectV1 {
  final String lessonId;

  const ConfirmOpenHomeworkEffectV1(this.lessonId);

  @override
  String toString() => 'ConfirmOpenHomeworkEffectV1';
}

final class CatalogStateV1 extends Equatable {
  final CatalogLoadStateV1 loadState;
  final List<StudyV1> study;
  final String? selectedStudyId;
  final MaterialTreeV1? tree;
  final StudyProgressV1? progress;
  final String? errorIdentifier;

  CatalogStateV1({
    this.loadState = CatalogLoadStateV1.initial,
    Iterable<StudyV1> study = const [],
    this.selectedStudyId,
    this.tree,
    this.progress,
    this.errorIdentifier,
  }) : study = List.unmodifiable(study);

  CatalogStateV1 copyWith({
    CatalogLoadStateV1? loadState,
    Iterable<StudyV1>? study,
    String? Function()? selectedStudyId,
    MaterialTreeV1? Function()? tree,
    StudyProgressV1? Function()? progress,
    String? Function()? errorIdentifier,
  }) {
    return CatalogStateV1(
      loadState: loadState ?? this.loadState,
      study: study ?? this.study,
      selectedStudyId: selectedStudyId == null
          ? this.selectedStudyId
          : selectedStudyId(),
      tree: tree == null ? this.tree : tree(),
      progress: progress == null ? this.progress : progress(),
      errorIdentifier: errorIdentifier == null
          ? this.errorIdentifier
          : errorIdentifier(),
    );
  }

  @override
  List<Object?> get props => [
    loadState,
    [for (final value in study) _studyState(value)],
    selectedStudyId,
    tree,
    progress,
    errorIdentifier,
  ];
}

Object _studyState(StudyV1 value) => (
  value.id,
  value.title,
  value.goal,
  value.localRepositoryPath,
  value.version,
  value.contentRevision,
  value.isArchived,
);

final class CatalogBlocV1
    extends BlocWithEffects<CatalogEventV1, CatalogStateV1, CatalogEffectV1> {
  final StudyRepositoryV1 repository;

  CatalogBlocV1(this.repository) : super(CatalogStateV1()) {
    on<CatalogStartedV1>(_onStarted, transformer: restartable());
    on<CatalogStudySelectedV1>(_onSelected, transformer: restartable());
    on<CatalogStudyCreatedV1>(_onStudyCreated, transformer: sequential());
    on<CatalogSourceCreatedV1>(_onSourceCreated, transformer: sequential());
    on<CatalogSectionCreatedV1>(_onSectionCreated, transformer: sequential());
    on<CatalogLessonCreatedV1>(_onLessonCreated, transformer: sequential());
    on<CatalogItemUpdatedV1>(_onItemUpdated, transformer: sequential());
    on<CatalogItemArchiveChangedV1>(
      _onItemArchiveChanged,
      transformer: sequential(),
    );
    on<CatalogItemMoveRequestedV1>(
      _onItemMoveRequested,
      transformer: sequential(),
    );
    on<CatalogLessonStatusChangedV1>(
      _onLessonStatusChanged,
      transformer: sequential(),
    );
  }

  Future<void> _onStarted(
    CatalogStartedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    emit(state.copyWith(loadState: CatalogLoadStateV1.loading));
    final result = await studySafeCallV1(
      'catalog.list',
      () => repository.listStudies(includeArchived: true),
    );
    await result.fold((error) async => _emitFailure(error, emit), (
      studies,
    ) async {
      if (studies.isEmpty) {
        emit(
          state.copyWith(
            loadState: CatalogLoadStateV1.ready,
            study: studies,
            selectedStudyId: () => null,
            tree: () => null,
            progress: () => null,
            errorIdentifier: () => null,
          ),
        );
        return;
      }
      emit(
        state.copyWith(study: studies, selectedStudyId: () => studies.first.id),
      );
      await _loadStudy(studies.first.id, emit);
    });
  }

  Future<void> _onSelected(
    CatalogStudySelectedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    emit(
      state.copyWith(
        loadState: CatalogLoadStateV1.loading,
        selectedStudyId: () => event.studyId,
      ),
    );
    await _loadStudy(event.studyId, emit);
  }

  Future<void> _loadStudy(String studyId, Emitter<CatalogStateV1> emit) async {
    final result = await studySafeCallV1(
      'catalog.load',
      () async => (
        await repository.getMaterialTree(studyId, includeArchived: true),
        await repository.getDashboard(studyId),
      ),
    );
    result.fold(
      (error) => _emitFailure(error, emit),
      (data) => emit(
        state.copyWith(
          loadState: CatalogLoadStateV1.ready,
          tree: () => data.$1,
          progress: () => data.$2,
          errorIdentifier: () => null,
        ),
      ),
    );
  }

  Future<void> _onStudyCreated(
    CatalogStudyCreatedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    final result = await studySafeCallV1(
      'catalog.createStudy',
      () => repository.createStudy(event.study),
    );
    await result.fold((error) async => _emitFailure(error, emit), (
      study,
    ) async {
      emit(
        state.copyWith(
          study: [...state.study, study],
          selectedStudyId: () => study.id,
        ),
      );
      await _loadStudy(study.id, emit);
    });
  }

  Future<void> _onSourceCreated(
    CatalogSourceCreatedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    await _writeAndReload(
      'catalog.createSource',
      () => repository.createSource(event.source),
      emit,
    );
  }

  Future<void> _onSectionCreated(
    CatalogSectionCreatedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    await _writeAndReload(
      'catalog.createSection',
      () => repository.createSection(event.section),
      emit,
    );
  }

  Future<void> _onLessonCreated(
    CatalogLessonCreatedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    await _writeAndReload(
      'catalog.createLesson',
      () => repository.createLesson(event.lesson),
      emit,
    );
  }

  Future<void> _onItemUpdated(
    CatalogItemUpdatedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    final result = await studySafeCallV1(
      'catalog.updateItem',
      () => switch (event.item) {
        final StudyV1 item => repository.updateStudy(item),
        final LearningSourceV1 item => repository.updateSource(item),
        final SectionV1 item => repository.updateSection(item),
        final LessonV1 item => repository.updateLesson(item),
        _ => throw const ValidationErrorV1('item'),
      },
    );
    await result.fold((error) async => _emitFailure(error, emit), (item) async {
      if (item is StudyV1) {
        _replaceStudy(item, emit);
      }
      await _reloadSelected(emit);
    });
  }

  Future<void> _onItemArchiveChanged(
    CatalogItemArchiveChangedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    final result = await studySafeCallV1(
      'catalog.archiveItem',
      () => switch (event.item) {
        final StudyV1 item =>
          item.isArchived
              ? repository.restoreStudy(item)
              : repository.archiveStudy(item),
        final LearningSourceV1 item =>
          item.isArchived
              ? repository.restoreSource(item)
              : repository.archiveSource(item),
        final SectionV1 item =>
          item.isArchived
              ? repository.restoreSection(item)
              : repository.archiveSection(item),
        final LessonV1 item =>
          item.isArchived
              ? repository.restoreLesson(item)
              : repository.archiveLesson(item),
        _ => throw const ValidationErrorV1('item'),
      },
    );
    await result.fold((error) async => _emitFailure(error, emit), (item) async {
      if (item is StudyV1) {
        _replaceStudy(item, emit);
      }
      await _reloadSelected(emit);
    });
  }

  Future<void> _onItemMoveRequested(
    CatalogItemMoveRequestedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    final tree = state.tree;
    if (tree == null || event.offset.abs() != 1) {
      return;
    }
    final items = switch (event.item) {
      LearningSourceV1() => tree.source.map((node) => node.source).toList(),
      final SectionV1 item =>
        tree.source
            .where((node) => node.source.id == item.sourceId)
            .expand((node) => node.section)
            .toList(),
      final LessonV1 item =>
        tree.source
            .where((node) => node.source.id == item.sourceId)
            .expand((node) => node.lesson)
            .where((lesson) => lesson.sectionId == item.sectionId)
            .toList(),
      _ => const <Object>[],
    };
    final index = items.indexWhere((item) => item == event.item);
    final target = index + event.offset;
    if (index < 0 || target < 0 || target >= items.length) {
      return;
    }
    final first = _reorderItem(items[index], _position(items[target]));
    final second = _reorderItem(items[target], _position(items[index]));
    await _writeAndReload(
      'catalog.reorderMaterial',
      () => repository.reorderMaterial(
        studyId: tree.study.id,
        source: event.item is LearningSourceV1 ? [first, second] : const [],
        section: event.item is SectionV1 ? [first, second] : const [],
        lesson: event.item is LessonV1 ? [first, second] : const [],
      ),
      emit,
    );
  }

  ReorderItemV1 _reorderItem(Object item, int position) => ReorderItemV1(
    id: switch (item) {
      final LearningSourceV1 value => value.id,
      final SectionV1 value => value.id,
      final LessonV1 value => value.id,
      _ => throw const ValidationErrorV1('item'),
    },
    position: position,
    expectedVersion: switch (item) {
      final LearningSourceV1 value => value.version,
      final SectionV1 value => value.version,
      final LessonV1 value => value.version,
      _ => throw const ValidationErrorV1('item'),
    },
  );

  int _position(Object item) => switch (item) {
    final LearningSourceV1 value => value.position,
    final SectionV1 value => value.position,
    final LessonV1 value => value.position,
    _ => throw const ValidationErrorV1('item'),
  };

  void _replaceStudy(StudyV1 study, Emitter<CatalogStateV1> emit) {
    emit(
      state.copyWith(
        study: [
          for (final current in state.study)
            if (current.id == study.id) study else current,
        ],
      ),
    );
  }

  Future<void> _onLessonStatusChanged(
    CatalogLessonStatusChangedV1 event,
    Emitter<CatalogStateV1> emit,
  ) async {
    final result = await studySafeCallV1(
      'catalog.changeLessonStatus',
      () => repository.changeLessonStatus(
        lesson: event.lesson,
        status: event.status,
        acknowledgeOpenHomework: event.acknowledgeOpenHomework,
      ),
    );
    await result.fold((error) async {
      if (error is OpenHomeworkErrorV1) {
        emitEffect(ConfirmOpenHomeworkEffectV1(event.lesson.id));
        return;
      }
      _emitFailure(error, emit);
    }, (_) async => _reloadSelected(emit));
  }

  Future<void> _writeAndReload<T>(
    String operation,
    Future<T> Function() call,
    Emitter<CatalogStateV1> emit,
  ) async {
    final result = await studySafeCallV1(operation, call);
    await result.fold(
      (error) async => _emitFailure(error, emit),
      (_) async => _reloadSelected(emit),
    );
  }

  Future<void> _reloadSelected(Emitter<CatalogStateV1> emit) async {
    final studyId = state.selectedStudyId;
    if (studyId != null) {
      await _loadStudy(studyId, emit);
    }
  }

  void _emitFailure(Object error, Emitter<CatalogStateV1> emit) {
    final identifier = error is StudyErrorV1
        ? error.typeIdentifier
        : 'UnexpectedErrorV1';
    emit(
      state.copyWith(
        loadState: CatalogLoadStateV1.failed,
        errorIdentifier: () => identifier,
      ),
    );
    emitEffect(CatalogFailureEffectV1(identifier));
  }
}
