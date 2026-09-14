import 'package:equatable/equatable.dart';
import 'package:study/src/domain/_barrel.dart';

final class PublicationCommitV1 extends Equatable {
  final String message;

  const PublicationCommitV1._(this.message);

  factory PublicationCommitV1({required String message}) {
    final normalized = message.trim();
    if (normalized.isEmpty ||
        normalized.runes.length > StudyConstV1.maxTitleLength) {
      throw const ValidationErrorV1('commitMessage');
    }
    return PublicationCommitV1._(normalized);
  }

  PublicationCommitV1 copyWith({String? message}) =>
      PublicationCommitV1(message: message ?? this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'PublicationCommitV1(length: ${message.length})';

  String toDebugString() =>
      'PublicationCommitV1(message: <redacted>, length: ${message.length})';
}
