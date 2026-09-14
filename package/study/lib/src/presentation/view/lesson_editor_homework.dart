part of 'lesson_editor_page.dart';

final class _HomeworkView extends StatefulWidget {
  final String studyId;
  final String lessonId;
  final int createRequest;
  final List<HomeworkTaskV1> task;
  final bool busy;
  final ValueChanged<HomeworkTaskV1> onChanged;
  final ValueChanged<HomeworkTaskV1> onAdded;
  final ValueChanged<HomeworkTaskV1> onDelete;
  final void Function(HomeworkTaskV1, int) onMove;
  final ValueChanged<bool> onDirtyChanged;

  const _HomeworkView({
    required this.studyId,
    required this.lessonId,
    required this.createRequest,
    required this.task,
    required this.busy,
    required this.onChanged,
    required this.onAdded,
    required this.onDelete,
    required this.onMove,
    required this.onDirtyChanged,
    super.key,
  });

  @override
  State<_HomeworkView> createState() => _HomeworkViewState();
}

final class _HomeworkViewState extends State<_HomeworkView>
    with AutomaticKeepAliveClientMixin {
  final _prompt = TextEditingController();
  final _solution = TextEditingController();
  String? _editingId;
  DateTime? _dueAt;
  var _creating = false;
  var _dirty = false;
  var _showPromptError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.createRequest > 0) _scheduleCreate();
  }

  @override
  void didUpdateWidget(_HomeworkView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.createRequest != oldWidget.createRequest) _scheduleCreate();
    if (_editingId != null &&
        widget.task.every((task) => task.id != _editingId)) {
      final wasDirty = _dirty;
      _clearDraftFields();
      _dirty = false;
      if (wasDirty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onDirtyChanged(false);
        });
      }
      return;
    }
    if (!_dirty && _editingId != null) {
      final stored = widget.task
          .where((task) => task.id == _editingId)
          .firstOrNull;
      if (stored != null) _syncFrom(stored);
    }
  }

  void _scheduleCreate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) startCreate();
    });
  }

  @override
  void dispose() {
    _prompt.dispose();
    _solution.dispose();
    super.dispose();
  }

  void startCreate() {
    if (!mounted || widget.busy) return;
    if (_dirty) {
      _showFinishDraftMessage();
      return;
    }
    setState(() {
      _editingId = null;
      _creating = true;
      _prompt.clear();
      _solution.clear();
      _dueAt = null;
      _showPromptError = false;
    });
  }

  bool commitDraft() {
    if (!_dirty) return true;
    if (_prompt.text.trim().isEmpty) {
      setState(() => _showPromptError = true);
      return false;
    }
    final existing = widget.task
        .where((task) => task.id == _editingId)
        .firstOrNull;
    if (_creating) {
      widget.onAdded(
        HomeworkTaskV1(
          id: const Uuid().v4(),
          studyId: widget.studyId,
          lessonId: widget.lessonId,
          promptMarkdown: _prompt.text,
          solutionMarkdown: _solution.text,
          dueAt: _dueAt,
          position: widget.task.length,
        ),
      );
    } else if (existing != null) {
      widget.onChanged(
        existing.copyWith(
          promptMarkdown: _prompt.text,
          solutionMarkdown: _solution.text,
          dueAt: () => _dueAt,
        ),
      );
    }
    _clearDraft();
    return true;
  }

  void discardDraft() {
    if (!mounted) return;
    setState(_clearDraftFields);
    _setDirty(false);
  }

  void _clearDraft() {
    setState(_clearDraftFields);
    _setDirty(false);
  }

  void _clearDraftFields() {
    _editingId = null;
    _creating = false;
    _prompt.clear();
    _solution.clear();
    _dueAt = null;
    _showPromptError = false;
  }

  void _edit(HomeworkTaskV1 task) {
    if (_dirty && _editingId != task.id) {
      _showFinishDraftMessage();
      return;
    }
    setState(() {
      _editingId = task.id;
      _creating = false;
      _syncFrom(task);
      _showPromptError = false;
    });
  }

  void _syncFrom(HomeworkTaskV1 task) {
    _syncTextController(_prompt, task.promptMarkdown);
    _syncTextController(_solution, task.solutionMarkdown);
    _dueAt = task.dueAt;
  }

  void _markDirty() {
    if (_showPromptError && _prompt.text.trim().isNotEmpty) {
      setState(() => _showPromptError = false);
    }
    _setDirty(true);
  }

  void _setDirty(bool value) {
    if (_dirty == value) return;
    _dirty = value;
    widget.onDirtyChanged(value);
  }

  void _showFinishDraftMessage() {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Сохраните или отмените открытое задание')),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(9999),
      initialDate: _dueAt?.toLocal() ?? DateTime.now(),
    );
    if (!mounted || selected == null) return;
    setState(() => _dueAt = selected.toUtc());
    _setDirty(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final done = widget.task
        .where((task) => task.status == HomeworkStatusV1.done)
        .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Домашняя работа', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 3),
                  Text(
                    widget.task.isEmpty
                        ? 'Заданий пока нет'
                        : '$done из ${widget.task.length} выполнено',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
              final add = FilledButton.icon(
                onPressed: widget.busy ? null : startCreate,
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Добавить задание'),
              );
              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [heading, const SizedBox(height: 12), add],
                );
              }
              return Row(
                children: [
                  Expanded(child: heading),
                  add,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: StudySurface(
                  padding: EdgeInsets.zero,
                  radius: 24,
                  child: widget.task.isEmpty && !_creating
                      ? StudyStateView(
                          icon: Icons.task_alt_outlined,
                          title: 'Добавьте первое задание',
                          description: 'Храните условие, решение и срок рядом с конспектом.',
                          actionLabel: 'Добавить задание',
                          onAction: widget.busy ? null : startCreate,
                        )
                      : ListView(
                          key: const PageStorageKey('lesson-homework'),
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 36),
                          children: [
                            if (_creating) ...[
                              _editor(null),
                              if (widget.task.isNotEmpty) const Divider(),
                            ],
                            for (
                              var index = 0;
                              index < widget.task.length;
                              index++
                            ) ...[
                              _taskRow(widget.task[index], index),
                              if (index < widget.task.length - 1)
                                const Divider(),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskRow(HomeworkTaskV1 task, int index) {
    final theme = Theme.of(context);
    final done = task.status == HomeworkStatusV1.done;
    final overdue = !done && _isOverdue(task.dueAt);
    final expanded = task.id == _editingId;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: done,
                onChanged: widget.busy
                    ? null
                    : (value) => widget.onChanged(
                        task.copyWith(
                          status: value ?? false
                              ? HomeworkStatusV1.done
                              : HomeworkStatusV1.todo,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _edit(task),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Задание ${index + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: done
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        MarkdownBody(
                          data: task.promptMarkdown,
                          styleSheet: _markdownStyle(theme),
                        ),
                        if (task.dueAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${overdue ? 'Просрочено' : 'Срок'}: ${_dateLabel(task.dueAt!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: overdue
                                  ? studyWarningColor
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              PopupMenuButton<_HomeworkAction>(
                tooltip: 'Действия с заданием',
                enabled: !widget.busy,
                onSelected: (action) {
                  switch (action) {
                    case _HomeworkAction.moveUp:
                      widget.onMove(task, -1);
                    case _HomeworkAction.moveDown:
                      widget.onMove(task, 1);
                    case _HomeworkAction.edit:
                      _edit(task);
                    case _HomeworkAction.delete:
                      if (_editingId == task.id) discardDraft();
                      widget.onDelete(task);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _HomeworkAction.moveUp,
                    child: Text('Переместить выше'),
                  ),
                  PopupMenuItem(
                    value: _HomeworkAction.moveDown,
                    child: Text('Переместить ниже'),
                  ),
                  PopupMenuItem(
                    value: _HomeworkAction.edit,
                    child: Text('Редактировать'),
                  ),
                  PopupMenuItem(
                    value: _HomeworkAction.delete,
                    child: Text('Удалить'),
                  ),
                ],
              ),
            ],
          ),
          if (disableAnimations) ...[
            if (expanded) _editor(task),
          ] else
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: expanded ? _editor(task) : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _editor(HomeworkTaskV1? task) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('homework-inline-editor'),
      margin: const EdgeInsets.fromLTRB(48, 8, 8, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            task == null ? 'Новое задание' : 'Редактирование задания',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final prompt = TextField(
                controller: _prompt,
                minLines: 3,
                maxLines: 10,
                inputFormatters: const [_Utf8LengthFormatter()],
                onChanged: (_) => _markDirty(),
                decoration: InputDecoration(
                  labelText: 'Условие',
                  errorText: _showPromptError
                      ? 'Введите условие задания'
                      : null,
                ),
              );
              final solution = TextField(
                controller: _solution,
                minLines: 3,
                maxLines: 12,
                inputFormatters: const [_Utf8LengthFormatter()],
                onChanged: (_) => _markDirty(),
                decoration: const InputDecoration(labelText: 'Решение'),
              );
              if (constraints.maxWidth < 680) {
                return Column(
                  children: [prompt, const SizedBox(height: 14), solution],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: prompt),
                  const SizedBox(width: 14),
                  Expanded(child: solution),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Text(
                _dueAt == null ? 'Срок не задан' : _dateLabel(_dueAt!),
                style: theme.textTheme.bodySmall,
              ),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 17),
                label: const Text('Выбрать срок'),
              ),
              if (_dueAt != null)
                TextButton(
                  onPressed: () {
                    setState(() => _dueAt = null);
                    _setDirty(true);
                  },
                  child: const Text('Убрать срок'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              TextButton(onPressed: discardDraft, child: const Text('Отмена')),
              FilledButton(
                onPressed: widget.busy ? null : commitDraft,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _HomeworkAction { moveUp, moveDown, edit, delete }

bool _isOverdue(DateTime? value) {
  if (value == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return value.toLocal().isBefore(today);
}
