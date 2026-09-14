import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class ExportFileV1 extends Equatable {
  final String path;
  final List<int> content;
  final String sha256;

  const ExportFileV1._({
    required this.path,
    required this.content,
    required this.sha256,
  });

  factory ExportFileV1({
    required String path,
    required Iterable<int> content,
    required String sha256,
  }) {
    final bytes = List<int>.unmodifiable(content);
    if (path.trim().isEmpty || path.contains('\u0000')) {
      throw const ValidationErrorV1('path');
    }
    if (bytes.any((value) => value < 0 || value > 255)) {
      throw const ValidationErrorV1('content');
    }
    if (sha256.trim().isEmpty) throw const ValidationErrorV1('sha256');
    return ExportFileV1._(path: path, content: bytes, sha256: sha256);
  }

  ExportFileV1 copyWith({
    String? path,
    Iterable<int>? content,
    String? sha256,
  }) => ExportFileV1(
    path: path ?? this.path,
    content: content ?? this.content,
    sha256: sha256 ?? this.sha256,
  );

  @override
  List<Object?> get props => [path, content, sha256];

  @override
  String toString() =>
      'ExportFileV1(bytes: ${content.length}, hasSha256: ${sha256.isNotEmpty})';

  String toDebugString() =>
      'ExportFileV1(path: <redacted>, pathLength: ${path.length}, '
      'content: <redacted>, bytes: ${content.length}, '
      'hasSha256: ${sha256.isNotEmpty})';
}
