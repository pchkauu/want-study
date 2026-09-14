import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ExportSnapshotV1 extends Equatable {
  final String studyId;
  final int studyRevision;
  final List<ExportFileV1> file;

  const ExportSnapshotV1._({
    required this.studyId,
    required this.studyRevision,
    required this.file,
  });

  factory ExportSnapshotV1({
    required String studyId,
    required int studyRevision,
    required Iterable<ExportFileV1> file,
  }) {
    final files = List<ExportFileV1>.unmodifiable(file);
    if (studyId.trim().isEmpty) throw const ValidationErrorV1('studyId');
    if (studyRevision < 1) throw const ValidationErrorV1('studyRevision');
    if (files.map((value) => value.path).toSet().length != files.length) {
      throw const ValidationErrorV1('file');
    }
    final totalBytes = files.fold<int>(
      0,
      (sum, item) => sum + item.content.length,
    );
    if (totalBytes > StudyConstV1.maxExportSnapshotBytes) {
      throw const ValidationErrorV1('file');
    }
    return ExportSnapshotV1._(
      studyId: studyId,
      studyRevision: studyRevision,
      file: files,
    );
  }

  int get totalBytes => file.fold(0, (sum, item) => sum + item.content.length);

  ExportSnapshotV1 copyWith({
    String? studyId,
    int? studyRevision,
    Iterable<ExportFileV1>? file,
  }) => ExportSnapshotV1(
    studyId: studyId ?? this.studyId,
    studyRevision: studyRevision ?? this.studyRevision,
    file: file ?? this.file,
  );

  @override
  List<Object?> get props => [studyId, studyRevision, file];

  @override
  String toString() =>
      'ExportSnapshotV1(studyId: $studyId, studyRevision: $studyRevision, '
      'file: ${file.length}, totalBytes: $totalBytes)';

  String toDebugString() => toString();
}
