import 'package:domain_error/domain_error.dart';
import 'package:study/src/domain/_barrel.dart';

enum StudyFailureKindV1 {
  validation,
  notFound,
  conflict,
  openHomework,
  unavailable,
  publication,
  unexpected,
}

StudyFailureKindV1 studyFailureKindV1(DomainError error) {
  final studyError = error is StudyErrorV1 ? error : const UnexpectedErrorV1();
  return switch (studyError) {
    ValidationErrorV1() => StudyFailureKindV1.validation,
    NotFoundErrorV1() => StudyFailureKindV1.notFound,
    ConflictErrorV1() => StudyFailureKindV1.conflict,
    OpenHomeworkErrorV1() => StudyFailureKindV1.openHomework,
    UnavailableErrorV1() => StudyFailureKindV1.unavailable,
    PublicationErrorV1() => StudyFailureKindV1.publication,
    UnexpectedErrorV1() => StudyFailureKindV1.unexpected,
  };
}
