import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class PublicationV1 extends Equatable {
  final String studyId;
  final int studyRevision;
  final List<String> changedPath;
  final String commitSha;
  final PublicationStateV1 state;

  const PublicationV1._({
    required this.studyId,
    required this.studyRevision,
    required this.state,
    required this.changedPath,
    required this.commitSha,
  });

  factory PublicationV1({
    required String studyId,
    required int studyRevision,
    required PublicationStateV1 state,
    Iterable<String> changedPath = const [],
    String commitSha = '',
  }) {
    final paths = List<String>.unmodifiable(changedPath);
    if (studyId.trim().isEmpty) throw const ValidationErrorV1('studyId');
    if (studyRevision < 1) throw const ValidationErrorV1('studyRevision');
    if (paths.any((value) => value.trim().isEmpty) ||
        paths.toSet().length != paths.length) {
      throw const ValidationErrorV1('changedPath');
    }
    if (state != PublicationStateV1.preview && commitSha.trim().isEmpty) {
      throw const ValidationErrorV1('commitSha');
    }
    return PublicationV1._(
      studyId: studyId,
      studyRevision: studyRevision,
      state: state,
      changedPath: paths,
      commitSha: commitSha,
    );
  }

  PublicationV1 copyWith({
    String? studyId,
    int? studyRevision,
    Iterable<String>? changedPath,
    String? commitSha,
    PublicationStateV1? state,
  }) => PublicationV1(
    studyId: studyId ?? this.studyId,
    studyRevision: studyRevision ?? this.studyRevision,
    changedPath: changedPath ?? this.changedPath,
    commitSha: commitSha ?? this.commitSha,
    state: state ?? this.state,
  );

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

  String toDebugString() =>
      'PublicationV1(studyId: $studyId, studyRevision: $studyRevision, '
      'changedPath: ${changedPath.length}, commitSha: <redacted>, '
      'hasCommit: ${commitSha.isNotEmpty}, state: $state)';
}
