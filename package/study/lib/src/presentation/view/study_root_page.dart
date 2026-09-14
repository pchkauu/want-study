import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/src/application/bloc/catalog_bloc.dart';
import 'package:study/src/application/slug.dart';
import 'package:study/src/config/config.dart';
import 'package:study/src/dependency/repository_picker.dart';
import 'package:study/src/domain/model/learning_source.dart';
import 'package:study/src/domain/model/lesson.dart';
import 'package:study/src/domain/model/material_tree.dart';
import 'package:study/src/domain/model/section.dart';
import 'package:study/src/domain/model/study.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/model/study_progress.dart';
import 'package:study/src/domain/repository/knowledge_repository.dart';
import 'package:study/src/domain/repository/lesson_content_repository.dart';
import 'package:study/src/domain/repository/study_publication_repository.dart';
import 'package:study/src/domain/repository/study_repository.dart';
import 'package:study/src/presentation/view/concept_page.dart';
import 'package:study/src/presentation/view/lesson_editor_page.dart';
import 'package:study/src/presentation/view/publication_page.dart';
import 'package:uuid/uuid.dart';

final class StudyRootPageV1 extends StatefulWidget {
  final Config config;
  final StudyRepositoryV1 studyRepository;
  final LessonContentRepositoryV1 lessonContentRepository;
  final KnowledgeRepositoryV1 knowledgeRepository;
  final StudyPublicationRepositoryV1 publicationRepository;
  final RepositoryPickerV1 repositoryPicker;

  const StudyRootPageV1({
    required this.config,
    required this.studyRepository,
    required this.lessonContentRepository,
    required this.knowledgeRepository,
    required this.publicationRepository,
    required this.repositoryPicker,
    super.key,
  });

  @override
  State<StudyRootPageV1> createState() => _StudyRootPageV1State();
}

