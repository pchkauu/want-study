import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:graphview/GraphView.dart';
import 'package:study/src/application/safe_call.dart';
import 'package:study/src/application/slug.dart';
import 'package:study/src/domain/model/concept.dart';
import 'package:study/src/domain/model/concept_graph.dart';
import 'package:study/src/domain/model/concept_relation.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/repository/knowledge_repository.dart';
import 'package:study/src/presentation/widget/study_ui.dart';
import 'package:uuid/uuid.dart';

final class ConceptPageV1 extends StatefulWidget {
  final String studyId;
  final KnowledgeRepositoryV1 repository;

  const ConceptPageV1({
    required this.studyId,
    required this.repository,
    super.key,
  });

  @override
  State<ConceptPageV1> createState() => _ConceptPageV1State();
}

final class _ConceptPageV1State extends State<ConceptPageV1> {
  final _search = TextEditingController();
  ConceptGraphV1? _graph;
  List<ConceptV1> _result = const [];
  String? _selectedId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ConceptPageV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studyId != widget.studyId) {
      _selectedId = null;
      _load();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          StudySectionHeader(
            title: 'Понятия',
            description: 'Связи, псевдонимы и упоминания в конспектах.',
            trailing: FilledButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('Понятие'),
            ),
          ),
          const SizedBox(height: 18),
          SearchBar(
            controller: _search,
            hintText: 'Поиск понятия или псевдонима',
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            side: WidgetStatePropertyAll(
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (_) => _runSearch(),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _result.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final concept = _result[index];
                  return ActionChip(
                    label: Text(
                      concept.isArchived
                          ? '${concept.title} (архив)'
                          : concept.title,
                    ),
                    onPressed: concept.isArchived
                        ? () => _toggleArchive(concept)
                        : () => _select(concept.id),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const StudySkeleton(compact: true);
    }
    final graph = _graph;
    if (graph == null) {
      return StudyStateView(
        icon: Icons.cloud_off_outlined,
        title: 'Граф не загрузился',
        description: 'Проверьте локальный сервис и повторите попытку.',
        actionLabel: 'Повторить',
        actionIcon: Icons.refresh_rounded,
        onAction: _load,
      );
    }
    if (graph.concept.isEmpty) {
      return StudyStateView(
        icon: Icons.hub_outlined,
        title: 'Граф пока пуст',
        description: 'Добавьте первое понятие и свяжите его с конспектом.',
        actionLabel: 'Добавить понятие',
        onAction: _create,
      );
    }
    final view = _buildGraph(graph);
    final selected = graph.concept
        .where((concept) => concept.id == _selectedId)
        .firstOrNull;
    final inspector = selected == null
        ? const _EmptyConceptInspector()
        : _ConceptDetails(
            concept: selected,
            relation: graph.relation
                .where(
                  (relation) =>
                      relation.sourceConceptId == selected.id ||
                      relation.targetConceptId == selected.id,
                )
                .toList(),
            conceptById: view.$2,
            onEdit: () => _edit(selected),
            onArchive: () => _toggleArchive(selected),
            onAddRelation: () => _addRelation(selected),
            onDeleteRelation: _deleteRelation,
          );
    final canvas = StudySurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (graph.isTruncated)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              color: studyWarningColor.withValues(alpha: 0.1),
              child: const Text('Показан выбранный узел и два уровня соседей.'),
            ),
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(120),
              minScale: 0.1,
              maxScale: 3,
              child: GraphView(
                graph: view.$1,
                algorithm: FruchtermanReingoldAlgorithm(
                  FruchtermanReingoldConfiguration(iterations: 250),
                ),
                paint: Paint()
                  ..color = Theme.of(context).colorScheme.outline
                  ..strokeWidth = 1.2,
                builder: (node) {
                  final id = node.key?.value as String;
                  final concept = view.$2[id]!;
                  final selected = concept.id == _selectedId;
                  return InputChip(
                    selected: selected,
                    label: Text(concept.title),
                    onPressed: () => _select(concept.id),
                    onDeleted: selected ? () => _edit(concept) : null,
                    deleteIcon: const Icon(Icons.edit_outlined, size: 18),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, _) {
        if (MediaQuery.sizeOf(context).width < 960) {
          return Column(
            children: [
              Expanded(child: canvas),
              if (selected != null) ...[
                const SizedBox(height: 14),
                SizedBox(height: 250, child: inspector),
              ],
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: canvas),
            const SizedBox(width: 16),
            SizedBox(width: 360, child: inspector),
          ],
        );
      },
    );
  }

  (Graph, Map<String, ConceptV1>) _buildGraph(ConceptGraphV1 value) {
    final graph = Graph();
    final concepts = {for (final item in value.concept) item.id: item};
    final nodes = {for (final id in concepts.keys) id: Node.Id(id)};
    graph.addNodes(nodes.values.toList());
    for (final relation in value.relation) {
      final source = nodes[relation.sourceConceptId];
      final target = nodes[relation.targetConceptId];
      if (source != null && target != null) {
        graph.addEdge(source, target);
      }
    }
    return (graph, concepts);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final graph = await _safe(
        'knowledge.graph',
        () => widget.repository.getGraph(
          widget.studyId,
          selectedConceptId: _selectedId,
        ),
      );
      if (mounted) {
        setState(() {
          _graph = graph;
          _loading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _graph = null;
          _loading = false;
        });
        _showFailure();
      }
    }
  }

  Future<void> _runSearch() async {
    try {
      final result = await _safe(
        'knowledge.search',
        () => widget.repository.searchConcepts(
          widget.studyId,
          _search.text,
          includeArchived: true,
        ),
      );
      if (mounted) {
        setState(() => _result = result);
      }
    } on Object {
      if (mounted) {
        _showFailure();
      }
    }
  }

  Future<void> _select(String id) async {
    _selectedId = id;
    await _load();
  }

  Future<void> _create() async {
    final value = await _showEditor();
    if (value == null) {
      return;
    }
    try {
      final id = const Uuid().v4();
      await _safe(
        'knowledge.createConcept',
        () => widget.repository.createConcept(
          ConceptV1(
            id: id,
            studyId: widget.studyId,
            title: value.$1,
            descriptionMarkdown: value.$2,
            exportSlug: createExportSlugV1(
              value.$1,
              fallback: 'concept-${id.substring(0, 8)}',
            ),
            aliases: value.$3,
          ),
        ),
      );
      await _load();
    } on Object {
      if (mounted) {
        _showFailure();
      }
    }
  }

  Future<void> _edit(ConceptV1 concept) async {
    final value = await _showEditor(concept: concept);
    if (value == null) {
      return;
    }
    try {
      await _safe(
        'knowledge.updateConcept',
        () => widget.repository.updateConcept(
          concept.copyWith(
            title: value.$1,
            descriptionMarkdown: value.$2,
            aliases: value.$3,
          ),
        ),
      );
      await _load();
    } on Object {
      if (mounted) {
        _showFailure();
      }
    }
  }

  Future<void> _toggleArchive(ConceptV1 concept) async {
    try {
      if (concept.isArchived) {
        await _safe(
          'knowledge.restoreConcept',
          () => widget.repository.restoreConcept(concept),
        );
      } else {
        await _safe(
          'knowledge.archiveConcept',
          () => widget.repository.archiveConcept(concept),
        );
        if (_selectedId == concept.id) {
          _selectedId = null;
        }
      }
      await _runSearch();
      await _load();
    } on Object {
      if (mounted) {
        _showFailure();
      }
    }
  }

  Future<void> _addRelation(ConceptV1 source) async {
    final graph = _graph;
    if (graph == null) {
      return;
    }
    final target = graph.concept
        .where((concept) => concept.id != source.id)
        .toList();
    if (target.isEmpty) {
      return;
    }
    var targetId = target.first.id;
    var type = ConceptRelationTypeV1.relatedTo;
    final relation = await showDialog<ConceptRelationV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Новая связь'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: targetId,
                  decoration: const InputDecoration(labelText: 'Понятие'),
                  items: [
                    for (final concept in target)
                      DropdownMenuItem(
                        value: concept.id,
                        child: Text(concept.title),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => targetId = value ?? targetId),
                ),
                DropdownButtonFormField<ConceptRelationTypeV1>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Тип связи'),
                  items: [
                    for (final value in ConceptRelationTypeV1.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(_relationLabel(value)),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => type = value ?? type),
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
                ConceptRelationV1(
                  id: const Uuid().v4(),
                  studyId: widget.studyId,
                  sourceConceptId: source.id,
                  targetConceptId: targetId,
                  type: type,
                ),
              ),
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
    if (relation == null) {
      return;
    }
    try {
      await _safe(
        'knowledge.putRelation',
        () => widget.repository.putRelation(relation),
      );
      await _load();
    } on Object {
      if (mounted) {
        _showFailure();
      }
    }
  }

  Future<void> _deleteRelation(ConceptRelationV1 relation) async {
    try {
      await _safe(
        'knowledge.deleteRelation',
        () => widget.repository.deleteRelation(relation, confirmed: true),
      );
      await _load();
    } on Object {
      if (mounted) {
        _showFailure();
      }
    }
  }

  Future<(String, String, List<String>)?> _showEditor({
    ConceptV1? concept,
  }) async {
    final title = TextEditingController(text: concept?.title);
    final description = TextEditingController(
      text: concept?.descriptionMarkdown,
    );
    final aliases = TextEditingController(text: concept?.aliases.join(', '));
    String? error;
    final result = await showDialog<(String, String, List<String>)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(concept == null ? 'Новое понятие' : 'Понятие'),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  autofocus: true,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: 'Название',
                    errorText: error,
                  ),
                ),
                TextField(
                  controller: description,
                  minLines: 5,
                  maxLines: 12,
                  decoration: const InputDecoration(labelText: 'Описание'),
                ),
                TextField(
                  controller: aliases,
                  decoration: const InputDecoration(
                    labelText: 'Псевдонимы через запятую',
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
              onPressed: () {
                if (title.text.trim().isEmpty) {
                  setDialogState(() => error = 'Введите название');
                  return;
                }
                Navigator.pop(context, (
                  title.text.trim(),
                  description.text,
                  aliases.text
                      .split(',')
                      .map((value) => value.trim())
                      .where((value) => value.isNotEmpty)
                      .toList(growable: false),
                ));
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    description.dispose();
    aliases.dispose();
    return result;
  }

  void _showFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось выполнить операцию')),
    );
  }

  Future<T> _safe<T>(String operation, Future<T> Function() call) async {
    final result = await studySafeCallV1(operation, call);
    return result.fold((error) => throw error, (value) => value);
  }
}

