import 'package:study/src/domain/_barrel.dart';

abstract interface class StudyRepositoryV2 {
  const StudyRepositoryV2();

  Future<List<StudyV1>> listStudies({
    ArchiveScopeV1 scope = ArchiveScopeV1.activeOnly,
  });

  Future<StudyV1> createStudy(StudyV1 study);

  Future<StudyV1> updateStudy(StudyV1 study);

  Future<StudyV1> archiveStudy(StudyV1 study);

  Future<StudyV1> restoreStudy(StudyV1 study);

  Future<LearningSourceV1> createSource(LearningSourceV1 source);

  Future<LearningSourceV1> updateSource(LearningSourceV1 source);

  Future<LearningSourceV1> archiveSource(LearningSourceV1 source);

  Future<LearningSourceV1> restoreSource(LearningSourceV1 source);

  Future<SectionV1> createSection(SectionV1 section);

  Future<SectionV1> updateSection(SectionV1 section);

  Future<SectionV1> archiveSection(SectionV1 section);

  Future<SectionV1> restoreSection(SectionV1 section);

  Future<LessonV1> createLesson(LessonV1 lesson);

  Future<LessonV1> updateLesson(LessonV1 lesson);

  Future<LessonV1> archiveLesson(LessonV1 lesson);

  Future<LessonV1> restoreLesson(LessonV1 lesson);

  Future<LessonV1> changeLessonStatus(LessonStatusChangeV1 change);

  Future<MaterialTreeV1> getMaterialTree({
    required StudyV1 study,
    ArchiveScopeV1 scope = ArchiveScopeV1.activeOnly,
  });

  Future<MaterialTreeV1> reorderMaterial({
    required StudyV1 study,
    Iterable<ReorderItemV1> source = const [],
    Iterable<ReorderItemV1> section = const [],
    Iterable<ReorderItemV1> lesson = const [],
  });

  Future<StudyProgressV1> getDashboard(StudyV1 study);
}
