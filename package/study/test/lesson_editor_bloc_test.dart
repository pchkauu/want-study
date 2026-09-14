import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/src/application/safe_call.dart';
import 'package:study/study.dart';

final class _MockStudyRepository extends Mock implements StudyRepositoryV1 {}

final class _MockLessonRepository extends Mock
    implements LessonContentRepositoryV1 {}

final class _MockKnowledgeRepository extends Mock
    implements KnowledgeRepositoryV1 {}

final class _MockPublicationRepository extends Mock
    implements StudyPublicationRepositoryV1 {}

final class _MockRepositoryPicker extends Mock implements RepositoryPickerV1 {}

final class _ErrorReporter extends Mock implements StudyErrorReporterV1 {}

void main() {
  final repository = _MockLessonRepository();
  final reporter = _ErrorReporter();

  setUpAll(() async {
    registerFallbackValue(_block());
    registerFallbackValue(const ValidationErrorV1('test'));
    registerFallbackValue(StackTrace.current);
    await initPackage(
      config: const Config(),
      dependencies: Dependencies(
        studyRepository: _MockStudyRepository(),
        lessonContentRepository: repository,
        knowledgeRepository: _MockKnowledgeRepository(),
        publicationRepository: _MockPublicationRepository(),
        errorReporter: reporter,
        repositoryPicker: _MockRepositoryPicker(),
      ),
    );
  });

  setUp(() {
    reset(repository);
    reset(reporter);
    when(() => reporter.reportDomainError(any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => reporter.reportRawError(any(), any(), any()))
        .thenAnswer((_) async {});
  });

  test(
    'debounces edits and saves in order without losing newer text',
    () async {
      final firstSave = Completer<NoteBlockV1>();
      final secondSave = Completer<NoteBlockV1>();
      final secondCall = Completer<void>();
      final saved = <NoteBlockV1>[];
      var call = 0;
      when(() => repository.getWorkspace('lesson-id'))
          .thenAnswer((_) async => _workspace());
      when(() => repository.updateBlock(any())).thenAnswer((invocation) {
        final block = invocation.positionalArguments.single as NoteBlockV1;
        saved.add(block);
        call++;
        if (call == 2) {
          secondCall.complete();
        }
        return call == 1 ? firstSave.future : secondSave.future;
      });
      final bloc = LessonEditorBlocV1(
        repository: repository,
        autosaveDelay: const Duration(milliseconds: 10),
      );
      addTearDown(bloc.close);

      bloc.add(const LessonEditorStartedV1('lesson-id'));
      await bloc.stream.firstWhere(
        (state) => state.loadState == LessonEditorLoadStateV1.ready,
      );
      bloc.add(
        LessonEditorBlockChangedV1(_block().copyWith(markdown: 'first')),
      );
      await bloc.stream.firstWhere(
        (state) => state.saveState == SaveStateV1.saving,
      );
      bloc.add(
        LessonEditorBlockChangedV1(_block().copyWith(markdown: 'second')),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(saved, hasLength(1));

      firstSave.complete(saved.first.copyWith(version: 2));
      await secondCall.future.timeout(const Duration(seconds: 1));
      expect(saved, hasLength(2));
      expect(saved.last.markdown, 'second');
      expect(saved.last.version, 2);

      secondSave.complete(saved.last.copyWith(version: 3));
      await bloc.stream.firstWhere(
        (state) => state.saveState == SaveStateV1.saved,
      );
      expect(bloc.state.workspace!.block.single.markdown, 'second');
      expect(bloc.state.workspace!.block.single.version, 3);
    },
  );

  test('maps version conflict to state and one-time effect', () async {
    when(() => repository.getWorkspace('lesson-id'))
        .thenAnswer((_) async => _workspace());
    when(() => repository.updateBlock(any()))
        .thenThrow(const ConflictErrorV1('block/block-id'));
    final bloc = LessonEditorBlocV1(
      repository: repository,
      autosaveDelay: Duration.zero,
    );
    addTearDown(bloc.close);
    final effect = bloc.effectsStream.first;

    bloc.add(const LessonEditorStartedV1('lesson-id'));
    await bloc.stream.firstWhere(
      (state) => state.loadState == LessonEditorLoadStateV1.ready,
    );
    bloc.add(LessonEditorBlockChangedV1(_block().copyWith(markdown: 'draft')));

    expect(await effect, isA<LessonEditorFailureEffectV1>());
    expect(bloc.state.saveState, SaveStateV1.conflict);
  });

  test('reports a mapped raw failure as a domain error', () async {
    final result = await studySafeCallV1<void>(
      'testOperation',
      () => throw StateError('failed'),
    );

    expect(result.errorValue, isA<UnexpectedErrorV1>());
    verify(() => reporter.reportRawError('testOperation', any(), any()))
        .called(1);
    verify(
      () => reporter.reportDomainError(
        'testOperation',
        any(that: isA<UnexpectedErrorV1>()),
        any(),
      ),
    ).called(1);
  });

  test('keeps the result when domain reporting fails', () async {
    when(() => reporter.reportDomainError(any(), any(), any()))
        .thenThrow(StateError('report failed'));

    final result = await studySafeCallV1<void>(
      'testOperation',
      () => throw StateError('operation failed'),
    );

    expect(result.errorValue, isA<UnexpectedErrorV1>());
  });

  testWidgets('shows the empty study state', (tester) async {
    final studyRepository = _MockStudyRepository();
    when(() => studyRepository.listStudies(includeArchived: true))
        .thenAnswer(_emptyStudies);
    final facade = StudyFeatureFacadeV1(
      config: const Config(),
      studyRepository: studyRepository,
      lessonContentRepository: repository,
      knowledgeRepository: _MockKnowledgeRepository(),
      publicationRepository: _MockPublicationRepository(),
      repositoryPicker: _MockRepositoryPicker(),
    );

    await tester.pumpWidget(MaterialApp(home: facade.buildRoot()));
    await tester.pumpAndSettle();

    expect(find.text('Начните новое обучение'), findsOneWidget);
    expect(find.text('Создать обучение'), findsOneWidget);
  });
}

LessonWorkspaceV1 _workspace() => LessonWorkspaceV1(
  lesson: LessonV1(
    id: 'lesson-id',
    studyId: 'study-id',
    sourceId: 'source-id',
    title: 'Lesson',
    exportSlug: 'lesson',
    position: 0,
  ),
  block: [_block()],
);

NoteBlockV1 _block() => NoteBlockV1(
  id: 'block-id',
  studyId: 'study-id',
  lessonId: 'lesson-id',
  type: NoteBlockTypeV1.text,
  position: 0,
);

Future<List<StudyV1>> _emptyStudies(Invocation _) =>
    Future.value(const <StudyV1>[]);
