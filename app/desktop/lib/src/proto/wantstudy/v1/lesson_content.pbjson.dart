// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/lesson_content.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use noteBlockTypeDescriptor instead')
const NoteBlockType$json = {
  '1': 'NoteBlockType',
  '2': [
    {'1': 'NOTE_BLOCK_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'NOTE_BLOCK_TYPE_TEXT', '2': 1},
    {'1': 'NOTE_BLOCK_TYPE_DEFINITION', '2': 2},
    {'1': 'NOTE_BLOCK_TYPE_CLAIM', '2': 3},
    {'1': 'NOTE_BLOCK_TYPE_QUOTE', '2': 4},
    {'1': 'NOTE_BLOCK_TYPE_EXAMPLE', '2': 5},
    {'1': 'NOTE_BLOCK_TYPE_QUESTION', '2': 6},
    {'1': 'NOTE_BLOCK_TYPE_SUMMARY', '2': 7},
  ],
};

/// Descriptor for `NoteBlockType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List noteBlockTypeDescriptor = $convert.base64Decode(
    'Cg1Ob3RlQmxvY2tUeXBlEh8KG05PVEVfQkxPQ0tfVFlQRV9VTlNQRUNJRklFRBAAEhgKFE5PVE'
    'VfQkxPQ0tfVFlQRV9URVhUEAESHgoaTk9URV9CTE9DS19UWVBFX0RFRklOSVRJT04QAhIZChVO'
    'T1RFX0JMT0NLX1RZUEVfQ0xBSU0QAxIZChVOT1RFX0JMT0NLX1RZUEVfUVVPVEUQBBIbChdOT1'
    'RFX0JMT0NLX1RZUEVfRVhBTVBMRRAFEhwKGE5PVEVfQkxPQ0tfVFlQRV9RVUVTVElPThAGEhsK'
    'F05PVEVfQkxPQ0tfVFlQRV9TVU1NQVJZEAc=');

@$core.Deprecated('Use homeworkStatusDescriptor instead')
const HomeworkStatus$json = {
  '1': 'HomeworkStatus',
  '2': [
    {'1': 'HOMEWORK_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'HOMEWORK_STATUS_TODO', '2': 1},
    {'1': 'HOMEWORK_STATUS_DONE', '2': 2},
  ],
};

/// Descriptor for `HomeworkStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List homeworkStatusDescriptor = $convert.base64Decode(
    'Cg5Ib21ld29ya1N0YXR1cxIfChtIT01FV09SS19TVEFUVVNfVU5TUEVDSUZJRUQQABIYChRIT0'
    '1FV09SS19TVEFUVVNfVE9ETxABEhgKFEhPTUVXT1JLX1NUQVRVU19ET05FEAI=');

@$core.Deprecated('Use noteBlockDescriptor instead')
const NoteBlock$json = {
  '1': 'NoteBlock',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'lesson_id', '3': 3, '4': 1, '5': 9, '10': 'lessonId'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.NoteBlockType',
      '10': 'type'
    },
    {'1': 'markdown', '3': 5, '4': 1, '5': 9, '10': 'markdown'},
    {'1': 'source_url', '3': 6, '4': 1, '5': 9, '10': 'sourceUrl'},
    {'1': 'source_position', '3': 7, '4': 1, '5': 9, '10': 'sourcePosition'},
    {'1': 'position', '3': 8, '4': 1, '5': 5, '10': 'position'},
    {'1': 'version', '3': 9, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `NoteBlock`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteBlockDescriptor = $convert.base64Decode(
    'CglOb3RlQmxvY2sSDgoCaWQYASABKAlSAmlkEhkKCHN0dWR5X2lkGAIgASgJUgdzdHVkeUlkEh'
    'sKCWxlc3Nvbl9pZBgDIAEoCVIIbGVzc29uSWQSLwoEdHlwZRgEIAEoDjIbLndhbnRzdHVkeS52'
    'MS5Ob3RlQmxvY2tUeXBlUgR0eXBlEhoKCG1hcmtkb3duGAUgASgJUghtYXJrZG93bhIdCgpzb3'
    'VyY2VfdXJsGAYgASgJUglzb3VyY2VVcmwSJwoPc291cmNlX3Bvc2l0aW9uGAcgASgJUg5zb3Vy'
    'Y2VQb3NpdGlvbhIaCghwb3NpdGlvbhgIIAEoBVIIcG9zaXRpb24SGAoHdmVyc2lvbhgJIAEoA1'
    'IHdmVyc2lvbg==');

@$core.Deprecated('Use homeworkTaskDescriptor instead')
const HomeworkTask$json = {
  '1': 'HomeworkTask',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'lesson_id', '3': 3, '4': 1, '5': 9, '10': 'lessonId'},
    {'1': 'prompt_markdown', '3': 4, '4': 1, '5': 9, '10': 'promptMarkdown'},
    {
      '1': 'solution_markdown',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'solutionMarkdown'
    },
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.HomeworkStatus',
      '10': 'status'
    },
    {
      '1': 'due_at_epoch_millis',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'dueAtEpochMillis',
      '17': true
    },
    {'1': 'position', '3': 8, '4': 1, '5': 5, '10': 'position'},
    {'1': 'version', '3': 9, '4': 1, '5': 3, '10': 'version'},
  ],
  '8': [
    {'1': '_due_at_epoch_millis'},
  ],
};

