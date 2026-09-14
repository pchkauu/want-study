import 'package:study/src/domain/_barrel.dart';

abstract interface class StudyPublicationRepositoryV2 {
  const StudyPublicationRepositoryV2();

  Future<ExportSnapshotV1> renderStudyExport(StudyV1 study);

  Future<PublicationPreviewV1> preview({
    required StudyV1 study,
    required ExportSnapshotV1 snapshot,
  });

  Future<PublicationV1> publish({
    required StudyV1 study,
    required ExportSnapshotV1 snapshot,
    required PublicationCommitV1 commit,
  });

  Future<PublicationV1> retryPush(PublicationV1 publication);
}
