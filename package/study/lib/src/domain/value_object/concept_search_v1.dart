import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ConceptSearchV1 extends Equatable {
  final String query;
  final ArchiveScopeV1 archiveScope;
  final int limit;

  const ConceptSearchV1._({
    required this.query,
    required this.archiveScope,
    required this.limit,
  });

  factory ConceptSearchV1({
    String query = '',
    ArchiveScopeV1 archiveScope = ArchiveScopeV1.activeOnly,
    int limit = 50,
  }) {
    if (limit < StudyConstV1.minConceptSearchLimit ||
        limit > StudyConstV1.maxConceptSearchLimit) {
      throw const ValidationErrorV1('limit');
    }
    return ConceptSearchV1._(
      query: query.trim(),
      archiveScope: archiveScope,
      limit: limit,
    );
  }

  ConceptSearchV1 copyWith({
    String? query,
    ArchiveScopeV1? archiveScope,
    int? limit,
  }) => ConceptSearchV1(
    query: query ?? this.query,
    archiveScope: archiveScope ?? this.archiveScope,
    limit: limit ?? this.limit,
  );

  @override
  List<Object?> get props => [query, archiveScope, limit];

  @override
  String toString() =>
      'ConceptSearchV1(queryLength: ${query.length}, '
      'archiveScope: $archiveScope, limit: $limit)';

  String toDebugString() =>
      'ConceptSearchV1(query: <redacted>, queryLength: ${query.length}, '
      'archiveScope: $archiveScope, limit: $limit)';
}
