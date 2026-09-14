part of 'lesson_editor_page.dart';

final class _NoteDocument extends StatefulWidget {
  final List<NoteBlockV1> block;
  final bool busy;
  final _LessonViewMode mode;
  final ValueChanged<_LessonViewMode> onModeChanged;
  final ValueChanged<NoteBlockV1> onChanged;
  final String Function(NoteBlockTypeV1) onAdd;
  final ValueChanged<NoteBlockV1> onDelete;
  final ValueChanged<NoteBlockV1> onConcept;
  final ValueChanged<NoteBlockV1> onSource;
  final Future<void> Function(String) onOpenUrl;
  final void Function(NoteBlockV1, int) onMove;
  final ValueChanged<_LessonAction> onLessonAction;

  const _NoteDocument({
    required this.block,
    required this.busy,
    required this.mode,
    required this.onModeChanged,
    required this.onChanged,
    required this.onAdd,
    required this.onDelete,
    required this.onConcept,
    required this.onSource,
    required this.onOpenUrl,
    required this.onMove,
    required this.onLessonAction,
    super.key,
  });

  @override
  State<_NoteDocument> createState() => _NoteDocumentState();
}

final class _NoteDocumentState extends State<_NoteDocument>
    with AutomaticKeepAliveClientMixin {
  final Map<String, GlobalKey<_NoteBlockEditorState>> _editorKey = {};
  String? _activeBlockId;
  String? _pendingFocusId;

  @override
  bool get wantKeepAlive => true;

  NoteBlockV1? get _activeBlock {
    final id = _effectiveActiveId;
    return widget.block.where((block) => block.id == id).firstOrNull;
  }

  String? get _effectiveActiveId {
    if (widget.block.any((block) => block.id == _activeBlockId)) {
      return _activeBlockId;
    }
    return widget.block.firstOrNull?.id;
  }

  @override
  void didUpdateWidget(_NoteDocument oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = widget.block.map((block) => block.id).toSet();
    _editorKey.removeWhere((id, _) => !ids.contains(id));
    if (_pendingFocusId != null && ids.contains(_pendingFocusId)) {
      _activeBlockId = _pendingFocusId;
      final id = _pendingFocusId;
      _pendingFocusId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && id != null) _editorKey[id]?.currentState?.requestFocus();
      });
    } else if (!ids.contains(_activeBlockId)) {
      final previousIndex = oldWidget.block.indexWhere(
        (block) => block.id == _activeBlockId,
      );
      final nextIndex = previousIndex < 0
          ? 0
          : previousIndex >= widget.block.length
          ? widget.block.length - 1
          : previousIndex;
      _activeBlockId = widget.block.isEmpty ? null : widget.block[nextIndex].id;
      final id = _activeBlockId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && id != null) _editorKey[id]?.currentState?.requestFocus();
      });
    }
  }

  Future<void> openCommands() async {
    if (!mounted) return;
    final command = await showDialog<_CommandItem>(
      context: context,
      builder: (context) => _CommandPalette(command: _commands()),
    );
    if (!mounted || command == null) return;
    command.run();
  }

  List<_CommandItem> _commands() {
    final active = _activeBlock;
    return [
      if (active != null && widget.mode == _LessonViewMode.edit) ...[
        for (final type in NoteBlockTypeV1.values)
          _CommandItem(
            group: 'Тип блока',
            label: _blockLabel(type),
            icon: _blockIcon(type),
            search: '${_blockLabel(type)} тип блок',
            run: () => widget.onChanged(active.copyWith(type: type)),
          ),
        for (final action in _MarkdownAction.values)
          _CommandItem(
            group: 'Markdown',
            label: _markdownActionLabel(action),
            icon: _markdownActionIcon(action),
            search: '${_markdownActionLabel(action)} markdown формат',
            run: () => _editorKey[active.id]?.currentState?.apply(action),
          ),
        _CommandItem(
          group: 'Блок',
          label: 'Источник блока',
          icon: Icons.link_rounded,
          search: 'ссылка источник позиция глава время',
          run: () => widget.onSource(active),
        ),
        _CommandItem(
          group: 'Блок',
          label: 'Связать понятия',
          icon: Icons.hub_outlined,
          search: 'понятия связи знания',
          run: () => widget.onConcept(active),
        ),
      ],
      _CommandItem(
        group: 'Урок',
        label: 'Новый текстовый блок',
        icon: Icons.add_rounded,
        search: 'добавить новый блок текст',
        run: () => _createBlock(NoteBlockTypeV1.text),
      ),
      _CommandItem(
        group: 'Урок',
        label: 'Новое задание',
        icon: Icons.add_task_rounded,
        search: 'домашняя работа задача добавить',
        run: () => widget.onLessonAction(_LessonAction.newHomework),
      ),
      _CommandItem(
        group: 'Урок',
        label: 'Новый файл',
        icon: Icons.note_add_outlined,
        search: 'файл код добавить',
        run: () => widget.onLessonAction(_LessonAction.newFile),
      ),
      _CommandItem(
        group: 'Навигация',
        label: widget.mode == _LessonViewMode.edit
            ? 'Режим чтения'
            : 'Режим редактирования',
        icon: widget.mode == _LessonViewMode.edit
            ? Icons.chrome_reader_mode_outlined
            : Icons.edit_outlined,
        search: 'режим чтение редактирование просмотр',
        run: () => widget.onModeChanged(
          widget.mode == _LessonViewMode.edit
              ? _LessonViewMode.read
              : _LessonViewMode.edit,
        ),
      ),
      _CommandItem(
        group: 'Навигация',
        label: 'Конспект',
        icon: Icons.notes_rounded,
        search: 'перейти конспект',
        run: () => widget.onLessonAction(_LessonAction.note),
      ),
      _CommandItem(
        group: 'Навигация',
        label: 'Домашняя работа',
        icon: Icons.task_alt_rounded,
        search: 'перейти домашняя работа задания',
        run: () => widget.onLessonAction(_LessonAction.homework),
      ),
      _CommandItem(
        group: 'Навигация',
        label: 'Файлы',
        icon: Icons.code_rounded,
        search: 'перейти файлы код',
        run: () => widget.onLessonAction(_LessonAction.file),
      ),
      _CommandItem(
        group: 'Навигация',
        label: 'Назад к материалу',
        icon: Icons.arrow_back_rounded,
        search: 'назад материал выйти',
        run: () => widget.onLessonAction(_LessonAction.back),
      ),
    ];
  }

  void _createBlock(NoteBlockTypeV1 type) {
    final id = widget.onAdd(type);
    setState(() {
      _activeBlockId = id;
      _pendingFocusId = id;
    });
  }

  void _activate(String id) {
    if (widget.mode == _LessonViewMode.read) return;
    setState(() => _activeBlockId = id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editorKey[id]?.currentState?.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final activeId = _effectiveActiveId;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        children: [
          _NoteToolbar(
            mode: widget.mode,
            busy: widget.busy,
            onModeChanged: widget.onModeChanged,
            onCommands: openCommands,
            onAdd: () => _createBlock(NoteBlockTypeV1.text),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final document = AnimatedSwitcher(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: _document(activeId),
                );
                if (constraints.maxWidth < 1200) {
                  return Column(
                    children: [
                      if (widget.block.isNotEmpty) ...[
                        SizedBox(
                          height: 58,
                          child: _CompactBlockNavigator(
                            block: widget.block,
                            activeId: activeId,
                            onSelected: _activate,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Expanded(child: document),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 270,
                      child: _BlockOutline(
                        block: widget.block,
                        activeId: activeId,
                        onSelected: _activate,
                        onAdd: widget.mode == _LessonViewMode.edit
                            ? () => _createBlock(NoteBlockTypeV1.text)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(child: document),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _document(String? activeId) {
    if (widget.block.isEmpty) {
      return StudyStateView(
        key: const ValueKey('empty-note-document'),
        icon: Icons.edit_note_rounded,
        title: 'Начните конспект',
        description:
            'Добавьте блок или введите «/», чтобы открыть команды урока.',
        actionLabel: 'Добавить блок',
        onAction: widget.busy ? null : () => _createBlock(NoteBlockTypeV1.text),
      );
    }
    return Center(
      key: ValueKey(widget.mode),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: StudySurface(
          padding: EdgeInsets.zero,
          radius: 24,
          child: ListView.builder(
            key: const PageStorageKey('lesson-note-document'),
            padding: const EdgeInsets.fromLTRB(34, 30, 34, 72),
            itemCount:
                widget.block.length +
                (widget.mode == _LessonViewMode.edit ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.block.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: widget.busy
                          ? null
                          : () => _createBlock(NoteBlockTypeV1.text),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Продолжить конспект'),
                    ),
                  ),
                );
              }
              final block = widget.block[index];
              final key = _editorKey.putIfAbsent(
                block.id,
                GlobalKey<_NoteBlockEditorState>.new,
              );
              return _NoteBlockEditor(
                key: key,
                block: block,
                index: index,
                active:
                    widget.mode == _LessonViewMode.edit && block.id == activeId,
                reading: widget.mode == _LessonViewMode.read,
                busy: widget.busy,
                onActivate: () => _activate(block.id),
                onChanged: widget.onChanged,
                onMove: (offset) => widget.onMove(block, offset),
                onDelete: () => widget.onDelete(block),
                onConcept: () => widget.onConcept(block),
                onSource: () => widget.onSource(block),
                onOpenUrl: widget.onOpenUrl,
                onSlash: openCommands,
              );
            },
          ),
        ),
      ),
    );
  }
}

final class _NoteToolbar extends StatelessWidget {
  final _LessonViewMode mode;
  final bool busy;
  final ValueChanged<_LessonViewMode> onModeChanged;
  final VoidCallback onCommands;
  final VoidCallback onAdd;

  const _NoteToolbar({
    required this.mode,
    required this.busy,
    required this.onModeChanged,
    required this.onCommands,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final modeSelector = SegmentedButton<_LessonViewMode>(
          segments: const [
            ButtonSegment(
              value: _LessonViewMode.edit,
              icon: Icon(Icons.edit_outlined, size: 18),
              label: Text('Редактирование'),
            ),
            ButtonSegment(
              value: _LessonViewMode.read,
              icon: Icon(Icons.chrome_reader_mode_outlined, size: 18),
              label: Text('Чтение'),
            ),
          ],
          selected: {mode},
          showSelectedIcon: false,
          onSelectionChanged: (value) => onModeChanged(value.first),
        );
        final actions = mode == _LessonViewMode.read
            ? const SizedBox.shrink()
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onCommands,
                    icon: const Icon(Icons.keyboard_command_key_rounded),
                    label: const Text('Команды'),
                  ),
                  FilledButton.icon(
                    onPressed: busy ? null : onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Добавить блок'),
                  ),
                ],
              );
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Конспект занятия',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  modeSelector,
                ],
              ),
              const SizedBox(height: 10),
              actions,
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Конспект занятия',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mode == _LessonViewMode.edit
                        ? 'Один цельный документ. Активный блок готов к вводу.'
                        : 'Чистый документ без элементов редактирования.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            modeSelector,
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}

final class _BlockOutline extends StatelessWidget {
  final List<NoteBlockV1> block;
  final String? activeId;
  final ValueChanged<String> onSelected;
  final VoidCallback? onAdd;

  const _BlockOutline({
    required this.block,
    required this.activeId,
    required this.onSelected,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StudySurface(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('Структура', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: block.isEmpty
                ? Center(
                    child: Text('Пока пусто', style: theme.textTheme.bodySmall),
                  )
                : ListView.builder(
                    itemCount: block.length,
                    itemBuilder: (context, index) {
                      final item = block[index];
                      final selected = item.id == activeId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: selected
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.16,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => onSelected(item.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 9,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _blockIcon(item.type),
                                    size: 16,
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${index + 1}. ${_blockLabel(item.type)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelMedium,
                                        ),
                                        Text(
                                          _blockExcerpt(item),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (onAdd != null)
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить блок'),
            ),
        ],
      ),
    );
  }
}

final class _CompactBlockNavigator extends StatelessWidget {
  final List<NoteBlockV1> block;
  final String? activeId;
  final ValueChanged<String> onSelected;

  const _CompactBlockNavigator({
    required this.block,
    required this.activeId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      itemCount: block.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final item = block[index];
        final selected = item.id == activeId;
        return Material(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.18)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelected(item.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(_blockIcon(item.type), size: 17),
                  const SizedBox(width: 8),
                  Text('${index + 1}. ${_blockLabel(item.type)}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _NoteBlockEditor extends StatefulWidget {
  final NoteBlockV1 block;
  final int index;
  final bool active;
  final bool reading;
  final bool busy;
  final VoidCallback onActivate;
  final ValueChanged<NoteBlockV1> onChanged;
  final ValueChanged<int> onMove;
  final VoidCallback onDelete;
  final VoidCallback onConcept;
  final VoidCallback onSource;
  final Future<void> Function(String) onOpenUrl;
  final VoidCallback onSlash;

  const _NoteBlockEditor({
    required this.block,
    required this.index,
    required this.active,
    required this.reading,
    required this.busy,
    required this.onActivate,
    required this.onChanged,
    required this.onMove,
    required this.onDelete,
    required this.onConcept,
    required this.onSource,
    required this.onOpenUrl,
    required this.onSlash,
    super.key,
  });

  @override
  State<_NoteBlockEditor> createState() => _NoteBlockEditorState();
}

final class _NoteBlockEditorState extends State<_NoteBlockEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  var _hovered = false;
  var _openingCommands = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.markdown);
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(_NoteBlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTextController(_controller, widget.block.markdown);
    if (widget.active && !oldWidget.active) requestFocus();
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.active) _focusNode.requestFocus();
    });
  }

  void apply(_MarkdownAction action) {
    if (!widget.active || widget.reading) return;
    switch (action) {
      case _MarkdownAction.heading2:
        _prefixLines('## ');
      case _MarkdownAction.heading3:
        _prefixLines('### ');
      case _MarkdownAction.bold:
        _wrap('**', '**', placeholder: 'важный текст');
      case _MarkdownAction.italic:
        _wrap('_', '_', placeholder: 'выделенный текст');
      case _MarkdownAction.bullet:
        _prefixLines('- ');
      case _MarkdownAction.numbered:
        _prefixLines('1. ');
      case _MarkdownAction.quote:
        _prefixLines('> ');
      case _MarkdownAction.inlineCode:
        _wrap('`', '`', placeholder: 'код');
      case _MarkdownAction.codeBlock:
        _wrap('```\n', '\n```', placeholder: 'код');
      case _MarkdownAction.link:
        _link();
      case _MarkdownAction.divider:
        _insert('\n---\n');
    }
  }

  void _handleChanged(String value) {
    final cursor = _controller.selection.extentOffset;
    if (!_openingCommands && cursor > 0) {
      final lineStart = value.lastIndexOf('\n', cursor - 1) + 1;
      final line = value.substring(lineStart, cursor);
      if (line.trim() == '/') {
        final slashIndex = lineStart + line.lastIndexOf('/');
        final cleaned = value.replaceRange(slashIndex, slashIndex + 1, '');
        _controller.value = TextEditingValue(
          text: cleaned,
          selection: TextSelection.collapsed(offset: cursor - 1),
        );
        _publish();
        _openingCommands = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          widget.onSlash();
          if (mounted) _openingCommands = false;
        });
        return;
      }
    }
    _publish();
  }

  void _publish() {
    widget.onChanged(widget.block.copyWith(markdown: _controller.text));
  }

  void _replaceSelection(String replacement, int selectionStart, int end) {
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : _controller.text.length;
    final finish = selection.isValid ? selection.end : _controller.text.length;
    final text = _controller.text.replaceRange(start, finish, replacement);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: start + selectionStart,
        extentOffset: start + end,
      ),
    );
    _publish();
    _focusNode.requestFocus();
  }

  void _wrap(String before, String after, {required String placeholder}) {
    final selection = _controller.selection;
    final selected = selection.isValid && !selection.isCollapsed
        ? selection.textInside(_controller.text)
        : placeholder;
    final replacement = '$before$selected$after';
    _replaceSelection(
      replacement,
      before.length,
      before.length + selected.length,
    );
  }

  void _prefixLines(String prefix) {
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : _controller.text.length;
    final end = selection.isValid ? selection.end : start;
    final lineStart = _controller.text.lastIndexOf('\n', start - 1) + 1;
    final nextBreak = _controller.text.indexOf('\n', end);
    final lineEnd = nextBreak < 0 ? _controller.text.length : nextBreak;
    final selected = _controller.text.substring(lineStart, lineEnd);
    final replacement = selected
        .split('\n')
        .map((line) => '$prefix$line')
        .join('\n');
    final text = _controller.text.replaceRange(lineStart, lineEnd, replacement);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: lineStart + prefix.length,
        extentOffset: lineStart + replacement.length,
      ),
    );
    _publish();
    _focusNode.requestFocus();
  }

  void _link() {
    final selection = _controller.selection;
    final selected = selection.isValid && !selection.isCollapsed
        ? selection.textInside(_controller.text)
        : 'текст ссылки';
    final replacement = '[$selected](https://)';
    final urlStart = replacement.indexOf('https://');
    _replaceSelection(replacement, urlStart, urlStart + 'https://'.length);
  }

  void _insert(String value) {
    _replaceSelection(value, value.length, value.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final interactive = widget.active && !widget.reading;
    final showActions = interactive || _hovered || _focusNode.hasFocus;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.fromLTRB(
          interactive ? 18 : 10,
          14,
          interactive ? 18 : 10,
          18,
        ),
        decoration: BoxDecoration(
          color: interactive
              ? theme.colorScheme.surfaceContainerHigh
              : Colors.transparent,
          borderRadius: BorderRadius.circular(interactive ? 16 : 10),
          border: Border.all(
            color: interactive
                ? theme.colorScheme.primary.withValues(alpha: 0.48)
                : Colors.transparent,
          ),
          boxShadow: interactive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  _blockIcon(widget.block.type),
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _blockLabel(widget.block.type),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                ExcludeFocus(
                  excluding: !showActions || widget.reading,
                  child: ExcludeSemantics(
                    excluding: !showActions || widget.reading,
                    child: AnimatedOpacity(
                      opacity: showActions && !widget.reading ? 1 : 0,
                      duration: disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      child: IgnorePointer(
                        ignoring: !showActions || widget.reading,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Выше',
                              onPressed: widget.busy || widget.index == 0
                                  ? null
                                  : () => widget.onMove(-1),
                              icon: const Icon(Icons.arrow_upward_rounded),
                            ),
                            IconButton(
                              tooltip: 'Ниже',
                              onPressed: widget.busy
                                  ? null
                                  : () => widget.onMove(1),
                              icon: const Icon(Icons.arrow_downward_rounded),
                            ),
                            IconButton(
                              tooltip: 'Источник блока',
                              onPressed: widget.busy ? null : widget.onSource,
                              icon: const Icon(Icons.link_rounded),
                            ),
                            IconButton(
                              tooltip: 'Связать понятия',
                              onPressed: widget.busy ? null : widget.onConcept,
                              icon: const Icon(Icons.hub_outlined),
                            ),
                            IconButton(
                              tooltip: 'Удалить блок',
                              onPressed: widget.busy ? null : widget.onDelete,
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (interactive) ...[
              _MarkdownToolbar(onSelected: apply),
              const SizedBox(height: 10),
              CallbackShortcuts(
                bindings: {
                  const SingleActivator(
                    LogicalKeyboardKey.keyB,
                    meta: true,
                  ): () =>
                      apply(_MarkdownAction.bold),
                  const SingleActivator(
                    LogicalKeyboardKey.keyB,
                    control: true,
                  ): () =>
                      apply(_MarkdownAction.bold),
                  const SingleActivator(
                    LogicalKeyboardKey.keyK,
                    meta: true,
                  ): () =>
                      apply(_MarkdownAction.link),
                  const SingleActivator(
                    LogicalKeyboardKey.keyK,
                    control: true,
                  ): () =>
                      apply(_MarkdownAction.link),
                },
                child: TextField(
                  key: ValueKey('note-editor-${widget.block.id}'),
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 7,
                  maxLines: 24,
                  inputFormatters: const [_Utf8LengthFormatter()],
                  textAlignVertical: TextAlignVertical.top,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  onChanged: _handleChanged,
                  decoration: const InputDecoration(
                    hintText: 'Пишите Markdown. «/» откроет команды.',
                  ),
                ),
              ),
            ] else
              Semantics(
                button: !widget.reading,
                label: widget.reading
                    ? null
                    : 'Редактировать блок ${widget.index + 1}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: widget.reading ? null : widget.onActivate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: widget.block.markdown.trim().isEmpty
                        ? Text(
                            'Пустой блок. Нажмите, чтобы начать.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : MarkdownBody(
                            data: widget.block.markdown,
                            selectable: true,
                            styleSheet: _markdownStyle(theme),
                          ),
                  ),
                ),
              ),
            if (widget.block.sourcePosition.isNotEmpty ||
                widget.block.sourceUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              _BlockSource(block: widget.block, onOpenUrl: widget.onOpenUrl),
            ],
          ],
        ),
      ),
    );
  }
}

