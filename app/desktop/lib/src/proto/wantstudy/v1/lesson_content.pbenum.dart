// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/lesson_content.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NoteBlockType extends $pb.ProtobufEnum {
  static const NoteBlockType NOTE_BLOCK_TYPE_UNSPECIFIED =
      NoteBlockType._(0, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_UNSPECIFIED');
  static const NoteBlockType NOTE_BLOCK_TYPE_TEXT =
      NoteBlockType._(1, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_TEXT');
  static const NoteBlockType NOTE_BLOCK_TYPE_DEFINITION =
      NoteBlockType._(2, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_DEFINITION');
  static const NoteBlockType NOTE_BLOCK_TYPE_CLAIM =
      NoteBlockType._(3, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_CLAIM');
  static const NoteBlockType NOTE_BLOCK_TYPE_QUOTE =
      NoteBlockType._(4, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_QUOTE');
  static const NoteBlockType NOTE_BLOCK_TYPE_EXAMPLE =
      NoteBlockType._(5, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_EXAMPLE');
  static const NoteBlockType NOTE_BLOCK_TYPE_QUESTION =
      NoteBlockType._(6, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_QUESTION');
  static const NoteBlockType NOTE_BLOCK_TYPE_SUMMARY =
      NoteBlockType._(7, _omitEnumNames ? '' : 'NOTE_BLOCK_TYPE_SUMMARY');

  static const $core.List<NoteBlockType> values = <NoteBlockType>[
    NOTE_BLOCK_TYPE_UNSPECIFIED,
    NOTE_BLOCK_TYPE_TEXT,
    NOTE_BLOCK_TYPE_DEFINITION,
    NOTE_BLOCK_TYPE_CLAIM,
    NOTE_BLOCK_TYPE_QUOTE,
    NOTE_BLOCK_TYPE_EXAMPLE,
    NOTE_BLOCK_TYPE_QUESTION,
    NOTE_BLOCK_TYPE_SUMMARY,
  ];

  static final $core.List<NoteBlockType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static NoteBlockType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NoteBlockType._(super.value, super.name);
}

class HomeworkStatus extends $pb.ProtobufEnum {
  static const HomeworkStatus HOMEWORK_STATUS_UNSPECIFIED =
      HomeworkStatus._(0, _omitEnumNames ? '' : 'HOMEWORK_STATUS_UNSPECIFIED');
  static const HomeworkStatus HOMEWORK_STATUS_TODO =
      HomeworkStatus._(1, _omitEnumNames ? '' : 'HOMEWORK_STATUS_TODO');
  static const HomeworkStatus HOMEWORK_STATUS_DONE =
      HomeworkStatus._(2, _omitEnumNames ? '' : 'HOMEWORK_STATUS_DONE');

  static const $core.List<HomeworkStatus> values = <HomeworkStatus>[
    HOMEWORK_STATUS_UNSPECIFIED,
    HOMEWORK_STATUS_TODO,
    HOMEWORK_STATUS_DONE,
  ];

  static final $core.List<HomeworkStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static HomeworkStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HomeworkStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
