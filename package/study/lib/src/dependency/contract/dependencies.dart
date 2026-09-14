import 'package:package_context/package_context.dart' as package_context;
import 'package:study/src/application/service/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

final class Dependencies extends package_context.PackageDependencies {
  final StudyRepositoryV2 studyRepository;
  final LessonContentRepositoryV2 lessonContentRepository;
  final KnowledgeRepositoryV2 knowledgeRepository;
  final StudyPublicationRepositoryV2 publicationRepository;
  final StudyErrorReporterV2 errorReporter;
  final RepositoryPickerService repositoryPicker;

  const Dependencies({
    required this.studyRepository,
    required this.lessonContentRepository,
    required this.knowledgeRepository,
    required this.publicationRepository,
    required this.errorReporter,
    required this.repositoryPicker,
  });
}
