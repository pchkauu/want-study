import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/src/application/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';
import 'package:study/src/presentation/_barrel.dart';

final class PublicationPageV1 extends StatefulWidget {
  final StudyV1 study;
  final PublicationControllerV2 controller;
  final VoidCallback? onConfigureRepository;

  const PublicationPageV1({
    required this.study,
    required this.controller,
    this.onConfigureRepository,
    super.key,
  });

  @override
  State<PublicationPageV1> createState() => _PublicationPageV1State();
}

final class _PublicationPageV1State extends State<PublicationPageV1> {
  late final PublicationControllerV2 _controller;
  var _isActive = true;
  final _message = TextEditingController(
    text: 'docs(study): update learning progress',
  );

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _message.addListener(_onMessageChanged);
  }

  @override
  void didUpdateWidget(PublicationPageV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.study.id != widget.study.id) {
      _controller.add(PublicationPreviewRequestedV2(widget.study));
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
    _message.removeListener(_onMessageChanged);
    _message.dispose();
    super.dispose();
  }

  void _onMessageChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _controller,
      child:
          BlocEffectConsumer<
            PublicationControllerV2,
            PublicationStateV2,
            PublicationEffectV2
          >(
            bloc: _controller,
            listener: _onEffect,
            builder: (context, state) {
              final visibleState =
                  state.study?.id == widget.study.id &&
                      state.study?.version == widget.study.version &&
                      (state.snapshot == null ||
                          state.snapshot?.studyId == widget.study.id) &&
                      (state.preview == null ||
                          state.preview?.studyId == widget.study.id) &&
                      (state.publication == null ||
                          state.publication?.studyId == widget.study.id)
                  ? state
                  : PublicationStateV2(study: widget.study);
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, _) {
                          final compact =
                              MediaQuery.sizeOf(context).width < 960;
                          final controls = _buildControls(
                            context,
                            visibleState,
                          );
                          final diff = _buildDiff(context, visibleState);
                          if (compact) {
                            return Column(
                              children: [
                                SizedBox(height: 280, child: controls),
                                const SizedBox(height: 16),
                                Expanded(child: diff),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(width: 360, child: controls),
                              const SizedBox(width: 16),
                              Expanded(child: diff),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildControls(BuildContext context, PublicationStateV2 state) {
    if (widget.study.localRepositoryPath.trim().isEmpty) {
      return StudySurface(
        child: StudyStateView(
          icon: Icons.folder_off_outlined,
          title: 'Git-репозиторий не выбран',
          description: 'Укажите локальный репозиторий в настройках обучения.',
          actionLabel: 'Настроить обучение',
          actionIcon: Icons.settings_outlined,
          onAction: widget.onConfigureRepository,
        ),
      );
    }
    final busy =
        state.loadState == PublicationLoadStateV2.preparing ||
        state.loadState == PublicationLoadStateV2.publishing;
    final (statusLabel, statusIcon, statusColor) = _publicationStatus(
      context,
      state,
    );
    return StudySurface(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 18, color: statusColor),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    statusLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            if (busy) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(minHeight: 2),
            ],
            const SizedBox(height: 16),
            Text(
              'Предпросмотр не меняет репозиторий. Запись выполняется только после подтверждения.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            _PublicationSteps(state: state),
            const SizedBox(height: 22),
            if (state.loadState == PublicationLoadStateV2.pushFailed) ...[
              OutlinedButton.icon(
                onPressed: () =>
                    _controller.add(const PublicationPushRetriedV2()),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Повторить push'),
              ),
            ] else
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => _controller.add(
                        PublicationPreviewRequestedV2(widget.study),
                      ),
                icon: const Icon(Icons.preview_outlined),
                label: const Text('Построить предпросмотр'),
              ),
            if (state.loadState == PublicationLoadStateV2.ready &&
                state.preview != null) ...[
              const SizedBox(height: 22),
              TextField(
                controller: _message,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Сообщение коммита',
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed:
                    state.loadState == PublicationLoadStateV2.publishing ||
                        _message.text.trim().isEmpty
                    ? null
                    : _confirm,
                icon: const Icon(Icons.publish),
                label: const Text('Записать и отправить'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiff(BuildContext context, PublicationStateV2 state) {
    if (widget.study.localRepositoryPath.trim().isEmpty) {
      return StudySurface(
        padding: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const StudyStateView(
          icon: Icons.difference_outlined,
          title: 'Предпросмотр недоступен',
          description: 'Сначала выберите локальный Git-репозиторий.',
        ),
      );
    }
    final preview = state.preview;
    return StudySurface(
      padding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: preview == null
          ? const StudyStateView(
              icon: Icons.difference_outlined,
              title: 'Предпросмотр не построен',
              description: 'Сначала проверьте изменения управляемых файлов.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Text(
                    'Markdown diff',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: SelectableText(
                      preview.diff.isEmpty ? 'Изменений нет.' : preview.diff,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  (String, IconData, Color) _publicationStatus(
    BuildContext context,
    PublicationStateV2 state,
  ) {
    final scheme = Theme.of(context).colorScheme;
    if (state.loadState == PublicationLoadStateV2.failed &&
        state.failure == StudyFailureKindV1.conflict) {
      return (
        'Данные изменились — обновите предпросмотр',
        Icons.refresh_rounded,
        studyWarningColor,
      );
    }
    return switch (state.loadState) {
      PublicationLoadStateV2.initial => (
        'Готово к проверке',
        Icons.shield_outlined,
        scheme.onSurfaceVariant,
      ),
      PublicationLoadStateV2.preparing => (
        'Строится предпросмотр',
        Icons.sync,
        scheme.primary,
      ),
      PublicationLoadStateV2.ready => (
        'Предпросмотр готов',
        Icons.check_circle_outline,
        scheme.tertiary,
      ),
      PublicationLoadStateV2.publishing => (
        'Публикация',
        Icons.cloud_upload_outlined,
        scheme.primary,
      ),
      PublicationLoadStateV2.published => (
        'Опубликовано',
        Icons.cloud_done_outlined,
        scheme.tertiary,
      ),
      PublicationLoadStateV2.pushFailed => (
        'Push не выполнен',
        Icons.cloud_off_outlined,
        studyWarningColor,
      ),
      PublicationLoadStateV2.failed => (
        'Проверка не выполнена',
        Icons.error_outline,
        scheme.error,
      ),
    };
  }

  Future<void> _confirm() async {
    if (!mounted || !_isActive) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Опубликовать изменения?'),
        content: const Text(
          'Приложение изменит только управляемые файлы, создаст commit и выполнит push текущей ветки.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Опубликовать'),
          ),
        ],
      ),
    );
    if (mounted && _isActive && (confirmed ?? false)) {
      _controller.add(
        PublicationConfirmedV2(
          PublicationCommitV1(message: _message.text.trim()),
        ),
      );
    }
  }

  void _onEffect(BuildContext _, PublicationEffectV2 effect) {
    if (!mounted || !_isActive) return;
    final message = switch (effect) {
      PublicationFailureEffectV2(failure: StudyFailureKindV1.conflict) =>
        'Данные изменились. Постройте предпросмотр заново.',
      PublicationFailureEffectV2() => 'Публикация не выполнена',
      PublicationSuccessEffectV2() => 'Изменения опубликованы',
    };
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }
}

final class _PublicationSteps extends StatelessWidget {
  final PublicationStateV2 state;

  const _PublicationSteps({required this.state});

  @override
  Widget build(BuildContext context) {
    final published = state.loadState == PublicationLoadStateV2.published;
    final committed =
        published || state.loadState == PublicationLoadStateV2.pushFailed;
    final prepared = state.preview != null || committed;
    return Column(
      children: [
        _PublicationStep(
          index: 1,
          label: 'Проверка файлов',
          complete: prepared,
        ),
        _PublicationStep(
          index: 2,
          label: 'Создание commit',
          complete: committed,
        ),
        _PublicationStep(
          index: 3,
          label: 'Отправка изменений',
          complete: published,
        ),
      ],
    );
  }
}

final class _PublicationStep extends StatelessWidget {
  final int index;
  final String label;
  final bool complete;

  const _PublicationStep({
    required this.index,
    required this.label,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = complete
        ? theme.colorScheme.tertiary
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: complete
                ? Icon(Icons.check_rounded, size: 15, color: color)
                : Text(
                    '$index',
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
