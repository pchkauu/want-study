import 'package:package_context/package_context.dart' as package_context;
import 'package:study/src/dependency/error_reporter.dart';
import 'package:study/src/dependency/repository_picker.dart';
import 'package:study/src/domain/repository/knowledge_repository.dart';
import 'package:study/src/domain/repository/lesson_content_repository.dart';
import 'package:study/src/domain/repository/study_publication_repository.dart';
import 'package:study/src/domain/repository/study_repository.dart';

final class Dependencies extends package_context.PackageDependencies {
  final StudyRepositoryV1 studyRepository;
  final LessonContentRepositoryV1 lessonContentRepository;
  final KnowledgeRepositoryV1 knowledgeRepository;
  final StudyPublicationRepositoryV1 publicationRepository;
  final StudyErrorReporterV1 errorReporter;
  final RepositoryPickerV1 repositoryPicker;

  const Dependencies({
    required this.studyRepository,
    required this.lessonContentRepository,
    required this.knowledgeRepository,
    required this.publicationRepository,
    required this.errorReporter,
    required this.repositoryPicker,
  });
}
