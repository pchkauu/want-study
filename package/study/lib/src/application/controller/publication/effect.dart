part of 'controller.dart';

sealed class PublicationEffectV2 extends Equatable {
  const PublicationEffectV2();
}

final class PublicationFailureEffectV2 extends PublicationEffectV2 {
  final StudyFailureKindV1 failure;

  const PublicationFailureEffectV2(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'PublicationFailureEffectV2(failure: $failure)';
}

final class PublicationSuccessEffectV2 extends PublicationEffectV2 {
  const PublicationSuccessEffectV2();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'PublicationSuccessEffectV2';
}
