import 'package:study/src/domain/model/code_file.dart';
import 'package:study/src/domain/model/homework_task.dart';
import 'package:study/src/domain/model/lesson_workspace.dart';
import 'package:study/src/domain/model/note_block.dart';
import 'package:study/src/domain/model/reorder_item.dart';

abstract interface class LessonContentRepositoryV1 {
  Future<LessonWorkspaceV1> getWorkspace(String lessonId);

  Future<NoteBlockV1> createBlock(NoteBlockV1 block);

  Future<NoteBlockV1> updateBlock(NoteBlockV1 block);

  Future<void> deleteBlock(NoteBlockV1 block, {required bool confirmed});

  Future<HomeworkTaskV1> createTask(HomeworkTaskV1 task);

  Future<HomeworkTaskV1> updateTask(HomeworkTaskV1 task);

  Future<void> deleteTask(HomeworkTaskV1 task, {required bool confirmed});

  Future<CodeFileV1> createFile(CodeFileV1 file);

  Future<CodeFileV1> updateFile(CodeFileV1 file);

  Future<void> deleteFile(CodeFileV1 file, {required bool confirmed});

  Future<LessonWorkspaceV1> reorderContent({
    required String lessonId,
    Iterable<ReorderItemV1> block = const [],
    Iterable<ReorderItemV1> task = const [],
  });
}
