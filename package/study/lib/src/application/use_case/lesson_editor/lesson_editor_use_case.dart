import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:study/src/application/service/_barrel.dart';
import 'package:study/src/application/use_case/lesson_editor/contract/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

@lazySingleton
final class LessonEditorUseCase {
  final LessonContentRepositoryV2 _lessonRepository;
  final KnowledgeRepositoryV2 _knowledgeRepository;
  final StudyUseCaseExecutor _executor;

  const LessonEditorUseCase(
    this._lessonRepository,
    this._knowledgeRepository,
    this._executor,
  );

  FutureResult<LessonWorkspaceResultV1> loadV1({
    required LessonWorkspaceParamsV1 params,
  }) {
    const op = 'LessonEditorUseCase.loadV1():';
    return _executor.call(
      operation: op,
      body: () async => LessonWorkspaceResultV1(
        await _lessonRepository.getWorkspace(params.lesson),
      ),
    );
  }

  FutureResult<LessonBlockSaveResultV1> saveBlockV1({
    required LessonSaveBlockParamsV1 params,
  }) {
    const op = 'LessonEditorUseCase.saveBlockV1():';
    return _executor.call(
      operation: op,
      body: () async => LessonBlockSaveResultV1(
        await _lessonRepository.updateBlock(params.block),
      ),
    );
  }

  FutureResult<LessonWorkspaceResultV1> mutateV1({
    required LessonMutationParamsV1 params,
  }) {
    const op = 'LessonEditorUseCase.mutateV1():';
    return _executor.call(operation: op, body: () => _mutate(params));
  }

  FutureResult<LessonConceptSearchResultV1> searchConceptV1({
    required LessonConceptSearchParamsV1 params,
  }) {
    const op = 'LessonEditorUseCase.searchConceptV1():';
    return _executor.call(
      operation: op,
      body: () async => LessonConceptSearchResultV1(
        await _knowledgeRepository.searchConcepts(
          study: params.study,
          search: params.search,
        ),
      ),
    );
  }

  FutureResult<LessonBlockConceptResultV1> changeBlockConceptV1({
    required LessonBlockConceptParamsV1 params,
  }) {
    const op = 'LessonEditorUseCase.changeBlockConceptV1():';
    return _executor.call(
      operation: op,
      body: () async {
        final concept = switch (params.action) {
          ConceptBlockLinkActionV1.link => await _knowledgeRepository.linkBlock(
            params.concept,
            params.block,
          ),
          ConceptBlockLinkActionV1.unlink =>
            await _knowledgeRepository.unlinkBlock(
              params.concept,
              params.block,
            ),
        };
        return LessonBlockConceptResultV1(concept);
      },
    );
  }

  Future<LessonWorkspaceResultV1> _mutate(LessonMutationParamsV1 params) async {
    switch (params.mutation) {
      case LessonCreateBlockV1(:final block):
        await _lessonRepository.createBlock(block);
      case LessonDeleteBlockV1(:final block):
        await _lessonRepository.deleteBlock(block);
      case LessonCreateTaskV1(:final task):
        await _lessonRepository.createTask(task);
      case LessonUpdateTaskV1(:final task):
        await _lessonRepository.updateTask(task);
      case LessonDeleteTaskV1(:final task):
        await _lessonRepository.deleteTask(task);
      case LessonCreateFileV1(:final file):
        await _lessonRepository.createFile(file);
      case LessonUpdateFileV1(:final file):
        await _lessonRepository.updateFile(file);
      case LessonDeleteFileV1(:final file):
        await _lessonRepository.deleteFile(file);
      case LessonReorderContentV1(:final block, :final task):
        await _lessonRepository.reorderContent(
          lesson: params.lesson,
          block: block,
          task: task,
        );
    }
    return LessonWorkspaceResultV1(
      await _lessonRepository.getWorkspace(params.lesson),
    );
  }
}
