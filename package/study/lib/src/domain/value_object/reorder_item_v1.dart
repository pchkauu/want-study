import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ReorderItemV1 extends Equatable {
  final String id;
  final int position;
  final int expectedVersion;

  const ReorderItemV1._({
    required this.id,
    required this.position,
    required this.expectedVersion,
  });

  factory ReorderItemV1({
    required String id,
    required int position,
    required int expectedVersion,
  }) {
    if (position < 0) throw const ValidationErrorV1('position');
    if (expectedVersion < 1) {
      throw const ValidationErrorV1('expectedVersion');
    }
    return ReorderItemV1._(
      id: id,
      position: position,
      expectedVersion: expectedVersion,
    );
  }

  ReorderItemV1 copyWith({String? id, int? position, int? expectedVersion}) =>
      ReorderItemV1(
        id: id ?? this.id,
        position: position ?? this.position,
        expectedVersion: expectedVersion ?? this.expectedVersion,
      );

  @override
  List<Object?> get props => [id, position, expectedVersion];

  @override
  String toString() =>
      'ReorderItemV1(id: $id, position: $position, '
      'expectedVersion: $expectedVersion)';

  String toDebugString() => toString();
}
