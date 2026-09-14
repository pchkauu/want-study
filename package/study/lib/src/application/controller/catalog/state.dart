part of 'controller.dart';

enum CatalogLoadStateV2 { initial, loading, ready, failed }

final class CatalogStateV2 extends Equatable {
  final CatalogLoadStateV2 loadState;
  final List<StudyV1> study;
  final StudyV1? selectedStudy;
  final MaterialTreeV1? tree;
  final StudyProgressV1? progress;
  final StudyFailureKindV1? failure;

  CatalogStateV2({
    this.loadState = CatalogLoadStateV2.initial,
    Iterable<StudyV1> study = const [],
    this.selectedStudy,
    this.tree,
    this.progress,
    this.failure,
  }) : study = List.unmodifiable(study);

  String? get selectedStudyId => selectedStudy?.id;

  CatalogStateV2 copyWith({
    CatalogLoadStateV2? loadState,
    Iterable<StudyV1>? study,
    StudyV1? Function()? selectedStudy,
    MaterialTreeV1? Function()? tree,
    StudyProgressV1? Function()? progress,
    StudyFailureKindV1? Function()? failure,
  }) => CatalogStateV2(
    loadState: loadState ?? this.loadState,
    study: study ?? this.study,
    selectedStudy: selectedStudy == null ? this.selectedStudy : selectedStudy(),
    tree: tree == null ? this.tree : tree(),
    progress: progress == null ? this.progress : progress(),
    failure: failure == null ? this.failure : failure(),
  );

  @override
  List<Object?> get props => [
    loadState,
    [for (final value in study) (value.id, _studyEventHash(value))],
    selectedStudy?.id,
    tree,
    progress,
    failure,
  ];
}
