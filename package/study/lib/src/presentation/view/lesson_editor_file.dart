part of 'lesson_editor_page.dart';

final class _FileView extends StatefulWidget {
  final List<CodeFileV1> file;
  final bool busy;
  final SaveStateV1 saveState;
  final ValueChanged<CodeFileV1> onChanged;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final ValueChanged<CodeFileV1> onDelete;
  final ValueChanged<bool> onDirtyChanged;

  const _FileView({
    required this.file,
    required this.busy,
    required this.saveState,
    required this.onChanged,
    required this.onRetry,
    required this.onAdd,
    required this.onDelete,
    required this.onDirtyChanged,
    super.key,
  });

  @override
  State<_FileView> createState() => _FileViewState();
}

final class _FileViewState extends State<_FileView>
    with AutomaticKeepAliveClientMixin {
  final Map<String, String> _draft = {};
  final Set<String> _submitted = {};
  final Set<String> _failed = {};
  String? _selectedFileId;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(_FileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasDirty = _draft.isNotEmpty;
    final ids = widget.file.map((file) => file.id).toSet();
    _draft.removeWhere((id, _) => !ids.contains(id));
    _submitted.removeWhere((id) => !ids.contains(id));
    _failed.removeWhere((id) => !ids.contains(id));
    if ({SaveStateV1.failed, SaveStateV1.conflict}.contains(widget.saveState)) {
      _failed.addAll(_submitted);
      _submitted.clear();
    }
    for (final file in widget.file) {
      if ((_submitted.contains(file.id) || _failed.contains(file.id)) &&
          _draft[file.id] == file.content) {
        _submitted.remove(file.id);
        _draft.remove(file.id);
        _failed.remove(file.id);
      }
    }
    if (widget.file.every((file) => file.id != _selectedFileId)) {
      _selectedFileId = widget.file.firstOrNull?.id;
    }
    if (wasDirty != _draft.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notifyDirty();
      });
    }
  }

  bool commitDraft() {
    if (_draft.isEmpty) return true;
    var retry = false;
    for (final entry in _draft.entries) {
      if (_submitted.contains(entry.key)) continue;
      if (_failed.remove(entry.key)) {
        _submitted.add(entry.key);
        retry = true;
        continue;
      }
      final file = widget.file
          .where((file) => file.id == entry.key)
          .firstOrNull;
      if (file == null) continue;
      _submitted.add(file.id);
      widget.onChanged(file.copyWith(content: entry.value));
    }
    if (retry) widget.onRetry();
    if (mounted) setState(() {});
    return true;
  }

  void discardDraft() {
    if (_draft.isEmpty) return;
    setState(() {
      _draft.clear();
      _submitted.clear();
      _failed.clear();
    });
    _notifyDirty();
  }

  void _setDraft(CodeFileV1 file, String value) {
    setState(() {
      _submitted.remove(file.id);
      _failed.remove(file.id);
      if (value == file.content) {
        _draft.remove(file.id);
      } else {
        _draft[file.id] = value;
      }
    });
    _notifyDirty();
  }

  void _discardFile(CodeFileV1 file) {
    setState(() {
      _draft.remove(file.id);
      _submitted.remove(file.id);
      _failed.remove(file.id);
    });
    _notifyDirty();
  }

  void _saveFile(CodeFileV1 file) {
    final value = _draft[file.id];
    if (value == null || _submitted.contains(file.id)) return;
    if (_failed.contains(file.id)) {
      setState(() {
        _failed.remove(file.id);
        _submitted.add(file.id);
      });
      widget.onRetry();
      return;
    }
    setState(() => _submitted.add(file.id));
    widget.onChanged(file.copyWith(content: value));
  }

  void _deleteFile(CodeFileV1 file) {
    _discardFile(file);
    widget.onDelete(file);
  }

  void _notifyDirty() => widget.onDirtyChanged(_draft.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final selected = widget.file
        .where((file) => file.id == _selectedFileId)
        .firstOrNull;
    final file = selected ?? widget.file.firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Файлы урока', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 3),
                  Text(
                    widget.file.isEmpty
                        ? 'Файлов пока нет'
                        : '${widget.file.length} ${_fileCountLabel(widget.file.length)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
              final add = FilledButton.icon(
                onPressed: widget.busy ? null : widget.onAdd,
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('Добавить файл'),
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
            child: StudySurface(
              padding: EdgeInsets.zero,
              radius: 24,
              child: file == null
                  ? StudyStateView(
                      icon: Icons.code_rounded,
                      title: 'Добавьте первый файл',
                      description: 'Храните исходный код и текстовые файлы рядом с уроком.',
                      actionLabel: 'Добавить файл',
                      onAction: widget.busy ? null : widget.onAdd,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 920;
                        final editor = _CodeFileEditor(
                          key: ValueKey(file.id),
                          file: file,
                          content: _draft[file.id] ?? file.content,
                          dirty: _draft.containsKey(file.id),
                          saving: _submitted.contains(file.id),
                          failed: _failed.contains(file.id),
                          busy: widget.busy,
                          onChanged: (value) => _setDraft(file, value),
                          onSaved: () => _saveFile(file),
                          onDiscarded: () => _discardFile(file),
                          onDeleted: () => _deleteFile(file),
                        );
                        if (compact) {
                          return Column(
                            children: [
                              SizedBox(height: 68, child: _fileList(true)),
                              const Divider(),
                              Expanded(child: editor),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            SizedBox(width: 250, child: _fileList(false)),
                            const VerticalDivider(),
                            Expanded(child: editor),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileList(bool horizontal) {
    final theme = Theme.of(context);
    if (horizontal) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: widget.file.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = widget.file[index];
          final selected = item.id == (_selectedFileId ?? widget.file.first.id);
          return Material(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.18)
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => setState(() => _selectedFileId = item.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.code_rounded, size: 17),
                    const SizedBox(width: 8),
                    Text(item.relativePath),
                    if (_draft.containsKey(item.id)) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.circle, size: 7, color: studyWarningColor),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: widget.file.length,
      itemBuilder: (context, index) {
        final item = widget.file[index];
        final selected = item.id == (_selectedFileId ?? widget.file.first.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: ListTile(
              dense: true,
              selected: selected,
              leading: const Icon(Icons.code_rounded, size: 18),
              title: Text(
                item.relativePath,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.homeworkTaskId == null ? 'Урок' : 'Домашняя работа',
                maxLines: 1,
              ),
              trailing: _draft.containsKey(item.id)
                  ? const Icon(Icons.circle, size: 7, color: studyWarningColor)
                  : null,
              onTap: () => setState(() => _selectedFileId = item.id),
            ),
          ),
        );
      },
    );
  }
}

final class _CodeFileEditor extends StatefulWidget {
  final CodeFileV1 file;
  final String content;
  final bool dirty;
  final bool saving;
  final bool failed;
  final bool busy;
  final ValueChanged<String> onChanged;
  final VoidCallback onSaved;
  final VoidCallback onDiscarded;
  final VoidCallback onDeleted;

  const _CodeFileEditor({
    required this.file,
    required this.content,
    required this.dirty,
    required this.saving,
    required this.failed,
    required this.busy,
    required this.onChanged,
    required this.onSaved,
    required this.onDiscarded,
    required this.onDeleted,
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
    _controller = TextEditingController(text: widget.content);
  }

  @override
  void didUpdateWidget(_CodeFileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTextController(_controller, widget.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.relativePath,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (widget.file.language.isNotEmpty)
                          widget.file.language,
                        switch (widget.file.homeworkTaskId) {
                          null => 'Файл урока',
                          _ => 'Файл задания',
                        },
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (widget.dirty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    widget.failed
                        ? 'Ошибка сохранения'
                        : widget.saving
                        ? 'Сохраняется'
                        : 'Изменён',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: widget.failed
                          ? theme.colorScheme.error
                          : widget.saving
                          ? theme.colorScheme.primary
                          : studyWarningColor,
                    ),
                  ),
                ),
              TextButton(
                onPressed: widget.dirty && !widget.saving
                    ? widget.onDiscarded
                    : null,
                child: const Text('Сбросить'),
              ),
              const SizedBox(width: 6),
              FilledButton(
                onPressed: widget.dirty && !widget.busy && !widget.saving
                    ? widget.onSaved
                    : null,
                child: const Text('Сохранить'),
              ),
              IconButton(
                tooltip: 'Удалить файл',
                onPressed: widget.busy ? null : widget.onDeleted,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: TextField(
              controller: _controller,
              expands: true,
              maxLines: null,
              inputFormatters: const [_Utf8LengthFormatter()],
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', height: 1.5),
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                hintText: 'Содержимое UTF-8 файла',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fileCountLabel(int count) {
  final mod100 = count % 100;
  if (mod100 >= 11 && mod100 <= 14) return 'файлов';
  return switch (count % 10) {
    1 => 'файл',
    2 || 3 || 4 => 'файла',
    _ => 'файлов',
  };
}
