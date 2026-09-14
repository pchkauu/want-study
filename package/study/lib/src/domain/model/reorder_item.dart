import 'package:equatable/equatable.dart';
import 'package:study/src/domain/model/validation.dart';

final class ReorderItemV1 extends Equatable {
  final String id;
  final int position;
  final int expectedVersion;

  ReorderItemV1({
    required this.id,
    required int position,
    required int expectedVersion,
  }) : position = StudyValidationV1.position('position', position),
       expectedVersion = StudyValidationV1.version(
         'expectedVersion',
         expectedVersion,
       );

  @override
  List<Object?> get props => [id, position, expectedVersion];
}
