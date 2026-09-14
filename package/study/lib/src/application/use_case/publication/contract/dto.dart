import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class PublicationPrepareParamsV1 extends Equatable {
  final StudyV1 study;

  const PublicationPrepareParamsV1(this.study);

  @override
  List<Object?> get props => [study.id, study.contentRevision];
}

final class PublicationPublishParamsV1 extends Equatable {
  final StudyV1 study;
  final ExportSnapshotV1 snapshot;
  final PublicationCommitV1 commit;

  const PublicationPublishParamsV1({
    required this.study,
    required this.snapshot,
    required this.commit,
  });

  @override
  List<Object?> get props => [study.id, snapshot, commit];
}

final class PublicationRetryPushParamsV1 extends Equatable {
  final PublicationV1 publication;

  const PublicationRetryPushParamsV1(this.publication);

  @override
  List<Object?> get props => [publication];
}

final class PublicationPrepareResultV1 extends Equatable {
  final ExportSnapshotV1 snapshot;
  final PublicationPreviewV1 preview;

  const PublicationPrepareResultV1({
    required this.snapshot,
    required this.preview,
  });

  @override
  List<Object?> get props => [snapshot, preview];
}

final class PublicationPublishResultV1 extends Equatable {
  final PublicationV1 publication;

  const PublicationPublishResultV1(this.publication);

  @override
  List<Object?> get props => [publication];
}
