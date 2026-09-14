import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/protos.dart';
import 'package:injectable/injectable.dart';
import 'package:study/study.dart' as domain;
import 'package:want_study_desktop/src/proto/wantstudy/v1/export.pb.dart'
    as export_proto;
import 'package:want_study_desktop/src/proto/wantstudy/v1/export.pbgrpc.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/knowledge.pb.dart'
    as knowledge_proto;
import 'package:want_study_desktop/src/proto/wantstudy/v1/knowledge.pbgrpc.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/lesson_content.pb.dart'
    as content_proto;
import 'package:want_study_desktop/src/proto/wantstudy/v1/lesson_content.pbgrpc.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/study.pb.dart'
    as study_proto;
import 'package:want_study_desktop/src/proto/wantstudy/v1/study.pbgrpc.dart';

Future<T> _read<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on GrpcError catch (error, stackTrace) {
    if (error.code == StatusCode.unavailable) {
      try {
        return await call();
      } on GrpcError catch (retryError, retryStackTrace) {
        throw _mapGrpcError(retryError, retryStackTrace);
      } on Object catch (retryError, retryStackTrace) {
        throw domain.UnexpectedErrorV1(
          cause: retryError,
          stackTrace: retryStackTrace,
        );
      }
    }
    throw _mapGrpcError(error, stackTrace);
  } on Object catch (error, stackTrace) {
    throw domain.UnexpectedErrorV1(cause: error, stackTrace: stackTrace);
  }
}

Future<T> _write<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on GrpcError catch (error, stackTrace) {
    throw _mapGrpcError(error, stackTrace);
  } on Object catch (error, stackTrace) {
    throw domain.UnexpectedErrorV1(cause: error, stackTrace: stackTrace);
  }
}

Future<T> _createWrite<T>(
  Future<T> Function() call,
  Future<T?> Function() reconcile,
) async {
  try {
    return await call();
  } on GrpcError catch (error, stackTrace) {
    if (error.code == StatusCode.deadlineExceeded) {
      try {
        final stored = await reconcile();
        if (stored != null) {
          return stored;
        }
      } on domain.ConflictErrorV1 {
        rethrow;
      } on Object {
        // Preserve the original ambiguous timeout.
      }
    }
    throw _mapGrpcError(error, stackTrace);
  } on domain.DomainError {
    rethrow;
  } on Object catch (error, stackTrace) {
    throw domain.UnexpectedErrorV1(cause: error, stackTrace: stackTrace);
  }
}

domain.DomainError _mapGrpcError(GrpcError error, StackTrace stackTrace) {
  final details = error.details ?? const [];
  final info = details.whereType<ErrorInfo>().firstOrNull;
  final reason = info?.reason;
  final badRequest = details.whereType<BadRequest>().firstOrNull;
  final precondition = details.whereType<PreconditionFailure>().firstOrNull;
  final field = badRequest?.fieldViolations.firstOrNull?.field_1 ?? 'request';
  final resource =
      precondition?.violations.firstOrNull?.subject ??
      info?.domain ??
      'resource';

  if (reason == 'OPEN_HOMEWORK') {
    return const domain.OpenHomeworkErrorV1();
  }
  if (reason == 'VERSION_CONFLICT' || error.code == StatusCode.aborted) {
    return domain.ConflictErrorV1(resource);
  }
  if (reason == 'VALIDATION_FAILED' ||
      error.code == StatusCode.invalidArgument) {
    return domain.ValidationErrorV1(field);
  }
  if (reason == 'NOT_FOUND' || error.code == StatusCode.notFound) {
    return domain.NotFoundErrorV1(resource);
  }
  if (error.code == StatusCode.unavailable ||
      error.code == StatusCode.deadlineExceeded) {
    return domain.UnavailableErrorV1(cause: error, stackTrace: stackTrace);
  }
  if (error.code == StatusCode.alreadyExists) {
    return domain.ConflictErrorV1(resource);
  }
  return domain.UnexpectedErrorV1(cause: error, stackTrace: stackTrace);
}

@LazySingleton(as: domain.StudyRepositoryV1)
final class GrpcStudyRepositoryV1 implements domain.StudyRepositoryV1 {
  final StudyCatalogServiceClient _client;

  const GrpcStudyRepositoryV1(this._client);

  @override
  Future<List<domain.StudyV1>> listStudies({bool includeArchived = false}) =>
      _read(
        () async => (await _client.listStudies(
          study_proto.ListStudiesRequest(includeArchived: includeArchived),
        )).studies.map(_studyFromProto).toList(growable: false),
      );

  @override
  Future<domain.StudyV1> createStudy(domain.StudyV1 study) => _createWrite(
    () async => _studyFromProto(
      await _client.createStudy(
        study_proto.CreateStudyRequest(
          id: study.id,
          title: study.title,
          goal: study.goal,
          localRepositoryPath: study.localRepositoryPath,
        ),
      ),
    ),
    () async {
      final stored = _studyFromProto(
        await _client.getStudy(study_proto.GetStudyRequest(id: study.id)),
      );
      if (stored.title != study.title ||
          stored.goal != study.goal ||
          stored.localRepositoryPath != study.localRepositoryPath) {
        throw domain.ConflictErrorV1('study/${study.id}');
      }
      return stored;
    },
  );

