import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:observatory/observatory.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/dependency/injection.dart';
import 'package:want_study_desktop/src/infrastructure/app_adapter.dart';

part 'app_router.gr.dart';

@lazySingleton
@AutoRouterConfig()
final class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: StudyRoute.page, initial: true),
    AutoRoute(page: DiagnosticsRoute.page),
  ];
}

@RoutePage()
final class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

final class _StudyScreenState extends State<StudyScreen> {
  late Future<bool> _health;

  @override
  void initState() {
    super.initState();
    _health = getIt<HealthGatewayV1>().isServing();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _health,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!(snapshot.data ?? false)) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Want Study'),
              actions: [_diagnosticsButton(context)],
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'Локальный сервис недоступен',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const SelectableText('Запустите: docker compose up -d'),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => setState(
                      () => _health = getIt<HealthGatewayV1>().isServing(),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Проверить снова'),
                  ),
                ],
              ),
            ),
          );
        }
        return Stack(
          children: [
            Positioned.fill(child: getIt<StudyFeatureFacadeV1>().buildRoot()),
            Positioned(top: 12, right: 12, child: _diagnosticsButton(context)),
          ],
        );
      },
    );
  }

  Widget _diagnosticsButton(BuildContext context) => IconButton.filledTonal(
    onPressed: () => context.router.push(const DiagnosticsRoute()),
    tooltip: 'Локальные логи',
    icon: const Icon(Icons.monitor_heart_outlined),
  );
}

@RoutePage()
final class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ObservatoryLogScreen(appBarTitle: 'Локальные логи');
}