/// Descriptor for `HomeworkTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List homeworkTaskDescriptor = $convert.base64Decode(
    'CgxIb21ld29ya1Rhc2sSDgoCaWQYASABKAlSAmlkEhkKCHN0dWR5X2lkGAIgASgJUgdzdHVkeU'
    'lkEhsKCWxlc3Nvbl9pZBgDIAEoCVIIbGVzc29uSWQSJwoPcHJvbXB0X21hcmtkb3duGAQgASgJ'
    'Ug5wcm9tcHRNYXJrZG93bhIrChFzb2x1dGlvbl9tYXJrZG93bhgFIAEoCVIQc29sdXRpb25NYX'
    'JrZG93bhI0CgZzdGF0dXMYBiABKA4yHC53YW50c3R1ZHkudjEuSG9tZXdvcmtTdGF0dXNSBnN0'
    'YXR1cxIyChNkdWVfYXRfZXBvY2hfbWlsbGlzGAcgASgDSABSEGR1ZUF0RXBvY2hNaWxsaXOIAQ'
    'ESGgoIcG9zaXRpb24YCCABKAVSCHBvc2l0aW9uEhgKB3ZlcnNpb24YCSABKANSB3ZlcnNpb25C'
    'FgoUX2R1ZV9hdF9lcG9jaF9taWxsaXM=');

@$core.Deprecated('Use codeFileDescriptor instead')
const CodeFile$json = {
  '1': 'CodeFile',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'lesson_id', '3': 3, '4': 1, '5': 9, '10': 'lessonId'},
    {
      '1': 'homework_task_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'homeworkTaskId',
      '17': true
    },
    {'1': 'relative_path', '3': 5, '4': 1, '5': 9, '10': 'relativePath'},
    {'1': 'language', '3': 6, '4': 1, '5': 9, '10': 'language'},
    {'1': 'content', '3': 7, '4': 1, '5': 9, '10': 'content'},
    {'1': 'version', '3': 8, '4': 1, '5': 3, '10': 'version'},
  ],
  '8': [
    {'1': '_homework_task_id'},
  ],
};

/// Descriptor for `CodeFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List codeFileDescriptor = $convert.base64Decode(
    'CghDb2RlRmlsZRIOCgJpZBgBIAEoCVICaWQSGQoIc3R1ZHlfaWQYAiABKAlSB3N0dWR5SWQSGw'
    'oJbGVzc29uX2lkGAMgASgJUghsZXNzb25JZBItChBob21ld29ya190YXNrX2lkGAQgASgJSABS'
    'DmhvbWV3b3JrVGFza0lkiAEBEiMKDXJlbGF0aXZlX3BhdGgYBSABKAlSDHJlbGF0aXZlUGF0aB'
    'IaCghsYW5ndWFnZRgGIAEoCVIIbGFuZ3VhZ2USGAoHY29udGVudBgHIAEoCVIHY29udGVudBIY'
    'Cgd2ZXJzaW9uGAggASgDUgd2ZXJzaW9uQhMKEV9ob21ld29ya190YXNrX2lk');

