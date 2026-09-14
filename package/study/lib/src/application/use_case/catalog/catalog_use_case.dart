import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:study/src/application/service/_barrel.dart';
import 'package:study/src/application/use_case/catalog/contract/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

@lazySingleton
final class CatalogUseCase {
  final StudyRepositoryV2 _repository;
  final RepositoryPickerService _repositoryPicker;
  final StudyUseCaseExecutor _executor;

  const CatalogUseCase(
    this._repository,
    this._repositoryPicker,
    this._executor,
  );

  FutureResult<CatalogSnapshotV1> loadV1({
    required CatalogLoadParamsV1 params,
  }) {
    const op = 'CatalogUseCase.loadV1():';
    return _executor.call(
      operation: op,
      body: () => _load(preferredStudy: params.preferredStudy),
    );
  }

  FutureResult<CatalogSnapshotV1> mutateV1({
    required CatalogMutationParamsV1 params,
  }) {
    const op = 'CatalogUseCase.mutateV1():';
    return _executor.call(operation: op, body: () => _mutate(params));
  }

  FutureResult<RepositorySelectionV1> pickRepositoryV1({
    required CatalogPickRepositoryParamsV1 params,
  }) {
    const op = 'CatalogUseCase.pickRepositoryV1():';
    return _executor.call(
      operation: op,
      body: () async {
        final result = await _repositoryPicker.pickRepository();
        return result.fold((error) => throw error, (selection) => selection);
      },
    );
  }

  Future<CatalogSnapshotV1> _mutate(CatalogMutationParamsV1 params) async {
    var preferredStudy = params.selectedStudy;
    switch (params.mutation) {
      case CatalogCreateStudyV1(:final study):
        preferredStudy = await _repository.createStudy(study);
      case CatalogUpdateStudyV1(:final study):
        preferredStudy = await _repository.updateStudy(study);
      case CatalogArchiveStudyV1(:final study):
        preferredStudy = study.isArchived
            ? await _repository.restoreStudy(study)
            : await _repository.archiveStudy(study);
      case CatalogCreateSourceV1(:final source):
        await _repository.createSource(source);
      case CatalogUpdateSourceV1(:final source):
        await _repository.updateSource(source);
      case CatalogArchiveSourceV1(:final source):
        source.isArchived
            ? await _repository.restoreSource(source)
            : await _repository.archiveSource(source);
      case CatalogCreateSectionV1(:final section):
        await _repository.createSection(section);
      case CatalogUpdateSectionV1(:final section):
        await _repository.updateSection(section);
      case CatalogArchiveSectionV1(:final section):
        section.isArchived
            ? await _repository.restoreSection(section)
            : await _repository.archiveSection(section);
      case CatalogCreateLessonV1(:final lesson):
        await _repository.createLesson(lesson);
      case CatalogUpdateLessonV1(:final lesson):
        await _repository.updateLesson(lesson);
      case CatalogArchiveLessonV1(:final lesson):
        lesson.isArchived
            ? await _repository.restoreLesson(lesson)
            : await _repository.archiveLesson(lesson);
      case CatalogChangeLessonStatusV1(:final change):
        await _repository.changeLessonStatus(change);
      case CatalogReorderMaterialV1(
        :final study,
        :final source,
        :final section,
        :final lesson,
      ):
        await _repository.reorderMaterial(
          study: study,
          source: source,
          section: section,
          lesson: lesson,
        );
    }
    return _load(preferredStudy: preferredStudy);
  }

  Future<CatalogSnapshotV1> _load({StudyV1? preferredStudy}) async {
    final studies = await _repository.listStudies(
      scope: ArchiveScopeV1.includeArchived,
    );
    if (studies.isEmpty) return CatalogSnapshotV1();
    final selected = studies.firstWhere(
      (study) => study.id == preferredStudy?.id,
      orElse: () => studies.first,
    );
    final tree = await _repository.getMaterialTree(
      study: selected,
      scope: ArchiveScopeV1.includeArchived,
    );
    final progress = await _repository.getDashboard(selected);
    return CatalogSnapshotV1(
      study: studies,
      selectedStudy: selected,
      tree: tree,
      progress: progress,
    );
  }
}
