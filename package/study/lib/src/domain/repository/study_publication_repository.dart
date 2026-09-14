import 'package:study/src/domain/model/publication.dart';
import 'package:study/src/domain/model/study.dart';

abstract interface class StudyPublicationRepositoryV1 {
  Future<ExportSnapshotV1> renderStudyExport(
    String studyId, {
    int? expectedContentRevision,
  });

  Future<PublicationPreviewV1> preview({
    required StudyV1 study,
    required ExportSnapshotV1 snapshot,
  });

  Future<PublicationV1> publish({
    required StudyV1 study,
    required ExportSnapshotV1 snapshot,
    required String commitMessage,
  });

  Future<PublicationV1> retryPush(PublicationV1 publication);
}
