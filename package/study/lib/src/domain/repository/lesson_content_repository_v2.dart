import 'package:study/src/domain/_barrel.dart';

abstract interface class LessonContentRepositoryV2 {
  const LessonContentRepositoryV2();

  Future<LessonWorkspaceV1> getWorkspace(LessonV1 lesson);

  Future<NoteBlockV1> createBlock(NoteBlockV1 block);

  Future<NoteBlockV1> updateBlock(NoteBlockV1 block);

  Future<NoteBlockV1> deleteBlock(NoteBlockV1 block);

  Future<HomeworkTaskV1> createTask(HomeworkTaskV1 task);

  Future<HomeworkTaskV1> updateTask(HomeworkTaskV1 task);

  Future<HomeworkTaskV1> deleteTask(HomeworkTaskV1 task);

  Future<CodeFileV1> createFile(CodeFileV1 file);

  Future<CodeFileV1> updateFile(CodeFileV1 file);

  Future<CodeFileV1> deleteFile(CodeFileV1 file);

  Future<LessonWorkspaceV1> reorderContent({
    required LessonV1 lesson,
    Iterable<ReorderItemV1> block = const [],
    Iterable<ReorderItemV1> task = const [],
  });
}
