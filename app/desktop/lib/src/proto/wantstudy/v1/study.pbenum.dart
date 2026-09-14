// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/study.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class LearningSourceType extends $pb.ProtobufEnum {
  static const LearningSourceType LEARNING_SOURCE_TYPE_UNSPECIFIED =
      LearningSourceType._(
          0, _omitEnumNames ? '' : 'LEARNING_SOURCE_TYPE_UNSPECIFIED');
  static const LearningSourceType LEARNING_SOURCE_TYPE_COURSE =
      LearningSourceType._(
          1, _omitEnumNames ? '' : 'LEARNING_SOURCE_TYPE_COURSE');
  static const LearningSourceType LEARNING_SOURCE_TYPE_BOOK =
      LearningSourceType._(
          2, _omitEnumNames ? '' : 'LEARNING_SOURCE_TYPE_BOOK');
  static const LearningSourceType LEARNING_SOURCE_TYPE_ARTICLE =
      LearningSourceType._(
          3, _omitEnumNames ? '' : 'LEARNING_SOURCE_TYPE_ARTICLE');
  static const LearningSourceType LEARNING_SOURCE_TYPE_VIDEO =
      LearningSourceType._(
          4, _omitEnumNames ? '' : 'LEARNING_SOURCE_TYPE_VIDEO');
  static const LearningSourceType LEARNING_SOURCE_TYPE_OTHER =
      LearningSourceType._(
          5, _omitEnumNames ? '' : 'LEARNING_SOURCE_TYPE_OTHER');

  static const $core.List<LearningSourceType> values = <LearningSourceType>[
    LEARNING_SOURCE_TYPE_UNSPECIFIED,
    LEARNING_SOURCE_TYPE_COURSE,
    LEARNING_SOURCE_TYPE_BOOK,
    LEARNING_SOURCE_TYPE_ARTICLE,
    LEARNING_SOURCE_TYPE_VIDEO,
    LEARNING_SOURCE_TYPE_OTHER,
  ];

  static final $core.List<LearningSourceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static LearningSourceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LearningSourceType._(super.value, super.name);
}

class LessonStatus extends $pb.ProtobufEnum {
  static const LessonStatus LESSON_STATUS_UNSPECIFIED =
      LessonStatus._(0, _omitEnumNames ? '' : 'LESSON_STATUS_UNSPECIFIED');
  static const LessonStatus LESSON_STATUS_PLANNED =
      LessonStatus._(1, _omitEnumNames ? '' : 'LESSON_STATUS_PLANNED');
  static const LessonStatus LESSON_STATUS_STUDYING =
      LessonStatus._(2, _omitEnumNames ? '' : 'LESSON_STATUS_STUDYING');
  static const LessonStatus LESSON_STATUS_HOMEWORK =
      LessonStatus._(3, _omitEnumNames ? '' : 'LESSON_STATUS_HOMEWORK');
  static const LessonStatus LESSON_STATUS_MASTERED =
      LessonStatus._(4, _omitEnumNames ? '' : 'LESSON_STATUS_MASTERED');

  static const $core.List<LessonStatus> values = <LessonStatus>[
    LESSON_STATUS_UNSPECIFIED,
    LESSON_STATUS_PLANNED,
    LESSON_STATUS_STUDYING,
    LESSON_STATUS_HOMEWORK,
    LESSON_STATUS_MASTERED,
  ];

  static final $core.List<LessonStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static LessonStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LessonStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
