import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ProgressIndicatorV1 extends Equatable {
  final int completed;
  final int total;

  const ProgressIndicatorV1._({required this.completed, required this.total});

  factory ProgressIndicatorV1({required int completed, required int total}) {
    if (completed < 0 || total < 0 || completed > total) {
      throw const ValidationErrorV1('progress');
    }
    return ProgressIndicatorV1._(completed: completed, total: total);
  }

  double get fraction => total == 0 ? 0 : completed / total;

  ProgressIndicatorV1 copyWith({int? completed, int? total}) =>
      ProgressIndicatorV1(
        completed: completed ?? this.completed,
        total: total ?? this.total,
      );

  @override
  List<Object?> get props => [completed, total];

  @override
  String toString() =>
      'ProgressIndicatorV1(completed: $completed, total: $total)';

  String toDebugString() => toString();
}
