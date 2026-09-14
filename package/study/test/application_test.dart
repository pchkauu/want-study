import 'dart:async';

import 'package:domain_error/domain_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/src/application/_barrel.dart';
import 'package:study/study.dart';

final class _StudyRepository extends Mock implements StudyRepositoryV2 {}

final class _LessonRepository extends Mock
    implements LessonContentRepositoryV2 {}

final class _KnowledgeRepository extends Mock
    implements KnowledgeRepositoryV2 {}

final class _RepositoryPicker extends Mock implements RepositoryPickerService {}

final class _ErrorReporter extends Mock implements StudyErrorReporterV2 {}

void main() {
  late _LessonRepository lessonRepository;
  late _KnowledgeRepository knowledgeRepository;
  late _ErrorReporter reporter;
  late StudyUseCaseExecutor executor;
  late LessonEditorUseCase useCase;

  setUpAll(() {
    LaunchMode.initializeAutomatically();
    registerFallbackValue(_block());
    registerFallbackValue(_task());
    registerFallbackValue(_file());
    registerFallbackValue(_lesson());
    registerFallbackValue(_study());
    registerFallbackValue(_source());
    registerFallbackValue(_concept());
    registerFallbackValue(ConceptSearchV1());
    registerFallbackValue(const <ReorderItemV1>[]);
    registerFallbackValue(
      const StudyErrorContextV1(
        operation: 'test',
        layer: StudyErrorLayerV1.application,
      ),
    );
    registerFallbackValue(const ValidationErrorV1('test'));
    registerFallbackValue(StackTrace.current);
  });

  setUp(() {
    lessonRepository = _LessonRepository();
    knowledgeRepository = _KnowledgeRepository();
    reporter = _ErrorReporter();
    executor = StudyUseCaseExecutor(reporter);
    useCase = LessonEditorUseCase(
      lessonRepository,
      knowledgeRepository,
      executor,
    );
    _stubReporter(reporter);
  });

  test('debounces edits and saves newer draft in sequence', () async {
    final firstSave = Completer<NoteBlockV1>();
    final secondSave = Completer<NoteBlockV1>();
    final secondCall = Completer<void>();
    final saved = <NoteBlockV1>[];
    var call = 0;
    when(() => lessonRepository.getWorkspace(_lesson()))
        .thenAnswer((_) async => _workspace());
    when(() => lessonRepository.updateBlock(any())).thenAnswer((invocation) {
      final block = invocation.positionalArguments.single as NoteBlockV1;
      saved.add(block);
      call++;
      if (call == 2) secondCall.complete();
      return call == 1 ? firstSave.future : secondSave.future;
    });
    final controller = LessonEditorControllerV2.withAutosaveDelay(
      useCase,
      reporter,
      const Duration(milliseconds: 10),
    );
    addTearDown(controller.close);

    controller.add(LessonEditorStartedV2(_lesson()));
    await controller.stream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV2.ready,
    );
    controller.add(
      LessonEditorBlockChangedV2(_block().copyWith(markdown: 'first')),
    );
    await controller.stream.firstWhere(
      (state) => state.saveState == SaveStateV1.saving,
    );
    controller.add(
      LessonEditorBlockChangedV2(_block().copyWith(markdown: 'second')),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(saved, hasLength(1));

    firstSave.complete(saved.first.copyWith(version: 2));
    await secondCall.future.timeout(const Duration(seconds: 1));
    expect(saved.last.markdown, 'second');
    expect(saved.last.version, 2);

    secondSave.complete(saved.last.copyWith(version: 3));
    await controller.stream.firstWhere(
      (state) => state.saveState == SaveStateV1.saved,
    );
    expect(controller.state.workspace!.block.single.markdown, 'second');
    expect(controller.state.workspace!.block.single.version, 3);
  });

  test('debounces and saves two note blocks independently', () async {
    final secondBlock = _block(id: 'block-2', position: 1);
    final workspace = _workspace(block: [_block(), secondBlock]);
    final saved = <NoteBlockV1>[];
    when(() => lessonRepository.getWorkspace(_lesson()))
        .thenAnswer((_) async => workspace);
    when(() => lessonRepository.updateBlock(any())).thenAnswer((invocation) {
      final block = invocation.positionalArguments.single as NoteBlockV1;
      saved.add(block);
      return Future.value(block.copyWith(version: block.version + 1));
    });
    final controller = LessonEditorControllerV2.withAutosaveDelay(
      useCase,
      reporter,
      const Duration(milliseconds: 10),
    );
    addTearDown(controller.close);

    controller.add(LessonEditorStartedV2(_lesson()));
    await controller.stream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV2.ready,
    );
    controller
      ..add(LessonEditorBlockChangedV2(_block().copyWith(markdown: 'first')))
      ..add(
        LessonEditorBlockChangedV2(secondBlock.copyWith(markdown: 'second')),
      );

    await controller.stream.firstWhere(
      (state) => state.saveState == SaveStateV1.saved,
    );
    expect(
      saved.map((value) => value.id),
      containsAll(['block-id', 'block-2']),
    );
    expect(saved, hasLength(2));
  });

  test('serializes rapid task updates with current versions', () async {
    final firstUpdate = Completer<void>();
    var storedTask = _task();
    final version = <int>[];
    var call = 0;
    when(() => lessonRepository.getWorkspace(_lesson()))
        .thenAnswer((_) async => _workspace(task: [storedTask]));
    when(() => lessonRepository.updateTask(any()))
        .thenAnswer((invocation) async {
          final task = invocation.positionalArguments.single as HomeworkTaskV1;
          version.add(task.version);
          call++;
          if (call == 1) await firstUpdate.future;
          storedTask = task.copyWith(version: task.version + 1);
          return storedTask;
        });
    final controller = LessonEditorControllerV2.withAutosaveDelay(
      useCase,
      reporter,
      Duration.zero,
    );
    addTearDown(controller.close);

    controller.add(LessonEditorStartedV2(_lesson()));
    await controller.stream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV2.ready,
    );
    final done = _task().copyWith(status: HomeworkStatusV1.done);
    controller
      ..add(LessonEditorTaskChangedV2(done))
      ..add(LessonEditorTaskChangedV2(done));
    await untilCalled(() => lessonRepository.updateTask(any()));
    firstUpdate.complete();
    await controller.stream.firstWhere(
      (state) => state.saveState == SaveStateV1.saved,
    );

    expect(version, [1, 2]);
    expect(controller.state.workspace!.task.single.version, 3);
  });

  test('rebases update queued after reorder', () async {
    var task = [_task(), _task(id: 'task-2', position: 1)];
    HomeworkTaskV1? updated;
    when(() => lessonRepository.getWorkspace(_lesson()))
        .thenAnswer((_) async => _workspace(task: task));
    when(
      () => lessonRepository.reorderContent(
        lesson: any(named: 'lesson'),
        block: any(named: 'block'),
        task: any(named: 'task'),
      ),
    ).thenAnswer((_) async {
      task = [
        task[1].copyWith(position: 0, version: 2),
        task[0].copyWith(position: 1, version: 2),
      ];
      return _workspace(task: task);
    });
    when(() => lessonRepository.updateTask(any()))
        .thenAnswer((invocation) async {
          updated = invocation.positionalArguments.single as HomeworkTaskV1;
          task = [task.first, updated!.copyWith(version: updated!.version + 1)];
          return task.last;
        });
    final controller = LessonEditorControllerV2.withAutosaveDelay(
      useCase,
      reporter,
      Duration.zero,
    );
    addTearDown(controller.close);

    controller.add(LessonEditorStartedV2(_lesson()));
    await controller.stream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV2.ready,
    );
    controller
      ..add(LessonEditorTaskMoveRequestedV2(_task(), 1))
      ..add(
        LessonEditorTaskChangedV2(_task().copyWith(promptMarkdown: 'updated')),
      );
    await controller.stream.firstWhere(
      (state) => state.saveState == SaveStateV1.saved,
    );

    expect(updated?.version, 2);
    expect(updated?.position, 1);
  });

  for (final (name, kind, failure) in [
    ('task mutation after failure', 'task', const UnavailableErrorV1()),
    ('file mutation after failure', 'file', const UnavailableErrorV1()),
    ('mutation after conflict', 'task', const ConflictErrorV1('task/task-id')),
  ]) {
    test('retries $name', () async {
      var task = _task();
      var file = _file();
      var calls = 0;
      when(() => lessonRepository.getWorkspace(_lesson()))
          .thenAnswer((_) async => _workspace(task: [task], file: [file]));
      if (kind == 'task') {
        when(() => lessonRepository.updateTask(any())).thenAnswer((invocation) {
          calls++;
          if (calls == 1) {
            throw failure;
          }
          final value = invocation.positionalArguments.single as HomeworkTaskV1;
          task = value.copyWith(version: value.version + 1);
          return Future.value(task);
        });
      } else {
        when(() => lessonRepository.updateFile(any())).thenAnswer((invocation) {
          calls++;
          if (calls == 1) {
            throw failure;
          }
          final value = invocation.positionalArguments.single as CodeFileV1;
          file = value.copyWith(version: value.version + 1);
          return Future.value(file);
        });
      }
      final controller = LessonEditorControllerV2.withAutosaveDelay(
        useCase,
        reporter,
        Duration.zero,
      );
      addTearDown(controller.close);

      controller.add(LessonEditorStartedV2(_lesson()));
      await controller.stream.firstWhere(
        (state) => state.loadState == LessonEditorLoadStateV2.ready,
      );
      controller.add(
        kind == 'task'
            ? LessonEditorTaskChangedV2(
                task.copyWith(status: HomeworkStatusV1.done),
              )
            : LessonEditorFileChangedV2(file.copyWith(content: 'updated')),
      );
      await controller.stream.firstWhere(
        (state) =>
            state.saveState ==
            (failure is ConflictErrorV1
                ? SaveStateV1.conflict
                : SaveStateV1.failed),
      );
      controller.add(const LessonEditorRetrySaveV2());
      await controller.stream.firstWhere(
        (state) => state.saveState == SaveStateV1.saved,
      );

      expect(calls, 2);
    });
  }

  test('discard cancels drafts and reloads server text', () async {
    final server = _block().copyWith(markdown: 'server');
    when(() => lessonRepository.getWorkspace(_lesson()))
        .thenAnswer((_) async => _workspace(block: [server]));
    final controller = LessonEditorControllerV2.withAutosaveDelay(
      useCase,
      reporter,
      const Duration(seconds: 1),
    );
    addTearDown(controller.close);

    controller.add(LessonEditorStartedV2(_lesson()));
    await controller.stream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV2.ready,
    );
    controller.add(
      LessonEditorBlockChangedV2(server.copyWith(markdown: 'draft')),
    );
    await controller.stream.firstWhere(
      (state) => state.saveState == SaveStateV1.dirty,
    );
    controller.add(const LessonEditorDiscardV2());
    await controller.stream.firstWhere(
      (state) =>
          state.loadState == LessonEditorLoadStateV2.ready &&
          state.workspace?.block.single.markdown == 'server',
    );

    verifyNever(() => lessonRepository.updateBlock(any()));
  });

  test('close cancels every block autosave timer', () async {
    final secondBlock = _block(id: 'block-2', position: 1);
    when(() => lessonRepository.getWorkspace(_lesson()))
        .thenAnswer((_) async => _workspace(block: [_block(), secondBlock]));
    final controller = LessonEditorControllerV2.withAutosaveDelay(
      useCase,
      reporter,
      const Duration(milliseconds: 30),
    );

    final stateStream = controller.stream;
    controller.add(LessonEditorStartedV2(_lesson()));
    await stateStream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV2.ready,
    );
    controller
      ..add(LessonEditorBlockChangedV2(_block().copyWith(markdown: 'first')))
      ..add(
        LessonEditorBlockChangedV2(secondBlock.copyWith(markdown: 'second')),
      );
    await controller.stream.firstWhere((state) => state.draftRevision == 2);
    await controller.close();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    verifyNever(() => lessonRepository.updateBlock(any()));
  });

  test('maps conflict to typed state and one-time effect', () async {
    when(() => lessonRepository.getWorkspace(_lesson()))
        .thenAnswer((_) async => _workspace());
    when(() => lessonRepository.updateBlock(any()))
        .thenThrow(const ConflictErrorV1('block/block-id'));
    final controller = LessonEditorControllerV2.withAutosaveDelay(
      useCase,
      reporter,
      Duration.zero,
    );
    addTearDown(controller.close);
    final effect = controller.effectsStream.first;

    controller.add(LessonEditorStartedV2(_lesson()));
    await controller.stream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV2.ready,
    );
    controller.add(
      LessonEditorBlockChangedV2(_block().copyWith(markdown: 'draft')),
    );

    expect(
      await effect,
      const LessonEditorFailureEffectV2(StudyFailureKindV1.conflict),
    );
    expect(controller.state.saveState, SaveStateV1.conflict);
    final contexts = verify(
      () => reporter.reportDomainError(
        context: captureAny(named: 'context'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).captured.cast<StudyErrorContextV1>();
    expect(
      contexts.map((value) => value.layer),
      containsAll([
        StudyErrorLayerV1.application,
        StudyErrorLayerV1.controller,
      ]),
    );
  });

  test('maps raw failure and reports application layer', () async {
    final result = await executor.call<void>(
      operation: 'TestUseCase.runV1():',
      body: () => throw StateError('failed'),
    );

    expect(result.errorValue, isA<UnexpectedErrorV1>());
    verify(
      () => reporter.reportRawError(
        context: any(named: 'context'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).called(1);
  });

  test('preserves DomainError when observer fails', () async {
    const expected = ConflictErrorV1('lesson');
    when(
      () => reporter.reportDomainError(
        context: any(named: 'context'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenThrow(StateError('report failed'));

    final result = await executor.call<void>(
      operation: 'TestUseCase.runV1():',
      body: () => throw expected,
    );

    expect(identical(result.errorValue, expected), isTrue);
    verify(
      () => reporter.reportObserverError(
        context: any(named: 'context'),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).called(1);
  });

  test('catalog init shares one in-flight load', () async {
    final studyRepository = _StudyRepository();
    final picker = _RepositoryPicker();
    final studies = Completer<List<StudyV1>>();
    when(
      () => studyRepository.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).thenAnswer((_) => studies.future);
    final catalogUseCase = CatalogUseCase(studyRepository, picker, executor);
    final controller = CatalogControllerV2(catalogUseCase, reporter);
    addTearDown(controller.close);

    final first = controller.init();
    final second = controller.init();
    expect(identical(first, second), isTrue);
    studies.complete(const []);
    await first;

    verify(
      () => studyRepository.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).called(1);
    expect(controller.state.loadState, CatalogLoadStateV2.ready);
  });

  test('catalog rebases update queued after reorder', () async {
    final studyRepository = _StudyRepository();
    final picker = _RepositoryPicker();
    var source = [_source(), _source(id: 'source-2', position: 1)];
    LearningSourceV1? updated;
    when(
      () => studyRepository.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).thenAnswer((_) async => [_study()]);
    when(
      () => studyRepository.getMaterialTree(
        study: any(named: 'study'),
        scope: ArchiveScopeV1.includeArchived,
      ),
    ).thenAnswer((_) async => _tree(source));
    when(() => studyRepository.getDashboard(any()))
        .thenAnswer((_) async => _progress());
    when(
      () => studyRepository.reorderMaterial(
        study: any(named: 'study'),
        source: any(named: 'source'),
        section: any(named: 'section'),
        lesson: any(named: 'lesson'),
      ),
    ).thenAnswer((_) async {
      source = [
        source[1].copyWith(position: 0, version: 2),
        source[0].copyWith(position: 1, version: 2),
      ];
      return _tree(source);
    });
    when(() => studyRepository.updateSource(any())).thenAnswer((call) async {
      updated = call.positionalArguments.single as LearningSourceV1;
      source = [source.first, updated!.copyWith(version: updated!.version + 1)];
      return source.last;
    });
    final controller = CatalogControllerV2(
      CatalogUseCase(studyRepository, picker, executor),
      reporter,
    );
    addTearDown(controller.close);

    await controller.init();
    controller
      ..add(CatalogSourceMoveRequestedV2(_source(), 1))
      ..add(
        CatalogSourceUpdatedV2(_source().copyWith(title: 'Updated source')),
      );
    await untilCalled(() => studyRepository.updateSource(any()));

    expect(updated?.version, 2);
    expect(updated?.position, 1);
  });

  test('concept mutations share one queue and use current version', () async {
    var concept = [_concept(), _concept(id: 'concept-2', title: 'Second')];
    final updateGate = Completer<void>();
    ConceptV1? archived;
    when(
      () => knowledgeRepository.getGraph(
        study: any(named: 'study'),
        selectedConcept: any(named: 'selectedConcept'),
      ),
    ).thenAnswer((_) async => ConceptGraphV1(concept: concept));
    when(
      () => knowledgeRepository.searchConcepts(
        study: any(named: 'study'),
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => concept);
    when(() => knowledgeRepository.updateConcept(any()))
        .thenAnswer((call) async {
          await updateGate.future;
          final value = call.positionalArguments.single as ConceptV1;
          concept = [value.copyWith(version: 2), concept.last];
          return concept.first;
        });
    when(() => knowledgeRepository.archiveConcept(any()))
        .thenAnswer((call) async {
          archived = call.positionalArguments.single as ConceptV1;
          concept = [
            archived!.copyWith(version: 3, isArchived: true),
            concept.last,
          ];
          return concept.first;
        });
    final controller = ConceptControllerV1(
      ConceptUseCase(knowledgeRepository, executor),
      reporter,
    );
    addTearDown(controller.close);

    controller.add(ConceptStartedV1(_study()));
    await controller.stream.firstWhere(
      (state) => state.loadState == ConceptLoadStateV1.ready,
    );
    controller
      ..add(ConceptUpdatedV1(_concept().copyWith(title: 'Updated')))
      ..add(ConceptArchiveChangedV1(_concept()));
    await untilCalled(() => knowledgeRepository.updateConcept(any()));
    updateGate.complete();
    await untilCalled(() => knowledgeRepository.archiveConcept(any()));
    await controller.stream.firstWhere(
      (state) => state.graph?.concept.first.isArchived ?? false,
    );

    expect(archived?.version, 2);
  });

  test('repository picker cancellation stays a normal result', () async {
    final studyRepository = _StudyRepository();
    final picker = _RepositoryPicker();
    when(picker.pickRepository).thenAnswer(
      (_) async => const Either.success(RepositorySelectionV1.cancelled()),
    );
    final catalogUseCase = CatalogUseCase(studyRepository, picker, executor);

    final result = await catalogUseCase.pickRepositoryV1(
      params: const CatalogPickRepositoryParamsV1(),
    );

    expect(result.successValue.isSelected, isFalse);
    verify(picker.pickRepository).called(1);
  });
}

void _stubReporter(_ErrorReporter reporter) {
  when(
    () => reporter.reportDomainError(
      context: any(named: 'context'),
      error: any(named: 'error'),
      stackTrace: any(named: 'stackTrace'),
    ),
  ).thenAnswer((_) async {});
  when(
    () => reporter.reportRawError(
      context: any(named: 'context'),
      error: any(named: 'error'),
      stackTrace: any(named: 'stackTrace'),
    ),
  ).thenAnswer((_) async {});
  when(
    () => reporter.reportObserverError(
      context: any(named: 'context'),
      error: any(named: 'error'),
      stackTrace: any(named: 'stackTrace'),
    ),
  ).thenAnswer((_) async {});
}

LessonV1 _lesson() => LessonV1(
  id: 'lesson-id',
  studyId: 'study-id',
  sourceId: 'source-id',
  title: 'Lesson',
  exportSlug: 'lesson',
  position: 0,
);

LessonWorkspaceV1 _workspace({
  List<NoteBlockV1>? block,
  List<HomeworkTaskV1> task = const [],
  List<CodeFileV1> file = const [],
}) => LessonWorkspaceV1(
  lesson: _lesson(),
  block: block ?? [_block()],
  task: task,
  file: file,
);

NoteBlockV1 _block({String id = 'block-id', int position = 0}) => NoteBlockV1(
  id: id,
  studyId: 'study-id',
  lessonId: 'lesson-id',
  type: NoteBlockTypeV1.text,
  position: position,
);

HomeworkTaskV1 _task({String id = 'task-id', int position = 0}) =>
    HomeworkTaskV1(
      id: id,
      studyId: 'study-id',
      lessonId: 'lesson-id',
      promptMarkdown: 'task',
      position: position,
    );

CodeFileV1 _file() => CodeFileV1(
  id: 'file-id',
  studyId: 'study-id',
  lessonId: 'lesson-id',
  relativePath: 'main.c',
);

StudyV1 _study() => StudyV1(id: 'study-id', title: 'Study');

LearningSourceV1 _source({String id = 'source-id', int position = 0}) =>
    LearningSourceV1(
      id: id,
      studyId: 'study-id',
      type: LearningSourceTypeV1.course,
      title: 'Source',
      exportSlug: id,
      position: position,
    );

MaterialTreeV1 _tree(List<LearningSourceV1> source) => MaterialTreeV1(
  study: _study(),
  source: [for (final value in source) LearningSourceNodeV1(source: value)],
);

StudyProgressV1 _progress() => StudyProgressV1(
  material: ProgressIndicatorV1(completed: 0, total: 0),
  homework: ProgressIndicatorV1(completed: 0, total: 0),
  lessonStatusCount: const {},
  studyRevision: 1,
);

ConceptV1 _concept({String id = 'concept-id', String title = 'Concept'}) =>
    ConceptV1(id: id, studyId: 'study-id', title: title, exportSlug: id);
