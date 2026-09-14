import 'dart:async';
import 'dart:convert';

import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:study/src/application/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';
import 'package:study/src/presentation/_barrel.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:uuid/uuid.dart';

part 'lesson_editor_file.dart';
part 'lesson_editor_homework.dart';
part 'lesson_editor_note.dart';

final class LessonEditorPageV1 extends StatefulWidget {
  final StudyV1 study;
  final LessonV1 lesson;
  final CatalogControllerV2 catalogController;
  final LessonEditorControllerV2 controller;

  const LessonEditorPageV1({
    required this.study,
    required this.lesson,
    required this.catalogController,
    required this.controller,
    super.key,
  });

  @override
  State<LessonEditorPageV1> createState() => _LessonEditorPageV1State();
}

final class _LessonEditorPageV1State extends State<LessonEditorPageV1>
    with SingleTickerProviderStateMixin {
  late final LessonEditorControllerV2 _controller;
  late final TabController _tabController;
  final _noteKey = GlobalKey<_NoteDocumentState>();
  final _homeworkKey = GlobalKey<_HomeworkViewState>();
  final _fileKey = GlobalKey<_FileViewState>();
  var _viewMode = _LessonViewMode.edit;
  var _homeworkCreateRequest = 0;
  var _homeworkDirty = false;
  var _fileDirty = false;
  var _isActive = true;

  bool get _hasLocalDraft => _homeworkDirty || _fileDirty;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller..add(LessonEditorStartedV2(widget.lesson));
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void activate() {
    super.activate();
    _isActive = true;
  }

  @override
  void deactivate() {
    _isActive = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _controller,
      child:
          BlocEffectConsumer<
            LessonEditorControllerV2,
            LessonEditorStateV2,
            LessonEditorEffectV2
          >(
            bloc: _controller,
            listener: _onEffect,
            builder: (context, state) {
              final unsafeToLeave =
                  _hasLocalDraft || _isControllerDraftUnsafe(state.saveState);
              final effectiveSaveState =
                  _hasLocalDraft &&
                      {
                        SaveStateV1.clean,
                        SaveStateV1.saved,
                      }.contains(state.saveState)
                  ? SaveStateV1.dirty
                  : state.saveState;
              return BlocBuilder<CatalogControllerV2, CatalogStateV2>(
                bloc: widget.catalogController,
                builder: (context, catalogState) {
                  final lesson = _currentLesson(catalogState) ?? widget.lesson;
                  return PopScope(
                    canPop: !unsafeToLeave,
                    onPopInvokedWithResult: (didPop, _) {
                      if (!didPop) unawaited(_requestLeave(state));
                    },
                    child: StudyBackdrop(
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: _buildAppBar(state, effectiveSaveState, lesson),
                        body: _body(state),
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    LessonEditorStateV2 state,
    SaveStateV1 saveState,
    LessonV1 lesson,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 960;
    final workspace = state.workspace;
    return AppBar(
      toolbarHeight: 86,
      leadingWidth: 112,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Назад к материалу',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'asset/logo_512px.png',
              package: 'study',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Want Study',
            ),
          ],
        ),
      ),
      titleSpacing: 12,
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    widget.study.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (lesson.sourcePosition.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.chevron_right_rounded, size: 14),
                  ),
                  Flexible(
                    child: Text(
                      lesson.sourcePosition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              lesson.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      actions: [
        _LessonStatusControl(
          lesson: lesson,
          compact: width < 1120,
          onSelected: _changeLessonStatus,
        ),
        if (lesson.url.isNotEmpty)
          IconButton(
            tooltip: _httpUri(lesson.url) == null
                ? 'Некорректная ссылка источника'
                : 'Открыть источник урока',
            onPressed: _httpUri(lesson.url) == null
                ? null
                : () => _openExternalUrl(lesson.url),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        _SaveBadge(state: saveState, compact: compact),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: const EdgeInsets.all(4),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    tabs: [
                      _LessonTab(
                        label: 'Конспект',
                        count: workspace?.block.length ?? 0,
                      ),
                      _LessonTab(
                        label: 'Домашняя работа',
                        count: workspace?.task.length ?? 0,
                      ),
                      _LessonTab(
                        label: 'Файлы',
                        count: workspace?.file.length ?? 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LessonV1? _currentLesson(CatalogStateV2 state) => state.tree?.source
      .expand((source) => source.lesson)
      .where((lesson) => lesson.id == widget.lesson.id)
      .firstOrNull;

  void _changeLessonStatus(LessonV1 lesson, LessonStatusV1 status) {
    if (lesson.status == status) return;
    widget.catalogController.add(
      CatalogLessonStatusChangedV2(
        LessonStatusChangeV1(lesson: lesson, status: status),
      ),
    );
  }

  Widget _body(LessonEditorStateV2 state) {
    if (state.loadState == LessonEditorLoadStateV2.loading ||
        state.loadState == LessonEditorLoadStateV2.initial) {
      return const StudySkeleton();
    }
    final workspace = state.workspace;
    if (workspace == null) {
      return StudyStateView(
        icon: Icons.cloud_off_outlined,
        title: 'Урок не загрузился',
        description: 'Проверьте локальный сервис и повторите попытку.',
        actionLabel: 'Повторить',
        actionIcon: Icons.refresh_rounded,
        onAction: () => _controller.add(LessonEditorStartedV2(widget.lesson)),
      );
    }
    final busy = state.saveState == SaveStateV1.saving;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyP,
          meta: true,
          shift: true,
        ): () =>
            _noteKey.currentState?.openCommands(),
        const SingleActivator(
          LogicalKeyboardKey.keyP,
          control: true,
          shift: true,
        ): () =>
            _noteKey.currentState?.openCommands(),
      },
      child: Focus(
        autofocus: true,
        child: TabBarView(
          controller: _tabController,
          children: [
            _NoteDocument(
              key: _noteKey,
              block: workspace.block,
              busy: busy,
              mode: _viewMode,
              onModeChanged: (mode) => setState(() => _viewMode = mode),
              onChanged: (block) =>
                  _controller.add(LessonEditorBlockChangedV2(block)),
              onAdd: _addBlock,
              onDelete: _deleteItem,
              onConcept: _editBlockConcept,
              onSource: _editBlockSource,
              onOpenUrl: _openExternalUrl,
              onMove: (block, offset) => _controller.add(
                LessonEditorBlockMoveRequestedV2(block, offset),
              ),
              onLessonAction: (action) =>
                  _handleLessonAction(action, workspace),
            ),
            _HomeworkView(
              key: _homeworkKey,
              studyId: widget.lesson.studyId,
              lessonId: widget.lesson.id,
              createRequest: _homeworkCreateRequest,
              task: workspace.task,
              busy: busy,
              onChanged: (task) =>
                  _controller.add(LessonEditorTaskChangedV2(task)),
              onAdded: (task) => _controller.add(LessonEditorTaskAddedV2(task)),
              onDelete: _deleteItem,
              onMove: (task, offset) => _controller.add(
                LessonEditorTaskMoveRequestedV2(task, offset),
              ),
              onDirtyChanged: _setHomeworkDirty,
            ),
            _FileView(
              key: _fileKey,
              file: workspace.file,
              busy: busy,
              saveState: state.saveState,
              onChanged: (file) =>
                  _controller.add(LessonEditorFileChangedV2(file)),
              onRetry: () => _controller.add(const LessonEditorRetrySaveV2()),
              onAdd: () => _addFile(workspace.task),
              onDelete: _deleteItem,
              onDirtyChanged: _setFileDirty,
            ),
          ],
        ),
      ),
    );
  }

  void _setHomeworkDirty(bool value) {
    if (mounted && _homeworkDirty != value) {
      setState(() => _homeworkDirty = value);
    }
  }

  void _setFileDirty(bool value) {
    if (mounted && _fileDirty != value) setState(() => _fileDirty = value);
  }

  String _addBlock(NoteBlockTypeV1 type) {
    final id = const Uuid().v4();
    final position = _controller.state.workspace?.block.length ?? 0;
    _controller.add(
      LessonEditorBlockAddedV2(
        NoteBlockV1(
          id: id,
          studyId: widget.lesson.studyId,
          lessonId: widget.lesson.id,
          type: type,
          position: position,
        ),
      ),
    );
    return id;
  }

  Future<void> _handleLessonAction(
    _LessonAction action,
    LessonWorkspaceV1 workspace,
  ) async {
    if (!mounted || !_isActive) return;
    switch (action) {
      case _LessonAction.note:
        await _selectTab(0);
      case _LessonAction.homework:
        await _selectTab(1);
      case _LessonAction.file:
        await _selectTab(2);
      case _LessonAction.newHomework:
        setState(() => _homeworkCreateRequest++);
        await _selectTab(1);
      case _LessonAction.newFile:
        await _selectTab(2);
        if (mounted && _isActive) await _addFile(workspace.task);
      case _LessonAction.read:
        setState(() => _viewMode = _LessonViewMode.read);
      case _LessonAction.back:
        await Navigator.maybePop(context);
    }
  }

  Future<void> _selectTab(int index) async {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    _tabController.animateTo(
      index,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
    if (duration > Duration.zero) await Future<void>.delayed(duration);
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _deleteItem(Object item) async {
    if (!mounted || !_isActive) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить без возможности восстановления?'),
        content: const Text('Это действие удалит выбранный элемент.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (!mounted || !_isActive || !(confirmed ?? false)) return;
    switch (item) {
      case final NoteBlockV1 value:
        _controller.add(LessonEditorBlockDeletedV2(value));
      case final HomeworkTaskV1 value:
        _controller.add(LessonEditorTaskDeletedV2(value));
      case final CodeFileV1 value:
        _controller.add(LessonEditorFileDeletedV2(value));
    }
  }

  Future<void> _editBlockConcept(NoteBlockV1 block) async {
    if (!mounted || !_isActive) return;
    final concept = (await _controller.searchConcept(
      study: widget.study,
      query: '',
    )).toList();
    if (!mounted || !_isActive) return;
    final busyConcept = <String>{};
    await showStudyDialogV1<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => StudySideSheet(
          title: const Text('Понятия блока'),
          child: SizedBox(
            width: 480,
            height: 420,
            child: concept.isEmpty
                ? const Center(
                    child: Text(
                      'Сначала добавьте понятие в разделе «Понятия».',
                    ),
                  )
                : ListView.builder(
                    itemCount: concept.length,
                    itemBuilder: (context, index) {
                      final item = concept[index];
                      final linked = item.blockIds.contains(block.id);
                      return CheckboxListTile(
                        value: linked,
                        title: Text(item.title),
                        onChanged: busyConcept.contains(item.id)
                            ? null
                            : (_) async {
                                setDialogState(() => busyConcept.add(item.id));
                                final stored = await _controller
                                    .changeBlockConcept(
                                      concept: item,
                                      block: block,
                                      link: !linked,
                                    );
                                if (stored != null) concept[index] = stored;
                                if (mounted && _isActive && context.mounted) {
                                  setDialogState(
                                    () => busyConcept.remove(item.id),
                                  );
                                }
                              },
                      );
                    },
                  ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Готово'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBlockSource(NoteBlockV1 block) async {
    if (!mounted || !_isActive) return;
    final url = TextEditingController(text: block.sourceUrl);
    final position = TextEditingController(text: block.sourcePosition);
    final result = await showStudyDialogV1<NoteBlockV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final value = url.text.trim();
          final invalid = value.isNotEmpty && _httpUri(value) == null;
          return StudySideSheet(
            title: const Text('Источник блока'),
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  TextField(
                    controller: url,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Ссылка',
                      hintText: 'https://…',
                      errorText: invalid
                          ? 'Ссылка сохранится, но открыть её нельзя'
                          : null,
                    ),
                  ),
                  TextField(
                    controller: position,
                    decoration: const InputDecoration(
                      labelText: 'Позиция в источнике',
                      hintText: 'Глава 3, 12:40',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  block.copyWith(
                    sourceUrl: url.text.trim(),
                    sourcePosition: position.text.trim(),
                  ),
                ),
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
    url.dispose();
    position.dispose();
    if (mounted && _isActive && result != null) {
      _controller.add(LessonEditorBlockChangedV2(result));
    }
  }

  Future<void> _addFile(List<HomeworkTaskV1> task) async {
    if (!mounted || !_isActive) return;
    final relativePath = TextEditingController();
    final language = TextEditingController();
    final content = TextEditingController();
    String? homeworkTaskId;
    final result = await showStudyDialogV1<CodeFileV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => StudySideSheet(
          title: const Text('Новый файл'),
          child: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                TextField(
                  controller: relativePath,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Относительный путь',
                    hintText: 'src/main.c',
                  ),
                ),
                TextField(
                  controller: language,
                  decoration: const InputDecoration(labelText: 'Язык'),
                ),
                DropdownButtonFormField<String?>(
                  initialValue: homeworkTaskId,
                  decoration: const InputDecoration(
                    labelText: 'Принадлежность',
                  ),
                  items: [
                    const DropdownMenuItem(child: Text('Урок')),
                    for (final item in task)
                      DropdownMenuItem(
                        value: item.id,
                        child: Text('Задание ${item.position + 1}'),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => homeworkTaskId = value),
                ),
                TextField(
                  controller: content,
                  minLines: 8,
                  maxLines: 16,
                  inputFormatters: const [_Utf8LengthFormatter()],
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: const InputDecoration(labelText: 'Содержимое'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: !_isValidRelativePath(relativePath.text)
                  ? null
                  : () => Navigator.pop(
                      context,
                      CodeFileV1(
                        id: const Uuid().v4(),
                        studyId: widget.lesson.studyId,
                        lessonId: widget.lesson.id,
                        homeworkTaskId: homeworkTaskId,
                        relativePath: relativePath.text,
                        language: language.text,
                        content: content.text,
                      ),
                    ),
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
    relativePath.dispose();
    language.dispose();
    content.dispose();
    if (mounted && _isActive && result != null) {
      _controller.add(LessonEditorFileAddedV2(result));
    }
  }

  Future<void> _requestLeave(LessonEditorStateV2 state) async {
    if (!mounted || !_isActive) return;
    if (!_hasLocalDraft && !_isControllerDraftUnsafe(state.saveState)) {
      await Navigator.maybePop(context);
      return;
    }
    final action = await showDialog<_LeaveAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменения не сохранены'),
        content: const Text(
          'Сохраните изменения, останьтесь в уроке или верните данные с сервера.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _LeaveAction.stay),
            child: const Text('Остаться'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _LeaveAction.discard),
            child: const Text('Сбросить и перечитать'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _LeaveAction.save),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (!mounted || !_isActive) return;
    switch (action) {
      case _LeaveAction.save:
        final homeworkSaved = _homeworkKey.currentState?.commitDraft() ?? true;
        final fileSaved = _fileKey.currentState?.commitDraft() ?? true;
        if (!homeworkSaved || !fileSaved) return;
        _controller.add(const LessonEditorRetrySaveV2());
        if (await _waitForSuccessfulSave() && mounted && _isActive) {
          await WidgetsBinding.instance.endOfFrame;
          if (!mounted || !_isActive) return;
          await Navigator.maybePop(context);
        }
      case _LeaveAction.discard:
        _homeworkKey.currentState?.discardDraft();
        _fileKey.currentState?.discardDraft();
        _controller.add(const LessonEditorDiscardV2());
      case _LeaveAction.stay:
      case null:
        break;
    }
  }

  Future<bool> _waitForSuccessfulSave() async {
    await Future<void>.delayed(Duration.zero);
    if (!_isControllerDraftUnsafe(_controller.state.saveState)) return true;
    final state = await _controller.stream.firstWhere(
      (state) => {
        SaveStateV1.clean,
        SaveStateV1.saved,
        SaveStateV1.failed,
        SaveStateV1.conflict,
      }.contains(state.saveState),
    );
    return {SaveStateV1.clean, SaveStateV1.saved}.contains(state.saveState);
  }

  Future<void> _onEffect(BuildContext _, LessonEditorEffectV2 effect) async {
    if (!mounted || !_isActive) return;
    switch (effect) {
      case LessonEditorFailureEffectV2():
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить изменения')),
        );
      case LessonEditorNavigateEffectV2():
        final navigator = Navigator.maybeOf(context);
        if (navigator != null && navigator.canPop()) navigator.pop();
      case LessonEditorDraftDecisionEffectV2():
        await _requestLeave(_controller.state);
    }
  }

  Future<void> _openExternalUrl(String value) async {
    final uri = _httpUri(value);
    if (uri == null || !mounted || !_isActive) return;
    try {
      final opened = await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );
      if (!opened && mounted && _isActive) _showLinkFailure();
    } on Object {
      if (mounted && _isActive) _showLinkFailure();
    }
  }

  void _showLinkFailure() {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text('Не удалось открыть ссылку')));
  }
}

enum _LessonViewMode { edit, read }

enum _LessonAction { note, homework, file, newHomework, newFile, read, back }

enum _LeaveAction { save, stay, discard }

final class _LessonTab extends StatelessWidget {
  final String label;
  final int count;

  const _LessonTab({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text('$count'),
            ),
          ),
        ],
      ),
    );
  }
}

final class _SaveBadge extends StatelessWidget {
  final SaveStateV1 state;
  final bool compact;

  const _SaveBadge({required this.state, required this.compact});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (state) {
      SaveStateV1.dirty => (
        Icons.edit_outlined,
        'Есть изменения',
        studyWarningColor,
      ),
      SaveStateV1.saving => (Icons.sync, 'Сохранение', scheme.primary),
      SaveStateV1.saved || SaveStateV1.clean => (
        Icons.cloud_done_outlined,
        'Сохранено',
        scheme.tertiary,
      ),
      SaveStateV1.failed => (Icons.cloud_off_outlined, 'Ошибка', scheme.error),
      SaveStateV1.conflict => (
        Icons.warning_amber_rounded,
        'Конфликт',
        studyWarningColor,
      ),
    };
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          if (!compact) ...[
            const SizedBox(width: 7),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
    return Tooltip(message: label, child: child);
  }
}

final class _LessonStatusControl extends StatelessWidget {
  final LessonV1 lesson;
  final bool compact;
  final void Function(LessonV1 lesson, LessonStatusV1 status) onSelected;

  const _LessonStatusControl({
    required this.lesson,
    required this.compact,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = lessonStatusColor(context, lesson.status);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<LessonStatusV1>(
        tooltip: 'Изменить статус урока',
        position: PopupMenuPosition.under,
        onSelected: (status) => onSelected(lesson, status),
        itemBuilder: (context) => [
          for (final status in LessonStatusV1.values)
            PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    status == lesson.status
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 17,
                    color: lessonStatusColor(context, status),
                  ),
                  const SizedBox(width: 10),
                  Text(lessonStatusLabel(status)),
                ],
              ),
            ),
        ],
        child: compact
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.flag_outlined, size: 19, color: color),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LessonStatusBadge(status: lesson.status),
                  const SizedBox(width: 2),
                  Icon(Icons.expand_more_rounded, size: 18, color: color),
                ],
              ),
      ),
    );
  }
}

final class _Utf8LengthFormatter extends TextInputFormatter {
  const _Utf8LengthFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => utf8.encode(newValue.text).length <= StudyConstV1.maxContentBytes
      ? newValue
      : oldValue;
}

Uri? _httpUri(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
          uri.hasAuthority &&
          (uri.scheme == 'http' || uri.scheme == 'https')
      ? uri
      : null;
}

String _blockLabel(NoteBlockTypeV1 type) => switch (type) {
  NoteBlockTypeV1.text => 'Текст',
  NoteBlockTypeV1.definition => 'Определение',
  NoteBlockTypeV1.claim => 'Тезис',
  NoteBlockTypeV1.quote => 'Цитата',
  NoteBlockTypeV1.example => 'Пример',
  NoteBlockTypeV1.question => 'Вопрос',
  NoteBlockTypeV1.summary => 'Итог',
};

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.'
      '${local.month.toString().padLeft(2, '0')}.${local.year}';
}

bool _isValidRelativePath(String value) {
  final part = value.split('/');
  return value.isNotEmpty &&
      !value.startsWith('/') &&
      !value.contains(r'\') &&
      part.every((item) => item.isNotEmpty && item != '.' && item != '..');
}

bool _isControllerDraftUnsafe(SaveStateV1 state) => {
  SaveStateV1.dirty,
  SaveStateV1.saving,
  SaveStateV1.failed,
  SaveStateV1.conflict,
}.contains(state);

void _syncTextController(TextEditingController controller, String text) {
  if (controller.text == text) return;
  final oldOffset = controller.selection.baseOffset;
  final offset = oldOffset < 0
      ? 0
      : oldOffset > text.length
      ? text.length
      : oldOffset;
  controller.value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: offset),
  );
}
