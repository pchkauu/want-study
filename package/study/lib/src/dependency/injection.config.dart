// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:study/src/application/_barrel.dart' as _i263;
import 'package:study/src/application/controller/catalog/controller.dart'
    as _i432;
import 'package:study/src/application/controller/concept/controller.dart'
    as _i644;
import 'package:study/src/application/controller/lesson_editor/controller.dart'
    as _i548;
import 'package:study/src/application/controller/publication/controller.dart'
    as _i541;
import 'package:study/src/application/service/_barrel.dart' as _i1039;
import 'package:study/src/application/service/error/_barrel.dart' as _i646;
import 'package:study/src/application/service/study_use_case_executor.dart'
    as _i639;
import 'package:study/src/application/use_case/_barrel.dart' as _i146;
import 'package:study/src/application/use_case/catalog/catalog_use_case.dart'
    as _i1064;
import 'package:study/src/application/use_case/concept/concept_use_case.dart'
    as _i456;
import 'package:study/src/application/use_case/lesson_editor/lesson_editor_use_case.dart'
    as _i496;
import 'package:study/src/application/use_case/publication/publication_use_case.dart'
    as _i844;
import 'package:study/src/config/_barrel.dart' as _i143;
import 'package:study/src/dependency/injection.dart' as _i805;
import 'package:study/src/domain/_barrel.dart' as _i256;
import 'package:study/src/feature/study_feature_facade_v2.dart' as _i653;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final studyModule = _$StudyModule();
    gh.lazySingleton<_i143.Config>(() => studyModule.config);
    gh.lazySingleton<_i256.StudyRepositoryV2>(
      () => studyModule.studyRepository,
    );
    gh.lazySingleton<_i256.LessonContentRepositoryV2>(
      () => studyModule.lessonContentRepository,
    );
    gh.lazySingleton<_i256.KnowledgeRepositoryV2>(
      () => studyModule.knowledgeRepository,
    );
    gh.lazySingleton<_i256.StudyPublicationRepositoryV2>(
      () => studyModule.publicationRepository,
    );
    gh.lazySingleton<_i263.StudyErrorReporterV2>(
      () => studyModule.errorReporter,
    );
    gh.lazySingleton<_i263.RepositoryPickerService>(
      () => studyModule.repositoryPicker,
    );
    gh.lazySingleton<_i639.StudyUseCaseExecutor>(
      () => _i639.StudyUseCaseExecutor(gh<_i646.StudyErrorReporterV2>()),
    );
    gh.lazySingleton<_i1064.CatalogUseCase>(
      () => _i1064.CatalogUseCase(
        gh<_i256.StudyRepositoryV2>(),
        gh<_i1039.RepositoryPickerService>(),
        gh<_i1039.StudyUseCaseExecutor>(),
      ),
    );
    gh.lazySingleton<_i432.CatalogControllerV2>(
      () => _i432.CatalogControllerV2(
        gh<_i146.CatalogUseCase>(),
        gh<_i1039.StudyErrorReporterV2>(),
      ),
    );
    gh.lazySingleton<_i456.ConceptUseCase>(
      () => _i456.ConceptUseCase(
        gh<_i256.KnowledgeRepositoryV2>(),
        gh<_i1039.StudyUseCaseExecutor>(),
      ),
    );
    gh.lazySingleton<_i496.LessonEditorUseCase>(
      () => _i496.LessonEditorUseCase(
        gh<_i256.LessonContentRepositoryV2>(),
        gh<_i256.KnowledgeRepositoryV2>(),
        gh<_i1039.StudyUseCaseExecutor>(),
      ),
    );
    gh.lazySingleton<_i844.PublicationUseCase>(
      () => _i844.PublicationUseCase(
        gh<_i256.StudyPublicationRepositoryV2>(),
        gh<_i1039.StudyUseCaseExecutor>(),
      ),
    );
    gh.lazySingleton<_i644.ConceptControllerV1>(
      () => _i644.ConceptControllerV1(
        gh<_i146.ConceptUseCase>(),
        gh<_i1039.StudyErrorReporterV2>(),
      ),
    );
    gh.lazySingleton<_i548.LessonEditorControllerV2>(
      () => _i548.LessonEditorControllerV2(
        gh<_i146.LessonEditorUseCase>(),
        gh<_i1039.StudyErrorReporterV2>(),
        config: gh<_i143.Config>(),
      ),
    );
    gh.lazySingleton<_i541.PublicationControllerV2>(
      () => _i541.PublicationControllerV2(
        gh<_i146.PublicationUseCase>(),
        gh<_i1039.StudyErrorReporterV2>(),
      ),
    );
    gh.lazySingleton<_i653.StudyFeatureFacadeV2>(
      () => _i653.StudyFeatureFacadeV2(
        config: gh<_i143.Config>(),
        catalogController: gh<_i263.CatalogControllerV2>(),
        lessonEditorController: gh<_i263.LessonEditorControllerV2>(),
        conceptController: gh<_i263.ConceptControllerV1>(),
        publicationController: gh<_i263.PublicationControllerV2>(),
      ),
    );
    return this;
  }
}

class _$StudyModule extends _i805.StudyModule {}
