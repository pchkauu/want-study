import 'package:flutter/widgets.dart';
import 'package:study/src/config/config.dart';
import 'package:study/src/dependency/repository_picker.dart';
import 'package:study/src/domain/repository/knowledge_repository.dart';
import 'package:study/src/domain/repository/lesson_content_repository.dart';
import 'package:study/src/domain/repository/study_publication_repository.dart';
import 'package:study/src/domain/repository/study_repository.dart';
import 'package:study/src/presentation/view/study_root_page.dart';

final class StudyFeatureFacadeV1 {
  final Config config;
  final StudyRepositoryV1 studyRepository;
  final LessonContentRepositoryV1 lessonContentRepository;
  final KnowledgeRepositoryV1 knowledgeRepository;
  final StudyPublicationRepositoryV1 publicationRepository;
  final RepositoryPickerV1 repositoryPicker;

  const StudyFeatureFacadeV1({
    required this.config,
    required this.studyRepository,
    required this.lessonContentRepository,
    required this.knowledgeRepository,
    required this.publicationRepository,
    required this.repositoryPicker,
  });

  Widget buildRoot() => StudyRootPageV1(
    config: config,
    studyRepository: studyRepository,
    lessonContentRepository: lessonContentRepository,
    knowledgeRepository: knowledgeRepository,
    publicationRepository: publicationRepository,
    repositoryPicker: repositoryPicker,
  );
}
