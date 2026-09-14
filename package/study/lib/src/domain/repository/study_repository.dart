import 'package:study/src/domain/model/learning_source.dart';
import 'package:study/src/domain/model/lesson.dart';
import 'package:study/src/domain/model/material_tree.dart';
import 'package:study/src/domain/model/reorder_item.dart';
import 'package:study/src/domain/model/section.dart';
import 'package:study/src/domain/model/study.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/model/study_progress.dart';

abstract interface class StudyRepositoryV1 {
  Future<List<StudyV1>> listStudies({bool includeArchived = false});

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

  Future<LessonV1> changeLessonStatus({
    required LessonV1 lesson,
    required LessonStatusV1 status,
    bool acknowledgeOpenHomework = false,
  });

  Future<MaterialTreeV1> getMaterialTree(
    String studyId, {
    bool includeArchived = false,
  });

  Future<MaterialTreeV1> reorderMaterial({
    required String studyId,
    Iterable<ReorderItemV1> source = const [],
    Iterable<ReorderItemV1> section = const [],
    Iterable<ReorderItemV1> lesson = const [],
  });

  Future<StudyProgressV1> getDashboard(String studyId);
}
