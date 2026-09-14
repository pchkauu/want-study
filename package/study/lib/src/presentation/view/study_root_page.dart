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
import 'package:study/src/presentation/widget/study_ui.dart';
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
          return LayoutBuilder(
            builder: (context, constraints) {
              final extended = constraints.maxWidth >= 1200;
              final disableAnimations = MediaQuery.disableAnimationsOf(context);
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      extended: extended,
                      minWidth: 88,
                      minExtendedWidth: 244,
                      groupAlignment: -0.58,
                      selectedIndex: _selectedPage,
                      onDestinationSelected: (value) {
                        setState(() => _selectedPage = value);
                      },
                      leading: _NavigationBrand(extended: extended),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.space_dashboard_outlined),
                          selectedIcon: Icon(Icons.space_dashboard_rounded),
                          label: Text('Обзор'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.menu_book_outlined),
                          selectedIcon: Icon(Icons.menu_book_rounded),
                          label: Text('Материал'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.hub_outlined),
                          selectedIcon: Icon(Icons.hub_rounded),
                          label: Text('Понятия'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.publish_outlined),
                          selectedIcon: Icon(Icons.publish_rounded),
                          label: Text('Публикация'),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey(_selectedPage),
                          child: _buildContent(context, state),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CatalogStateV1 state) {
    if (state.loadState == CatalogLoadStateV1.loading && state.study.isEmpty) {
      return const StudySkeleton();
    }
    if (state.loadState == CatalogLoadStateV1.failed && state.study.isEmpty) {
      return StudyStateView(
        icon: Icons.cloud_off_outlined,
        title: 'Не удалось загрузить обучение',
        description: 'Проверьте локальный сервис и повторите попытку.',
        actionLabel: 'Повторить',
        actionIcon: Icons.refresh_rounded,
        onAction: () => _catalogBloc.add(const CatalogStartedV1()),
      );
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

final class _NavigationBrand extends StatelessWidget {
  final bool extended;

  const _NavigationBrand({required this.extended});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: extended ? 220 : 64,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 30),
        child: Row(
          mainAxisAlignment: extended
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFFF2F4F8),
                size: 23,
              ),
            ),
            if (extended) ...[
              const SizedBox(width: 13),
              Flexible(
                child: Text(
                  'Want Study',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ],
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
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStudyId,
                    isDense: true,
                    borderRadius: BorderRadius.circular(14),
                    style: theme.textTheme.titleLarge,
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    items: [
                      for (final item in study)
                        DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            item.isArchived
                                ? '${item.title} (архив)'
                                : item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                if (selected?.goal.isNotEmpty ?? false) ...[
                  const SizedBox(height: 5),
                  Text(
                    selected!.goal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 18),
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
          const SizedBox(width: 8),
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
  Widget build(BuildContext context) => StudyStateView(
    icon: Icons.auto_stories_outlined,
    title: 'Начните новое обучение',
    description: 'Добавьте курс или книгу, разбейте материал на уроки и ведите конспект в одном месте.',
    actionLabel: 'Создать обучение',
    onAction: onCreate,
  );
}

final class _DashboardView extends StatelessWidget {
  final StudyProgressV1? progress;

  const _DashboardView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final value = progress;
    if (value == null) {
      return const StudySkeleton();
    }
    return LayoutBuilder(
      builder: (context, _) {
        final compact = MediaQuery.sizeOf(context).width < 960;
        final panels = [
          _ProgressPanel(
            title: 'Материал',
            description: 'Освоенные уроки',
            icon: Icons.menu_book_rounded,
            progress: value.material,
            primary: true,
          ),
          _ProgressPanel(
            title: 'Домашняя работа',
            description: 'Выполненные задания',
            icon: Icons.task_alt_rounded,
            progress: value.homework,
          ),
        ];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StudySectionHeader(
                    title: 'Прогресс',
                    description:
                        'Материал и домашняя работа считаются независимо.',
                  ),
                  const SizedBox(height: 24),
                  if (compact)
                    Column(
                      children: [
                        panels.first,
                        const SizedBox(height: 16),
                        panels.last,
                      ],
                    )
                  else
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 2, child: panels.first),
                          const SizedBox(width: 18),
                          Expanded(child: panels.last),
                        ],
                      ),
                    ),
                  const SizedBox(height: 30),
                  Text(
                    'Статусы уроков',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  _LessonStatusGrid(count: value.lessonStatusCount),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _ProgressPanel extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ProgressIndicatorV1 progress;
  final bool primary;

  const _ProgressPanel({
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = primary ? const Color(0xFFF2F4F8) : scheme.onSurface;
    final muted = primary ? const Color(0xFFCFD5FF) : scheme.onSurfaceVariant;
    final fraction = progress.fraction.clamp(0.0, 1.0);
    final percent = (fraction * 100).round();
    return StudySurface(
      color: primary ? scheme.primary : scheme.surface,
      borderColor: primary ? scheme.primary : scheme.outlineVariant,
      radius: 24,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: foreground.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: foreground, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            '$percent%',
            style: theme.textTheme.displaySmall?.copyWith(
              color: foreground,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            borderRadius: BorderRadius.circular(999),
            color: primary ? foreground : scheme.primary,
            backgroundColor: primary
                ? foreground.withValues(alpha: 0.18)
                : scheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 12),
          Text(
            '${progress.completed} из ${progress.total}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

final class _LessonStatusGrid extends StatelessWidget {
  final Map<String, int> count;

  const _LessonStatusGrid({required this.count});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final status in LessonStatusV1.values)
              SizedBox(
                width: width,
                child: _LessonStatusMetric(
                  status: status,
                  count: count[_statusKey(status)] ?? 0,
                ),
              ),
          ],
        );
      },
    );
  }
}

final class _LessonStatusMetric extends StatelessWidget {
  final LessonStatusV1 status;
  final int count;

  const _LessonStatusMetric({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = lessonStatusColor(context, status);
    return StudySurface(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lessonStatusLabel(status),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 3),
                Text(
                  '$count',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _MaterialView extends StatefulWidget {
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
  State<_MaterialView> createState() => _MaterialViewState();
}

final class _MaterialViewState extends State<_MaterialView> {
  String? _selectedSourceId;
  String? _selectedSectionId;

  @override
  void didUpdateWidget(_MaterialView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tree = widget.tree;
    if (tree == null || tree.source.isEmpty) {
      _selectedSourceId = null;
      _selectedSectionId = null;
      return;
    }
    final source = tree.source
        .where((node) => node.source.id == _selectedSourceId)
        .firstOrNull;
    if (source == null) {
      _selectedSourceId = tree.source.first.source.id;
      _selectedSectionId = null;
      return;
    }
    if (_selectedSectionId != null &&
        !source.section.any((section) => section.id == _selectedSectionId)) {
      _selectedSectionId = source.section.firstOrNull?.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.tree;
    if (value == null) {
      return const StudySkeleton(compact: true);
    }
    if (value.source.isEmpty) {
      return StudyStateView(
        icon: Icons.menu_book_outlined,
        title: 'Материал пока пуст',
        description: 'Добавьте курс, книгу, статью или другой источник.',
        actionLabel: 'Добавить источник',
        onAction: widget.onCreateSource,
      );
    }
    final selectedNode = value.source
        .where((node) => node.source.id == _selectedSourceId)
        .firstOrNull;
    final node = selectedNode ?? value.source.first;
    final section = node.section
        .where((item) => item.id == _selectedSectionId)
        .firstOrNull;
    return LayoutBuilder(
      builder: (context, _) {
        final compact = MediaQuery.sizeOf(context).width < 960;
        final sidebar = _MaterialSidebar(
          source: value.source,
          selectedSourceId: node.source.id,
          selectedSectionId: section?.id,
          onCreateSource: widget.onCreateSource,
          onSelectSource: (sourceId) {
            setState(() {
              _selectedSourceId = sourceId;
              _selectedSectionId = null;
            });
          },
          onSelectSection: (sourceId, sectionId) {
            setState(() {
              _selectedSourceId = sourceId;
              _selectedSectionId = sectionId;
            });
          },
          onSourceAction: _onSourceAction,
          onSectionAction: _onSectionAction,
        );
        final lessons = _LessonWorkspace(
          node: node,
          section: section,
          onCreateSection: () => widget.onCreateSection(node),
          onCreateLesson: () => widget.onCreateLesson(node, section),
          onOpenLesson: widget.onOpenLesson,
          onEditLesson: (lesson) => widget.onEditLesson(node, lesson),
          onArchiveLesson: (lesson) => widget.onArchiveItem(lesson),
          onMoveLesson: (lesson, offset) => widget.onMoveItem(lesson, offset),
          onStatusChanged: widget.onStatusChanged,
        );
        return Padding(
          padding: const EdgeInsets.all(24),
          child: compact
              ? Column(
                  children: [
                    SizedBox(height: 230, child: sidebar),
                    const SizedBox(height: 16),
                    Expanded(child: lessons),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(width: 320, child: sidebar),
                    const SizedBox(width: 18),
                    Expanded(child: lessons),
                  ],
                ),
        );
      },
    );
  }

  void _onSourceAction(LearningSourceNodeV1 node, _MaterialAction action) {
    switch (action) {
      case _MaterialAction.edit:
        widget.onEditSource(node.source);
      case _MaterialAction.moveUp:
        widget.onMoveItem(node.source, -1);
      case _MaterialAction.moveDown:
        widget.onMoveItem(node.source, 1);
      case _MaterialAction.archive:
        widget.onArchiveItem(node.source);
      case _MaterialAction.addSection:
        widget.onCreateSection(node);
      case _MaterialAction.addLesson:
        widget.onCreateLesson(node, null);
    }
  }

  void _onSectionAction(
    LearningSourceNodeV1 node,
    SectionV1 section,
    _MaterialAction action,
  ) {
    switch (action) {
      case _MaterialAction.edit:
        widget.onEditSection(node, section);
      case _MaterialAction.moveUp:
        widget.onMoveItem(section, -1);
      case _MaterialAction.moveDown:
        widget.onMoveItem(section, 1);
      case _MaterialAction.archive:
        widget.onArchiveItem(section);
      case _MaterialAction.addLesson:
        widget.onCreateLesson(node, section);
      case _MaterialAction.addSection:
        break;
    }
  }
}

enum _MaterialAction { edit, moveUp, moveDown, archive, addSection, addLesson }

final class _MaterialSidebar extends StatelessWidget {
  final List<LearningSourceNodeV1> source;
  final String selectedSourceId;
  final String? selectedSectionId;
  final VoidCallback? onCreateSource;
  final ValueChanged<String> onSelectSource;
  final void Function(String, String) onSelectSection;
  final void Function(LearningSourceNodeV1, _MaterialAction) onSourceAction;
  final void Function(LearningSourceNodeV1, SectionV1, _MaterialAction)
  onSectionAction;

  const _MaterialSidebar({
    required this.source,
    required this.selectedSourceId,
    required this.selectedSectionId,
    required this.onCreateSource,
    required this.onSelectSource,
    required this.onSelectSection,
    required this.onSourceAction,
    required this.onSectionAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StudySurface(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Библиотека', style: theme.textTheme.titleLarge),
                ),
                IconButton(
                  tooltip: 'Добавить источник',
                  onPressed: onCreateSource,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                for (final node in source) ...[
                  _HierarchyTile(
                    icon: _sourceIcon(node.source.type),
                    title: node.source.title,
                    subtitle: node.source.isArchived
                        ? '${_sourceTypeLabel(node.source.type)}, архив'
                        : _sourceTypeLabel(node.source.type),
                    selected:
                        selectedSourceId == node.source.id &&
                        selectedSectionId == null,
                    muted: node.source.isArchived,
                    onTap: () => onSelectSource(node.source.id),
                    menu: _sourceMenu(
                      node,
                      (action) => onSourceAction(node, action),
                    ),
                  ),
                  for (final section in node.section)
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: _HierarchyTile(
                        icon: Icons.folder_outlined,
                        title: section.title,
                        subtitle: section.isArchived ? 'Архив' : null,
                        selected:
                            selectedSourceId == node.source.id &&
                            selectedSectionId == section.id,
                        muted: section.isArchived || node.source.isArchived,
                        onTap: () =>
                            onSelectSection(node.source.id, section.id),
                        menu: _sectionMenu(
                          node,
                          section,
                          (action) => onSectionAction(node, section, action),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _HierarchyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final bool muted;
  final VoidCallback onTap;
  final Widget menu;

  const _HierarchyTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.muted,
    required this.onTap,
    required this.menu,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: muted ? 0.55 : 1,
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                menu,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _LessonWorkspace extends StatelessWidget {
  final LearningSourceNodeV1 node;
  final SectionV1? section;
  final VoidCallback onCreateSection;
  final VoidCallback onCreateLesson;
  final ValueChanged<LessonV1> onOpenLesson;
  final ValueChanged<LessonV1> onEditLesson;
  final ValueChanged<LessonV1> onArchiveLesson;
  final void Function(LessonV1, int) onMoveLesson;
  final void Function(LessonV1, LessonStatusV1) onStatusChanged;

  const _LessonWorkspace({
    required this.node,
    required this.section,
    required this.onCreateSection,
    required this.onCreateLesson,
    required this.onOpenLesson,
    required this.onEditLesson,
    required this.onArchiveLesson,
    required this.onMoveLesson,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = section == null
        ? node.lesson
        : node.lesson.where((item) => item.sectionId == section!.id).toList();
    final disabled = node.source.isArchived || (section?.isArchived ?? false);
    return StudySurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 20, 18),
            child: StudySectionHeader(
              title: section?.title ?? node.source.title,
              description: section == null
                  ? '${_sourceTypeLabel(node.source.type)}, уроков: ${lesson.length}'
                  : '${node.source.title}, уроков: ${lesson.length}',
              trailing: Wrap(
                spacing: 10,
                children: [
                  if (section == null)
                    OutlinedButton.icon(
                      onPressed: disabled ? null : onCreateSection,
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('Раздел'),
                    ),
                  FilledButton.icon(
                    onPressed: disabled ? null : onCreateLesson,
                    icon: const Icon(Icons.add),
                    label: const Text('Урок'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: lesson.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 36,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Уроков пока нет',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Добавьте первый урок в выбранную группу.',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: disabled ? null : onCreateLesson,
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить урок'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: lesson.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = lesson[index];
                      return _LessonRow(
                        lesson: item,
                        onOpen: () => onOpenLesson(item),
                        onEdit: () => onEditLesson(item),
                        onArchive: () => onArchiveLesson(item),
                        onMove: (offset) => onMoveLesson(item, offset),
                        onStatusChanged: (status) =>
                            onStatusChanged(item, status),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

final class _LessonRow extends StatelessWidget {
  final LessonV1 lesson;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final ValueChanged<int> onMove;
  final ValueChanged<LessonStatusV1> onStatusChanged;

  const _LessonRow({
    required this.lesson,
    required this.onOpen,
    required this.onEdit,
    required this.onArchive,
    required this.onMove,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: lesson.isArchived ? 0.55 : 1,
      child: Material(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    lesson.sourcePosition.isEmpty
                        ? '${lesson.position + 1}'
                        : lesson.sourcePosition,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 14),
                PopupMenuButton<LessonStatusV1>(
                  tooltip: 'Изменить статус',
                  enabled: !lesson.isArchived,
                  onSelected: onStatusChanged,
                  itemBuilder: (context) => [
                    for (final status in LessonStatusV1.values)
                      PopupMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 9,
                              color: lessonStatusColor(context, status),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lessonStatusLabel(status),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  child: LessonStatusBadge(status: lesson.status),
                ),
                PopupMenuButton<_MaterialAction>(
                  tooltip: 'Действия с уроком',
                  onSelected: (action) {
                    switch (action) {
                      case _MaterialAction.edit:
                        onEdit();
                      case _MaterialAction.moveUp:
                        onMove(-1);
                      case _MaterialAction.moveDown:
                        onMove(1);
                      case _MaterialAction.archive:
                        onArchive();
                      case _MaterialAction.addSection:
                      case _MaterialAction.addLesson:
                        break;
                    }
                  },
                  itemBuilder: (context) =>
                      _itemMenu(archived: lesson.isArchived, noun: 'урок'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _sourceMenu(
  LearningSourceNodeV1 node,
  ValueChanged<_MaterialAction> onSelected,
) {
  return PopupMenuButton<_MaterialAction>(
    tooltip: 'Действия с источником',
    onSelected: onSelected,
    itemBuilder: (context) => [
      ..._itemMenu(archived: node.source.isArchived, noun: 'источник'),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: _MaterialAction.addSection,
        enabled: !node.source.isArchived,
        child: const Text('Добавить раздел'),
      ),
      PopupMenuItem(
        value: _MaterialAction.addLesson,
        enabled: !node.source.isArchived,
        child: const Text('Добавить урок'),
      ),
    ],
  );
}

Widget _sectionMenu(
  LearningSourceNodeV1 node,
  SectionV1 section,
  ValueChanged<_MaterialAction> onSelected,
) {
  final disabled = node.source.isArchived || section.isArchived;
  return PopupMenuButton<_MaterialAction>(
    tooltip: 'Действия с разделом',
    onSelected: onSelected,
    itemBuilder: (context) => [
      ..._itemMenu(archived: section.isArchived, noun: 'раздел'),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: _MaterialAction.addLesson,
        enabled: !disabled,
        child: const Text('Добавить урок'),
      ),
    ],
  );
}

List<PopupMenuEntry<_MaterialAction>> _itemMenu({
  required bool archived,
  required String noun,
}) {
  return [
    PopupMenuItem(value: _MaterialAction.edit, child: Text('Изменить $noun')),
    const PopupMenuItem(
      value: _MaterialAction.moveUp,
      child: Text('Переместить выше'),
    ),
    const PopupMenuItem(
      value: _MaterialAction.moveDown,
      child: Text('Переместить ниже'),
    ),
    PopupMenuItem(
      value: _MaterialAction.archive,
      child: Text(archived ? 'Восстановить' : 'Архивировать'),
    ),
  ];
}

IconData _sourceIcon(LearningSourceTypeV1 value) => switch (value) {
  LearningSourceTypeV1.course => Icons.school_outlined,
  LearningSourceTypeV1.book => Icons.menu_book_outlined,
  LearningSourceTypeV1.article => Icons.article_outlined,
  LearningSourceTypeV1.video => Icons.play_circle_outline,
  LearningSourceTypeV1.other => Icons.folder_copy_outlined,
};

String _sourceTypeLabel(LearningSourceTypeV1 value) => switch (value) {
  LearningSourceTypeV1.course => 'Курс',
  LearningSourceTypeV1.book => 'Книга',
  LearningSourceTypeV1.article => 'Статья',
  LearningSourceTypeV1.video => 'Видео',
  LearningSourceTypeV1.other => 'Другое',
};

String _statusKey(LessonStatusV1 value) => switch (value) {
  LessonStatusV1.planned => 'planned',
  LessonStatusV1.studying => 'studying',
  LessonStatusV1.homework => 'homework',
  LessonStatusV1.mastered => 'mastered',
};
