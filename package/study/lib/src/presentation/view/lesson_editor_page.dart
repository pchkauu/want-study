import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:study/src/application/bloc/lesson_editor_bloc.dart';
import 'package:study/src/application/safe_call.dart';
import 'package:study/src/domain/model/code_file.dart';
import 'package:study/src/domain/model/homework_task.dart';
import 'package:study/src/domain/model/lesson.dart';
import 'package:study/src/domain/model/note_block.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/repository/knowledge_repository.dart';
import 'package:study/src/domain/repository/lesson_content_repository.dart';
import 'package:uuid/uuid.dart';

final class LessonEditorPageV1 extends StatefulWidget {
  final LessonV1 lesson;
  final LessonContentRepositoryV1 repository;
  final KnowledgeRepositoryV1 knowledgeRepository;
  final Duration autosaveDelay;

  const LessonEditorPageV1({
    required this.lesson,
    required this.repository,
    required this.knowledgeRepository,
    required this.autosaveDelay,
    super.key,
  });

  @override
  State<LessonEditorPageV1> createState() => _LessonEditorPageV1State();
}

final class _LessonEditorPageV1State extends State<LessonEditorPageV1> {
  late final LessonEditorBlocV1 _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = LessonEditorBlocV1(
      repository: widget.repository,
      autosaveDelay: widget.autosaveDelay,
    )..add(LessonEditorStartedV1(widget.lesson.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child:
          BlocEffectConsumer<
            LessonEditorBlocV1,
            LessonEditorStateV1,
            LessonEditorEffectV1
          >(
            listener: _onEffect,
            builder: (context, state) {
              final unsafeToLeave =
                  state.saveState == SaveStateV1.dirty ||
                  state.saveState == SaveStateV1.saving ||
                  state.saveState == SaveStateV1.failed ||
                  state.saveState == SaveStateV1.conflict;
              return PopScope(
                canPop: !unsafeToLeave,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    _bloc.add(const LessonEditorNavigationRequestedV1());
                  }
                },
                child: DefaultTabController(
                  length: 3,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(widget.lesson.title),
                      bottom: const TabBar(
                        tabs: [
                          Tab(text: 'Конспект'),
                          Tab(text: 'Домашняя работа'),
                          Tab(text: 'Файлы'),
                        ],
                      ),
                      actions: [
                        _SaveBadge(state: state.saveState),
                        const SizedBox(width: 16),
                      ],
                    ),
                    body: _body(state),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _body(LessonEditorStateV1 state) {
    if (state.loadState == LessonEditorLoadStateV1.loading ||
        state.loadState == LessonEditorLoadStateV1.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    final workspace = state.workspace;
    if (workspace == null) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => _bloc.add(LessonEditorStartedV1(widget.lesson.id)),
          icon: const Icon(Icons.refresh),
          label: const Text('Повторить'),
        ),
      );
    }
    return TabBarView(
      children: [
        _NoteView(
          block: workspace.block,
          onChanged: (block) => _bloc.add(LessonEditorBlockChangedV1(block)),
          onAdd: () => _addBlock(context, workspace.block.length),
          onDelete: (block) => _deleteItem(context, block),
          onConcept: (block) => _editBlockConcept(context, block),
          onMove: (block, offset) =>
              _bloc.add(LessonEditorItemMoveRequestedV1(block, offset)),
        ),
        _HomeworkView(
          task: workspace.task,
          onChanged: (task) => _bloc.add(LessonEditorTaskChangedV1(task)),
          onAdd: () => _addTask(context, workspace.task.length),
          onEdit: (task) => _addTask(context, task.position, task),
          onDelete: (task) => _deleteItem(context, task),
          onMove: (task, offset) =>
              _bloc.add(LessonEditorItemMoveRequestedV1(task, offset)),
        ),
        _FileView(
          file: workspace.file,
          onChanged: (file) => _bloc.add(LessonEditorFileChangedV1(file)),
          onAdd: () => _addFile(context, workspace.task),
          onDelete: (file) => _deleteItem(context, file),
        ),
      ],
    );
  }

  Future<void> _deleteItem(BuildContext context, Object item) async {
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
    if (confirmed ?? false) {
      _bloc.add(LessonEditorItemDeletedV1(item));
    }
  }

  Future<void> _editBlockConcept(
    BuildContext context,
    NoteBlockV1 block,
  ) async {
    try {
      final result = await studySafeCallV1(
        'knowledge.listForBlock',
        () => widget.knowledgeRepository.searchConcepts(
          widget.lesson.studyId,
          '',
          limit: 100,
        ),
      );
      final concept = result.fold(
        (error) => throw error,
        (value) => value.toList(),
      );
      final busyConcept = <String>{};
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Понятия блока'),
            content: SizedBox(
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
                                  setDialogState(
                                    () => busyConcept.add(item.id),
                                  );
                                  final update = await studySafeCallV1(
                                    linked
                                        ? 'knowledge.unlinkBlock'
                                        : 'knowledge.linkBlock',
                                    () => linked
                                        ? widget.knowledgeRepository
                                              .unlinkBlock(item, block.id)
                                        : widget.knowledgeRepository.linkBlock(
                                            item,
                                            block.id,
                                          ),
                                  );
                                  update.fold(
                                    (_) => _showFailure(),
                                    (stored) => concept[index] = stored,
                                  );
                                  if (context.mounted) {
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
    } on Object {
      if (context.mounted) {
        _showFailure();
      }
    }
  }

  void _showFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось выполнить операцию')),
    );
  }

  Future<void> _onEffect(
    BuildContext context,
    LessonEditorEffectV1 effect,
  ) async {
    switch (effect) {
      case LessonEditorFailureEffectV1():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить изменения')),
        );
      case LessonEditorNavigateEffectV1():
        Navigator.of(context).pop();
      case LessonEditorDraftDecisionEffectV1():
        final action = await showDialog<_DraftAction>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Изменения не сохранены'),
            content: const Text('Выберите действие для текущего черновика.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, _DraftAction.stay),
                child: const Text('Остаться'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _DraftAction.discard),
                child: const Text('Сбросить и перечитать'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, _DraftAction.retry),
                child: const Text('Повторить сохранение'),
              ),
            ],
          ),
        );
        switch (action) {
          case _DraftAction.retry:
            _bloc.add(const LessonEditorRetrySaveV1());
          case _DraftAction.discard:
            _bloc.add(const LessonEditorDiscardV1());
          case _DraftAction.stay:
          case null:
            break;
        }
    }
  }

  Future<void> _addBlock(BuildContext context, int position) async {
    var type = NoteBlockTypeV1.text;
    final result = await showDialog<NoteBlockTypeV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новый блок'),
          content: DropdownButtonFormField(
            initialValue: type,
            items: [
              for (final value in NoteBlockTypeV1.values)
                DropdownMenuItem(value: value, child: Text(_blockLabel(value))),
            ],
            onChanged: (value) => setDialogState(() => type = value ?? type),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, type),
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      _bloc.add(
        LessonEditorBlockAddedV1(
          NoteBlockV1(
            id: const Uuid().v4(),
            studyId: widget.lesson.studyId,
            lessonId: widget.lesson.id,
            type: result,
            position: position,
          ),
        ),
      );
    }
  }

  Future<void> _addTask(
    BuildContext context,
    int position, [
    HomeworkTaskV1? existing,
  ]) async {
    final prompt = TextEditingController(text: existing?.promptMarkdown);
    final solution = TextEditingController(text: existing?.solutionMarkdown);
    var dueAt = existing?.dueAt;
    final result = await showDialog<HomeworkTaskV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Новое задание' : 'Задание'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: prompt,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Условие'),
                ),
                TextField(
                  controller: solution,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Решение'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dueAt == null
                            ? 'Срок не задан'
                            : 'Срок: ${_dateLabel(dueAt!)}',
                      ),
                    ),
                    if (dueAt != null)
                      IconButton(
                        tooltip: 'Убрать срок',
                        onPressed: () => setDialogState(() => dueAt = null),
                        icon: const Icon(Icons.clear),
                      ),
                    OutlinedButton(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(9999),
                          initialDate: dueAt?.toLocal() ?? DateTime.now(),
                        );
                        if (selected != null) {
                          setDialogState(() => dueAt = selected.toUtc());
                        }
                      },
                      child: const Text('Выбрать срок'),
                    ),
                  ],
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
                existing?.copyWith(
                      promptMarkdown: prompt.text,
                      solutionMarkdown: solution.text,
                      dueAt: () => dueAt,
                    ) ??
                    HomeworkTaskV1(
                      id: const Uuid().v4(),
                      studyId: widget.lesson.studyId,
                      lessonId: widget.lesson.id,
                      promptMarkdown: prompt.text,
                      solutionMarkdown: solution.text,
                      dueAt: dueAt,
                      position: position,
                    ),
              ),
              child: Text(existing == null ? 'Добавить' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
    prompt.dispose();
    solution.dispose();
    if (result != null) {
      _bloc.add(
        existing == null
            ? LessonEditorTaskAddedV1(result)
            : LessonEditorTaskChangedV1(result),
      );
    }
  }

  Future<void> _addFile(BuildContext context, List<HomeworkTaskV1> task) async {
    final relativePath = TextEditingController();
    final language = TextEditingController();
    final content = TextEditingController();
    String? homeworkTaskId;
    final result = await showDialog<CodeFileV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новый файл'),
          content: SizedBox(
            width: 640,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
    if (result != null) {
      _bloc.add(LessonEditorFileAddedV1(result));
    }
  }
}