final class _EmptyConceptInspector extends StatelessWidget {
  const _EmptyConceptInspector();

  @override
  Widget build(BuildContext context) {
    return StudySurface(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.ads_click_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              'Выберите понятие',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Здесь появятся описание и связи.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

final class _ConceptDetails extends StatelessWidget {
  final ConceptV1 concept;
  final List<ConceptRelationV1> relation;
  final Map<String, ConceptV1> conceptById;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onAddRelation;
  final ValueChanged<ConceptRelationV1> onDeleteRelation;

  const _ConceptDetails({
    required this.concept,
    required this.relation,
    required this.conceptById,
    required this.onEdit,
    required this.onArchive,
    required this.onAddRelation,
    required this.onDeleteRelation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StudySurface(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    concept.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Добавить связь',
                  onPressed: onAddRelation,
                  icon: const Icon(Icons.add_link),
                ),
                IconButton(
                  tooltip: 'Изменить понятие',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: concept.isArchived
                      ? 'Восстановить понятие'
                      : 'Архивировать понятие',
                  onPressed: onArchive,
                  icon: Icon(
                    concept.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Привязки к блокам: ${concept.blockIds.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            if (concept.aliases.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('Псевдонимы', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final alias in concept.aliases) Chip(label: Text(alias)),
                ],
              ),
            ],
            if (concept.descriptionMarkdown.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('Описание', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              MarkdownBody(data: concept.descriptionMarkdown),
            ],
            if (relation.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Text('Связи', style: theme.textTheme.labelLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in relation)
                    InputChip(
                      label: Text(
                        '${_relationLabel(item.type)}: '
                        '${_otherTitle(item, concept.id, conceptById)}',
                      ),
                      onDeleted: () => onDeleteRelation(item),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _otherTitle(
  ConceptRelationV1 relation,
  String selectedId,
  Map<String, ConceptV1> conceptById,
) {
  final otherId = relation.sourceConceptId == selectedId
      ? relation.targetConceptId
      : relation.sourceConceptId;
  return conceptById[otherId]?.title ?? 'Неизвестное понятие';
}

String _relationLabel(ConceptRelationTypeV1 value) => switch (value) {
  ConceptRelationTypeV1.relatedTo => 'Связано с',
  ConceptRelationTypeV1.partOf => 'Часть',
  ConceptRelationTypeV1.prerequisiteFor => 'Предпосылка для',
  ConceptRelationTypeV1.contrastsWith => 'Противопоставлено',
  ConceptRelationTypeV1.appliesTo => 'Применяется к',
};
