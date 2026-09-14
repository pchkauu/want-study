import 'package:domain_error/domain_error.dart';
import 'package:equatable/equatable.dart';

enum StudyErrorLayerV1 { infrastructure, application, controller }

final class StudyErrorContextV1 extends Equatable {
  final String operation;
  final StudyErrorLayerV1 layer;

  const StudyErrorContextV1({required this.operation, required this.layer});

  @override
  List<Object?> get props => [operation, layer];

  @override
  String toString() =>
      'StudyErrorContextV1(operation: $operation, layer: $layer)';
}

abstract interface class StudyErrorReporterV2 {
  const StudyErrorReporterV2();

  Future<void> reportDomainError({
    required StudyErrorContextV1 context,
    required DomainError error,
    required StackTrace stackTrace,
  });

  Future<void> reportRawError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  });

  Future<void> reportObserverError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  });
}