final class _StudyRootPageV1State extends State<StudyRootPageV1> {
  late final CatalogBlocV1 _catalogBloc;
  var _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _catalogBloc = CatalogBlocV1(widget.studyRepository)
      ..add(const CatalogStartedV1());
  }

  @override
  void dispose() {
    _catalogBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _catalogBloc,
      child: BlocEffectConsumer<CatalogBlocV1, CatalogStateV1, CatalogEffectV1>(
        listener: _onEffect,
        builder: (context, state) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: MediaQuery.sizeOf(context).width >= 1180,
                  selectedIndex: _selectedPage,
                  onDestinationSelected: (value) {
                    setState(() => _selectedPage = value);
                  },
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Icon(
                      Icons.auto_stories_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.space_dashboard_outlined),
                      selectedIcon: Icon(Icons.space_dashboard),
                      label: Text('Обзор'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: Text('Материал'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.hub_outlined),
                      selectedIcon: Icon(Icons.hub),
                      label: Text('Понятия'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.publish_outlined),
                      selectedIcon: Icon(Icons.publish),
                      label: Text('Публикация'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CatalogStateV1 state) {
    if (state.loadState == CatalogLoadStateV1.loading && state.study.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.study.isEmpty) {
      return _EmptyStudyView(onCreate: () => _createStudy(context));
    }
    final selectedStudy = state.study
        .where((study) => study.id == state.selectedStudyId)
        .firstOrNull;
    return Column(
      children: [
        _StudyHeader(
          study: state.study,
          selectedStudyId: state.selectedStudyId,
          onSelected: (id) => _catalogBloc.add(CatalogStudySelectedV1(id)),
          onCreate: () => _createStudy(context),
          onEdit: selectedStudy == null
              ? null
              : () => _createStudy(context, selectedStudy),
          onArchive: selectedStudy == null
              ? null
              : () => _catalogBloc.add(
                  CatalogItemArchiveChangedV1(selectedStudy),
                ),
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (_selectedPage) {
            0 => _DashboardView(progress: state.progress),
            1 => _MaterialView(
              tree: state.tree,
              onCreateSource: selectedStudy == null
                  ? null
                  : () => _createSource(context, selectedStudy),
              onCreateSection: (source) =>
                  _createSection(context, selectedStudy!, source),
              onCreateLesson: (source, section) =>
                  _createLesson(context, selectedStudy!, source, section),
              onEditSource: (source) =>
                  _createSource(context, selectedStudy!, source),
              onEditSection: (source, section) =>
                  _createSection(context, selectedStudy!, source, section),
              onEditLesson: (source, lesson) => _createLesson(
                context,
                selectedStudy!,
                source,
                source.section
                    .where((section) => section.id == lesson.sectionId)
                    .firstOrNull,
                lesson,
              ),
              onOpenLesson: (lesson) => _openLesson(context, lesson),
              onArchiveItem: (item) =>
                  _catalogBloc.add(CatalogItemArchiveChangedV1(item)),
              onMoveItem: (item, offset) =>
                  _catalogBloc.add(CatalogItemMoveRequestedV1(item, offset)),
              onStatusChanged: (lesson, status) => _catalogBloc.add(
                CatalogLessonStatusChangedV1(lesson: lesson, status: status),
              ),
            ),
            2 =>
              selectedStudy == null
                  ? const SizedBox.shrink()
                  : ConceptPageV1(
                      studyId: selectedStudy.id,
                      repository: widget.knowledgeRepository,
                    ),
            _ =>
              selectedStudy == null
                  ? const SizedBox.shrink()
                  : PublicationPageV1(
                      study: selectedStudy,
                      repository: widget.publicationRepository,
                    ),
          },
        ),
      ],
    );
  }

  Future<void> _onEffect(BuildContext context, CatalogEffectV1 effect) async {
    switch (effect) {
      case CatalogFailureEffectV1():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось выполнить операцию')),
        );
      case ConfirmOpenHomeworkEffectV1():
        final lesson = _findLesson(effect.lessonId);
        if (lesson == null) {
          return;
        }
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Есть открытые задания'),
            content: const Text(
              'Отметить урок освоенным, несмотря на невыполненную домашнюю работу?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Отметить освоенным'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          _catalogBloc.add(
            CatalogLessonStatusChangedV1(
              lesson: lesson,
              status: LessonStatusV1.mastered,
              acknowledgeOpenHomework: true,
            ),
          );
        }
    }
  }

  LessonV1? _findLesson(String id) {
    for (final source
        in _catalogBloc.state.tree?.source ?? const <LearningSourceNodeV1>[]) {
      for (final lesson in source.lesson) {
        if (lesson.id == id) {
          return lesson;
        }
      }
    }
    return null;
  }

  Future<void> _createStudy(BuildContext context, [StudyV1? existing]) async {
    final title = TextEditingController(text: existing?.title);
    final goal = TextEditingController(text: existing?.goal);
    var repositoryPath = existing?.localRepositoryPath ?? '';
    final result = await showDialog<StudyV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Новое обучение' : 'Обучение'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  autofocus: true,
                  maxLength: 200,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                TextField(
                  controller: goal,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Цель'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        repositoryPath.isEmpty
                            ? 'Git-репозиторий не выбран'
                            : 'Git-репозиторий выбран',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final path = await widget.repositoryPicker
                            .pickRepository();
                        if (path != null) {
                          setDialogState(() => repositoryPath = path);
                        }
                      },
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Выбрать'),
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
              onPressed: title.text.trim().isEmpty
                  ? null
                  : () {
                      final id = const Uuid().v4();
                      Navigator.pop(
                        context,
                        existing?.copyWith(
                              title: title.text,
                              goal: goal.text,
                              localRepositoryPath: repositoryPath,
                            ) ??
                            StudyV1(
                              id: id,
                              title: title.text,
                              goal: goal.text,
                              localRepositoryPath: repositoryPath,
                            ),
                      );
                    },
              child: Text(existing == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    goal.dispose();
    if (result != null) {
      _catalogBloc.add(
        existing == null
            ? CatalogStudyCreatedV1(result)
            : CatalogItemUpdatedV1(result),
      );
    }
  }

  Future<void> _createSource(
    BuildContext context,
    StudyV1 study, [
    LearningSourceV1? existing,
  ]) async {
    final title = TextEditingController(text: existing?.title);
    final author = TextEditingController(text: existing?.author);
    final url = TextEditingController(text: existing?.url);
    var type = existing?.type ?? LearningSourceTypeV1.course;
    final result = await showDialog<LearningSourceV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Новый источник' : 'Источник'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  maxLength: 200,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                DropdownButtonFormField(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Тип'),
                  items: [
                    for (final value in LearningSourceTypeV1.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(_sourceTypeLabel(value)),
                      ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => type = value ?? type),
                ),
                TextField(
                  controller: author,
                  decoration: const InputDecoration(labelText: 'Автор'),
                ),
                TextField(
                  controller: url,
                  decoration: const InputDecoration(labelText: 'Ссылка'),
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
              onPressed: title.text.trim().isEmpty
                  ? null
                  : () {
                      final id = const Uuid().v4();
                      Navigator.pop(
                        context,
                        existing?.copyWith(
                              type: type,
                              title: title.text,
                              author: author.text,
                              url: url.text,
                            ) ??
                            LearningSourceV1(
                              id: id,
                              studyId: study.id,
                              type: type,
                              title: title.text,
                              author: author.text,
                              url: url.text,
                              exportSlug: createExportSlugV1(
                                title.text,
                                fallback: 'source-${id.substring(0, 8)}',
                              ),
                              position:
                                  _catalogBloc.state.tree?.source.length ?? 0,
                            ),
                      );
                    },
              child: Text(existing == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    author.dispose();
    url.dispose();
    if (result != null) {
      _catalogBloc.add(
        existing == null
            ? CatalogSourceCreatedV1(result)
            : CatalogItemUpdatedV1(result),
      );
    }
  }

  Future<void> _createSection(
    BuildContext context,
    StudyV1 study,
    LearningSourceNodeV1 node, [
    SectionV1? existing,
  ]) async {
    final title = TextEditingController(text: existing?.title);
    final result = await showDialog<SectionV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Новый раздел' : 'Раздел'),
          content: TextField(
            controller: title,
            autofocus: true,
            maxLength: 200,
            onChanged: (_) => setDialogState(() {}),
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: title.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                      context,
                      existing?.copyWith(title: title.text) ??
                          SectionV1(
                            id: const Uuid().v4(),
                            studyId: study.id,
                            sourceId: node.source.id,
                            title: title.text,
                            position: node.section.length,
                          ),
                    ),
              child: Text(existing == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    if (result != null) {
      _catalogBloc.add(
        existing == null
            ? CatalogSectionCreatedV1(result)
            : CatalogItemUpdatedV1(result),
      );
    }
  }

  Future<void> _createLesson(
    BuildContext context,
    StudyV1 study,
    LearningSourceNodeV1 node,
    SectionV1? section, [
    LessonV1? existing,
  ]) async {
    final title = TextEditingController(text: existing?.title);
    final sourcePosition = TextEditingController(
      text: existing?.sourcePosition,
    );
    final url = TextEditingController(text: existing?.url);
    final result = await showDialog<LessonV1>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Новый урок' : 'Урок'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  autofocus: true,
                  maxLength: 200,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                TextField(
                  controller: sourcePosition,
                  decoration: const InputDecoration(
                    labelText: 'Позиция в источнике',
                  ),
                ),
                TextField(
                  controller: url,
                  decoration: const InputDecoration(labelText: 'Ссылка'),
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
              onPressed: title.text.trim().isEmpty
                  ? null
                  : () {
                      final id = const Uuid().v4();
                      Navigator.pop(
                        context,
                        existing?.copyWith(
                              sectionId: () => section?.id,
                              title: title.text,
                              url: url.text,
                              sourcePosition: sourcePosition.text,
                            ) ??
                            LessonV1(
                              id: id,
                              studyId: study.id,
                              sourceId: node.source.id,
                              sectionId: section?.id,
                              title: title.text,
                              url: url.text,
                              sourcePosition: sourcePosition.text,
                              exportSlug: createExportSlugV1(
                                sourcePosition.text.isEmpty
                                    ? title.text
                                    : '${sourcePosition.text}-${title.text}',
                                fallback: 'lesson-${id.substring(0, 8)}',
                              ),
                              position: node.lesson.length,
                            ),
                      );
                    },
              child: Text(existing == null ? 'Создать' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    sourcePosition.dispose();
    url.dispose();
    if (result != null) {
      _catalogBloc.add(
        existing == null
            ? CatalogLessonCreatedV1(result)
            : CatalogItemUpdatedV1(result),
      );
    }
  }

  Future<void> _openLesson(BuildContext context, LessonV1 lesson) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LessonEditorPageV1(
          lesson: lesson,
          repository: widget.lessonContentRepository,
          knowledgeRepository: widget.knowledgeRepository,
          autosaveDelay: widget.config.autosaveDelay,
        ),
      ),
    );
  }
}

final class _StudyHeader extends StatelessWidget {
  final List<StudyV1> study;
  final String? selectedStudyId;
  final ValueChanged<String> onSelected;
  final VoidCallback onCreate;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  const _StudyHeader({
    required this.study,
    required this.selectedStudyId,
    required this.onSelected,
    required this.onCreate,
    required this.onEdit,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final selected = study
        .where((item) => item.id == selectedStudyId)
        .firstOrNull;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStudyId,
                isExpanded: true,
                items: [
                  for (final item in study)
                    DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        item.isArchived ? '${item.title} · архив' : item.title,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onSelected(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: 'Изменить обучение',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: selected?.isArchived ?? false
                ? 'Восстановить обучение'
                : 'Архивировать обучение',
            onPressed: onArchive,
            icon: Icon(
              selected?.isArchived ?? false
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
          ),
          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Новое обучение'),
          ),
        ],
      ),
    );
  }
}

final class _EmptyStudyView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyStudyView({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Начните новое обучение',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте курс или книгу, разбейте материал на уроки и ведите конспект в одном месте.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Создать обучение'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _DashboardView extends StatelessWidget {
  final StudyProgressV1? progress;

  const _DashboardView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final value = progress;
    if (value == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Text('Прогресс', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _ProgressCard(
              title: 'Материал',
              icon: Icons.menu_book,
              progress: value.material,
            ),
            _ProgressCard(
              title: 'Домашняя работа',
              icon: Icons.task_alt,
              progress: value.homework,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Статусы уроков', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: [
            for (final entry in value.lessonStatusCount.entries)
              Chip(
                label: Text('${_statusKeyLabel(entry.key)}: ${entry.value}'),
              ),
          ],
        ),
      ],
    );
  }
}

final class _ProgressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ProgressIndicatorV1 progress;

  const _ProgressCard({
    required this.title,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 12),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: progress.fraction),
              const SizedBox(height: 12),
              Text('${progress.completed} из ${progress.total}'),
            ],
          ),
        ),
      ),
    );
  }
}

