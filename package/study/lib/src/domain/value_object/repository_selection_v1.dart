import 'package:equatable/equatable.dart';

final class RepositorySelectionV1 extends Equatable {
  final String? path;

  const RepositorySelectionV1._(this.path);

  const RepositorySelectionV1.cancelled() : this._(null);

  factory RepositorySelectionV1.selected({required String path}) {
    if (path.isEmpty) return const RepositorySelectionV1.cancelled();
    return RepositorySelectionV1._(path);
  }

  bool get isSelected => path != null;

  RepositorySelectionV1 copyWith({String? Function()? path}) {
    if (path == null) return this;
    final value = path();
    return value == null
        ? const RepositorySelectionV1.cancelled()
        : RepositorySelectionV1.selected(path: value);
  }

  @override
  List<Object?> get props => [path];

  @override
  String toString() => 'RepositorySelectionV1(isSelected: $isSelected)';

  String toDebugString() =>
      'RepositorySelectionV1(path: <redacted>, isSelected: $isSelected)';
}
