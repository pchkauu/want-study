part of 'controller.dart';

sealed class PublicationEventV2 extends Equatable {
  const PublicationEventV2();
}

final class PublicationPreviewRequestedV2 extends PublicationEventV2 {
  final StudyV1 study;

  const PublicationPreviewRequestedV2(this.study);

  @override
  List<Object?> get props => [study.id, study.contentRevision];
}

final class PublicationConfirmedV2 extends PublicationEventV2 {
  final PublicationCommitV1 commit;

  const PublicationConfirmedV2(this.commit);

  @override
  List<Object?> get props => [commit];
}

final class PublicationPushRetriedV2 extends PublicationEventV2 {
  const PublicationPushRetriedV2();

  @override
  List<Object?> get props => const [];
}