final class _MaterialView extends StatelessWidget {
  final MaterialTreeV1? tree;
  final VoidCallback? onCreateSource;
  final ValueChanged<LearningSourceNodeV1> onCreateSection;
  final void Function(LearningSourceNodeV1, SectionV1?) onCreateLesson;
  final ValueChanged<LearningSourceV1> onEditSource;
  final void Function(LearningSourceNodeV1, SectionV1) onEditSection;
  final void Function(LearningSourceNodeV1, LessonV1) onEditLesson;
  final ValueChanged<LessonV1> onOpenLesson;
  final ValueChanged<Object> onArchiveItem;
  final void Function(Object, int) onMoveItem;
  final void Function(LessonV1, LessonStatusV1) onStatusChanged;

  const _MaterialView({
    required this.tree,
    required this.onCreateSource,
    required this.onCreateSection,
    required this.onCreateLesson,
    required this.onEditSource,
    required this.onEditSection,
    required this.onEditLesson,
    required this.onOpenLesson,
    required this.onArchiveItem,
    required this.onMoveItem,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = tree;
    if (value == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Материал',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            FilledButton.icon(
              onPressed: onCreateSource,
              icon: const Icon(Icons.add),
              label: const Text('Источник'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (value.source.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Добавьте первый источник: курс, книгу или статью.'),
            ),
          ),
        for (final node in value.source)
          _SourceCard(
            node: node,
            onCreateSection: () => onCreateSection(node),
            onCreateLesson: (section) => onCreateLesson(node, section),
            onEdit: () => onEditSource(node.source),
            onEditSection: (section) => onEditSection(node, section),
            onEditLesson: (lesson) => onEditLesson(node, lesson),
            onOpenLesson: onOpenLesson,
            onArchiveItem: onArchiveItem,
            onMoveItem: onMoveItem,
            onStatusChanged: onStatusChanged,
          ),
      ],
    );
  }
}

