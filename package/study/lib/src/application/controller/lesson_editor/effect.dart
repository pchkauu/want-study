part of 'controller.dart';

sealed class LessonEditorEffectV2 extends Equatable {
  const LessonEditorEffectV2();
}

final class LessonEditorFailureEffectV2 extends LessonEditorEffectV2 {
  final StudyFailureKindV1 failure;

  const LessonEditorFailureEffectV2(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'LessonEditorFailureEffectV2(failure: $failure)';
}

final class LessonEditorDraftDecisionEffectV2 extends LessonEditorEffectV2 {
  const LessonEditorDraftDecisionEffectV2();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'LessonEditorDraftDecisionEffectV2';
}

final class LessonEditorNavigateEffectV2 extends LessonEditorEffectV2 {
  const LessonEditorNavigateEffectV2();

  @override
  List<Object?> get props => const [];

  @override
  String toString() => 'LessonEditorNavigateEffectV2';
}
