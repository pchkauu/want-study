import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:observatory/observatory.dart' as observatory;
import 'package:study/study.dart' as study;
import 'package:want_study_desktop/src/dependency/injection.dart';
import 'package:want_study_desktop/src/navigation/app_router.dart';
import 'package:want_study_desktop/src/theme/app_theme.dart';

Future<void> main() => observatory.Observatory.run<void>(
  config: const observatory.Config(
    historyLimit: 500,
    blocEffects: observatory.TalkerBlocEffectsSettings(
      printEffectFullData: false,
    ),
  ),
  zoneName: 'main',
  body: _start,
);

Future<void> _start() async {
  LaunchMode.initialize(LaunchModeType.foreground);
  configureDependencies();
  observatory.Observatory.attachTo(getIt<Dio>());
  final facade = await study.initPackage(
    config: const study.Config(),
    dependencies: study.Dependencies(
      studyRepository: getIt(),
      lessonContentRepository: getIt(),
      knowledgeRepository: getIt(),
      publicationRepository: getIt(),
      errorReporter: getIt(),
      repositoryPicker: getIt(),
    ),
  );
  getIt.registerSingleton(facade);
  runApp(observatory.ObservatoryWidget(child: WantStudyApp(router: getIt())));
}

final class WantStudyApp extends StatelessWidget {
  final AppRouter router;

  const WantStudyApp({required this.router, super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Want Study',
    debugShowCheckedModeBanner: false,
    theme: buildWantStudyTheme(),
    darkTheme: buildWantStudyTheme(),
    themeMode: ThemeMode.dark,
    routerConfig: router.config(
      navigatorObservers: () => observatory.Observatory.navigatorObservers,
    ),
  );
}
