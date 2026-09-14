part of 'controller.dart';

enum PublicationLoadStateV2 {
  initial,
  preparing,
  ready,
  publishing,
  published,
  pushFailed,
  failed,
}

final class PublicationStateV2 extends Equatable {
  final PublicationLoadStateV2 loadState;
  final StudyV1? study;
  final ExportSnapshotV1? snapshot;
  final PublicationPreviewV1? preview;
  final PublicationV1? publication;
  final StudyFailureKindV1? failure;

  const PublicationStateV2({
    this.loadState = PublicationLoadStateV2.initial,
    this.study,
    this.snapshot,
    this.preview,
    this.publication,
    this.failure,
  });

  PublicationStateV2 copyWith({
    PublicationLoadStateV2? loadState,
    StudyV1? Function()? study,
    ExportSnapshotV1? Function()? snapshot,
    PublicationPreviewV1? Function()? preview,
    PublicationV1? Function()? publication,
    StudyFailureKindV1? Function()? failure,
  }) => PublicationStateV2(
    loadState: loadState ?? this.loadState,
    study: study == null ? this.study : study(),
    snapshot: snapshot == null ? this.snapshot : snapshot(),
    preview: preview == null ? this.preview : preview(),
    publication: publication == null ? this.publication : publication(),
    failure: failure == null ? this.failure : failure(),
  );

  @override
  List<Object?> get props => [
    loadState,
    study?.id,
    snapshot,
    preview,
    publication,
    failure,
  ];
}
