import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:observatory/observatory.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/dependency/injection.dart';
import 'package:want_study_desktop/src/infrastructure/app_adapter.dart';
import 'package:want_study_desktop/src/theme/app_theme.dart';

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
  final Future<bool> Function()? healthCheck;

  const StudyScreen({this.healthCheck, super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

final class _StudyScreenState extends State<StudyScreen> {
  late Future<bool> _health;

  @override
  void initState() {
    super.initState();
    _health = _checkHealth();
  }

  Future<bool> _checkHealth() =>
      widget.healthCheck?.call() ?? getIt<HealthGatewayV1>().isServing();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _health,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: _HealthSkeleton());
        }
        if (!(snapshot.data ?? false)) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Want Study'),
              actions: [_diagnosticsButton(context)],
            ),
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, -0.9),
                  radius: 1.1,
                  colors: [Color(0x1F6152ED), Colors.transparent],
                ),
              ),
              child: Center(
                child: Container(
                  width: 560,
                  padding: const EdgeInsets.fromLTRB(44, 40, 44, 46),
                  decoration: BoxDecoration(
                    color: WantStudyColor.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 36,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: WantStudyColor.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.cloud_off_outlined,
                          color: WantStudyColor.error,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Локальный сервис недоступен',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Запустите сервисы и повторите проверку.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: WantStudyColor.textMuted),
                      ),
                      const SizedBox(height: 16),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          color: WantStudyColor.background,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: SelectableText(
                            'docker compose up -d',
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () =>
                            setState(() => _health = _checkHealth()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Проверить снова'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return getIt<StudyFeatureFacadeV2>().buildRoot(
          onOpenDiagnostics: () =>
              context.router.push(const DiagnosticsRoute()),
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

final class _HealthSkeleton extends StatelessWidget {
  const _HealthSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    return Center(
      child: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 260,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 340,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
final class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ObservatoryLogScreen(appBarTitle: 'Локальные логи');
}
