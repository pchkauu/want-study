import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/study_enum.dart';

final class ExportFileV1 extends Equatable {
  final String path;
  final List<int> content;
  final String sha256;

  ExportFileV1({
    required this.path,
    required Iterable<int> content,
    required this.sha256,
  }) : content = List.unmodifiable(content);

  @override
  List<Object?> get props => [path, content, sha256];

  @override
  String toString() =>
      'ExportFileV1(bytes: ${content.length}, sha256: $sha256)';
}

final class ExportSnapshotV1 extends Equatable {
  final String studyId;
  final int studyRevision;
  final List<ExportFileV1> file;

  ExportSnapshotV1({
    required this.studyId,
    required this.studyRevision,
    required Iterable<ExportFileV1> file,
  }) : file = List.unmodifiable(file);

  int get totalBytes => file.fold(0, (sum, item) => sum + item.content.length);

  @override
  List<Object?> get props => [studyId, studyRevision, file];
}

final class PublicationPreviewV1 extends Equatable {
  final String studyId;
  final int studyRevision;
  final String diff;
  final List<String> changedPath;

  PublicationPreviewV1({
    required this.studyId,
    required this.studyRevision,
    required this.diff,
    required Iterable<String> changedPath,
  }) : changedPath = List.unmodifiable(changedPath);

  @override
  List<Object?> get props => [studyId, studyRevision, diff, changedPath];

  @override
  String toString() =>
      'PublicationPreviewV1(studyId: $studyId, '
      'studyRevision: $studyRevision, changedPath: ${changedPath.length})';
}

final class PublicationV1 extends Equatable {
  final String studyId;
  final int studyRevision;
  final List<String> changedPath;
  final String commitSha;
  final PublicationStateV1 state;

  PublicationV1({
    required this.studyId,
    required this.studyRevision,
    required this.state,
    Iterable<String> changedPath = const [],
    this.commitSha = '',
  }) : changedPath = List.unmodifiable(changedPath);

  @override
  List<Object?> get props => [
    studyId,
    studyRevision,
    changedPath,
    commitSha,
    state,
  ];

  @override
  String toString() =>
      'PublicationV1(studyId: $studyId, studyRevision: $studyRevision, '
      'changedPath: ${changedPath.length}, hasCommit: ${commitSha.isNotEmpty}, '
      'state: $state)';
}
