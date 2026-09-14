import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:want_study_desktop/src/proto/grpc/health/v1/health.pbgrpc.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/export.pbgrpc.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/knowledge.pbgrpc.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/lesson_content.pbgrpc.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/study.pbgrpc.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class AppModule {
  @lazySingleton
  ClientChannel channel() => ClientChannel(
    '127.0.0.1',
    port: 50051,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );

  @lazySingleton
  StudyCatalogServiceClient studyCatalog(ClientChannel channel) =>
      StudyCatalogServiceClient(channel);

  @lazySingleton
  LessonContentServiceClient lessonContent(ClientChannel channel) =>
      LessonContentServiceClient(channel);

  @lazySingleton
  KnowledgeServiceClient knowledge(ClientChannel channel) =>
      KnowledgeServiceClient(channel);

  @lazySingleton
  ExportServiceClient export(ClientChannel channel) =>
      ExportServiceClient(channel);

  @lazySingleton
  HealthClient health(ClientChannel channel) => HealthClient(channel);

  @lazySingleton
  Dio dio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
