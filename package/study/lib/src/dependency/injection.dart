import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:study/src/application/_barrel.dart';
import 'package:study/src/config/_barrel.dart';
import 'package:study/src/core/context/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

import 'injection.config.dart';

final studyGetIt = GetIt.asNewInstance();

@InjectableInit()
void configureStudyDependencies() => studyGetIt.init();

@module
abstract class StudyModule {
  @lazySingleton
  Config get config => packageContext.config;

  @lazySingleton
  StudyRepositoryV2 get studyRepository =>
      packageContext.dependencies.studyRepository;

  @lazySingleton
  LessonContentRepositoryV2 get lessonContentRepository =>
      packageContext.dependencies.lessonContentRepository;

  @lazySingleton
  KnowledgeRepositoryV2 get knowledgeRepository =>
      packageContext.dependencies.knowledgeRepository;

  @lazySingleton
  StudyPublicationRepositoryV2 get publicationRepository =>
      packageContext.dependencies.publicationRepository;

  @lazySingleton
  StudyErrorReporterV2 get errorReporter =>
      packageContext.dependencies.errorReporter;

  @lazySingleton
  RepositoryPickerService get repositoryPicker =>
      packageContext.dependencies.repositoryPicker;
}
