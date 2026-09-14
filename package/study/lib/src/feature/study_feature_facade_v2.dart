import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:study/src/application/_barrel.dart';
import 'package:study/src/config/_barrel.dart';
import 'package:study/src/presentation/_barrel.dart';

@lazySingleton
final class StudyFeatureFacadeV2 {
  final Config config;
  final CatalogControllerV2 catalogController;
  final LessonEditorControllerV2 lessonEditorController;
  final ConceptControllerV1 conceptController;
  final PublicationControllerV2 publicationController;

  const StudyFeatureFacadeV2({
    required this.config,
    required this.catalogController,
    required this.lessonEditorController,
    required this.conceptController,
    required this.publicationController,
  });

  Widget buildRoot({VoidCallback? onOpenDiagnostics}) => StudyRootPageV1(
    config: config,
    catalogController: catalogController,
    lessonEditorController: lessonEditorController,
    conceptController: conceptController,
    publicationController: publicationController,
    onOpenDiagnostics: onOpenDiagnostics,
  );
}
