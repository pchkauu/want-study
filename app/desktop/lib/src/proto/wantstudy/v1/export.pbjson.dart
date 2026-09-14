// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/export.proto.

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

@$core.Deprecated('Use renderStudyExportRequestDescriptor instead')
const RenderStudyExportRequest$json = {
  '1': 'RenderStudyExportRequest',
  '2': [
    {'1': 'study_id', '3': 1, '4': 1, '5': 9, '10': 'studyId'},
    {
      '1': 'expected_content_revision',
      '3': 2,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'expectedContentRevision',
      '17': true
    },
  ],
  '8': [
    {'1': '_expected_content_revision'},
  ],
};

/// Descriptor for `RenderStudyExportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List renderStudyExportRequestDescriptor = $convert.base64Decode(
    'ChhSZW5kZXJTdHVkeUV4cG9ydFJlcXVlc3QSGQoIc3R1ZHlfaWQYASABKAlSB3N0dWR5SWQSPw'
    'oZZXhwZWN0ZWRfY29udGVudF9yZXZpc2lvbhgCIAEoA0gAUhdleHBlY3RlZENvbnRlbnRSZXZp'
    'c2lvbogBAUIcChpfZXhwZWN0ZWRfY29udGVudF9yZXZpc2lvbg==');

@$core.Deprecated('Use exportHeaderDescriptor instead')
const ExportHeader$json = {
  '1': 'ExportHeader',
  '2': [
    {'1': 'study_id', '3': 1, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'study_revision', '3': 2, '4': 1, '5': 3, '10': 'studyRevision'},
    {'1': 'total_bytes', '3': 3, '4': 1, '5': 3, '10': 'totalBytes'},
    {'1': 'file_count', '3': 4, '4': 1, '5': 5, '10': 'fileCount'},
  ],
};

/// Descriptor for `ExportHeader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportHeaderDescriptor = $convert.base64Decode(
    'CgxFeHBvcnRIZWFkZXISGQoIc3R1ZHlfaWQYASABKAlSB3N0dWR5SWQSJQoOc3R1ZHlfcmV2aX'
    'Npb24YAiABKANSDXN0dWR5UmV2aXNpb24SHwoLdG90YWxfYnl0ZXMYAyABKANSCnRvdGFsQnl0'
    'ZXMSHQoKZmlsZV9jb3VudBgEIAEoBVIJZmlsZUNvdW50');

@$core.Deprecated('Use exportFileDescriptor instead')
const ExportFile$json = {
  '1': 'ExportFile',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
    {'1': 'sha256', '3': 3, '4': 1, '5': 9, '10': 'sha256'},
  ],
};

/// Descriptor for `ExportFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportFileDescriptor = $convert.base64Decode(
    'CgpFeHBvcnRGaWxlEhIKBHBhdGgYASABKAlSBHBhdGgSGAoHY29udGVudBgCIAEoDFIHY29udG'
    'VudBIWCgZzaGEyNTYYAyABKAlSBnNoYTI1Ng==');

@$core.Deprecated('Use exportChunkDescriptor instead')
const ExportChunk$json = {
  '1': 'ExportChunk',
  '2': [
    {
      '1': 'header',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.ExportHeader',
      '9': 0,
      '10': 'header'
    },
    {
      '1': 'file',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.ExportFile',
      '9': 0,
      '10': 'file'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
};

/// Descriptor for `ExportChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportChunkDescriptor = $convert.base64Decode(
    'CgtFeHBvcnRDaHVuaxI0CgZoZWFkZXIYASABKAsyGi53YW50c3R1ZHkudjEuRXhwb3J0SGVhZG'
    'VySABSBmhlYWRlchIuCgRmaWxlGAIgASgLMhgud2FudHN0dWR5LnYxLkV4cG9ydEZpbGVIAFIE'
    'ZmlsZUIHCgV2YWx1ZQ==');