final class _MarkdownToolbar extends StatelessWidget {
  final ValueChanged<_MarkdownAction> onSelected;

  const _MarkdownToolbar({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final action in _MarkdownAction.values)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: IconButton(
                tooltip: _markdownActionLabel(action),
                onPressed: () => onSelected(action),
                icon: Icon(_markdownActionIcon(action), size: 19),
              ),
            ),
        ],
      ),
    );
  }
}

final class _BlockSource extends StatelessWidget {
  final NoteBlockV1 block;
  final Future<void> Function(String) onOpenUrl;

  const _BlockSource({required this.block, required this.onOpenUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validUrl = _httpUri(block.sourceUrl) != null;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Icon(
          validUrl ? Icons.bookmark_outline_rounded : Icons.link_off_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        if (block.sourcePosition.isNotEmpty)
          Text(block.sourcePosition, style: theme.textTheme.bodySmall),
        if (block.sourceUrl.isNotEmpty)
          TextButton.icon(
            onPressed: validUrl ? () => onOpenUrl(block.sourceUrl) : null,
            icon: const Icon(Icons.open_in_new_rounded, size: 15),
            label: Text(validUrl ? 'Открыть источник' : 'Некорректная ссылка'),
          ),
      ],
    );
  }
}

final class _CommandItem {
  final String group;
  final String label;
  final String search;
  final IconData icon;
  final VoidCallback run;

