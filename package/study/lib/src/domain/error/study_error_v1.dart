import 'package:domain_error/domain_error.dart';

sealed class StudyErrorV1 extends DomainError {
  const StudyErrorV1({super.message, super.cause, super.stackTrace});

  @override
  String get typeIdentifier => 'StudyErrorV1';
}

final class ValidationErrorV1 extends StudyErrorV1 {
  final String field;

  const ValidationErrorV1(this.field)
    : super(message: 'Некорректное значение поля');

  @override
  String get typeIdentifier => 'ValidationErrorV1';

  @override
  List<Object?> get props => [...super.props, field];
}

final class NotFoundErrorV1 extends StudyErrorV1 {
  final String resource;

  const NotFoundErrorV1(this.resource) : super(message: 'Данные не найдены');

  @override
  String get typeIdentifier => 'NotFoundErrorV1';

  @override
  List<Object?> get props => [...super.props, resource];
}

final class ConflictErrorV1 extends StudyErrorV1 {
  final String resource;

  const ConflictErrorV1(this.resource)
    : super(message: 'Данные были изменены в другом окне');

  @override
  String get typeIdentifier => 'ConflictErrorV1';

  @override
  List<Object?> get props => [...super.props, resource];
}

final class OpenHomeworkErrorV1 extends StudyErrorV1 {
  const OpenHomeworkErrorV1()
    : super(message: 'Остались невыполненные задания');

  @override
  String get typeIdentifier => 'OpenHomeworkErrorV1';
}

final class UnavailableErrorV1 extends StudyErrorV1 {
  const UnavailableErrorV1({super.cause, super.stackTrace})
    : super(message: 'Сервис временно недоступен');

  @override
  String get typeIdentifier => 'UnavailableErrorV1';
}

final class PublicationErrorV1 extends StudyErrorV1 {
  final String reason;

  const PublicationErrorV1(this.reason, {super.cause, super.stackTrace})
    : super(message: 'Публикация не выполнена');

  @override
  String get typeIdentifier => 'PublicationErrorV1';

  @override
  List<Object?> get props => [...super.props, reason];
}

final class UnexpectedErrorV1 extends StudyErrorV1 {
  const UnexpectedErrorV1({super.cause, super.stackTrace})
    : super(message: 'Не удалось выполнить операцию');

  @override
  String get typeIdentifier => 'UnexpectedErrorV1';
}
