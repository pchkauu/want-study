import 'package:get_it/get_it.dart';
import 'package:package_context/package_context.dart' as package_context;
import 'package:study/src/config/config.dart';
import 'package:study/src/core/package_context.dart';
import 'package:study/src/dependency/dependencies.dart';
import 'package:study/src/feature/study_feature_facade.dart';

final _locator = GetIt.asNewInstance();

Future<StudyFeatureFacadeV1> initPackage({
  required Config config,
  required Dependencies dependencies,
}) async {
  await packageContext.ensureInitialized(
    graph: package_context.PackageGraph(
      config: config,
      dependencies: dependencies,
    ),
    isBound: _locator.isRegistered<StudyFeatureFacadeV1>(),
    bind: () {
      _locator.registerSingleton(
        StudyFeatureFacadeV1(
          config: config,
          studyRepository: dependencies.studyRepository,
          lessonContentRepository: dependencies.lessonContentRepository,
          knowledgeRepository: dependencies.knowledgeRepository,
          publicationRepository: dependencies.publicationRepository,
          repositoryPicker: dependencies.repositoryPicker,
        ),
      );
    },
  );
  return _locator<StudyFeatureFacadeV1>();
}
