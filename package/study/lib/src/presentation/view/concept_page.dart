import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:graphview/GraphView.dart';
import 'package:study/src/application/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';
import 'package:study/src/presentation/_barrel.dart';
import 'package:uuid/uuid.dart';

final class ConceptPageV1 extends StatefulWidget {
  final StudyV1 study;
  final ConceptControllerV1 controller;

  const ConceptPageV1({
    required this.study,
    required this.controller,
    super.key,
  });

  @override
  State<ConceptPageV1> createState() => _ConceptPageV1State();
}

final class _ConceptPageV1State extends State<ConceptPageV1> {
  final _search = TextEditingController();
  String? _renderGraphTopology;
  String? _graphPresentation;
  Graph? _renderGraph;
  Map<String, ConceptV1> _conceptById = {};
  Widget? _renderedGraphContent;
  var _isActive = true;

  @override
  void initState() {
    super.initState();
    widget.controller.add(ConceptStartedV1(widget.study));
  }

  @override
  void didUpdateWidget(ConceptPageV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.study.id != widget.study.id) {
      _search.clear();
      _renderGraphTopology = null;
      _graphPresentation = null;
      _renderGraph = null;
      _conceptById = {};
      _renderedGraphContent = null;
      widget.controller.add(ConceptStartedV1(widget.study));
    }
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
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.controller,
      child:
          BlocEffectConsumer<
            ConceptControllerV1,
            ConceptStateV1,
            ConceptEffectV1
          >(
            bloc: widget.controller,
            listener: (_, effect) {
              if (effect is ConceptFailureEffectV1) _showFailure();
            },
            builder: _build,
          ),
    );
  }

  Widget _build(BuildContext context, ConceptStateV1 state) {
    final currentStudy = state.study?.id == widget.study.id;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: _search,
                  hintText: 'Поиск понятия или псевдонима',
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (value) =>
                      widget.controller.add(ConceptSearchChangedV1(value)),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Понятие'),
              ),
            ],
          ),
          if (currentStudy && state.searchResult.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.searchResult.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final concept = state.searchResult[index];
                  return ActionChip(
                    label: Text(
                      concept.isArchived
                          ? '${concept.title} (архив)'
                          : concept.title,
                    ),
                    onPressed: concept.isArchived
                        ? () => _toggleArchive(concept)
                        : () => _select(concept),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(child: _body(state)),
        ],
      ),
    );
  }

  Widget _body(ConceptStateV1 state) {
    if (state.study?.id != widget.study.id) {
      return const StudySkeleton(compact: true);
    }
    if (state.loadState == ConceptLoadStateV1.loading ||
        state.loadState == ConceptLoadStateV1.initial) {
      return const StudySkeleton(compact: true);
    }
    final graph = state.graph;
    if (graph == null) {
      return StudyStateView(
        icon: Icons.cloud_off_outlined,
        title: 'Граф не загрузился',
        description: 'Проверьте локальный сервис и повторите попытку.',
        actionLabel: 'Повторить',
        actionIcon: Icons.refresh_rounded,
        onAction: () => widget.controller.add(ConceptStartedV1(widget.study)),
      );
    }
    if (graph.concept.any((concept) => concept.studyId != widget.study.id) ||
        graph.relation.any((relation) => relation.studyId != widget.study.id)) {
      return const StudySkeleton(compact: true);
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
    final view = _graphView(graph);
    final selected =
        state.selectedConcept ??
        (graph.concept.length == 1 ? graph.concept.single : null);
    final inspector = KeyedSubtree(
      key: const ValueKey('concept-inspector'),
      child: selected == null
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
            ),
    );
    final graphContent = graph.concept.length == 1
        ? InteractiveViewer(
            minScale: 0.1,
            maxScale: 3,
            child: Center(
              child: _conceptChip(
                concept: graph.concept.single,
                selectedConceptId: selected?.id,
              ),
            ),
          )
        : _multiNodeGraphContent(graph, view, selected?.id);
    final canvas = StudySurface(
      key: const ValueKey('concept-graph-canvas'),
      padding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Text(
                  'Карта знаний',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  'Понятий: ${graph.concept.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(),
          if (graph.isTruncated)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              color: studyWarningColor.withValues(alpha: 0.1),
              child: const Text('Показан выбранный узел и два уровня соседей.'),
            ),
          Expanded(child: graphContent),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Column(
            children: [
              Expanded(flex: 3, child: canvas),
              const SizedBox(height: 14),
              Expanded(flex: 2, child: inspector),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: canvas),
            const SizedBox(width: 16),
            SizedBox(width: 320, child: inspector),
          ],
        );
      },
    );
  }

  (Graph, Map<String, ConceptV1>) _buildGraph(ConceptGraphV1 value) {
    final graph = Graph();
    final concepts = {for (final item in value.concept) item.id: item};
    final id = concepts.keys.toList()..sort();
    final nodes = {
      for (var index = 0; index < id.length; index++)
        id[index]: Node.Id(id[index])
          ..position = Offset((index % 5) * 180.0, (index ~/ 5) * 96.0),
    };
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

  (Graph, Map<String, ConceptV1>) _graphView(ConceptGraphV1 value) {
    final topology = _topologyKey(value);
    if (_renderGraphTopology != topology || _renderGraph == null) {
      final view = _buildGraph(value);
      _renderGraphTopology = topology;
      _renderGraph = view.$1;
      _conceptById = view.$2;
    } else {
      _conceptById = {for (final concept in value.concept) concept.id: concept};
    }
    return (_renderGraph!, _conceptById);
  }

  Widget _multiNodeGraphContent(
    ConceptGraphV1 value,
    (Graph, Map<String, ConceptV1>) view,
    String? selectedConceptId,
  ) {
    final topology = _topologyKey(value);
    final conceptPresentation =
        value.concept
            .map(
              (concept) =>
                  '${concept.id}:${concept.title}:${concept.isArchived}',
            )
            .toList()
          ..sort();
    final presentation = [
      topology,
      selectedConceptId,
      ...conceptPresentation,
    ].join('|');
    // Reusing the same widget avoids losing graph children during unrelated
    // parent rebuilds. Visible node changes still recreate the graph safely.
    if (_renderedGraphContent == null || _graphPresentation != presentation) {
      _graphPresentation = presentation;
      final algorithm = view.$1.edges.isEmpty
          ? CircleLayoutAlgorithm(
              CircleLayoutConfiguration(reduceEdgeCrossing: false),
              null,
            )
          : FruchtermanReingoldAlgorithm(
              FruchtermanReingoldConfiguration(
                iterations: value.concept.length > 100 ? 40 : 250,
                repulsionRate: 0.3,
                attractionRate: 0.04,
                repulsionPercentage: 0.5,
                shuffleNodes: false,
              ),
            );
      _renderedGraphContent = InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(120),
        minScale: 0.1,
        maxScale: 3,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            label: 'Связей: ${view.$1.edges.length}',
            child: GraphView(
              key: ValueKey(presentation),
              graph: view.$1,
              algorithm: algorithm,
              animated: false,
              paint: Paint()
                ..color = Theme.of(context).colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.55)
                ..strokeWidth = 1.5,
              builder: (node) {
                final id = node.key?.value as String;
                return _conceptChip(
                  concept: view.$2[id]!,
                  selectedConceptId: selectedConceptId,
                );
              },
            ),
          ),
        ),
      );
    }
    return KeyedSubtree(key: ValueKey(topology), child: _renderedGraphContent!);
  }

  Widget _conceptChip({
    required ConceptV1 concept,
    required String? selectedConceptId,
  }) {
    final selected = concept.id == selectedConceptId;
    return Material(
      color: Colors.transparent,
      child: InputChip(
        key: ValueKey(concept.id),
        selected: selected,
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            concept.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onPressed: () => _select(concept),
        onDeleted: selected ? () => _edit(concept) : null,
        deleteIcon: const Icon(Icons.edit_outlined, size: 18),
      ),
    );
  }

  String _topologyKey(ConceptGraphV1 graph) {
    final concept = graph.concept.map((value) => value.id).toList()..sort();
    final relation =
        graph.relation
            .map(
              (value) =>
                  '${value.sourceConceptId}:${value.targetConceptId}:'
                  '${value.type.name}',
            )
            .toList()
          ..sort();
    return '${concept.join('|')}#${relation.join('|')}';
  }

  void _select(ConceptV1 concept) =>
      widget.controller.add(ConceptSelectedV1(concept));

  Future<void> _create() async {
    final value = await _showEditor();
    if (!mounted || !_isActive || value == null) {
      return;
    }
    final id = const Uuid().v4();
    widget.controller.add(
      ConceptCreatedV1(
        ConceptV1(
          id: id,
          studyId: widget.study.id,
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
  }

  Future<void> _edit(ConceptV1 concept) async {
    final value = await _showEditor(concept: concept);
    if (!mounted || !_isActive || value == null) {
      return;
    }
    widget.controller.add(
      ConceptUpdatedV1(
        concept.copyWith(
          title: value.$1,
          descriptionMarkdown: value.$2,
          aliases: value.$3,
        ),
      ),
    );
  }

  Future<void> _toggleArchive(ConceptV1 concept) async {
    widget.controller.add(ConceptArchiveChangedV1(concept));
  }

  Future<void> _addRelation(ConceptV1 source) async {
    if (!mounted || !_isActive) return;
    final graph = widget.controller.state.graph;
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
    final relation = await showStudyDialogV1<ConceptRelationV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => StudySideSheet(
          title: const Text('Новая связь'),
          child: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: targetId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Понятие'),
                  items: [
                    for (final concept in target)
                      DropdownMenuItem(
                        value: concept.id,
                        child: Text(
                          concept.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                  studyId: widget.study.id,
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
    if (!mounted || !_isActive || relation == null) {
      return;
    }
    widget.controller.add(ConceptRelationAddedV1(relation));
  }

  void _deleteRelation(ConceptRelationV1 relation) =>
      widget.controller.add(ConceptRelationDeletedV1(relation));

  Future<(String, String, List<String>)?> _showEditor({
    ConceptV1? concept,
  }) async {
    if (!mounted || !_isActive) return null;
    final title = TextEditingController(text: concept?.title);
    final description = TextEditingController(
      text: concept?.descriptionMarkdown,
    );
    final aliases = TextEditingController(text: concept?.aliases.join(', '));
    String? error;
    final result = await showStudyDialogV1<(String, String, List<String>)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => StudySideSheet(
          title: Text(concept == null ? 'Новое понятие' : 'Понятие'),
          child: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
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
    if (!mounted || !_isActive) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Не удалось выполнить операцию')),
    );
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
                borderRadius: BorderRadius.circular(8),
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
