import 'package:flutter/foundation.dart';
import 'package:package_context/package_context.dart' as package_context;
import 'package:study/src/config/_barrel.dart';
import 'package:study/src/core/context/_barrel.dart';
import 'package:study/src/dependency/_barrel.dart';
import 'package:study/src/feature/_barrel.dart';

Future<StudyFeatureFacadeV2> initPackage({
  required Config config,
  required Dependencies dependencies,
  @visibleForTesting bool resetForTesting = false,
}) async {
  if (resetForTesting) await _resetPackageForTesting();
  await packageContext.ensureInitialized(
    graph: package_context.PackageGraph(
      config: config,
      dependencies: dependencies,
    ),
    isBound: studyGetIt.isRegistered<StudyFeatureFacadeV2>(),
    bind: configureStudyDependencies,
  );
  return studyGetIt<StudyFeatureFacadeV2>();
}

Future<void> _resetPackageForTesting() async {
  if (studyGetIt.isRegistered<StudyFeatureFacadeV2>()) {
    final facade = studyGetIt<StudyFeatureFacadeV2>();
    if (!facade.catalogController.isClosed) {
      await facade.catalogController.close();
    }
    if (!facade.lessonEditorController.isClosed) {
      await facade.lessonEditorController.close();
    }
    if (!facade.conceptController.isClosed) {
      await facade.conceptController.close();
    }
    if (!facade.publicationController.isClosed) {
      await facade.publicationController.close();
    }
  }
  await studyGetIt.reset();
  // ignore: invalid_use_of_visible_for_testing_member
  packageContext.reset();
}