  @override
  Future<domain.StudyV1> updateStudy(domain.StudyV1 study) => _write(
    () async => _studyFromProto(
      await _client.updateStudy(
        study_proto.UpdateStudyRequest(
          id: study.id,
          title: study.title,
          goal: study.goal,
          localRepositoryPath: study.localRepositoryPath,
          expectedVersion: Int64(study.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.StudyV1> archiveStudy(domain.StudyV1 study) =>
      _changeStudy(study, _client.archiveStudy);

  @override
  Future<domain.StudyV1> restoreStudy(domain.StudyV1 study) =>
      _changeStudy(study, _client.restoreStudy);

  Future<domain.StudyV1> _changeStudy(
    domain.StudyV1 study,
    ResponseFuture<study_proto.Study> Function(
      study_proto.ChangeArchiveRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(
    () async => _studyFromProto(
      await call(
        study_proto.ChangeArchiveRequest(
          id: study.id,
          expectedVersion: Int64(study.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.LearningSourceV1> createSource(
    domain.LearningSourceV1 source,
  ) => _createWrite(
    () async => _sourceFromProto(
      await _client.createLearningSource(
        study_proto.CreateLearningSourceRequest(
          id: source.id,
          studyId: source.studyId,
          type: _sourceTypeToProto(source.type),
          title: source.title,
          author: source.author,
          url: source.url,
          exportSlug: source.exportSlug,
          position: source.position,
        ),
      ),
    ),
    () async {
      final tree = await getMaterialTree(source.studyId, includeArchived: true);
      final stored = tree.source
          .map((node) => node.source)
          .where((item) => item.id == source.id)
          .firstOrNull;
      if (stored == null) {
        return null;
      }
      if (stored.studyId != source.studyId ||
          stored.type != source.type ||
          stored.title != source.title ||
          stored.author != source.author ||
          stored.url != source.url ||
          stored.exportSlug != source.exportSlug ||
          stored.position != source.position) {
        throw domain.ConflictErrorV1('source/${source.id}');
      }
      return stored;
    },
  );

  @override
  Future<domain.LearningSourceV1> updateSource(
    domain.LearningSourceV1 source,
  ) => _write(
    () async => _sourceFromProto(
      await _client.updateLearningSource(
        study_proto.UpdateLearningSourceRequest(
          source: _sourceToProto(source),
          expectedVersion: Int64(source.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.LearningSourceV1> archiveSource(
    domain.LearningSourceV1 source,
  ) => _changeSource(source, _client.archiveLearningSource);

  @override
  Future<domain.LearningSourceV1> restoreSource(
    domain.LearningSourceV1 source,
  ) => _changeSource(source, _client.restoreLearningSource);

  Future<domain.LearningSourceV1> _changeSource(
    domain.LearningSourceV1 source,
    ResponseFuture<study_proto.LearningSource> Function(
      study_proto.ChangeArchiveRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(
    () async => _sourceFromProto(
      await call(
        study_proto.ChangeArchiveRequest(
          id: source.id,
          expectedVersion: Int64(source.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.SectionV1> createSection(domain.SectionV1 section) =>
      _createWrite(
        () async => _sectionFromProto(
          await _client.createSection(
            study_proto.CreateSectionRequest(
              id: section.id,
              studyId: section.studyId,
              sourceId: section.sourceId,
              title: section.title,
              position: section.position,
            ),
          ),
        ),
        () async {
          final tree = await getMaterialTree(
            section.studyId,
            includeArchived: true,
          );
          final stored = tree.source
              .expand((node) => node.section)
              .where((item) => item.id == section.id)
              .firstOrNull;
          if (stored == null) {
            return null;
          }
          if (stored.studyId != section.studyId ||
              stored.sourceId != section.sourceId ||
              stored.title != section.title ||
              stored.position != section.position) {
            throw domain.ConflictErrorV1('section/${section.id}');
          }
          return stored;
        },
      );

  @override
  Future<domain.SectionV1> updateSection(domain.SectionV1 section) => _write(
    () async => _sectionFromProto(
      await _client.updateSection(
        study_proto.UpdateSectionRequest(
          section: _sectionToProto(section),
          expectedVersion: Int64(section.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.SectionV1> archiveSection(domain.SectionV1 section) =>
      _changeSection(section, _client.archiveSection);

  @override
  Future<domain.SectionV1> restoreSection(domain.SectionV1 section) =>
      _changeSection(section, _client.restoreSection);

  Future<domain.SectionV1> _changeSection(
    domain.SectionV1 section,
    ResponseFuture<study_proto.Section> Function(
      study_proto.ChangeArchiveRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(
    () async => _sectionFromProto(
      await call(
        study_proto.ChangeArchiveRequest(
          id: section.id,
          expectedVersion: Int64(section.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.LessonV1> createLesson(domain.LessonV1 lesson) => _createWrite(
    () async => _lessonFromProto(
      await _client.createLesson(
        study_proto.CreateLessonRequest(
          id: lesson.id,
          studyId: lesson.studyId,
          sourceId: lesson.sourceId,
          sectionId: lesson.sectionId,
          title: lesson.title,
          url: lesson.url,
          sourcePosition: lesson.sourcePosition,
          exportSlug: lesson.exportSlug,
          position: lesson.position,
          status: _lessonStatusToProto(lesson.status),
        ),
      ),
    ),
    () async {
      final tree = await getMaterialTree(lesson.studyId, includeArchived: true);
      final stored = tree.source
          .expand((node) => node.lesson)
          .where((item) => item.id == lesson.id)
          .firstOrNull;
      if (stored == null) {
        return null;
      }
      if (stored.studyId != lesson.studyId ||
          stored.sourceId != lesson.sourceId ||
          stored.sectionId != lesson.sectionId ||
          stored.title != lesson.title ||
          stored.url != lesson.url ||
          stored.sourcePosition != lesson.sourcePosition ||
          stored.exportSlug != lesson.exportSlug ||
          stored.position != lesson.position ||
          stored.status != lesson.status) {
        throw domain.ConflictErrorV1('lesson/${lesson.id}');
      }
      return stored;
    },
  );

  @override
  Future<domain.LessonV1> updateLesson(domain.LessonV1 lesson) => _write(
    () async => _lessonFromProto(
      await _client.updateLesson(
        study_proto.UpdateLessonRequest(
          lesson: _lessonToProto(lesson),
          expectedVersion: Int64(lesson.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.LessonV1> archiveLesson(domain.LessonV1 lesson) =>
      _changeLesson(lesson, _client.archiveLesson);

  @override
  Future<domain.LessonV1> restoreLesson(domain.LessonV1 lesson) =>
      _changeLesson(lesson, _client.restoreLesson);

  Future<domain.LessonV1> _changeLesson(
    domain.LessonV1 lesson,
    ResponseFuture<study_proto.Lesson> Function(
      study_proto.ChangeArchiveRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(
    () async => _lessonFromProto(
      await call(
        study_proto.ChangeArchiveRequest(
          id: lesson.id,
          expectedVersion: Int64(lesson.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.LessonV1> changeLessonStatus({
    required domain.LessonV1 lesson,
    required domain.LessonStatusV1 status,
    bool acknowledgeOpenHomework = false,
  }) => _write(
    () async => _lessonFromProto(
      await _client.changeLessonStatus(
        study_proto.ChangeLessonStatusRequest(
          id: lesson.id,
          status: _lessonStatusToProto(status),
          expectedVersion: Int64(lesson.version),
          acknowledgeOpenHomework: acknowledgeOpenHomework,
        ),
      ),
    ),
  );

  @override
  Future<domain.MaterialTreeV1> getMaterialTree(
    String studyId, {
    bool includeArchived = false,
  }) => _read(
    () async => _treeFromProto(
      await _client.getMaterialTree(
        study_proto.GetMaterialTreeRequest(
          studyId: studyId,
          includeArchived: includeArchived,
        ),
      ),
    ),
  );

  @override
  Future<domain.MaterialTreeV1> reorderMaterial({
    required String studyId,
    Iterable<domain.ReorderItemV1> source = const [],
    Iterable<domain.ReorderItemV1> section = const [],
    Iterable<domain.ReorderItemV1> lesson = const [],
  }) => _write(
    () async => _treeFromProto(
      await _client.reorderMaterial(
        study_proto.ReorderMaterialRequest(
          studyId: studyId,
          sources: source.map(_reorderToProto),
          sections: section.map(_reorderToProto),
          lessons: lesson.map(_reorderToProto),
        ),
      ),
    ),
  );

  @override
  Future<domain.StudyProgressV1> getDashboard(String studyId) => _read(
    () async => _dashboardFromProto(
      await _client.getDashboard(
        study_proto.GetDashboardRequest(studyId: studyId),
      ),
    ),
  );
}

@LazySingleton(as: domain.LessonContentRepositoryV1)
final class GrpcLessonContentRepositoryV1
    implements domain.LessonContentRepositoryV1 {
  final LessonContentServiceClient _client;

  const GrpcLessonContentRepositoryV1(this._client);

  @override
  Future<domain.LessonWorkspaceV1> getWorkspace(String lessonId) => _read(
    () async => _workspaceFromProto(
      await _client.getLessonWorkspace(
        content_proto.GetLessonWorkspaceRequest(lessonId: lessonId),
      ),
    ),
  );

  @override
  Future<domain.NoteBlockV1> createBlock(domain.NoteBlockV1 block) =>
      _createWrite(
        () async => _blockFromProto(
          await _client.createNoteBlock(
            content_proto.CreateNoteBlockRequest(block: _blockToProto(block)),
          ),
        ),
        () async {
          final workspace = await getWorkspace(block.lessonId);
          final stored = workspace.block
              .where((item) => item.id == block.id)
              .firstOrNull;
          if (stored == null) {
            return null;
          }
          if (stored.studyId != block.studyId ||
              stored.lessonId != block.lessonId ||
              stored.type != block.type ||
              stored.markdown != block.markdown ||
              stored.sourceUrl != block.sourceUrl ||
              stored.sourcePosition != block.sourcePosition ||
              stored.position != block.position) {
            throw domain.ConflictErrorV1('block/${block.id}');
          }
          return stored;
        },
      );

  @override
  Future<domain.NoteBlockV1> updateBlock(domain.NoteBlockV1 block) => _write(
    () async => _blockFromProto(
      await _client.updateNoteBlock(
        content_proto.UpdateNoteBlockRequest(
          block: _blockToProto(block),
          expectedVersion: Int64(block.version),
        ),
      ),
    ),
  );

  @override
  Future<void> deleteBlock(
    domain.NoteBlockV1 block, {
    required bool confirmed,
  }) => _delete(block.id, block.version, confirmed, _client.deleteNoteBlock);

  @override
  Future<domain.HomeworkTaskV1> createTask(domain.HomeworkTaskV1 task) =>
      _createWrite(
        () async => _taskFromProto(
          await _client.createHomeworkTask(
            content_proto.CreateHomeworkTaskRequest(task: _taskToProto(task)),
          ),
        ),
        () async {
          final workspace = await getWorkspace(task.lessonId);
          final stored = workspace.task
              .where((item) => item.id == task.id)
              .firstOrNull;
          if (stored == null) {
            return null;
          }
          if (stored.studyId != task.studyId ||
              stored.lessonId != task.lessonId ||
              stored.promptMarkdown != task.promptMarkdown ||
              stored.solutionMarkdown != task.solutionMarkdown ||
              stored.status != task.status ||
              stored.dueAt != task.dueAt ||
              stored.position != task.position) {
            throw domain.ConflictErrorV1('task/${task.id}');
          }
          return stored;
        },
      );

  @override
  Future<domain.HomeworkTaskV1> updateTask(domain.HomeworkTaskV1 task) =>
      _write(
        () async => _taskFromProto(
          await _client.updateHomeworkTask(
            content_proto.UpdateHomeworkTaskRequest(
              task: _taskToProto(task),
              expectedVersion: Int64(task.version),
            ),
          ),
        ),
      );

  @override
  Future<void> deleteTask(
    domain.HomeworkTaskV1 task, {
    required bool confirmed,
  }) => _delete(task.id, task.version, confirmed, _client.deleteHomeworkTask);

  @override
  Future<domain.CodeFileV1> createFile(domain.CodeFileV1 file) => _createWrite(
    () async => _fileFromProto(
      await _client.createCodeFile(
        content_proto.CreateCodeFileRequest(file: _fileToProto(file)),
      ),
    ),
    () async {
      final workspace = await getWorkspace(file.lessonId);
      final stored = workspace.file
          .where((item) => item.id == file.id)
          .firstOrNull;
      if (stored == null) {
        return null;
      }
      if (stored.studyId != file.studyId ||
          stored.lessonId != file.lessonId ||
          stored.homeworkTaskId != file.homeworkTaskId ||
          stored.relativePath != file.relativePath ||
          stored.language != file.language ||
          stored.content != file.content) {
        throw domain.ConflictErrorV1('file/${file.id}');
      }
      return stored;
    },
  );

  @override
  Future<domain.CodeFileV1> updateFile(domain.CodeFileV1 file) => _write(
    () async => _fileFromProto(
      await _client.updateCodeFile(
        content_proto.UpdateCodeFileRequest(
          file: _fileToProto(file),
          expectedVersion: Int64(file.version),
        ),
      ),
    ),
  );

  @override
  Future<void> deleteFile(domain.CodeFileV1 file, {required bool confirmed}) =>
      _delete(file.id, file.version, confirmed, _client.deleteCodeFile);

  Future<void> _delete(
    String id,
    int version,
    bool confirmed,
    ResponseFuture<content_proto.DeleteContentResponse> Function(
      content_proto.DeleteContentRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(() async {
    await call(
      content_proto.DeleteContentRequest(
        id: id,
        expectedVersion: Int64(version),
        confirmed: confirmed,
      ),
    );
  });

  @override
  Future<domain.LessonWorkspaceV1> reorderContent({
    required String lessonId,
    Iterable<domain.ReorderItemV1> block = const [],
    Iterable<domain.ReorderItemV1> task = const [],
  }) => _write(
    () async => _workspaceFromProto(
      await _client.reorderLessonContent(
        content_proto.ReorderLessonContentRequest(
          lessonId: lessonId,
          blocks: block.map(_reorderToProto),
          tasks: task.map(_reorderToProto),
        ),
      ),
    ),
  );
}

@LazySingleton(as: domain.KnowledgeRepositoryV1)
final class GrpcKnowledgeRepositoryV1 implements domain.KnowledgeRepositoryV1 {
  final KnowledgeServiceClient _client;

  const GrpcKnowledgeRepositoryV1(this._client);

  @override
  Future<domain.ConceptV1> createConcept(domain.ConceptV1 concept) =>
      _createWrite(
        () async => _conceptFromProto(
          await _client.createConcept(
            knowledge_proto.CreateConceptRequest(
              concept: _conceptToProto(concept),
            ),
          ),
        ),
        () async {
          final stored = (await searchConcepts(
            concept.studyId,
            concept.title,
            includeArchived: true,
            limit: 100,
          )).where((item) => item.id == concept.id).firstOrNull;
          if (stored == null) {
            return null;
          }
          if (stored.studyId != concept.studyId ||
              stored.title != concept.title ||
              stored.descriptionMarkdown != concept.descriptionMarkdown ||
              stored.exportSlug != concept.exportSlug ||
              stored.aliases
                  .toSet()
                  .difference(concept.aliases.toSet())
                  .isNotEmpty ||
              concept.aliases
                  .toSet()
                  .difference(stored.aliases.toSet())
                  .isNotEmpty) {
            throw domain.ConflictErrorV1('concept/${concept.id}');
          }
          return stored;
        },
      );

  @override
  Future<domain.ConceptV1> updateConcept(domain.ConceptV1 concept) => _write(
    () async => _conceptFromProto(
      await _client.updateConcept(
        knowledge_proto.UpdateConceptRequest(
          concept: _conceptToProto(concept),
          expectedVersion: Int64(concept.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.ConceptV1> archiveConcept(domain.ConceptV1 concept) =>
      _changeConcept(concept, _client.archiveConcept);

  @override
  Future<domain.ConceptV1> restoreConcept(domain.ConceptV1 concept) =>
      _changeConcept(concept, _client.restoreConcept);

  Future<domain.ConceptV1> _changeConcept(
    domain.ConceptV1 concept,
    ResponseFuture<knowledge_proto.Concept> Function(
      study_proto.ChangeArchiveRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(
    () async => _conceptFromProto(
      await call(
        study_proto.ChangeArchiveRequest(
          id: concept.id,
          expectedVersion: Int64(concept.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.ConceptV1> addAlias(domain.ConceptV1 concept, String alias) =>
      _alias(concept, alias, _client.addConceptAlias);

  @override
  Future<domain.ConceptV1> removeAlias(
    domain.ConceptV1 concept,
    String alias,
  ) => _alias(concept, alias, _client.removeConceptAlias);

  Future<domain.ConceptV1> _alias(
    domain.ConceptV1 concept,
    String alias,
    ResponseFuture<knowledge_proto.Concept> Function(
      knowledge_proto.ChangeConceptAliasRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(
    () async => _conceptFromProto(
      await call(
        knowledge_proto.ChangeConceptAliasRequest(
          conceptId: concept.id,
          alias: alias,
          expectedVersion: Int64(concept.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.ConceptV1> linkBlock(
    domain.ConceptV1 concept,
    String blockId,
  ) => _blockLink(concept, blockId, _client.linkBlockConcept);

  @override
  Future<domain.ConceptV1> unlinkBlock(
    domain.ConceptV1 concept,
    String blockId,
  ) => _blockLink(concept, blockId, _client.unlinkBlockConcept);

  Future<domain.ConceptV1> _blockLink(
    domain.ConceptV1 concept,
    String blockId,
    ResponseFuture<knowledge_proto.Concept> Function(
      knowledge_proto.ChangeBlockConceptRequest, {
      CallOptions? options,
    })
    call,
  ) => _write(
    () async => _conceptFromProto(
      await call(
        knowledge_proto.ChangeBlockConceptRequest(
          conceptId: concept.id,
          blockId: blockId,
          expectedVersion: Int64(concept.version),
        ),
      ),
    ),
  );

  @override
  Future<domain.ConceptRelationV1> putRelation(
    domain.ConceptRelationV1 relation,
  ) => _createWrite(
    () async => _relationFromProto(
      await _client.putConceptRelation(
        knowledge_proto.PutConceptRelationRequest(
          relation: _relationToProto(relation),
        ),
      ),
    ),
    () async {
      final graph = await getGraph(relation.studyId);
      final stored = graph.relation
          .where((item) => item.id == relation.id)
          .firstOrNull;
      if (stored == null) {
        return null;
      }
      if (stored.studyId != relation.studyId ||
          stored.sourceConceptId != relation.sourceConceptId ||
          stored.targetConceptId != relation.targetConceptId ||
          stored.type != relation.type) {
        throw domain.ConflictErrorV1('relation/${relation.id}');
      }
      return stored;
    },
  );

  @override
  Future<void> deleteRelation(
    domain.ConceptRelationV1 relation, {
    required bool confirmed,
  }) => _write(() async {
    await _client.deleteConceptRelation(
      knowledge_proto.DeleteConceptRelationRequest(
        id: relation.id,
        expectedVersion: Int64(relation.version),
        confirmed: confirmed,
      ),
    );
  });

  @override
  Future<List<domain.ConceptV1>> searchConcepts(
    String studyId,
    String query, {
    bool includeArchived = false,
    int limit = 50,
  }) => _read(
    () async => (await _client.searchConcepts(
      knowledge_proto.SearchConceptsRequest(
        studyId: studyId,
        query: query,
        includeArchived: includeArchived,
        limit: limit,
      ),
    )).concepts.map(_conceptFromProto).toList(growable: false),
  );

  @override
  Future<domain.ConceptGraphV1> getGraph(
    String studyId, {
    String? selectedConceptId,
  }) => _read(() async {
    final value = await _client.getConceptGraph(
      knowledge_proto.GetConceptGraphRequest(
        studyId: studyId,
        selectedConceptId: selectedConceptId,
      ),
    );
    return domain.ConceptGraphV1(
      concept: value.concepts.map(_conceptFromProto),
      relation: value.relations.map(_relationFromProto),
      isTruncated: value.truncated,
    );
  });
}

@lazySingleton
final class GrpcExportGatewayV1 {
  final ExportServiceClient _client;

  const GrpcExportGatewayV1(this._client);

  Future<domain.ExportSnapshotV1> render(
    String studyId, {
    int? expectedContentRevision,
  }) => _read(() async {
    final request = export_proto.RenderStudyExportRequest(
      studyId: studyId,
      expectedContentRevision: expectedContentRevision == null
          ? null
          : Int64(expectedContentRevision),
    );
    export_proto.ExportHeader? header;
    final files = <domain.ExportFileV1>[];
    await for (final chunk in _client.renderStudyExport(request)) {
      switch (chunk.whichValue()) {
        case export_proto.ExportChunk_Value.header:
          header = chunk.header;
        case export_proto.ExportChunk_Value.file:
          files.add(
            domain.ExportFileV1(
              path: chunk.file.path,
              content: chunk.file.content,
              sha256: chunk.file.sha256,
            ),
          );
        case export_proto.ExportChunk_Value.notSet:
          throw const domain.UnexpectedErrorV1();
      }
    }
    final value = header;
    if (value == null || value.studyId != studyId) {
      throw const domain.UnexpectedErrorV1();
    }
    return domain.ExportSnapshotV1(
      studyId: value.studyId,
      studyRevision: value.studyRevision.toInt(),
      file: files,
    );
  });
}

domain.StudyV1 _studyFromProto(study_proto.Study value) => domain.StudyV1(
  id: value.id,
  title: value.title,
  goal: value.goal,
  localRepositoryPath: value.localRepositoryPath,
  version: value.version.toInt(),
  contentRevision: value.contentRevision.toInt(),
  isArchived: value.archived,
);

domain.LearningSourceV1 _sourceFromProto(study_proto.LearningSource value) =>
    domain.LearningSourceV1(
      id: value.id,
      studyId: value.studyId,
      type: _sourceTypeFromProto(value.type),
      title: value.title,
      author: value.author,
      url: value.url,
      exportSlug: value.exportSlug,
      position: value.position,
      version: value.version.toInt(),
      isArchived: value.archived,
    );

study_proto.LearningSource _sourceToProto(domain.LearningSourceV1 value) =>
    study_proto.LearningSource(
      id: value.id,
      studyId: value.studyId,
      type: _sourceTypeToProto(value.type),
      title: value.title,
      author: value.author,
      url: value.url,
      exportSlug: value.exportSlug,
      position: value.position,
      version: Int64(value.version),
      archived: value.isArchived,
    );

domain.SectionV1 _sectionFromProto(study_proto.Section value) =>
    domain.SectionV1(
      id: value.id,
      studyId: value.studyId,
      sourceId: value.sourceId,
      title: value.title,
      position: value.position,
      version: value.version.toInt(),
      isArchived: value.archived,
    );

study_proto.Section _sectionToProto(domain.SectionV1 value) =>
    study_proto.Section(
      id: value.id,
      studyId: value.studyId,
      sourceId: value.sourceId,
      title: value.title,
      position: value.position,
      version: Int64(value.version),
      archived: value.isArchived,
    );

domain.LessonV1 _lessonFromProto(study_proto.Lesson value) => domain.LessonV1(
  id: value.id,
  studyId: value.studyId,
  sourceId: value.sourceId,
  sectionId: value.hasSectionId() ? value.sectionId : null,
  title: value.title,
  url: value.url,
  sourcePosition: value.sourcePosition,
  exportSlug: value.exportSlug,
  position: value.position,
  status: _lessonStatusFromProto(value.status),
  startedAt: value.hasStartedAtEpochMillis()
      ? DateTime.fromMillisecondsSinceEpoch(
          value.startedAtEpochMillis.toInt(),
          isUtc: true,
        )
      : null,
  masteredAt: value.hasMasteredAtEpochMillis()
      ? DateTime.fromMillisecondsSinceEpoch(
          value.masteredAtEpochMillis.toInt(),
          isUtc: true,
        )
      : null,
  version: value.version.toInt(),
  isArchived: value.archived,
);

study_proto.Lesson _lessonToProto(domain.LessonV1 value) => study_proto.Lesson(
  id: value.id,
  studyId: value.studyId,
  sourceId: value.sourceId,
  sectionId: value.sectionId,
  title: value.title,
  url: value.url,
  sourcePosition: value.sourcePosition,
  exportSlug: value.exportSlug,
  position: value.position,
  status: _lessonStatusToProto(value.status),
  startedAtEpochMillis: value.startedAt == null
      ? null
      : Int64(value.startedAt!.millisecondsSinceEpoch),
  masteredAtEpochMillis: value.masteredAt == null
      ? null
      : Int64(value.masteredAt!.millisecondsSinceEpoch),
  version: Int64(value.version),
  archived: value.isArchived,
);

domain.MaterialTreeV1 _treeFromProto(study_proto.MaterialTree value) =>
    domain.MaterialTreeV1(
      study: _studyFromProto(value.study),
      source: value.sources.map(
        (node) => domain.LearningSourceNodeV1(
          source: _sourceFromProto(node.source),
          section: node.sections.map(_sectionFromProto),
          lesson: node.lessons.map(_lessonFromProto),
        ),
      ),
    );

domain.StudyProgressV1 _dashboardFromProto(study_proto.Dashboard value) =>
    domain.StudyProgressV1(
      material: domain.ProgressIndicatorV1(
        completed: value.material.completed,
        total: value.material.total,
      ),
      homework: domain.ProgressIndicatorV1(
        completed: value.homework.completed,
        total: value.homework.total,
      ),
      lessonStatusCount: {
        for (final count in value.lessonStatuses)
          _lessonStatusFromProto(count.status).name: count.count,
      },
      studyRevision: value.studyRevision.toInt(),
    );

study_proto.ReorderItem _reorderToProto(domain.ReorderItemV1 value) =>
    study_proto.ReorderItem(
      id: value.id,
      position: value.position,
      expectedVersion: Int64(value.expectedVersion),
    );

domain.LessonWorkspaceV1 _workspaceFromProto(
  content_proto.LessonWorkspace value,
) => domain.LessonWorkspaceV1(
  lesson: _lessonFromProto(value.lesson),
  block: value.blocks.map(_blockFromProto),
  task: value.tasks.map(_taskFromProto),
  file: value.files.map(_fileFromProto),
  conceptId: value.conceptIds,
);

domain.NoteBlockV1 _blockFromProto(content_proto.NoteBlock value) =>
    domain.NoteBlockV1(
      id: value.id,
      studyId: value.studyId,
      lessonId: value.lessonId,
      type: _blockTypeFromProto(value.type),
      markdown: value.markdown,
      sourceUrl: value.sourceUrl,
      sourcePosition: value.sourcePosition,
      position: value.position,
      version: value.version.toInt(),
    );

content_proto.NoteBlock _blockToProto(domain.NoteBlockV1 value) =>
    content_proto.NoteBlock(
      id: value.id,
      studyId: value.studyId,
      lessonId: value.lessonId,
      type: _blockTypeToProto(value.type),
      markdown: value.markdown,
      sourceUrl: value.sourceUrl,
      sourcePosition: value.sourcePosition,
      position: value.position,
      version: Int64(value.version),
    );

domain.HomeworkTaskV1 _taskFromProto(content_proto.HomeworkTask value) =>
    domain.HomeworkTaskV1(
      id: value.id,
      studyId: value.studyId,
      lessonId: value.lessonId,
      promptMarkdown: value.promptMarkdown,
      solutionMarkdown: value.solutionMarkdown,
      status: _homeworkStatusFromProto(value.status),
      dueAt: value.hasDueAtEpochMillis()
          ? DateTime.fromMillisecondsSinceEpoch(
              value.dueAtEpochMillis.toInt(),
              isUtc: true,
            )
          : null,
      position: value.position,
      version: value.version.toInt(),
    );

content_proto.HomeworkTask _taskToProto(domain.HomeworkTaskV1 value) =>
    content_proto.HomeworkTask(
      id: value.id,
      studyId: value.studyId,
      lessonId: value.lessonId,
      promptMarkdown: value.promptMarkdown,
      solutionMarkdown: value.solutionMarkdown,
      status: _homeworkStatusToProto(value.status),
      dueAtEpochMillis: value.dueAt == null
          ? null
          : Int64(value.dueAt!.millisecondsSinceEpoch),
      position: value.position,
      version: Int64(value.version),
    );

domain.CodeFileV1 _fileFromProto(content_proto.CodeFile value) =>
    domain.CodeFileV1(
      id: value.id,
      studyId: value.studyId,
      lessonId: value.lessonId,
      homeworkTaskId: value.hasHomeworkTaskId() ? value.homeworkTaskId : null,
      relativePath: value.relativePath,
      language: value.language,
      content: value.content,
      version: value.version.toInt(),
    );

content_proto.CodeFile _fileToProto(domain.CodeFileV1 value) =>
    content_proto.CodeFile(
      id: value.id,
      studyId: value.studyId,
      lessonId: value.lessonId,
      homeworkTaskId: value.homeworkTaskId,
      relativePath: value.relativePath,
      language: value.language,
      content: value.content,
      version: Int64(value.version),
    );

domain.ConceptV1 _conceptFromProto(knowledge_proto.Concept value) =>
    domain.ConceptV1(
      id: value.id,
      studyId: value.studyId,
      title: value.title,
      descriptionMarkdown: value.descriptionMarkdown,
      exportSlug: value.exportSlug,
      aliases: value.aliases,
      blockIds: value.blockIds,
      version: value.version.toInt(),
      isArchived: value.archived,
    );

knowledge_proto.Concept _conceptToProto(domain.ConceptV1 value) =>
    knowledge_proto.Concept(
      id: value.id,
      studyId: value.studyId,
      title: value.title,
      descriptionMarkdown: value.descriptionMarkdown,
      exportSlug: value.exportSlug,
      aliases: value.aliases,
      blockIds: value.blockIds,
      version: Int64(value.version),
      archived: value.isArchived,
    );

domain.ConceptRelationV1 _relationFromProto(
  knowledge_proto.ConceptRelation value,
) => domain.ConceptRelationV1(
  id: value.id,
  studyId: value.studyId,
  sourceConceptId: value.sourceConceptId,
  targetConceptId: value.targetConceptId,
  type: _relationTypeFromProto(value.type),
  version: value.version.toInt(),
);

knowledge_proto.ConceptRelation _relationToProto(
  domain.ConceptRelationV1 value,
) => knowledge_proto.ConceptRelation(
  id: value.id,
  studyId: value.studyId,
  sourceConceptId: value.sourceConceptId,
  targetConceptId: value.targetConceptId,
  type: _relationTypeToProto(value.type),
  version: Int64(value.version),
);

study_proto.LearningSourceType _sourceTypeToProto(
  domain.LearningSourceTypeV1 value,
) => switch (value) {
  domain.LearningSourceTypeV1.course =>
    study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_COURSE,
  domain.LearningSourceTypeV1.book =>
    study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_BOOK,
  domain.LearningSourceTypeV1.article =>
    study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_ARTICLE,
  domain.LearningSourceTypeV1.video =>
    study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_VIDEO,
  domain.LearningSourceTypeV1.other =>
    study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_OTHER,
};

domain.LearningSourceTypeV1 _sourceTypeFromProto(
  study_proto.LearningSourceType value,
) => switch (value) {
  study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_COURSE =>
    domain.LearningSourceTypeV1.course,
  study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_BOOK =>
    domain.LearningSourceTypeV1.book,
  study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_ARTICLE =>
    domain.LearningSourceTypeV1.article,
  study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_VIDEO =>
    domain.LearningSourceTypeV1.video,
  study_proto.LearningSourceType.LEARNING_SOURCE_TYPE_OTHER =>
    domain.LearningSourceTypeV1.other,
  _ => throw const domain.UnexpectedErrorV1(),
};

study_proto.LessonStatus _lessonStatusToProto(domain.LessonStatusV1 value) =>
    switch (value) {
      domain.LessonStatusV1.planned =>
        study_proto.LessonStatus.LESSON_STATUS_PLANNED,
      domain.LessonStatusV1.studying =>
        study_proto.LessonStatus.LESSON_STATUS_STUDYING,
      domain.LessonStatusV1.homework =>
        study_proto.LessonStatus.LESSON_STATUS_HOMEWORK,
      domain.LessonStatusV1.mastered =>
        study_proto.LessonStatus.LESSON_STATUS_MASTERED,
    };

domain.LessonStatusV1 _lessonStatusFromProto(study_proto.LessonStatus value) =>
    switch (value) {
      study_proto.LessonStatus.LESSON_STATUS_PLANNED =>
        domain.LessonStatusV1.planned,
      study_proto.LessonStatus.LESSON_STATUS_STUDYING =>
        domain.LessonStatusV1.studying,
      study_proto.LessonStatus.LESSON_STATUS_HOMEWORK =>
        domain.LessonStatusV1.homework,
      study_proto.LessonStatus.LESSON_STATUS_MASTERED =>
        domain.LessonStatusV1.mastered,
      _ => throw const domain.UnexpectedErrorV1(),
    };

content_proto.NoteBlockType _blockTypeToProto(domain.NoteBlockTypeV1 value) =>
    switch (value) {
      domain.NoteBlockTypeV1.text =>
        content_proto.NoteBlockType.NOTE_BLOCK_TYPE_TEXT,
      domain.NoteBlockTypeV1.definition =>
        content_proto.NoteBlockType.NOTE_BLOCK_TYPE_DEFINITION,
      domain.NoteBlockTypeV1.claim =>
        content_proto.NoteBlockType.NOTE_BLOCK_TYPE_CLAIM,
      domain.NoteBlockTypeV1.quote =>
        content_proto.NoteBlockType.NOTE_BLOCK_TYPE_QUOTE,
      domain.NoteBlockTypeV1.example =>
        content_proto.NoteBlockType.NOTE_BLOCK_TYPE_EXAMPLE,
      domain.NoteBlockTypeV1.question =>
        content_proto.NoteBlockType.NOTE_BLOCK_TYPE_QUESTION,
      domain.NoteBlockTypeV1.summary =>
        content_proto.NoteBlockType.NOTE_BLOCK_TYPE_SUMMARY,
    };

domain.NoteBlockTypeV1 _blockTypeFromProto(content_proto.NoteBlockType value) =>
    switch (value) {
      content_proto.NoteBlockType.NOTE_BLOCK_TYPE_TEXT =>
        domain.NoteBlockTypeV1.text,
      content_proto.NoteBlockType.NOTE_BLOCK_TYPE_DEFINITION =>
        domain.NoteBlockTypeV1.definition,
      content_proto.NoteBlockType.NOTE_BLOCK_TYPE_CLAIM =>
        domain.NoteBlockTypeV1.claim,
      content_proto.NoteBlockType.NOTE_BLOCK_TYPE_QUOTE =>
        domain.NoteBlockTypeV1.quote,
      content_proto.NoteBlockType.NOTE_BLOCK_TYPE_EXAMPLE =>
        domain.NoteBlockTypeV1.example,
      content_proto.NoteBlockType.NOTE_BLOCK_TYPE_QUESTION =>
        domain.NoteBlockTypeV1.question,
      content_proto.NoteBlockType.NOTE_BLOCK_TYPE_SUMMARY =>
        domain.NoteBlockTypeV1.summary,
      _ => throw const domain.UnexpectedErrorV1(),
    };

content_proto.HomeworkStatus _homeworkStatusToProto(
  domain.HomeworkStatusV1 value,
) => switch (value) {
  domain.HomeworkStatusV1.todo =>
    content_proto.HomeworkStatus.HOMEWORK_STATUS_TODO,
  domain.HomeworkStatusV1.done =>
    content_proto.HomeworkStatus.HOMEWORK_STATUS_DONE,
};

domain.HomeworkStatusV1 _homeworkStatusFromProto(
  content_proto.HomeworkStatus value,
) => switch (value) {
  content_proto.HomeworkStatus.HOMEWORK_STATUS_TODO =>
    domain.HomeworkStatusV1.todo,
  content_proto.HomeworkStatus.HOMEWORK_STATUS_DONE =>
    domain.HomeworkStatusV1.done,
  _ => throw const domain.UnexpectedErrorV1(),
};

knowledge_proto.ConceptRelationType _relationTypeToProto(
  domain.ConceptRelationTypeV1 value,
) => switch (value) {
  domain.ConceptRelationTypeV1.relatedTo =>
    knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_RELATED_TO,
  domain.ConceptRelationTypeV1.partOf =>
    knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_PART_OF,
  domain.ConceptRelationTypeV1.prerequisiteFor =>
    knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_PREREQUISITE_FOR,
  domain.ConceptRelationTypeV1.contrastsWith =>
    knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_CONTRASTS_WITH,
  domain.ConceptRelationTypeV1.appliesTo =>
    knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_APPLIES_TO,
};

domain.ConceptRelationTypeV1 _relationTypeFromProto(
  knowledge_proto.ConceptRelationType value,
) => switch (value) {
  knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_RELATED_TO =>
    domain.ConceptRelationTypeV1.relatedTo,
  knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_PART_OF =>
    domain.ConceptRelationTypeV1.partOf,
  knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_PREREQUISITE_FOR =>
    domain.ConceptRelationTypeV1.prerequisiteFor,
  knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_CONTRASTS_WITH =>
    domain.ConceptRelationTypeV1.contrastsWith,
  knowledge_proto.ConceptRelationType.CONCEPT_RELATION_TYPE_APPLIES_TO =>
    domain.ConceptRelationTypeV1.appliesTo,
  _ => throw const domain.UnexpectedErrorV1(),
};
