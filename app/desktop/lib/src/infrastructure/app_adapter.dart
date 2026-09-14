import 'package:file_selector/file_selector.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:observatory/observatory.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/proto/grpc/health/v1/health.pbgrpc.dart';

@LazySingleton(as: RepositoryPickerV1)
final class DesktopRepositoryPickerV1 implements RepositoryPickerV1 {
  const DesktopRepositoryPickerV1();

  @override
  Future<String?> pickRepository() => getDirectoryPath(
    confirmButtonText: 'Выбрать',
    canCreateDirectories: false,
  );
}

@LazySingleton(as: StudyErrorReporterV1)
final class ObservatoryStudyErrorReporterV1 implements StudyErrorReporterV1 {
  const ObservatoryStudyErrorReporterV1();

  @override
  Future<void> reportDomainError(
    String operation,
    DomainError error,
    StackTrace stackTrace,
  ) => Observatory.capture(
    LogLevel.warning,
    '$operation:${error.typeIdentifier}',
    error: error,
    stackTrace: stackTrace,
  );

  @override
  Future<void> reportRawError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) => Observatory.capture(
    LogLevel.error,
    '$operation:UnexpectedErrorV1',
    error: error,
    stackTrace: stackTrace,
  );
}

@lazySingleton
final class HealthGatewayV1 {
  final HealthClient _client;

  const HealthGatewayV1(this._client);

  Future<bool> isServing() async {
    try {
      final response = await _client.check(
        HealthCheckRequest(),
        options: CallOptions(timeout: const Duration(seconds: 2)),
      );
      return response.status == HealthCheckResponse_ServingStatus.SERVING;
    } on Object {
      return false;
    }
  }
}
