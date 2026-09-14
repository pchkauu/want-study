import 'package:domain_error/domain_error.dart';
import 'package:study/src/core/package_context.dart';
import 'package:study/src/domain/error/study_error.dart';

FutureResult<T> studySafeCallV1<T>(
  String operation,
  Future<T> Function() call,
) async {
  var domainReported = false;
  final result = await captureResult(
    call,
    options: CaptureResultOptions(
      mapToDomainError: (error, stackTrace) =>
          UnexpectedErrorV1(cause: error, stackTrace: stackTrace),
      onDomainError: (error, stackTrace) {
        domainReported = true;
        return studyDependencies.errorReporter.reportDomainError(
          operation,
          error,
          stackTrace,
        );
      },
      onRawError: (error, stackTrace) => studyDependencies.errorReporter
          .reportRawError(operation, error, stackTrace),
    ),
  );
  if (result.isError && !domainReported) {
    try {
      final error = result.domainError;
      await studyDependencies.errorReporter.reportDomainError(
        operation,
        error,
        error.stackTrace ?? StackTrace.current,
      );
    } on Object {
      // Reporting never replaces the operation result.
    }
  }
  return result;
}