final class _SourceCard extends StatelessWidget {
  final LearningSourceNodeV1 node;
  final VoidCallback onCreateSection;
  final ValueChanged<SectionV1?> onCreateLesson;
  final VoidCallback onEdit;
  final ValueChanged<SectionV1> onEditSection;
  final ValueChanged<LessonV1> onEditLesson;
  final ValueChanged<LessonV1> onOpenLesson;
  final ValueChanged<Object> onArchiveItem;
  final void Function(Object, int) onMoveItem;
  final void Function(LessonV1, LessonStatusV1) onStatusChanged;

  const _SourceCard({
    required this.node,
    required this.onCreateSection,
    required this.onCreateLesson,
    required this.onEdit,
    required this.onEditSection,
    required this.onEditLesson,
    required this.onOpenLesson,
    required this.onArchiveItem,
    required this.onMoveItem,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final withoutSection = node.lesson
        .where((lesson) => lesson.sectionId == null)
        .toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(node.source.title),
        subtitle: Text(
          node.source.isArchived
              ? '${_sourceTypeLabel(node.source.type)} · архив'
              : _sourceTypeLabel(node.source.type),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Выше',
              onPressed: () => onMoveItem(node.source, -1),
              icon: const Icon(Icons.arrow_upward),
            ),
            IconButton(
              tooltip: 'Ниже',
              onPressed: () => onMoveItem(node.source, 1),
              icon: const Icon(Icons.arrow_downward),
            ),
            IconButton(
              tooltip: 'Изменить источник',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: node.source.isArchived ? 'Восстановить' : 'Архивировать',
              onPressed: () => onArchiveItem(node.source),
              icon: Icon(
                node.source.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Добавить раздел',
              onPressed: node.source.isArchived ? null : onCreateSection,
              icon: const Icon(Icons.create_new_folder_outlined),
            ),
            IconButton(
              tooltip: 'Добавить урок без раздела',
              onPressed: node.source.isArchived
                  ? null
                  : () => onCreateLesson(null),
              icon: const Icon(Icons.note_add_outlined),
            ),
          ],
        ),
        children: [
          for (final section in node.section)
            _SectionTile(
              section: section,
              lesson: node.lesson
                  .where((lesson) => lesson.sectionId == section.id)
                  .toList(),
              onCreateLesson: () => onCreateLesson(section),
              onEdit: () => onEditSection(section),
              onOpenLesson: onOpenLesson,
              onEditLesson: onEditLesson,
              onArchiveItem: onArchiveItem,
              onMoveItem: onMoveItem,
              onStatusChanged: onStatusChanged,
            ),
          for (final lesson in withoutSection)
            _LessonTile(
              lesson: lesson,
              onOpen: () => onOpenLesson(lesson),
              onEdit: () => onEditLesson(lesson),
              onArchive: () => onArchiveItem(lesson),
              onMove: (offset) => onMoveItem(lesson, offset),
              onStatusChanged: (status) => onStatusChanged(lesson, status),
            ),
        ],
      ),
    );
  }
}

