part of 'controller.dart';

enum LessonEditorLoadStateV2 { initial, loading, ready, failed }

final class LessonEditorStateV2 extends Equatable {
  final LessonEditorLoadStateV2 loadState;
  final LessonWorkspaceV1? workspace;
  final SaveStateV1 saveState;
  final int draftRevision;
  final StudyFailureKindV1? failure;

  const LessonEditorStateV2({
    this.loadState = LessonEditorLoadStateV2.initial,
    this.workspace,
    this.saveState = SaveStateV1.clean,
    this.draftRevision = 0,
    this.failure,
  });

  LessonEditorStateV2 copyWith({
    LessonEditorLoadStateV2? loadState,
    LessonWorkspaceV1? Function()? workspace,
    SaveStateV1? saveState,
    int? draftRevision,
    StudyFailureKindV1? Function()? failure,
  }) => LessonEditorStateV2(
    loadState: loadState ?? this.loadState,
    workspace: workspace == null ? this.workspace : workspace(),
    saveState: saveState ?? this.saveState,
    draftRevision: draftRevision ?? this.draftRevision,
    failure: failure == null ? this.failure : failure(),
  );

  @override
  List<Object?> get props => [
    loadState,
    workspace,
    saveState,
    draftRevision,
    failure,
  ];
}
