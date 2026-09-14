import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ConceptAliasV1 extends Equatable {
  final String value;

  const ConceptAliasV1._(this.value);

  factory ConceptAliasV1({required String value}) {
    final normalized = value.trim();
    if (normalized.isEmpty ||
        normalized.runes.length > StudyConstV1.maxTitleLength) {
      throw const ValidationErrorV1('alias');
    }
    return ConceptAliasV1._(normalized);
  }

  ConceptAliasV1 copyWith({String? value}) =>
      ConceptAliasV1(value: value ?? this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'ConceptAliasV1(length: ${value.length})';

  String toDebugString() =>
      'ConceptAliasV1(value: <redacted>, length: ${value.length})';
}
