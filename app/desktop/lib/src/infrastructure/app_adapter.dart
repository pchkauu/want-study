import 'package:domain_error/domain_error.dart';
import 'package:file_selector/file_selector.dart';
import 'package:grpc/grpc.dart';
import 'package:injectable/injectable.dart';
import 'package:observatory/observatory.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/proto/grpc/health/v1/health.pbgrpc.dart';

@LazySingleton(as: RepositoryPickerService)
final class DesktopRepositoryPickerV2 implements RepositoryPickerService {
  final StudyErrorReporterV2 _errorReporter;

  const DesktopRepositoryPickerV2(this._errorReporter);

  @override
  FutureResult<RepositorySelectionV1> pickRepository() {
    const context = StudyErrorContextV1(
      operation: 'DesktopRepositoryPickerV2.pickRepository():',
      layer: StudyErrorLayerV1.infrastructure,
    );
    return captureResult(
      () async {
        final path = await getDirectoryPath(
          confirmButtonText: 'Выбрать',
          canCreateDirectories: false,
        );
        return path == null
            ? const RepositorySelectionV1.cancelled()
            : RepositorySelectionV1.selected(path: path);
      },
      options: CaptureResultOptions(
        mapToDomainError: (error, stackTrace) =>
            UnexpectedErrorV1(cause: error, stackTrace: stackTrace),
        onRawError: (error, stackTrace) => _errorReporter.reportRawError(
          context: context,
          error: error,
          stackTrace: stackTrace,
        ),
        onDomainError: (error, stackTrace) => _errorReporter.reportDomainError(
          context: context,
          error: error,
          stackTrace: stackTrace,
        ),
        onObserverError: (error, stackTrace) =>
            _errorReporter.reportObserverError(
              context: context,
              error: error,
              stackTrace: stackTrace,
            ),
      ),
    );
  }
}

@LazySingleton(as: StudyErrorReporterV2)
final class ObservatoryStudyErrorReporterV2 implements StudyErrorReporterV2 {
  const ObservatoryStudyErrorReporterV2();

  @override
  Future<void> reportDomainError({
    required StudyErrorContextV1 context,
    required DomainError error,
    required StackTrace stackTrace,
  }) => Observatory.capture(
    LogLevel.warning,
    '${context.operation}:${error.typeIdentifier}',
    error: error,
    stackTrace: stackTrace,
  );

  @override
  Future<void> reportRawError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  }) => Observatory.capture(
    LogLevel.error,
    '${context.operation}:raw',
    error: error,
    stackTrace: stackTrace,
  );

  @override
  Future<void> reportObserverError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  }) => Observatory.capture(
    LogLevel.error,
    '${context.operation}:observer',
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
