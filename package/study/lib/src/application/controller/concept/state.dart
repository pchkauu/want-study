part of 'controller.dart';

enum ConceptLoadStateV1 { initial, loading, ready, failed }

final class ConceptStateV1 extends Equatable {
  final ConceptLoadStateV1 loadState;
  final StudyV1? study;
  final ConceptGraphV1? graph;
  final ConceptV1? selectedConcept;
  final ConceptSearchV1 search;
  final List<ConceptV1> searchResult;
  final StudyFailureKindV1? failure;

  ConceptStateV1({
    this.loadState = ConceptLoadStateV1.initial,
    this.study,
    this.graph,
    this.selectedConcept,
    ConceptSearchV1? search,
    Iterable<ConceptV1> searchResult = const [],
    this.failure,
  }) : search =
           search ??
           ConceptSearchV1(archiveScope: ArchiveScopeV1.includeArchived),
       searchResult = List.unmodifiable(searchResult);

  ConceptStateV1 copyWith({
    ConceptLoadStateV1? loadState,
    StudyV1? Function()? study,
    ConceptGraphV1? Function()? graph,
    ConceptV1? Function()? selectedConcept,
    ConceptSearchV1? search,
    Iterable<ConceptV1>? searchResult,
    StudyFailureKindV1? Function()? failure,
  }) => ConceptStateV1(
    loadState: loadState ?? this.loadState,
    study: study == null ? this.study : study(),
    graph: graph == null ? this.graph : graph(),
    selectedConcept: selectedConcept == null
        ? this.selectedConcept
        : selectedConcept(),
    search: search ?? this.search,
    searchResult: List.unmodifiable(searchResult ?? this.searchResult),
    failure: failure == null ? this.failure : failure(),
  );

  @override
  List<Object?> get props => [
    loadState,
    study?.id,
    graph,
    selectedConcept?.id,
    search,
    [for (final value in searchResult) (value.id, value.version)],
    failure,
  ];
}