@$core.Deprecated('Use getLessonWorkspaceRequestDescriptor instead')
const GetLessonWorkspaceRequest$json = {
  '1': 'GetLessonWorkspaceRequest',
  '2': [
    {'1': 'lesson_id', '3': 1, '4': 1, '5': 9, '10': 'lessonId'},
  ],
};

/// Descriptor for `GetLessonWorkspaceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLessonWorkspaceRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRMZXNzb25Xb3Jrc3BhY2VSZXF1ZXN0EhsKCWxlc3Nvbl9pZBgBIAEoCVIIbGVzc29uSW'
        'Q=');

@$core.Deprecated('Use lessonWorkspaceDescriptor instead')
const LessonWorkspace$json = {
  '1': 'LessonWorkspace',
  '2': [
    {
      '1': 'lesson',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Lesson',
      '10': 'lesson'
    },
    {
      '1': 'blocks',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.NoteBlock',
      '10': 'blocks'
    },
    {
      '1': 'tasks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.HomeworkTask',
      '10': 'tasks'
    },
    {
      '1': 'files',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.CodeFile',
      '10': 'files'
    },
    {'1': 'concept_ids', '3': 5, '4': 3, '5': 9, '10': 'conceptIds'},
  ],
};

/// Descriptor for `LessonWorkspace`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lessonWorkspaceDescriptor = $convert.base64Decode(
    'Cg9MZXNzb25Xb3Jrc3BhY2USLAoGbGVzc29uGAEgASgLMhQud2FudHN0dWR5LnYxLkxlc3Nvbl'
    'IGbGVzc29uEi8KBmJsb2NrcxgCIAMoCzIXLndhbnRzdHVkeS52MS5Ob3RlQmxvY2tSBmJsb2Nr'
    'cxIwCgV0YXNrcxgDIAMoCzIaLndhbnRzdHVkeS52MS5Ib21ld29ya1Rhc2tSBXRhc2tzEiwKBW'
    'ZpbGVzGAQgAygLMhYud2FudHN0dWR5LnYxLkNvZGVGaWxlUgVmaWxlcxIfCgtjb25jZXB0X2lk'
    'cxgFIAMoCVIKY29uY2VwdElkcw==');

@$core.Deprecated('Use createNoteBlockRequestDescriptor instead')
const CreateNoteBlockRequest$json = {
  '1': 'CreateNoteBlockRequest',
  '2': [
    {
      '1': 'block',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.NoteBlock',
      '10': 'block'
    },
  ],
};

/// Descriptor for `CreateNoteBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createNoteBlockRequestDescriptor =
    $convert.base64Decode(
        'ChZDcmVhdGVOb3RlQmxvY2tSZXF1ZXN0Ei0KBWJsb2NrGAEgASgLMhcud2FudHN0dWR5LnYxLk'
        '5vdGVCbG9ja1IFYmxvY2s=');

@$core.Deprecated('Use updateNoteBlockRequestDescriptor instead')
const UpdateNoteBlockRequest$json = {
  '1': 'UpdateNoteBlockRequest',
  '2': [
    {
      '1': 'block',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.NoteBlock',
      '10': 'block'
    },
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateNoteBlockRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNoteBlockRequestDescriptor = $convert.base64Decode(
    'ChZVcGRhdGVOb3RlQmxvY2tSZXF1ZXN0Ei0KBWJsb2NrGAEgASgLMhcud2FudHN0dWR5LnYxLk'
    '5vdGVCbG9ja1IFYmxvY2sSKQoQZXhwZWN0ZWRfdmVyc2lvbhgCIAEoA1IPZXhwZWN0ZWRWZXJz'
    'aW9u');

@$core.Deprecated('Use createHomeworkTaskRequestDescriptor instead')
const CreateHomeworkTaskRequest$json = {
  '1': 'CreateHomeworkTaskRequest',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.HomeworkTask',
      '10': 'task'
    },
  ],
};

