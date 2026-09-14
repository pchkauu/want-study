import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/navigation/app_router.dart';
import 'package:want_study_desktop/src/theme/app_theme.dart';

final class _StudyRepository extends Mock implements StudyRepositoryV1 {}

final class _LessonRepository extends Mock
    implements LessonContentRepositoryV1 {}

final class _KnowledgeRepository extends Mock
    implements KnowledgeRepositoryV1 {}

final class _PublicationRepository extends Mock
    implements StudyPublicationRepositoryV1 {}

final class _RepositoryPicker implements RepositoryPickerV1 {
  const _RepositoryPicker();

  @override
  Future<String?> pickRepository() async => null;
}

final class _ErrorReporter implements StudyErrorReporterV1 {
  const _ErrorReporter();

  @override
  Future<void> reportDomainError(
    String operation,
    DomainError error,
    StackTrace stackTrace,
  ) async {}

  @override
  Future<void> reportRawError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) async {}
}

void main() {
  setUpAll(() async {
    await initPackage(
      config: const Config(),
      dependencies: Dependencies(
        studyRepository: _StudyRepository(),
        lessonContentRepository: _LessonRepository(),
        knowledgeRepository: _KnowledgeRepository(),
        publicationRepository: _PublicationRepository(),
        errorReporter: const _ErrorReporter(),
        repositoryPicker: const _RepositoryPicker(),
      ),
    );
  });

  testWidgets('dark shell adapts at 1200 px and renders overview', (
    tester,
  ) async {
    final repositories = _Repositories();
    _stubCatalog(repositories.study);
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );
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
    final repositories = _Repositories();
    _stubCatalog(repositories.study);
    when(() => repositories.lesson.getWorkspace('lesson-studying'))
        .thenAnswer((_) async => _workspace());
    final save = Completer<NoteBlockV1>();
    when(() => repositories.lesson.updateBlock(_note()))
        .thenAnswer((_) => save.future);
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(
      _testApp(
        repositories
            .facadeWith(config: const Config(autosaveDelay: Duration.zero))
            .buildRoot(),
      ),
    );
    await tester.pumpAndSettle();

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
  });

  testWidgets('mastered status asks about open homework', (tester) async {
    final repositories = _Repositories();
    _stubCatalog(repositories.study);
    when(
      () => repositories.study.changeLessonStatus(
        lesson: _studyingLesson,
        status: LessonStatusV1.mastered,
        acknowledgeOpenHomework: any(named: 'acknowledgeOpenHomework'),
      ),
    ).thenAnswer((invocation) async {
      final acknowledged =
          invocation.namedArguments[#acknowledgeOpenHomework] as bool;
      if (!acknowledged) {
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
        lesson: _studyingLesson,
        status: LessonStatusV1.mastered,
        acknowledgeOpenHomework: true,
      ),
    ).called(1);
  });

  testWidgets('concept graph opens inspector', (tester) async {
    final repositories = _Repositories();
    _stubCatalog(repositories.study);
    when(
      () => repositories.knowledge.getGraph(
        'study-1',
        selectedConceptId: any(named: 'selectedConceptId'),
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
    expect(tester.takeException(), isNull);
  });

  testWidgets('publication shows preparing, push failure, success and error', (
    tester,
  ) async {
    final repositories = _Repositories();
    _stubCatalog(repositories.study);
    final snapshot = _snapshot();
    final snapshotResult = Completer<ExportSnapshotV1>();
    final publishResult = Completer<PublicationV1>();
    final retryResult = Completer<PublicationV1>();
    var renderCount = 0;
    when(
      () => repositories.publication.renderStudyExport(
        'study-1',
        expectedContentRevision: 7,
      ),
    ).thenAnswer((_) {
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
        commitMessage: 'docs(study): update learning progress',
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
  });

  testWidgets('loading, empty and catalog error use stable states', (
    tester,
  ) async {
    final loadingRepositories = _Repositories();
    final studies = Completer<List<StudyV1>>();
    when(() => loadingRepositories.study.listStudies(includeArchived: true))
        .thenAnswer((_) => studies.future);
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(loadingRepositories.facade.buildRoot()));
    await tester.pump();
    expect(find.bySemanticsLabel('Загрузка'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    studies.complete(const []);
    await tester.pumpAndSettle();
    expect(find.text('Начните новое обучение'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    final failedRepositories = _Repositories();
    when(() => failedRepositories.study.listStudies(includeArchived: true))
        .thenThrow(const UnavailableErrorV1());
    await tester.pumpWidget(_testApp(failedRepositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить обучение'), findsOneWidget);
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
  });
}

final class _Repositories {
  final study = _StudyRepository();
  final lesson = _LessonRepository();
  final knowledge = _KnowledgeRepository();
  final publication = _PublicationRepository();

  StudyFeatureFacadeV1 get facade => facadeWith();

  StudyFeatureFacadeV1 facadeWith({Config config = const Config()}) =>
      StudyFeatureFacadeV1(
        config: config,
        studyRepository: study,
        lessonContentRepository: lesson,
        knowledgeRepository: knowledge,
        publicationRepository: publication,
        repositoryPicker: const _RepositoryPicker(),
      );
}

void _stubCatalog(_StudyRepository repository) {
  when(() => repository.listStudies(includeArchived: true))
      .thenAnswer((_) async => [_study]);
  when(() => repository.getMaterialTree('study-1', includeArchived: true))
      .thenAnswer((_) async => _tree());
  when(() => repository.getDashboard('study-1'))
      .thenAnswer((_) async => _progress());
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
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
