import 'dart:async';
import 'dart:ui';

import 'package:domain_error/domain_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  setUpAll(() async {
    LaunchMode.initializeAutomatically();
    final fontLoader = FontLoader('GolosText')
      ..addFont(rootBundle.load('asset/font/golos_text_variable.ttf'));
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([fontLoader.load(), iconLoader.load()]);
    registerFallbackValue(
      LessonStatusChangeV1(
        lesson: _studyingLesson,
        status: LessonStatusV1.mastered,
      ),
    );
    registerFallbackValue(_note());
    registerFallbackValue(_workspace().task.single);
    registerFallbackValue(_workspace().file.single);
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
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Новое обучение'), findsNothing);
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
    when(
      () =>
          repositories.study.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).thenAnswer((_) async => [_study, _longArchivedStudy]);
    var diagnosticsOpened = false;
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(
      _testApp(
        repositories.facade.buildRoot(
          onOpenDiagnostics: () => diagnosticsOpened = true,
        ),
      ),
    );
    await _pumpCatalogState(tester, repositories, 'ready');

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byTooltip('Обзор'), findsOneWidget);
    expect(find.byKey(const ValueKey('study-selector')), findsOneWidget);
    expect(find.byTooltip('Локальные логи'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Локальные логи'));
    expect(diagnosticsOpened, isTrue);
    await tester.tap(find.byKey(const ValueKey('study-selector')));
    await tester.pumpAndSettle();
    final menu = tester.getRect(
      find.byKey(const ValueKey('study-selector-menu')),
    );
    expect(menu.width, lessThanOrEqualTo(480));
    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('golden/study_selector_dark.png'),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(1024, 720);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsNothing);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byTooltip('Материал')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
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
    final lessonTitleField = _textFieldWithLabel('Название');
    final lessonPositionField = _textFieldWithLabel('Позиция в источнике');
    expect(
      tester.getTopLeft(lessonPositionField).dy -
          tester.getBottomLeft(lessonTitleField).dy,
      greaterThanOrEqualTo(16),
    );
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
    await tester.tap(find.widgetWithText(OutlinedButton, 'Команды'));
    await tester.pumpAndSettle();
    expect(find.text('Тип блока'), findsOneWidget);
    expect(find.text('Markdown'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

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
    await tester.tap(find.text('Задание 1'));
    await tester.pumpAndSettle();
    expect(find.text('Редактирование задания'), findsOneWidget);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/lesson_homework_dark.png'),
    );
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
    expect(find.text('src/main.cpp'), findsWidgets);
    await tester.tap(find.text('Добавить файл'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    final fileEditor = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Содержимое UTF-8 файла',
    );
    await tester.enterText(fileEditor, 'int main() { return 1; }');
    await tester.pump();
    expect(find.text('Изменён'), findsOneWidget);
    await tester.tap(find.text('Сбросить'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(fileEditor).controller?.text,
      'int main() { return 0; }',
    );
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(find.text('src/main.cpp'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lesson document switches active block and reading mode', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest(
      config: const Config(autosaveDelay: Duration(days: 1)),
    );
    _stubCatalog(repositories.study);
    final second = _note().copyWith(
      id: 'block-2',
      type: NoteBlockTypeV1.summary,
      markdown: '## Слабая гарантия\n\nСостояние объекта остаётся корректным.',
      position: 1,
    );
    when(
      () => repositories.lesson.getWorkspace(_studyingLesson),
    ).thenAnswer((_) async => _workspace().copyWith(block: [_note(), second]));
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();

    expect(find.text('Структура'), findsOneWidget);
    expect(find.byKey(const ValueKey('note-editor-block-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('note-editor-block-2')), findsNothing);
    await tester.tap(find.text('2. Итог'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('note-editor-block-2')), findsOneWidget);

    await tester.tap(find.text('Чтение'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('note-editor-block-2')), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Команды'), findsNothing);
    expect(find.text('Добавить блок'), findsNothing);
    expect(find.text('Слабая гарантия'), findsWidgets);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/lesson_read_dark.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty document creates and focuses the first block', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    NoteBlockV1? created;
    var workspaceRead = 0;
    when(() => repositories.lesson.getWorkspace(_studyingLesson)).thenAnswer((
      _,
    ) async {
      workspaceRead++;
      return _workspace().copyWith(
        block: workspaceRead == 1 || created == null ? const [] : [created!],
      );
    });
    when(() => repositories.lesson.createBlock(any())).thenAnswer((call) async {
      created = call.positionalArguments.single as NoteBlockV1;
      return created!;
    });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();

    expect(find.text('Начните конспект'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('empty-note-document')),
        matching: find.widgetWithText(FilledButton, 'Добавить блок'),
      ),
    );
    await tester.pumpAndSettle();

    final editor = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText ==
              'Пишите Markdown. «/» откроет команды.',
    );
    expect(editor, findsOneWidget);
    expect(tester.widget<TextField>(editor).focusNode?.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleting the active block selects its nearest neighbour', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest(
      config: const Config(autosaveDelay: Duration(days: 1)),
    );
    _stubCatalog(repositories.study);
    final second = _note().copyWith(
      id: 'block-2',
      type: NoteBlockTypeV1.claim,
      markdown: '## Второй блок',
      position: 1,
    );
    final third = _note().copyWith(
      id: 'block-3',
      type: NoteBlockTypeV1.summary,
      markdown: '## Третий блок',
      position: 2,
    );
    var deleted = false;
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async {
          return _workspace().copyWith(
            block: deleted ? [_note(), third] : [_note(), second, third],
          );
        });
    when(() => repositories.lesson.deleteBlock(second)).thenAnswer((_) async {
      deleted = true;
      return second;
    });
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2. Тезис'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Удалить блок').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('note-editor-block-2')), findsNothing);
    expect(find.byKey(const ValueKey('note-editor-block-3')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('note-editor-block-3')))
          .focusNode
          ?.hasFocus,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('slash commands navigate and protect homework draft', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async => _workspace());
    when(() => repositories.lesson.updateBlock(any())).thenAnswer((call) {
      final block = call.positionalArguments.single as NoteBlockV1;
      return Future.value(block.copyWith(version: block.version + 1));
    });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();

    final noteEditor = find.byKey(const ValueKey('note-editor-block-1'));
    await tester.tap(noteEditor);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.text('Тип блока'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.enterText(noteEditor, '/');
    await tester.enterText(noteEditor, '/');
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Тип блока'), findsOneWidget);
    expect(find.text('Markdown'), findsOneWidget);
    final commandSearch = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Найдите действие…',
    );
    expect(tester.widget<TextField>(commandSearch).focusNode?.hasFocus, isTrue);
    await tester.enterText(commandSearch, 'Источник блока');
    await tester.pumpAndSettle();
    expect(find.text('Блок'), findsOneWidget);
    await tester.enterText(commandSearch, 'перейти файлы');
    await tester.pumpAndSettle();
    expect(find.text('Навигация'), findsOneWidget);
    await tester.enterText(commandSearch, 'Новое задание');
    await tester.pumpAndSettle();
    expect(find.text('Урок'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('homework-inline-editor')),
      findsOneWidget,
    );
    final prompt = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Условие',
    );
    await tester.enterText(prompt, 'Разобрать гарантии исключений');
    await tester.pump();
    expect(
      tester
          .widgetList<PopScope<dynamic>>(
            find.byWidgetPredicate((widget) => widget is PopScope),
          )
          .any((scope) => !scope.canPop),
      isTrue,
    );
    await tester.tap(find.byTooltip('Назад к материалу'));
    await tester.pumpAndSettle();
    expect(find.text('Изменения не сохранены'), findsOneWidget);
    await tester.tap(find.text('Остаться'));
    await tester.pumpAndSettle();
    expect(find.text('Разобрать гарантии исключений'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('note formatting and block source stay in the document', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    final sourced = _note().copyWith(
      sourceUrl: 'legacy link',
      sourcePosition: 'Глава 3, 12:40',
    );
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async => _workspace().copyWith(block: [sourced]));
    when(() => repositories.lesson.updateBlock(any())).thenAnswer((call) {
      final block = call.positionalArguments.single as NoteBlockV1;
      return Future.value(block.copyWith(version: block.version + 1));
    });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();

    expect(find.text('Некорректная ссылка'), findsOneWidget);
    final editor = find.byKey(const ValueKey('note-editor-block-1'));
    await tester.tap(editor);
    await tester.pump();
    final controller = tester.widget<TextField>(editor).controller!
      ..selection = const TextSelection(baseOffset: 3, extentOffset: 7);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(controller.text, contains('**RAII**'));
    final linkStart = controller.text.indexOf('Ресурс');
    controller.selection = TextSelection(
      baseOffset: linkStart,
      extentOffset: linkStart + 'Ресурс'.length,
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(controller.text, contains('[Ресурс](https://)'));

    await tester.drag(
      find.byKey(const PageStorageKey('lesson-note-document')),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(editor));
    await tester.pump();
    final sourceButton = find.byTooltip('Источник блока');
    await tester.ensureVisible(sourceButton);
    await tester.tap(sourceButton);
    await tester.pumpAndSettle();
    final url = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Ссылка',
    );
    await tester.enterText(url, 'https://example.com/lesson');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.text('Открыть источник'), findsOneWidget);
    expect(find.text('Глава 3, 12:40'), findsOneWidget);
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

  testWidgets('homework draft cancels and saves inline', (tester) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    var task = _workspace().task.single;
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async {
          return _workspace().copyWith(task: [task]);
        });
    when(() => repositories.lesson.updateTask(any())).thenAnswer((call) async {
      task = (call.positionalArguments.single as HomeworkTaskV1).copyWith(
        version: task.version + 1,
      );
      return task;
    });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Домашняя работа').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Задание 1'));
    await tester.pumpAndSettle();

    final prompt = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Условие',
    );
    await tester.enterText(prompt, 'Локальный черновик задания');
    final cancel = find.widgetWithText(TextButton, 'Отмена');
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.text('Объяснить сильную гарантию исключений.'), findsOneWidget);
    expect(find.text('Локальный черновик задания'), findsNothing);

    await tester.tap(find.text('Задание 1'));
    await tester.pumpAndSettle();
    await tester.enterText(prompt, 'Сохранённое условие задания');
    final save = find.widgetWithText(FilledButton, 'Сохранить');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Сохранённое условие задания'), findsOneWidget);
    verify(() => repositories.lesson.updateTask(any())).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('file draft exposes failure and retries save', (tester) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    var file = _workspace().file.single;
    var attempt = 0;
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async {
          return _workspace().copyWith(file: [file]);
        });
    when(() => repositories.lesson.updateFile(any())).thenAnswer((call) async {
      attempt++;
      if (attempt == 1) throw const UnavailableErrorV1();
      file = (call.positionalArguments.single as CodeFileV1).copyWith(
        version: file.version + 1,
      );
      return file;
    });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Файлы').last);
    await tester.pumpAndSettle();

    final editor = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Содержимое UTF-8 файла',
    );
    await tester.enterText(editor, 'int main() { return 2; }');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();
    expect(attempt, 1);
    expect(
      repositories.facade.lessonEditorController.state.saveState,
      SaveStateV1.failed,
    );
    expect(find.text('Ошибка сохранения'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('save-recovery')));
    await tester.pumpAndSettle();
    expect(find.text('Ошибка сохранения'), findsNothing);
    expect(find.text('Изменён'), findsNothing);
    expect(attempt, 2);
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
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Изменить статус урока'));
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
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Понятия'), findsOneWidget);
    final canvas = tester.getRect(
      find.byKey(const ValueKey('concept-graph-canvas')),
    );
    final inspector = tester.getRect(
      find.byKey(const ValueKey('concept-inspector')),
    );
    expect(canvas.width, greaterThan(inspector.width));
    for (final id in const ['concept-raii', 'concept-exception']) {
      final node = tester.getRect(find.byKey(ValueKey(id)));
      expect(
        canvas.deflate(20).contains(node.center),
        isTrue,
        reason: '$id at $node is outside $canvas',
      );
    }
    await tester.tap(find.text('RAII').first);
    await tester.pumpAndSettle();

    expect(find.text('Псевдонимы'), findsOneWidget);
    expect(find.text('Привязки к блокам: 1'), findsOneWidget);
    expect(find.text('Связи'), findsOneWidget);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/concept_dark.png'),
    );
    tester.view.physicalSize = const Size(900, 720);
    await tester.pumpAndSettle();
    final compactCanvas = tester.getRect(
      find.byKey(const ValueKey('concept-graph-canvas')),
    );
    final compactInspector = tester.getRect(
      find.byKey(const ValueKey('concept-inspector')),
    );
    expect(compactInspector.top, greaterThan(compactCanvas.top));
    final addRelation = find.byTooltip('Добавить связь');
    await tester.ensureVisible(addRelation);
    await tester.tap(addRelation);
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
    expect(tester.takeException(), isNull);
    expect(find.text('Новое понятие'), findsOneWidget);
    expect(find.byTooltip('Закрыть'), findsOneWidget);
    final title = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Название',
    );
    final description = _textFieldWithLabel('Описание');
    final aliases = _textFieldWithLabel('Псевдонимы через запятую');
    expect(
      tester.getTopLeft(description).dy - tester.getBottomLeft(title).dy,
      greaterThanOrEqualTo(16),
    );
    expect(
      tester.getTopLeft(aliases).dy - tester.getBottomLeft(description).dy,
      greaterThanOrEqualTo(16),
    );
    await tester.enterText(title, 'Единственное понятие');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Новое понятие'), findsNothing);
    expect(
      repositories.facade.conceptController.state.selectedConcept?.title,
      'Единственное понятие',
    );
    expect(find.text('Единственное понятие'), findsWidgets);
    expect(find.text('Привязки к блокам: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disconnected concepts render without exceptions', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    final graph = ConceptGraphV1(concept: _conceptGraph().concept);
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
    expect(find.bySemanticsLabel('Связей: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('concept graph renders 300 connected nodes', (tester) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    final graph = ConceptGraphV1(
      concept: [
        for (var index = 0; index < 300; index++)
          ConceptV1(
            id: 'concept-$index',
            studyId: _study.id,
            title: 'Понятие $index',
            exportSlug: 'concept-$index',
          ),
      ],
      relation: [
        for (var index = 0; index < 299; index++)
          ConceptRelationV1(
            id: 'relation-$index',
            studyId: _study.id,
            sourceConceptId: 'concept-$index',
            targetConceptId: 'concept-${index + 1}',
            type: ConceptRelationTypeV1.appliesTo,
          ),
      ],
    );
    when(
      () => repositories.knowledge.getGraph(
        study: _study,
        selectedConcept: any(named: 'selectedConcept'),
      ),
    ).thenAnswer((_) async => graph);
    await _setSurface(tester, const Size(1440, 900));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.hub_outlined));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Связей: 299'), findsOneWidget);
    expect(find.text('Понятий: 300'), findsOneWidget);
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

  testWidgets('homework retry preserves edits made while saving', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    _stubCatalog(repositories.study);
    var workspace = _workspace();
    final firstSave = Completer<HomeworkTaskV1>();
    final savedPrompt = <String>[];
    var calls = 0;
    when(() => repositories.lesson.getWorkspace(_studyingLesson))
        .thenAnswer((_) async => workspace);
    when(() => repositories.lesson.updateTask(any())).thenAnswer((call) {
      final task = call.positionalArguments.single as HomeworkTaskV1;
      savedPrompt.add(task.promptMarkdown);
      calls++;
      if (calls == 1) return firstSave.future;
      final stored = task.copyWith(version: task.version + 1);
      workspace = workspace.copyWith(task: [stored]);
      return Future.value(stored);
    });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_lessonTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Домашняя работа').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Задание 1'));
    await tester.pumpAndSettle();

    final prompt = _textFieldWithLabel('Условие');
    await tester.enterText(prompt, 'Первая версия');
    final saveButton = find.widgetWithText(FilledButton, 'Сохранить');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    final promptField = tester.widget<TextField>(prompt);
    promptField.controller!.text = 'Новая версия во время сохранения';
    promptField.onChanged?.call(promptField.controller!.text);
    await tester.pump();
    expect(
      tester.widget<TextField>(prompt).controller?.text,
      'Новая версия во время сохранения',
    );
    firstSave.completeError(const UnavailableErrorV1());
    await tester.pumpAndSettle();

    expect(
      find.text('Не удалось сохранить задание. Черновик сохранён.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(prompt).controller?.text,
      'Новая версия во время сохранения',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Повторить'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('homework-inline-editor')),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(prompt).controller?.text,
      'Новая версия во время сохранения',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Сохранить'));
    await tester.pumpAndSettle();
    expect(savedPrompt, [
      'Первая версия',
      'Первая версия',
      'Новая версия во время сохранения',
    ]);
    expect(find.byKey(const ValueKey('homework-inline-editor')), findsNothing);
    expect(tester.takeException(), isNull);
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
    final firstRetry = Completer<PublicationV1>();
    final secondRetry = Completer<PublicationV1>();
    var renderCount = 0;
    var retryCount = 0;
    when(() => repositories.publication.renderStudyExport(_study))
        .thenAnswer((_) {
          renderCount++;
          if (renderCount == 1) {
            return snapshotResult.future;
          }
          throw const ConflictErrorV1('study/study-id/content');
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
        .thenAnswer((_) {
          retryCount++;
          return retryCount == 1 ? firstRetry.future : secondRetry.future;
        });
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();
    await _precacheLogo(tester);

    await tester.tap(find.byIcon(Icons.publish_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Публикация'), findsOneWidget);
    expect(find.text('Готово к проверке'), findsOneWidget);
    await tester.tap(find.text('Построить предпросмотр'));
    await tester.pump();
    expect(find.text('Строится предпросмотр'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    snapshotResult.complete(snapshot);
    await tester.pumpAndSettle();
    expect(find.text('Предпросмотр готов'), findsOneWidget);
    await expectLater(
      find.byKey(const ValueKey('golden-root')),
      matchesGoldenFile('golden/publication_dark.png'),
    );

    await tester.ensureVisible(find.text('Записать и отправить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Записать и отправить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Опубликовать'));
    await tester.pump();
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey('study-selector')))
          .onTap,
      isNull,
    );
    publishResult.complete(_pushFailedPublication());
    await tester.pumpAndSettle();
    expect(find.text('Push не выполнен'), findsOneWidget);
    expect(find.text('Построить предпросмотр'), findsNothing);
    expect(find.text('Записать и отправить'), findsNothing);
    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey('study-selector')))
          .onTap,
      isNull,
    );

    await tester.tap(find.text('Повторить push'));
    await tester.pump();
    firstRetry.completeError(const PublicationErrorV1('push_failed'));
    await tester.pumpAndSettle();
    expect(find.text('Push не выполнен'), findsOneWidget);
    expect(find.text('Повторить push'), findsOneWidget);

    await tester.tap(find.text('Повторить push'));
    await tester.pump();
    secondRetry.complete(_publishedPublication());
    await tester.pumpAndSettle();
    expect(find.text('Опубликовано'), findsOneWidget);
    expect(find.text('Записать и отправить'), findsNothing);
    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey('study-selector')))
          .onTap,
      isNotNull,
    );

    await tester.tap(find.text('Построить предпросмотр'));
    await tester.pumpAndSettle();
    expect(
      find.text('Данные изменились — обновите предпросмотр'),
      findsOneWidget,
    );
    for (final size in const [Size(900, 720), Size(1440, 900)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('publication requests repository before preflight', (
    tester,
  ) async {
    final repositories = await _repositoriesForTest();
    final study = _study.copyWith(localRepositoryPath: '');
    when(
      () =>
          repositories.study.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).thenAnswer((_) async => [study]);
    when(
      () => repositories.study.getMaterialTree(
        study: study,
        scope: ArchiveScopeV1.includeArchived,
      ),
    ).thenAnswer((_) async => _tree());
    when(() => repositories.study.getDashboard(study))
        .thenAnswer((_) async => _progress());
    await _setSurface(tester, const Size(1024, 720));
    await tester.pumpWidget(_testApp(repositories.facade.buildRoot()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.publish_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Git-репозиторий не выбран'), findsOneWidget);
    expect(find.text('Настроить обучение'), findsOneWidget);
    verifyNever(() => repositories.publication.renderStudyExport(study));

    await tester.tap(find.text('Настроить обучение'));
    await tester.pumpAndSettle();
    expect(find.text('Обучение'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

Finder _textFieldWithLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

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
  localRepositoryPath: '/tmp/study',
  contentRevision: 7,
);

final _longArchivedStudy = StudyV1(
  id: 'study-archived',
  title: 'Очень длинное название архивного обучения для проверки компактного выбора проекта',
  goal: 'Очень длинная цель, которая должна аккуратно сокращаться внутри ограниченного меню.',
  isArchived: true,
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
