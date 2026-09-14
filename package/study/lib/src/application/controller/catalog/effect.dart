part of 'controller.dart';

sealed class CatalogEffectV2 extends Equatable {
  const CatalogEffectV2();
}

final class CatalogFailureEffectV2 extends CatalogEffectV2 {
  final StudyFailureKindV1 failure;

  const CatalogFailureEffectV2(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'CatalogFailureEffectV2(failure: $failure)';
}

final class ConfirmOpenHomeworkEffectV2 extends CatalogEffectV2 {
  final String lessonId;

  const ConfirmOpenHomeworkEffectV2(this.lessonId);

  @override
  List<Object?> get props => [lessonId];

  @override
  String toString() => 'ConfirmOpenHomeworkEffectV2';
}
