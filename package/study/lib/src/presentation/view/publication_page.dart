import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/src/application/bloc/publication_bloc.dart';
import 'package:study/src/domain/model/study.dart';
import 'package:study/src/domain/repository/study_publication_repository.dart';

final class PublicationPageV1 extends StatefulWidget {
  final StudyV1 study;
  final StudyPublicationRepositoryV1 repository;

  const PublicationPageV1({
    required this.study,
    required this.repository,
    super.key,
  });

  @override
  State<PublicationPageV1> createState() => _PublicationPageV1State();
}

final class _PublicationPageV1State extends State<PublicationPageV1> {
  late final PublicationBlocV1 _bloc;
  final _message = TextEditingController(
    text: 'docs(study): update learning progress',
  );

  @override
  void initState() {
    super.initState();
    _bloc = PublicationBlocV1(widget.repository);
  }

  @override
  void didUpdateWidget(PublicationPageV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.study.id != widget.study.id) {
      _bloc.add(PublicationPreviewRequestedV1(widget.study));
    }
  }

  @override
  void dispose() {
    _message.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child:
          BlocEffectConsumer<
            PublicationBlocV1,
            PublicationBlocStateV1,
            PublicationEffectV1
          >(
            listener: _onEffect,
            builder: (context, state) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Публикация',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Предпросмотр не меняет репозиторий. Запись и push выполняются только после подтверждения.',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed:
                            state.loadState ==
                                    PublicationLoadStateV1.preparing ||
                                state.loadState ==
                                    PublicationLoadStateV1.publishing
                            ? null
                            : () => _bloc.add(
                                PublicationPreviewRequestedV1(widget.study),
                              ),
                        icon: const Icon(Icons.preview_outlined),
                        label: const Text('Построить предпросмотр'),
                      ),
                      if (state.loadState == PublicationLoadStateV1.preparing ||
                          state.loadState ==
                              PublicationLoadStateV1.publishing) ...[
                        const SizedBox(width: 16),
                        const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                      if (state.loadState ==
                          PublicationLoadStateV1.pushFailed) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _bloc.add(const PublicationPushRetriedV1()),
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Повторить push'),
                        ),
                      ],
                    ],
                  ),
                  if (state.preview != null) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _message,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        labelText: 'Сообщение коммита',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLow,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            state.preview!.diff.isEmpty
                                ? 'Изменений нет.'
                                : state.preview!.diff,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed:
                            state.loadState ==
                                    PublicationLoadStateV1.publishing ||
                                _message.text.trim().isEmpty
                            ? null
                            : _confirm,
                        icon: const Icon(Icons.publish),
                        label: const Text('Записать, commit и push'),
                      ),
                    ),
                  ] else
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Сначала постройте безопасный предпросмотр.',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _confirm() async {
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
    if (confirmed ?? false) {
      _bloc.add(PublicationConfirmedV1(_message.text.trim()));
    }
  }

  void _onEffect(BuildContext context, PublicationEffectV1 effect) {
    final message = switch (effect) {
      PublicationFailureEffectV1() => 'Публикация не выполнена',
      PublicationSuccessEffectV1() => 'Изменения опубликованы',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