enum _DraftAction { retry, stay, discard }

final class _SaveBadge extends StatelessWidget {
  final SaveStateV1 state;

  const _SaveBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (state) {
      SaveStateV1.dirty => (Icons.edit_outlined, 'Есть изменения'),
      SaveStateV1.saving => (Icons.sync, 'Сохранение'),
      SaveStateV1.saved => (Icons.cloud_done_outlined, 'Сохранено'),
      SaveStateV1.failed => (Icons.cloud_off_outlined, 'Ошибка'),
      SaveStateV1.conflict => (Icons.warning_amber, 'Конфликт'),
      SaveStateV1.clean => (Icons.cloud_done_outlined, 'Сохранено'),
    };
    return Row(
      children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
    );
  }
}

final class _NoteView extends StatelessWidget {
  final List<NoteBlockV1> block;
  final ValueChanged<NoteBlockV1> onChanged;
  final VoidCallback onAdd;
  final ValueChanged<NoteBlockV1> onDelete;
  final ValueChanged<NoteBlockV1> onConcept;
  final void Function(NoteBlockV1, int) onMove;

  const _NoteView({
    required this.block,
    required this.onChanged,
    required this.onAdd,
    required this.onDelete,
    required this.onConcept,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: block.isEmpty
              ? const Center(child: Text('Добавьте первый блок конспекта.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: block.length,
                  itemBuilder: (context, index) => _BlockEditor(
                    key: ValueKey(block[index].id),
                    block: block[index],
                    onChanged: onChanged,
                    onDelete: () => onDelete(block[index]),
                    onConcept: () => onConcept(block[index]),
                    onMove: (offset) => onMove(block[index], offset),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Добавить блок'),
          ),
        ),
      ],
    );
  }
}

