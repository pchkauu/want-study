import 'package:domain_error/domain_error.dart';

abstract interface class StudyErrorReporterV1 {
  Future<void> reportDomainError(
    String operation,
    DomainError error,
    StackTrace stackTrace,
  );

  Future<void> reportRawError(
    String operation,
    Object error,
    StackTrace stackTrace,
  );
}
