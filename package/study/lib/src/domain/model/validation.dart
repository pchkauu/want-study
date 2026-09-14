import 'dart:convert';

import 'package:study/src/domain/error/study_error.dart';

abstract final class StudyValidationV1 {
  static const int maxTitleLength = 200;
  static const int maxContentBytes = 1024 * 1024;

  static String title(String field, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.runes.length > maxTitleLength) {
      throw ValidationErrorV1(field);
    }
    return normalized;
  }

  static String content(String field, String value) {
    if (utf8.encode(value).length > maxContentBytes) {
      throw ValidationErrorV1(field);
    }
    return value;
  }

  static int version(String field, int value) {
    if (value < 1) {
      throw ValidationErrorV1(field);
    }
    return value;
  }

  static int position(String field, int value) {
    if (value < 0) {
      throw ValidationErrorV1(field);
    }
    return value;
  }

  static String slug(String field, String value) {
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(value)) {
      throw ValidationErrorV1(field);
    }
    return value;
  }

  static String relativePath(String value) {
    final parts = value.split('/');
    if (value.isEmpty ||
        value.startsWith('/') ||
        value.contains(r'\') ||
        parts.any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw const ValidationErrorV1('relativePath');
    }
    return value;
  }
}