final class _BlockEditor extends StatefulWidget {
  final NoteBlockV1 block;
  final ValueChanged<NoteBlockV1> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onConcept;
  final ValueChanged<int> onMove;

  const _BlockEditor({
    required this.block,
    required this.onChanged,
    required this.onDelete,
    required this.onConcept,
    required this.onMove,
    super.key,
  });

  @override
  State<_BlockEditor> createState() => _BlockEditorState();
}

final class _BlockEditorState extends State<_BlockEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.markdown);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _blockLabel(widget.block.type),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Выше',
                  onPressed: () => widget.onMove(-1),
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  tooltip: 'Ниже',
                  onPressed: () => widget.onMove(1),
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  tooltip: 'Связать понятия',
                  onPressed: widget.onConcept,
                  icon: const Icon(Icons.hub_outlined),
                ),
                IconButton(
                  tooltip: 'Удалить блок',
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final editor = TextField(
                  controller: _controller,
                  minLines: 8,
                  maxLines: 20,
                  onChanged: (value) =>
                      widget.onChanged(widget.block.copyWith(markdown: value)),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Markdown',
                  ),
                );
                final preview = DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SizedBox(
                    height: 260,
                    child: Markdown(data: _controller.text),
                  ),
                );
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: [editor, const SizedBox(height: 12), preview],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: editor),
                    const SizedBox(width: 16),
                    Expanded(child: preview),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class _HomeworkView extends StatelessWidget {
  final List<HomeworkTaskV1> task;
  final ValueChanged<HomeworkTaskV1> onChanged;
  final VoidCallback onAdd;
  final ValueChanged<HomeworkTaskV1> onEdit;
  final ValueChanged<HomeworkTaskV1> onDelete;
  final void Function(HomeworkTaskV1, int) onMove;

  const _HomeworkView({
    required this.task,
    required this.onChanged,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: task.isEmpty
              ? const Center(child: Text('Домашних заданий пока нет.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: task.length,
                  itemBuilder: (context, index) {
                    final item = task[index];
                    return Card(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                tooltip: 'Выше',
                                onPressed: () => onMove(item, -1),
                                icon: const Icon(Icons.arrow_upward),
                              ),
                              IconButton(
                                tooltip: 'Ниже',
                                onPressed: () => onMove(item, 1),
                                icon: const Icon(Icons.arrow_downward),
                              ),
                              IconButton(
                                tooltip: 'Изменить задание',
                                onPressed: () => onEdit(item),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Удалить задание',
                                onPressed: () => onDelete(item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          CheckboxListTile(
                            value: item.status == HomeworkStatusV1.done,
                            onChanged: (value) => onChanged(
                              item.copyWith(
                                status: value ?? false
                                    ? HomeworkStatusV1.done
                                    : HomeworkStatusV1.todo,
                              ),
                            ),
                            title: MarkdownBody(data: item.promptMarkdown),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.dueAt != null)
                                  Text('Срок: ${_dateLabel(item.dueAt!)}'),
                                if (item.solutionMarkdown.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: MarkdownBody(
                                      data:
                                          '**Решение**\n\n${item.solutionMarkdown}',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_task),
            label: const Text('Добавить задание'),
          ),
        ),
      ],
    );
  }
}

final class _FileView extends StatelessWidget {
  final List<CodeFileV1> file;
  final ValueChanged<CodeFileV1> onChanged;
  final VoidCallback onAdd;
  final ValueChanged<CodeFileV1> onDelete;

  const _FileView({
    required this.file,
    required this.onChanged,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: file.isEmpty
              ? const Center(child: Text('Файлов пока нет.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: file.length,
                  itemBuilder: (context, index) => _CodeFileEditor(
                    key: ValueKey(file[index].id),
                    file: file[index],
                    onSaved: onChanged,
                    onDelete: () => onDelete(file[index]),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Добавить файл'),
          ),
        ),
      ],
    );
  }
}

final class _CodeFileEditor extends StatefulWidget {
  final CodeFileV1 file;
  final ValueChanged<CodeFileV1> onSaved;
  final VoidCallback onDelete;

  const _CodeFileEditor({
    required this.file,
    required this.onSaved,
    required this.onDelete,
    super.key,
  });

  @override
  State<_CodeFileEditor> createState() => _CodeFileEditorState();
}

final class _CodeFileEditorState extends State<_CodeFileEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.file.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.file.relativePath,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => widget.onSaved(
                    widget.file.copyWith(content: _controller.text),
                  ),
                  child: const Text('Сохранить'),
                ),
                IconButton(
                  tooltip: 'Удалить файл',
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 10,
              maxLines: 24,
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
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