/// Descriptor for `CreateHomeworkTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createHomeworkTaskRequestDescriptor =
    $convert.base64Decode(
        'ChlDcmVhdGVIb21ld29ya1Rhc2tSZXF1ZXN0Ei4KBHRhc2sYASABKAsyGi53YW50c3R1ZHkudj'
        'EuSG9tZXdvcmtUYXNrUgR0YXNr');

@$core.Deprecated('Use updateHomeworkTaskRequestDescriptor instead')
const UpdateHomeworkTaskRequest$json = {
  '1': 'UpdateHomeworkTaskRequest',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.HomeworkTask',
      '10': 'task'
    },
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateHomeworkTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateHomeworkTaskRequestDescriptor = $convert.base64Decode(
    'ChlVcGRhdGVIb21ld29ya1Rhc2tSZXF1ZXN0Ei4KBHRhc2sYASABKAsyGi53YW50c3R1ZHkudj'
    'EuSG9tZXdvcmtUYXNrUgR0YXNrEikKEGV4cGVjdGVkX3ZlcnNpb24YAiABKANSD2V4cGVjdGVk'
    'VmVyc2lvbg==');

@$core.Deprecated('Use createCodeFileRequestDescriptor instead')
const CreateCodeFileRequest$json = {
  '1': 'CreateCodeFileRequest',
  '2': [
    {
      '1': 'file',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.CodeFile',
      '10': 'file'
    },
  ],
};

/// Descriptor for `CreateCodeFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCodeFileRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVDb2RlRmlsZVJlcXVlc3QSKgoEZmlsZRgBIAEoCzIWLndhbnRzdHVkeS52MS5Db2'
    'RlRmlsZVIEZmlsZQ==');

@$core.Deprecated('Use updateCodeFileRequestDescriptor instead')
const UpdateCodeFileRequest$json = {
  '1': 'UpdateCodeFileRequest',
  '2': [
    {
      '1': 'file',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.CodeFile',
      '10': 'file'
    },
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateCodeFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCodeFileRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVDb2RlRmlsZVJlcXVlc3QSKgoEZmlsZRgBIAEoCzIWLndhbnRzdHVkeS52MS5Db2'
    'RlRmlsZVIEZmlsZRIpChBleHBlY3RlZF92ZXJzaW9uGAIgASgDUg9leHBlY3RlZFZlcnNpb24=');

@$core.Deprecated('Use deleteContentRequestDescriptor instead')
const DeleteContentRequest$json = {
  '1': 'DeleteContentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
    {'1': 'confirmed', '3': 3, '4': 1, '5': 8, '10': 'confirmed'},
  ],
};

/// Descriptor for `DeleteContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteContentRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVDb250ZW50UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSKQoQZXhwZWN0ZWRfdmVyc2'
    'lvbhgCIAEoA1IPZXhwZWN0ZWRWZXJzaW9uEhwKCWNvbmZpcm1lZBgDIAEoCFIJY29uZmlybWVk');

@$core.Deprecated('Use deleteContentResponseDescriptor instead')
const DeleteContentResponse$json = {
  '1': 'DeleteContentResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteContentResponseDescriptor = $convert
    .base64Decode('ChVEZWxldGVDb250ZW50UmVzcG9uc2USDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use reorderLessonContentRequestDescriptor instead')
const ReorderLessonContentRequest$json = {
  '1': 'ReorderLessonContentRequest',
  '2': [
    {'1': 'lesson_id', '3': 1, '4': 1, '5': 9, '10': 'lessonId'},
    {
      '1': 'blocks',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.ReorderItem',
      '10': 'blocks'
    },
    {
      '1': 'tasks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.ReorderItem',
      '10': 'tasks'
    },
  ],
};

/// Descriptor for `ReorderLessonContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reorderLessonContentRequestDescriptor =
    $convert.base64Decode(
        'ChtSZW9yZGVyTGVzc29uQ29udGVudFJlcXVlc3QSGwoJbGVzc29uX2lkGAEgASgJUghsZXNzb2'
        '5JZBIxCgZibG9ja3MYAiADKAsyGS53YW50c3R1ZHkudjEuUmVvcmRlckl0ZW1SBmJsb2NrcxIv'
        'CgV0YXNrcxgDIAMoCzIZLndhbnRzdHVkeS52MS5SZW9yZGVySXRlbVIFdGFza3M=');
