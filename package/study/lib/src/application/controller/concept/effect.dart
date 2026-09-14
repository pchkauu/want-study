part of 'controller.dart';

sealed class ConceptEffectV1 extends Equatable {
  const ConceptEffectV1();
}

final class ConceptFailureEffectV1 extends ConceptEffectV1 {
  final StudyFailureKindV1 failure;

  const ConceptFailureEffectV1(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'ConceptFailureEffectV1(failure: $failure)';
}
