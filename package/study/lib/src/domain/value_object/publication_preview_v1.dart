import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class PublicationPreviewV1 extends Equatable {
  final String studyId;
  final int studyRevision;
  final String diff;
  final List<String> changedPath;

  const PublicationPreviewV1._({
    required this.studyId,
    required this.studyRevision,
    required this.diff,
    required this.changedPath,
  });

  factory PublicationPreviewV1({
    required String studyId,
    required int studyRevision,
    required String diff,
    required Iterable<String> changedPath,
  }) {
    final paths = List<String>.unmodifiable(changedPath);
    if (studyId.trim().isEmpty) throw const ValidationErrorV1('studyId');
    if (studyRevision < 1) throw const ValidationErrorV1('studyRevision');
    if (paths.any((value) => value.trim().isEmpty) ||
        paths.toSet().length != paths.length) {
      throw const ValidationErrorV1('changedPath');
    }
    return PublicationPreviewV1._(
      studyId: studyId,
      studyRevision: studyRevision,
      diff: diff,
      changedPath: paths,
    );
  }

  PublicationPreviewV1 copyWith({
    String? studyId,
    int? studyRevision,
    String? diff,
    Iterable<String>? changedPath,
  }) => PublicationPreviewV1(
    studyId: studyId ?? this.studyId,
    studyRevision: studyRevision ?? this.studyRevision,
    diff: diff ?? this.diff,
    changedPath: changedPath ?? this.changedPath,
  );

  @override
  List<Object?> get props => [studyId, studyRevision, diff, changedPath];

  @override
  String toString() =>
      'PublicationPreviewV1(studyId: $studyId, '
      'studyRevision: $studyRevision, changedPath: ${changedPath.length})';

  String toDebugString() =>
      'PublicationPreviewV1(studyId: $studyId, '
      'studyRevision: $studyRevision, diff: <redacted>, '
      'diffLength: ${diff.length}, changedPath: ${changedPath.length})';
}
