import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:study/src/application/service/error/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

@lazySingleton
final class StudyUseCaseExecutor {
  final StudyErrorReporterV2 _reporter;

  const StudyUseCaseExecutor(this._reporter);

  FutureResult<T> call<T>({
    required String operation,
    required Future<T> Function() body,
  }) => captureResult(
    body,
    options: CaptureResultOptions(
      mapToDomainError: (error, stackTrace) =>
          UnexpectedErrorV1(cause: error, stackTrace: stackTrace),
      onDomainError: (error, stackTrace) => _reporter.reportDomainError(
        context: StudyErrorContextV1(
          operation: operation,
          layer: StudyErrorLayerV1.application,
        ),
        error: error,
        stackTrace: stackTrace,
      ),
      onRawError: (error, stackTrace) => _reporter.reportRawError(
        context: StudyErrorContextV1(
          operation: operation,
          layer: StudyErrorLayerV1.application,
        ),
        error: error,
        stackTrace: stackTrace,
      ),
      onObserverError: (error, stackTrace) => _reporter.reportObserverError(
        context: StudyErrorContextV1(
          operation: operation,
          layer: StudyErrorLayerV1.application,
        ),
        error: error,
        stackTrace: stackTrace,
      ),
    ),
  );
}