final class _SectionTile extends StatelessWidget {
  final SectionV1 section;
  final List<LessonV1> lesson;
  final VoidCallback onCreateLesson;
  final VoidCallback onEdit;
  final ValueChanged<LessonV1> onOpenLesson;
  final ValueChanged<LessonV1> onEditLesson;
  final ValueChanged<Object> onArchiveItem;
  final void Function(Object, int) onMoveItem;
  final void Function(LessonV1, LessonStatusV1) onStatusChanged;

  const _SectionTile({
    required this.section,
    required this.lesson,
    required this.onCreateLesson,
    required this.onEdit,
    required this.onOpenLesson,
    required this.onEditLesson,
    required this.onArchiveItem,
    required this.onMoveItem,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.only(left: 32, right: 16),
      title: Text(
        section.isArchived ? '${section.title} · архив' : section.title,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Выше',
            onPressed: () => onMoveItem(section, -1),
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            tooltip: 'Ниже',
            onPressed: () => onMoveItem(section, 1),
            icon: const Icon(Icons.arrow_downward),
          ),
          IconButton(
            tooltip: 'Изменить раздел',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: section.isArchived ? 'Восстановить' : 'Архивировать',
            onPressed: () => onArchiveItem(section),
            icon: Icon(
              section.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Добавить урок',
            onPressed: section.isArchived ? null : onCreateLesson,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      children: [
        for (final item in lesson)
          _LessonTile(
            lesson: item,
            onOpen: () => onOpenLesson(item),
            onEdit: () => onEditLesson(item),
            onArchive: () => onArchiveItem(item),
            onMove: (offset) => onMoveItem(item, offset),
            onStatusChanged: (status) => onStatusChanged(item, status),
          ),
      ],
    );
  }
}

final class _LessonTile extends StatelessWidget {
  final LessonV1 lesson;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final ValueChanged<int> onMove;
  final ValueChanged<LessonStatusV1> onStatusChanged;

  const _LessonTile({
    required this.lesson,
    required this.onOpen,
    required this.onEdit,
    required this.onArchive,
    required this.onMove,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 48, right: 20),
      onTap: onOpen,
      leading: const Icon(Icons.description_outlined),
      title: Text(
        lesson.sourcePosition.isEmpty
            ? lesson.title
            : '${lesson.sourcePosition} — ${lesson.title}',
      ),
      subtitle: lesson.isArchived ? const Text('Архив') : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Выше',
            onPressed: () => onMove(-1),
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            tooltip: 'Ниже',
            onPressed: () => onMove(1),
            icon: const Icon(Icons.arrow_downward),
          ),
          IconButton(
            tooltip: 'Изменить урок',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: lesson.isArchived ? 'Восстановить' : 'Архивировать',
            onPressed: onArchive,
            icon: Icon(
              lesson.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
          ),
          DropdownButton<LessonStatusV1>(
            value: lesson.status,
            items: [
              for (final status in LessonStatusV1.values)
                DropdownMenuItem(
                  value: status,
                  child: Text(_statusLabel(status)),
                ),
            ],
            onChanged: lesson.isArchived
                ? null
                : (value) {
                    if (value != null) {
                      onStatusChanged(value);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

String _sourceTypeLabel(LearningSourceTypeV1 value) => switch (value) {
  LearningSourceTypeV1.course => 'Курс',
  LearningSourceTypeV1.book => 'Книга',
  LearningSourceTypeV1.article => 'Статья',
  LearningSourceTypeV1.video => 'Видео',
  LearningSourceTypeV1.other => 'Другое',
};

String _statusLabel(LessonStatusV1 value) => switch (value) {
  LessonStatusV1.planned => 'Запланирован',
  LessonStatusV1.studying => 'Изучается',
  LessonStatusV1.homework => 'Домашняя работа',
  LessonStatusV1.mastered => 'Освоен',
};

String _statusKeyLabel(String value) => switch (value) {
  'planned' => 'Запланирован',
  'studying' => 'Изучается',
  'homework' => 'Домашняя работа',
  'mastered' => 'Освоен',
  _ => value,
};
