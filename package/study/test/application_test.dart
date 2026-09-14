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
    registerFallbackValue(_lesson());
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

LessonWorkspaceV1 _workspace() =>
    LessonWorkspaceV1(lesson: _lesson(), block: [_block()]);

NoteBlockV1 _block() => NoteBlockV1(
  id: 'block-id',
  studyId: 'study-id',
  lessonId: 'lesson-id',
  type: NoteBlockTypeV1.text,
  position: 0,
);