  const _CommandItem({
    required this.group,
    required this.label,
    required this.search,
    required this.icon,
    required this.run,
  });
}

final class _CommandPalette extends StatefulWidget {
  final List<_CommandItem> command;

  const _CommandPalette({required this.command});

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

final class _CommandPaletteState extends State<_CommandPalette> {
  final _query = TextEditingController();
  final _queryFocus = FocusNode();
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _queryFocus.requestFocus();
    });
  }

  List<_CommandItem> get _filtered {
    final query = _query.text.trim().toLowerCase();
    if (query.isEmpty) return widget.command;
    return widget.command
        .where(
          (item) =>
              '${item.label} ${item.search}'.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _query.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  void _move(int offset) {
    final items = _filtered;
    if (items.isEmpty) return;
    setState(() {
      _selectedIndex = (_selectedIndex + offset) % items.length;
      if (_selectedIndex < 0) _selectedIndex += items.length;
    });
  }

  void _submit() {
    final items = _filtered;
    if (items.isNotEmpty) Navigator.pop(context, items[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _filtered;
    if (_selectedIndex >= items.length) _selectedIndex = 0;
    return Dialog(
      alignment: const Alignment(0, -0.28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 620),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
            const SingleActivator(LogicalKeyboardKey.enter): _submit,
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.pop(context),
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: TextField(
                  controller: _query,
                  focusNode: _queryFocus,
                  onChanged: (_) => setState(() => _selectedIndex = 0),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Найдите действие…',
                  ),
                ),
              ),
              const Divider(),
              Flexible(
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(28),
                        child: Text(
                          'Ничего не найдено',
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final firstInGroup =
                              index == 0 ||
                              items[index - 1].group != item.group;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (firstInGroup)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    6,
                                  ),
                                  child: Text(
                                    item.group,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              Material(
                                color: index == _selectedIndex
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.16,
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                child: ListTile(
                                  dense: true,
                                  leading: Icon(item.icon, size: 19),
                                  title: Text(item.label),
                                  onTap: () => Navigator.pop(context, item),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MarkdownAction {
  heading2,
  heading3,
  bold,
  italic,
  bullet,
  numbered,
  quote,
  inlineCode,
  codeBlock,
  link,
  divider,
}

String _markdownActionLabel(_MarkdownAction action) => switch (action) {
  _MarkdownAction.heading2 => 'Заголовок',
  _MarkdownAction.heading3 => 'Подзаголовок',
  _MarkdownAction.bold => 'Полужирный',
  _MarkdownAction.italic => 'Курсив',
  _MarkdownAction.bullet => 'Маркированный список',
  _MarkdownAction.numbered => 'Нумерованный список',
  _MarkdownAction.quote => 'Цитата',
  _MarkdownAction.inlineCode => 'Код в строке',
  _MarkdownAction.codeBlock => 'Блок кода',
  _MarkdownAction.link => 'Ссылка',
  _MarkdownAction.divider => 'Разделитель',
};

IconData _markdownActionIcon(_MarkdownAction action) => switch (action) {
  _MarkdownAction.heading2 => Icons.title_rounded,
  _MarkdownAction.heading3 => Icons.text_fields_rounded,
  _MarkdownAction.bold => Icons.format_bold_rounded,
  _MarkdownAction.italic => Icons.format_italic_rounded,
  _MarkdownAction.bullet => Icons.format_list_bulleted_rounded,
  _MarkdownAction.numbered => Icons.format_list_numbered_rounded,
  _MarkdownAction.quote => Icons.format_quote_rounded,
  _MarkdownAction.inlineCode => Icons.code_rounded,
  _MarkdownAction.codeBlock => Icons.data_object_rounded,
  _MarkdownAction.link => Icons.link_rounded,
  _MarkdownAction.divider => Icons.horizontal_rule_rounded,
};

IconData _blockIcon(NoteBlockTypeV1 type) => switch (type) {
  NoteBlockTypeV1.text => Icons.notes_rounded,
  NoteBlockTypeV1.definition => Icons.menu_book_outlined,
  NoteBlockTypeV1.claim => Icons.lightbulb_outline_rounded,
  NoteBlockTypeV1.quote => Icons.format_quote_rounded,
  NoteBlockTypeV1.example => Icons.science_outlined,
  NoteBlockTypeV1.question => Icons.help_outline_rounded,
  NoteBlockTypeV1.summary => Icons.summarize_outlined,
};

String _blockExcerpt(NoteBlockV1 block) {
  final text = block.markdown
      .replaceAll(RegExp(r'[#>*_`\[\]()]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return text.isEmpty ? 'Пустой блок' : text;
}

MarkdownStyleSheet _markdownStyle(ThemeData theme) {
  final scheme = theme.colorScheme;
  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: theme.textTheme.bodyLarge?.copyWith(height: 1.68),
    h1: theme.textTheme.headlineLarge?.copyWith(height: 1.15),
    h2: theme.textTheme.headlineMedium?.copyWith(height: 1.2),
    h3: theme.textTheme.headlineSmall?.copyWith(height: 1.25),
    blockquoteDecoration: BoxDecoration(
      color: scheme.primary.withValues(alpha: 0.08),
      border: Border(left: BorderSide(color: scheme.primary, width: 3)),
      borderRadius: BorderRadius.circular(8),
    ),
    blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    code: theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      color: scheme.onSurface,
      backgroundColor: scheme.surfaceContainerHighest,
    ),
    codeblockDecoration: BoxDecoration(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: scheme.outlineVariant),
    ),
    codeblockPadding: const EdgeInsets.all(16),
    a: theme.textTheme.bodyLarge?.copyWith(
      color: scheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: scheme.primary,
    ),
    tableBorder: TableBorder.all(color: scheme.outlineVariant),
  );
}
