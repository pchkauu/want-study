import 'dart:async';

import 'package:domain_error/domain_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/navigation/app_router.dart';
import 'package:want_study_desktop/src/theme/app_theme.dart';

final class _StudyRepository extends Mock implements StudyRepositoryV2 {}

final class _LessonRepository extends Mock
    implements LessonContentRepositoryV2 {}

final class _KnowledgeRepository extends Mock
    implements KnowledgeRepositoryV2 {}

final class _PublicationRepository extends Mock
    implements StudyPublicationRepositoryV2 {}

final class _RepositoryPicker extends Mock implements RepositoryPickerService {}

final class _ErrorReporter implements StudyErrorReporterV2 {
  const _ErrorReporter();

  @override
  Future<void> reportDomainError({
    required StudyErrorContextV1 context,
    required DomainError error,
    required StackTrace stackTrace,
  }) async {}

  @override
  Future<void> reportRawError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  }) async {}

  @override
  Future<void> reportObserverError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  }) async {}
}

void main() {
  setUpAll(() {
    LaunchMode.initializeAutomatically();
    registerFallbackValue(
      LessonStatusChangeV1(
        lesson: _studyingLesson,
        status: LessonStatusV1.mastered,
      ),
    );
    registerFallbackValue(_note());
    registerFallbackValue(_workspace().task.single);
    registerFallbackValue(_conceptGraph().concept.first);
    registerFallbackValue(ConceptSearchV1());
  });

  testWidgets('loading, empty and catalog error use stable states', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    final studies = Completer<List<StudyV1>>();
    when(
      () =>
          repositories.study.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).thenAnswer((_) => studies.future);
    unawaited(repositories.facade.catalogController.init());
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await _pumpCatalogState(tester, repositories, 'loading');
    expect(find.bySemanticsLabel('Загрузка'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    studies.complete(const []);
    await _pumpCatalogState(tester, repositories, 'ready');
    expect(find.text('Начните новое обучение'), findsOneWidget);
    tester.view.physicalSize = const Size(900, 720);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Создать обучение'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1024, 720);
    await tester.pumpAndSettle();

    when(
      () =>
          repositories.study.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).thenThrow(const UnavailableErrorV1());
    repositories.facade.catalogController.reload();
    await _pumpCatalogState(tester, repositories, 'failed');
    expect(find.text('Не удалось загрузить обучение'), findsOneWidget);

    _stubCatalog(repositories.study);
    repositories.facade.catalogController.reload();
    await _pumpCatalogState(tester, repositories, 'ready');
  });

  testWidgets('dark shell adapts at 1200 px and renders overview', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await _pumpCatalogState(tester, repositories, 'ready');

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );
    expect(find.byKey(const ValueKey('want-study-logo')), findsOneWidget);
    await _precacheLogo(tester);
    expect(find.text('Материал'), findsWidgets);
    expect(find.text('Домашняя работа'), findsWidgets);
    expect(
      _contrast(WantStudyColor.text, WantStudyColor.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(WantStudyColor.text, WantStudyColor.accent),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(WantStudyColor.textMuted, WantStudyColor.surface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrast(WantStudyColor.accent, WantStudyColor.background),
      greaterThanOrEqualTo(3),
    );
    for (final color in const [
      WantStudyColor.success,
      WantStudyColor.warning,
      WantStudyColor.error,
    ]) {
      expect(
        _contrast(color, WantStudyColor.background),
        greaterThanOrEqualTo(4.5),
      );
    }
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/overview_dark.png'),
    );

    tester.view.physicalSize = const Size(1024, 720);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isFalse,
    );
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(900, 720);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('material and lesson editor fit 1024x720 at text scale 1.25', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async => _workspace());
    final save = Completer<NoteBlockV1>();
    when(() => repositories.lesson.updateBlock(_note()))
        .thenAnswer((_) => save.future);
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await _precacheLogo(tester);

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    expect(find.text(_sourceTitle), findsWidgets);
    expect(find.text(_lessonTitle), findsOneWidget);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/material_dark_1024.png'),
    );

    tester.view.physicalSize = const Size(900, 720);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Добавить источник'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Раздел'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Урок'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1024, 720);
    await tester.pumpAndSettle();

    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();
    expect(find.text('Сохранено'), findsOneWidget);
    expect(find.text('Конспект'), findsWidgets);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/lesson_editor_dark.png'),
    );

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, '# Обновлённый конспект');
    await tester.pump();
    await tester.pump(Duration.zero);
    expect(find.text('Сохранение'), findsOneWidget);
    save.complete(
      _note().copyWith(markdown: '# Обновлённый конспект', version: 2),
    );
    await tester.pumpAndSettle();
    expect(find.text('Сохранено'), findsOneWidget);

    await tester.tap(find.text('Домашняя работа').last);
    await tester.pumpAndSettle();
    expect(find.text('Срок: 20.09.2026'), findsOneWidget);
    expect(find.text('Решение'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(900, 720);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить задание'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Файлы').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Добавить файл'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('discard reloads server text in active editor', (tester) async {
    final repositories = await _repositoriesForTest(
      config: const Config(autosaveDelay: Duration(days: 1)),
    );
    _stubCatalog(repositories.study);
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async => _workspace());
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();
    final editor = find.byType(TextField).first;

    await tester.enterText(editor, 'Черновик');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Изменения не сохранены'), findsOneWidget);
    await tester.tap(find.text('Сбросить и перечитать'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(editor).controller?.text, _note().markdown);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mastered status asks about open homework', (tester) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    when(() => repositories.study.changeLessonStatus(any()))
        .thenAnswer((invocation) async {
          final change =
              invocation.positionalArguments.single as LessonStatusChangeV1;
          if (!change.acknowledgeOpenHomework) {
            throw const OpenHomeworkErrorV1();
          }
          return _studyingLesson.copyWith(
            status: LessonStatusV1.mastered,
            masteredAt: () => DateTime.utc(2026, 9, 14),
          );
        });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Изучается'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Освоен').last);
    await tester.pumpAndSettle();
    expect(find.text('Есть открытые задания'), findsOneWidget);
    await tester.tap(find.text('Отметить освоенным'));
    await tester.pumpAndSettle();

    verify(
      () => repositories.study.changeLessonStatus(
        LessonStatusChangeV1(
          lesson: _studyingLesson,
          status: LessonStatusV1.mastered,
          acknowledgeOpenHomework: true,
        ),
      ),
    ).called(1);
  });

  testWidgets('concept graph opens inspector', (tester) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    when(
      () => repositories.knowledge.getGraph(
        study: _study,
        selectedConcept: any(named: 'selectedConcept'),
      ),
    ).thenAnswer((_) async => _conceptGraph());
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RAII').first);
    await tester.pumpAndSettle();

    expect(find.text('Псевдонимы'), findsOneWidget);
    expect(find.text('Привязки к блокам: 1'), findsOneWidget);
    expect(find.text('Связи'), findsOneWidget);
    tester.view.physicalSize = const Size(900, 720);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Добавить связь'));
    await tester.pumpAndSettle();
    expect(find.text('Новая связь'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('first concept renders and opens inspector without graph crash', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    var graph = ConceptGraphV1();
    when(
      () => repositories.knowledge.getGraph(
        study: _study,
        selectedConcept: any(named: 'selectedConcept'),
      ),
    ).thenAnswer((_) async => graph);
    when(() => repositories.knowledge.createConcept(any())).thenAnswer((call) {
      final concept = call.positionalArguments.single as ConceptV1;
      graph = ConceptGraphV1(concept: [concept]);
      return Future.value(concept);
    });
    when(
      () => repositories.knowledge.searchConcepts(
        study: _study,
        search: any(named: 'search'),
      ),
    ).thenAnswer((_) async => graph.concept);
    await _setSurface(tester, const Size(900, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Граф пока пуст'), findsOneWidget);
    await tester.tap(find.text('Добавить понятие'));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    final title = find
        .descendant(of: dialog, matching: find.byType(TextField))
        .first;
    await tester.enterText(title, 'Единственное понятие');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Единственное понятие'), findsWidgets);
    expect(find.text('Привязки к блокам: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('concept graph survives topology changes and page switches', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    var graph = _singleConceptGraph();
    when(
      () => repositories.knowledge.getGraph(
        study: _study,
        selectedConcept: any(named: 'selectedConcept'),
      ),
    ).thenAnswer((_) async => graph);
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    graph = _conceptGraph();
    await tester.tap(find.byIcon(Icons.space_dashboard_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Гарантии исключений'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(900, 720);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final size in const [Size(1440, 900), Size(900, 720)]) {
      tester.view.physicalSize = size;
      await tester.tap(find.byIcon(Icons.space_dashboard_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.hub_outlined));
      await tester.pumpAndSettle();
      expect(find.text('RAII'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('late editor failure after disposal has no UI side effect', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async => _workspace());
    final update = Completer<HomeworkTaskV1>();
    when(() => repositories.lesson.updateTask(any()))
        .thenAnswer((_) => update.future);
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Домашняя работа').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await untilCalled(() => repositories.lesson.updateTask(any()));
    await tester.pumpWidget(const SizedBox.shrink());
    update.completeError(const UnavailableErrorV1());
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('publication shows preparing, push failure, success and error', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    final snapshot = _snapshot();
    final snapshotResult = Completer<ExportSnapshotV1>();
    final publishResult = Completer<PublicationV1>();
    final retryResult = Completer<PublicationV1>();
    var renderCount = 0;
    when(() => repositories.publication.renderStudyExport(_study))
        .thenAnswer((_) {
          renderCount++;
          if (renderCount == 1) {
            return snapshotResult.future;
          }
          throw const UnavailableErrorV1();
        });
    when(
      () => repositories.publication.preview(study: _study, snapshot: snapshot),
    ).thenAnswer((_) async => _preview());
    when(
      () => repositories.publication.publish(
        study: _study,
        snapshot: snapshot,
        commit: PublicationCommitV1(
          message: 'docs(study): update learning progress',
        ),
      ),
    ).thenAnswer((_) => publishResult.future);
    when(() => repositories.publication.retryPush(_pushFailedPublication()))
        .thenAnswer((_) => retryResult.future);
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.publish_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Готово к проверке'), findsOneWidget);
    await tester.tap(find.text('Построить предпросмотр'));
    await tester.pump();
    expect(find.text('Строится предпросмотр'), findsOneWidget);
    snapshotResult.complete(snapshot);
    await tester.pumpAndSettle();
    expect(find.text('Предпросмотр готов'), findsOneWidget);

    await tester.tap(find.text('Записать и отправить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Опубликовать'));
    await tester.pump();
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    publishResult.complete(_pushFailedPublication());
    await tester.pumpAndSettle();
    expect(find.text('Push не выполнен'), findsOneWidget);

    await tester.tap(find.text('Повторить push'));
    await tester.pump();
    retryResult.complete(_publishedPublication());
    await tester.pumpAndSettle();
    expect(find.text('Опубликовано'), findsOneWidget);

    await tester.tap(find.text('Построить предпросмотр'));
    await tester.pumpAndSettle();
    expect(find.text('Проверка не выполнена'), findsOneWidget);
    for (final size in const [Size(900, 720), Size(1440, 900)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('unavailable API has dark diagnostic state', (tester) async {
    final health = Completer<bool>();
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(
      _testApp(StudyScreen(healthCheck: () => health.future)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    health.complete(false);
    await tester.pumpAndSettle();

    expect(find.text('Локальный сервис недоступен'), findsOneWidget);
    expect(find.text('docker compose up -d'), findsOneWidget);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/api_unavailable_dark.png'),
    );
    for (final size in const [Size(1024, 720), Size(900, 720)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

final class _Repositories {
  final study = _StudyRepository();
  final lesson = _LessonRepository();
  final knowledge = _KnowledgeRepository();
  final publication = _PublicationRepository();
  final repositoryPicker = _RepositoryPicker();
  late StudyFeatureFacadeV2 facade;
}

Future<_Repositories> _repositoriesForTest({
  Config config = const Config(autosaveDelay: Duration.zero),
}) async {
  final repositories = _Repositories();
  repositories.facade = await initPackage(
    config: config,
    resetForTesting: true,
    dependencies: Dependencies(
      studyRepository: repositories.study,
      lessonContentRepository: repositories.lesson,
      knowledgeRepository: repositories.knowledge,
      publicationRepository: repositories.publication,
      errorReporter: const _ErrorReporter(),
      repositoryPicker: repositories.repositoryPicker,
    ),
  );
  addTearDown(() {
    unawaited(repositories.facade.catalogController.close());
    unawaited(repositories.facade.lessonEditorController.close());
    unawaited(repositories.facade.conceptController.close());
    unawaited(repositories.facade.publicationController.close());
  });
  return repositories;
}

void _stubCatalog(_StudyRepository repository) {
  when(() => repository.listStudies(scope: ArchiveScopeV1.includeArchived))
      .thenAnswer((_) async => [_study]);
  when(
    () => repository.getMaterialTree(
      study: _study,
      scope: ArchiveScopeV1.includeArchived,
    ),
  ).thenAnswer((_) async => _tree());
  when(() => repository.getDashboard(_study))
      .thenAnswer((_) async => _progress());
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Future<void> _precacheLogo(WidgetTester tester) async {
  final finder = find.byKey(const ValueKey('want-study-logo'));
  final image = tester.widget<Image>(finder);
  await tester.runAsync(
    () => precacheImage(image.image, tester.element(finder)),
  );
  await tester.pump();
}

Future<void> _pumpCatalogState(
  WidgetTester tester,
  _Repositories repositories,
  String state,
) async {
  for (var i = 0; i < 50; i++) {
    await tester.pump(const Duration(milliseconds: 1));
    if (repositories.facade.catalogController.state.toString().contains(
      'CatalogLoadStateV2.$state',
    )) {
      await tester.pump(const Duration(milliseconds: 1));
      return;
    }
  }
  fail('Catalog did not reach $state state.');
}

Widget _testApp(Widget home) => RepaintBoundary(
  key: const ValueKey('golden-root'),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildWantStudyTheme(),
    darkTheme: buildWantStudyTheme(),
    themeMode: ThemeMode.dark,
    themeAnimationDuration: Duration.zero,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.25),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: home,
  ),
);

double _contrast(Color foreground, Color background) {
  final light = foreground.computeLuminance() + 0.05;
  final dark = background.computeLuminance() + 0.05;
  return light > dark ? light / dark : dark / light;
}

const _sourceTitle =
    'Современный C++: фундаментальные конструкции, безопасность памяти и проектирование программ';
const _lessonTitle =
    'Управление временем жизни объектов и гарантии исключений в больших программах';

final _study = StudyV1(
  id: 'study-1',
  title: 'C/C++',
  goal: 'Уверенно проектировать и разбирать современные программы на C++.',
  contentRevision: 7,
);

final _source = LearningSourceV1(
  id: 'source-1',
  studyId: 'study-1',
  type: LearningSourceTypeV1.course,
  title: _sourceTitle,
  author: 'Stepik',
  exportSlug: 'modern-cpp',
  position: 0,
);

final _section = SectionV1(
  id: 'section-1',
  studyId: 'study-1',
  sourceId: 'source-1',
  title: 'Первое знакомство и базовые конструкции языка',
  position: 0,
);

final _plannedLesson = LessonV1(
  id: 'lesson-planned',
  studyId: 'study-1',
  sourceId: 'source-1',
  sectionId: 'section-1',
  title: 'План следующего занятия',
  exportSlug: 'planned',
  position: 0,
  sourcePosition: '1.1',
);

final _studyingLesson = LessonV1(
  id: 'lesson-studying',
  studyId: 'study-1',
  sourceId: 'source-1',
  sectionId: 'section-1',
  title: _lessonTitle,
  exportSlug: 'lifetime',
  position: 1,
  sourcePosition: '1.2',
  status: LessonStatusV1.studying,
  startedAt: DateTime.utc(2026, 9, 10),
);

final _homeworkLesson = LessonV1(
  id: 'lesson-homework',
  studyId: 'study-1',
  sourceId: 'source-1',
  sectionId: 'section-1',
  title: 'Практика с контейнерами',
  exportSlug: 'containers',
  position: 2,
  sourcePosition: '1.3',
  status: LessonStatusV1.homework,
  startedAt: DateTime.utc(2026, 9, 11),
);

final _masteredLesson = LessonV1(
  id: 'lesson-mastered',
  studyId: 'study-1',
  sourceId: 'source-1',
  sectionId: 'section-1',
  title: 'Первая программа',
  exportSlug: 'first-program',
  position: 3,
  sourcePosition: '1.4',
  status: LessonStatusV1.mastered,
  startedAt: DateTime.utc(2026, 9),
  masteredAt: DateTime.utc(2026, 9, 8),
);

MaterialTreeV1 _tree() => MaterialTreeV1(
  study: _study,
  source: [
    LearningSourceNodeV1(
      source: _source,
      section: [_section],
      lesson: [
        _plannedLesson,
        _studyingLesson,
        _homeworkLesson,
        _masteredLesson,
      ],
    ),
  ],
);

StudyProgressV1 _progress() => StudyProgressV1(
  material: ProgressIndicatorV1(completed: 1, total: 4),
  homework: ProgressIndicatorV1(completed: 3, total: 5),
  lessonStatusCount: const {
    'planned': 1,
    'studying': 1,
    'homework': 1,
    'mastered': 1,
  },
  studyRevision: 7,
);

NoteBlockV1 _note() => NoteBlockV1(
  id: 'block-1',
  studyId: 'study-1',
  lessonId: 'lesson-studying',
  type: NoteBlockTypeV1.definition,
  markdown: '## RAII\n\nРесурс принадлежит объекту и освобождается вместе с ним.\n\n```cpp\nstd::vector<int> values;\n```',
  position: 0,
);

LessonWorkspaceV1 _workspace() => LessonWorkspaceV1(
  lesson: _studyingLesson,
  block: [_note()],
  task: [
    HomeworkTaskV1(
      id: 'task-1',
      studyId: 'study-1',
      lessonId: 'lesson-studying',
      promptMarkdown: 'Объяснить сильную гарантию исключений.',
      solutionMarkdown: 'Использовать **copy and swap**.',
      dueAt: DateTime.utc(2026, 9, 20),
      position: 0,
    ),
  ],
  file: [
    CodeFileV1(
      id: 'file-1',
      studyId: 'study-1',
      lessonId: 'lesson-studying',
      relativePath: 'src/main.cpp',
      language: 'cpp',
      content: 'int main() { return 0; }',
    ),
  ],
  conceptId: const ['concept-raii'],
);

ConceptGraphV1 _conceptGraph() {
  final raii = ConceptV1(
    id: 'concept-raii',
    studyId: 'study-1',
    title: 'RAII',
    exportSlug: 'raii',
    descriptionMarkdown: 'Управление ресурсом через время жизни объекта.',
    aliases: const ['Resource Acquisition Is Initialization'],
    blockIds: const ['block-1'],
  );
  final exception = ConceptV1(
    id: 'concept-exception',
    studyId: 'study-1',
    title: 'Гарантии исключений',
    exportSlug: 'exception-safety',
  );
  return ConceptGraphV1(
    concept: [raii, exception],
    relation: [
      ConceptRelationV1(
        id: 'relation-1',
        studyId: 'study-1',
        sourceConceptId: raii.id,
        targetConceptId: exception.id,
        type: ConceptRelationTypeV1.appliesTo,
      ),
    ],
  );
}

ConceptGraphV1 _singleConceptGraph() {
  final concept = ConceptV1(
    id: 'concept-raii',
    studyId: 'study-1',
    title: 'RAII',
    exportSlug: 'raii',
    descriptionMarkdown: 'Управление ресурсом через время жизни объекта.',
  );
  return ConceptGraphV1(concept: [concept]);
}

ExportSnapshotV1 _snapshot() => ExportSnapshotV1(
  studyId: 'study-1',
  studyRevision: 7,
  file: [
    ExportFileV1(
      path: 'README.md',
      content: const [35, 32, 67, 47, 67, 43, 43],
      sha256: 'hash',
    ),
  ],
);

PublicationPreviewV1 _preview() => PublicationPreviewV1(
  studyId: 'study-1',
  studyRevision: 7,
  diff: 'diff --git a/README.md b/README.md\n+Материал: 25%\n+Домашняя работа: 60%',
  changedPath: const ['README.md'],
);

PublicationV1 _pushFailedPublication() => PublicationV1(
  studyId: 'study-1',
  studyRevision: 7,
  changedPath: const ['README.md'],
  commitSha: 'abc123',
  state: PublicationStateV1.pushFailed,
);

PublicationV1 _publishedPublication() => PublicationV1(
  studyId: 'study-1',
  studyRevision: 7,
  changedPath: const ['README.md'],
  commitSha: 'abc123',
  state: PublicationStateV1.published,
);
