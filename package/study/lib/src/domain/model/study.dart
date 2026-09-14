import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/validation.dart';

final class StudyV1 extends Equatable {
  final String id;
  final String title;
  final String goal;
  final String localRepositoryPath;
  final int version;
  final int contentRevision;
  final bool isArchived;

  const StudyV1._({
    required this.id,
    required this.title,
    required this.goal,
    required this.localRepositoryPath,
    required this.version,
    required this.contentRevision,
    required this.isArchived,
  });

  factory StudyV1({
    required String id,
    required String title,
    String goal = '',
    String localRepositoryPath = '',
    int version = 1,
    int contentRevision = 1,
    bool isArchived = false,
  }) {
    return StudyV1._(
      id: id,
      title: StudyValidationV1.title('title', title),
      goal: StudyValidationV1.content('goal', goal),
      localRepositoryPath: localRepositoryPath,
      version: StudyValidationV1.version('version', version),
      contentRevision: StudyValidationV1.version(
        'contentRevision',
        contentRevision,
      ),
      isArchived: isArchived,
    );
  }

  StudyV1 copyWith({
    String? title,
    String? goal,
    String? localRepositoryPath,
    int? version,
    int? contentRevision,
    bool? isArchived,
  }) {
    return StudyV1(
      id: id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      localRepositoryPath: localRepositoryPath ?? this.localRepositoryPath,
      version: version ?? this.version,
      contentRevision: contentRevision ?? this.contentRevision,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'StudyV1(id: $id, titleLength: ${title.length}, version: $version, '
      'contentRevision: $contentRevision, isArchived: $isArchived)';
}
