// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:grpc/grpc.dart' as _i1017;
import 'package:injectable/injectable.dart' as _i526;
import 'package:study/study.dart' as _i1018;
import 'package:want_study_desktop/src/dependency/injection.dart' as _i546;
import 'package:want_study_desktop/src/infrastructure/app_adapter.dart'
    as _i351;
import 'package:want_study_desktop/src/infrastructure/git_publication_repository.dart'
    as _i960;
import 'package:want_study_desktop/src/infrastructure/grpc_repository.dart'
    as _i194;
import 'package:want_study_desktop/src/navigation/app_router.dart' as _i798;
import 'package:want_study_desktop/src/proto/grpc/health/v1/health.pbgrpc.dart'
    as _i1019;
import 'package:want_study_desktop/src/proto/wantstudy/v1/export.pbgrpc.dart'
    as _i239;
import 'package:want_study_desktop/src/proto/wantstudy/v1/knowledge.pbgrpc.dart'
    as _i562;
import 'package:want_study_desktop/src/proto/wantstudy/v1/lesson_content.pbgrpc.dart'
    as _i891;
import 'package:want_study_desktop/src/proto/wantstudy/v1/study.pbgrpc.dart'
    as _i751;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i1017.ClientChannel>(() => appModule.channel());
    gh.lazySingleton<_i361.Dio>(() => appModule.dio());
    gh.lazySingleton<_i798.AppRouter>(() => _i798.AppRouter());
    gh.lazySingleton<_i1018.StudyErrorReporterV1>(
      () => const _i351.ObservatoryStudyErrorReporterV1(),
    );
    gh.lazySingleton<_i1018.RepositoryPickerV1>(
      () => const _i351.DesktopRepositoryPickerV1(),
    );
    gh.lazySingleton<_i751.StudyCatalogServiceClient>(
      () => appModule.studyCatalog(gh<_i1017.ClientChannel>()),
    );
    gh.lazySingleton<_i891.LessonContentServiceClient>(
      () => appModule.lessonContent(gh<_i1017.ClientChannel>()),
    );
    gh.lazySingleton<_i562.KnowledgeServiceClient>(
      () => appModule.knowledge(gh<_i1017.ClientChannel>()),
    );
    gh.lazySingleton<_i239.ExportServiceClient>(
      () => appModule.export(gh<_i1017.ClientChannel>()),
    );
    gh.lazySingleton<_i1019.HealthClient>(
      () => appModule.health(gh<_i1017.ClientChannel>()),
    );
    gh.lazySingleton<_i1018.LessonContentRepositoryV1>(
      () => _i194.GrpcLessonContentRepositoryV1(
        gh<_i891.LessonContentServiceClient>(),
      ),
    );
    gh.lazySingleton<_i1018.KnowledgeRepositoryV1>(
      () => _i194.GrpcKnowledgeRepositoryV1(gh<_i562.KnowledgeServiceClient>()),
    );
    gh.lazySingleton<_i194.GrpcExportGatewayV1>(
      () => _i194.GrpcExportGatewayV1(gh<_i239.ExportServiceClient>()),
    );
    gh.lazySingleton<_i351.HealthGatewayV1>(
      () => _i351.HealthGatewayV1(gh<_i1019.HealthClient>()),
    );
    gh.lazySingleton<_i1018.StudyRepositoryV1>(
      () => _i194.GrpcStudyRepositoryV1(gh<_i751.StudyCatalogServiceClient>()),
    );
    gh.lazySingleton<_i1018.StudyPublicationRepositoryV1>(
      () => _i960.GitPublicationRepositoryV1(
        gh<_i194.GrpcExportGatewayV1>(),
        gh<_i1018.StudyRepositoryV1>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i546.AppModule {}
