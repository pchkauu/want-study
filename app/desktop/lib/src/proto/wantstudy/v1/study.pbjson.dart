// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/study.proto.

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

@$core.Deprecated('Use learningSourceTypeDescriptor instead')
const LearningSourceType$json = {
  '1': 'LearningSourceType',
  '2': [
    {'1': 'LEARNING_SOURCE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'LEARNING_SOURCE_TYPE_COURSE', '2': 1},
    {'1': 'LEARNING_SOURCE_TYPE_BOOK', '2': 2},
    {'1': 'LEARNING_SOURCE_TYPE_ARTICLE', '2': 3},
    {'1': 'LEARNING_SOURCE_TYPE_VIDEO', '2': 4},
    {'1': 'LEARNING_SOURCE_TYPE_OTHER', '2': 5},
  ],
};

/// Descriptor for `LearningSourceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List learningSourceTypeDescriptor = $convert.base64Decode(
    'ChJMZWFybmluZ1NvdXJjZVR5cGUSJAogTEVBUk5JTkdfU09VUkNFX1RZUEVfVU5TUEVDSUZJRU'
    'QQABIfChtMRUFSTklOR19TT1VSQ0VfVFlQRV9DT1VSU0UQARIdChlMRUFSTklOR19TT1VSQ0Vf'
    'VFlQRV9CT09LEAISIAocTEVBUk5JTkdfU09VUkNFX1RZUEVfQVJUSUNMRRADEh4KGkxFQVJOSU'
    '5HX1NPVVJDRV9UWVBFX1ZJREVPEAQSHgoaTEVBUk5JTkdfU09VUkNFX1RZUEVfT1RIRVIQBQ==');

@$core.Deprecated('Use lessonStatusDescriptor instead')
const LessonStatus$json = {
  '1': 'LessonStatus',
  '2': [
    {'1': 'LESSON_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'LESSON_STATUS_PLANNED', '2': 1},
    {'1': 'LESSON_STATUS_STUDYING', '2': 2},
    {'1': 'LESSON_STATUS_HOMEWORK', '2': 3},
    {'1': 'LESSON_STATUS_MASTERED', '2': 4},
  ],
};

/// Descriptor for `LessonStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List lessonStatusDescriptor = $convert.base64Decode(
    'CgxMZXNzb25TdGF0dXMSHQoZTEVTU09OX1NUQVRVU19VTlNQRUNJRklFRBAAEhkKFUxFU1NPTl'
    '9TVEFUVVNfUExBTk5FRBABEhoKFkxFU1NPTl9TVEFUVVNfU1RVRFlJTkcQAhIaChZMRVNTT05f'
    'U1RBVFVTX0hPTUVXT1JLEAMSGgoWTEVTU09OX1NUQVRVU19NQVNURVJFRBAE');

@$core.Deprecated('Use studyDescriptor instead')
const Study$json = {
  '1': 'Study',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'goal', '3': 3, '4': 1, '5': 9, '10': 'goal'},
    {
      '1': 'local_repository_path',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'localRepositoryPath'
    },
    {'1': 'version', '3': 5, '4': 1, '5': 3, '10': 'version'},
    {'1': 'content_revision', '3': 6, '4': 1, '5': 3, '10': 'contentRevision'},
    {'1': 'archived', '3': 7, '4': 1, '5': 8, '10': 'archived'},
    {
      '1': 'created_at_epoch_millis',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'createdAtEpochMillis'
    },
    {
      '1': 'updated_at_epoch_millis',
      '3': 9,
      '4': 1,
      '5': 3,
      '10': 'updatedAtEpochMillis'
    },
  ],
};

/// Descriptor for `Study`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List studyDescriptor = $convert.base64Decode(
    'CgVTdHVkeRIOCgJpZBgBIAEoCVICaWQSFAoFdGl0bGUYAiABKAlSBXRpdGxlEhIKBGdvYWwYAy'
    'ABKAlSBGdvYWwSMgoVbG9jYWxfcmVwb3NpdG9yeV9wYXRoGAQgASgJUhNsb2NhbFJlcG9zaXRv'
    'cnlQYXRoEhgKB3ZlcnNpb24YBSABKANSB3ZlcnNpb24SKQoQY29udGVudF9yZXZpc2lvbhgGIA'
    'EoA1IPY29udGVudFJldmlzaW9uEhoKCGFyY2hpdmVkGAcgASgIUghhcmNoaXZlZBI1ChdjcmVh'
    'dGVkX2F0X2Vwb2NoX21pbGxpcxgIIAEoA1IUY3JlYXRlZEF0RXBvY2hNaWxsaXMSNQoXdXBkYX'
    'RlZF9hdF9lcG9jaF9taWxsaXMYCSABKANSFHVwZGF0ZWRBdEVwb2NoTWlsbGlz');

@$core.Deprecated('Use learningSourceDescriptor instead')
const LearningSource$json = {
  '1': 'LearningSource',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.LearningSourceType',
      '10': 'type'
    },
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'author', '3': 5, '4': 1, '5': 9, '10': 'author'},
    {'1': 'url', '3': 6, '4': 1, '5': 9, '10': 'url'},
    {'1': 'export_slug', '3': 7, '4': 1, '5': 9, '10': 'exportSlug'},
    {'1': 'position', '3': 8, '4': 1, '5': 5, '10': 'position'},
    {'1': 'version', '3': 9, '4': 1, '5': 3, '10': 'version'},
    {'1': 'archived', '3': 10, '4': 1, '5': 8, '10': 'archived'},
  ],
};

/// Descriptor for `LearningSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List learningSourceDescriptor = $convert.base64Decode(
    'Cg5MZWFybmluZ1NvdXJjZRIOCgJpZBgBIAEoCVICaWQSGQoIc3R1ZHlfaWQYAiABKAlSB3N0dW'
    'R5SWQSNAoEdHlwZRgDIAEoDjIgLndhbnRzdHVkeS52MS5MZWFybmluZ1NvdXJjZVR5cGVSBHR5'
    'cGUSFAoFdGl0bGUYBCABKAlSBXRpdGxlEhYKBmF1dGhvchgFIAEoCVIGYXV0aG9yEhAKA3VybB'
    'gGIAEoCVIDdXJsEh8KC2V4cG9ydF9zbHVnGAcgASgJUgpleHBvcnRTbHVnEhoKCHBvc2l0aW9u'
    'GAggASgFUghwb3NpdGlvbhIYCgd2ZXJzaW9uGAkgASgDUgd2ZXJzaW9uEhoKCGFyY2hpdmVkGA'
    'ogASgIUghhcmNoaXZlZA==');

@$core.Deprecated('Use sectionDescriptor instead')
const Section$json = {
  '1': 'Section',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'position', '3': 5, '4': 1, '5': 5, '10': 'position'},
    {'1': 'version', '3': 6, '4': 1, '5': 3, '10': 'version'},
    {'1': 'archived', '3': 7, '4': 1, '5': 8, '10': 'archived'},
  ],
};

/// Descriptor for `Section`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sectionDescriptor = $convert.base64Decode(
    'CgdTZWN0aW9uEg4KAmlkGAEgASgJUgJpZBIZCghzdHVkeV9pZBgCIAEoCVIHc3R1ZHlJZBIbCg'
    'lzb3VyY2VfaWQYAyABKAlSCHNvdXJjZUlkEhQKBXRpdGxlGAQgASgJUgV0aXRsZRIaCghwb3Np'
    'dGlvbhgFIAEoBVIIcG9zaXRpb24SGAoHdmVyc2lvbhgGIAEoA1IHdmVyc2lvbhIaCghhcmNoaX'
    'ZlZBgHIAEoCFIIYXJjaGl2ZWQ=');

@$core.Deprecated('Use lessonDescriptor instead')
const Lesson$json = {
  '1': 'Lesson',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 9, '10': 'sourceId'},
    {
      '1': 'section_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'sectionId',
      '17': true
    },
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'url', '3': 6, '4': 1, '5': 9, '10': 'url'},
    {'1': 'source_position', '3': 7, '4': 1, '5': 9, '10': 'sourcePosition'},
    {'1': 'export_slug', '3': 8, '4': 1, '5': 9, '10': 'exportSlug'},
    {'1': 'position', '3': 9, '4': 1, '5': 5, '10': 'position'},
    {
      '1': 'status',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.LessonStatus',
      '10': 'status'
    },
    {
      '1': 'started_at_epoch_millis',
      '3': 11,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'startedAtEpochMillis',
      '17': true
    },
    {
      '1': 'mastered_at_epoch_millis',
      '3': 12,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'masteredAtEpochMillis',
      '17': true
    },
    {'1': 'version', '3': 13, '4': 1, '5': 3, '10': 'version'},
    {'1': 'archived', '3': 14, '4': 1, '5': 8, '10': 'archived'},
  ],
  '8': [
    {'1': '_section_id'},
    {'1': '_started_at_epoch_millis'},
    {'1': '_mastered_at_epoch_millis'},
  ],
};

/// Descriptor for `Lesson`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lessonDescriptor = $convert.base64Decode(
    'CgZMZXNzb24SDgoCaWQYASABKAlSAmlkEhkKCHN0dWR5X2lkGAIgASgJUgdzdHVkeUlkEhsKCX'
    'NvdXJjZV9pZBgDIAEoCVIIc291cmNlSWQSIgoKc2VjdGlvbl9pZBgEIAEoCUgAUglzZWN0aW9u'
    'SWSIAQESFAoFdGl0bGUYBSABKAlSBXRpdGxlEhAKA3VybBgGIAEoCVIDdXJsEicKD3NvdXJjZV'
    '9wb3NpdGlvbhgHIAEoCVIOc291cmNlUG9zaXRpb24SHwoLZXhwb3J0X3NsdWcYCCABKAlSCmV4'
    'cG9ydFNsdWcSGgoIcG9zaXRpb24YCSABKAVSCHBvc2l0aW9uEjIKBnN0YXR1cxgKIAEoDjIaLn'
    'dhbnRzdHVkeS52MS5MZXNzb25TdGF0dXNSBnN0YXR1cxI6ChdzdGFydGVkX2F0X2Vwb2NoX21p'
    'bGxpcxgLIAEoA0gBUhRzdGFydGVkQXRFcG9jaE1pbGxpc4gBARI8ChhtYXN0ZXJlZF9hdF9lcG'
    '9jaF9taWxsaXMYDCABKANIAlIVbWFzdGVyZWRBdEVwb2NoTWlsbGlziAEBEhgKB3ZlcnNpb24Y'
    'DSABKANSB3ZlcnNpb24SGgoIYXJjaGl2ZWQYDiABKAhSCGFyY2hpdmVkQg0KC19zZWN0aW9uX2'
    'lkQhoKGF9zdGFydGVkX2F0X2Vwb2NoX21pbGxpc0IbChlfbWFzdGVyZWRfYXRfZXBvY2hfbWls'
    'bGlz');

@$core.Deprecated('Use createStudyRequestDescriptor instead')
const CreateStudyRequest$json = {
  '1': 'CreateStudyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'goal', '3': 3, '4': 1, '5': 9, '10': 'goal'},
    {
      '1': 'local_repository_path',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'localRepositoryPath'
    },
  ],
};

/// Descriptor for `CreateStudyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createStudyRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVTdHVkeVJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhQKBXRpdGxlGAIgASgJUgV0aX'
    'RsZRISCgRnb2FsGAMgASgJUgRnb2FsEjIKFWxvY2FsX3JlcG9zaXRvcnlfcGF0aBgEIAEoCVIT'
    'bG9jYWxSZXBvc2l0b3J5UGF0aA==');

@$core.Deprecated('Use getStudyRequestDescriptor instead')
const GetStudyRequest$json = {
  '1': 'GetStudyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetStudyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStudyRequestDescriptor =
    $convert.base64Decode('Cg9HZXRTdHVkeVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use listStudiesRequestDescriptor instead')
const ListStudiesRequest$json = {
  '1': 'ListStudiesRequest',
  '2': [
    {'1': 'include_archived', '3': 1, '4': 1, '5': 8, '10': 'includeArchived'},
  ],
};

/// Descriptor for `ListStudiesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listStudiesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0U3R1ZGllc1JlcXVlc3QSKQoQaW5jbHVkZV9hcmNoaXZlZBgBIAEoCFIPaW5jbHVkZU'
    'FyY2hpdmVk');

@$core.Deprecated('Use listStudiesResponseDescriptor instead')
const ListStudiesResponse$json = {
  '1': 'ListStudiesResponse',
  '2': [
    {
      '1': 'studies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.Study',
      '10': 'studies'
    },
  ],
};

/// Descriptor for `ListStudiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listStudiesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0U3R1ZGllc1Jlc3BvbnNlEi0KB3N0dWRpZXMYASADKAsyEy53YW50c3R1ZHkudjEuU3'
    'R1ZHlSB3N0dWRpZXM=');

@$core.Deprecated('Use updateStudyRequestDescriptor instead')
const UpdateStudyRequest$json = {
  '1': 'UpdateStudyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'goal', '3': 3, '4': 1, '5': 9, '10': 'goal'},
    {
      '1': 'local_repository_path',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'localRepositoryPath'
    },
    {'1': 'expected_version', '3': 5, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateStudyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateStudyRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVTdHVkeVJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhQKBXRpdGxlGAIgASgJUgV0aX'
    'RsZRISCgRnb2FsGAMgASgJUgRnb2FsEjIKFWxvY2FsX3JlcG9zaXRvcnlfcGF0aBgEIAEoCVIT'
    'bG9jYWxSZXBvc2l0b3J5UGF0aBIpChBleHBlY3RlZF92ZXJzaW9uGAUgASgDUg9leHBlY3RlZF'
    'ZlcnNpb24=');

@$core.Deprecated('Use changeArchiveRequestDescriptor instead')
const ChangeArchiveRequest$json = {
  '1': 'ChangeArchiveRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `ChangeArchiveRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeArchiveRequestDescriptor = $convert.base64Decode(
    'ChRDaGFuZ2VBcmNoaXZlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSKQoQZXhwZWN0ZWRfdmVyc2'
    'lvbhgCIAEoA1IPZXhwZWN0ZWRWZXJzaW9u');

@$core.Deprecated('Use createLearningSourceRequestDescriptor instead')
const CreateLearningSourceRequest$json = {
  '1': 'CreateLearningSourceRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.LearningSourceType',
      '10': 'type'
    },
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'author', '3': 5, '4': 1, '5': 9, '10': 'author'},
    {'1': 'url', '3': 6, '4': 1, '5': 9, '10': 'url'},
    {'1': 'export_slug', '3': 7, '4': 1, '5': 9, '10': 'exportSlug'},
    {'1': 'position', '3': 8, '4': 1, '5': 5, '10': 'position'},
  ],
};

/// Descriptor for `CreateLearningSourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createLearningSourceRequestDescriptor = $convert.base64Decode(
    'ChtDcmVhdGVMZWFybmluZ1NvdXJjZVJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhkKCHN0dWR5X2'
    'lkGAIgASgJUgdzdHVkeUlkEjQKBHR5cGUYAyABKA4yIC53YW50c3R1ZHkudjEuTGVhcm5pbmdT'
    'b3VyY2VUeXBlUgR0eXBlEhQKBXRpdGxlGAQgASgJUgV0aXRsZRIWCgZhdXRob3IYBSABKAlSBm'
    'F1dGhvchIQCgN1cmwYBiABKAlSA3VybBIfCgtleHBvcnRfc2x1ZxgHIAEoCVIKZXhwb3J0U2x1'
    'ZxIaCghwb3NpdGlvbhgIIAEoBVIIcG9zaXRpb24=');

@$core.Deprecated('Use updateLearningSourceRequestDescriptor instead')
const UpdateLearningSourceRequest$json = {
  '1': 'UpdateLearningSourceRequest',
  '2': [
    {
      '1': 'source',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.LearningSource',
      '10': 'source'
    },
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateLearningSourceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLearningSourceRequestDescriptor =
    $convert.base64Decode(
        'ChtVcGRhdGVMZWFybmluZ1NvdXJjZVJlcXVlc3QSNAoGc291cmNlGAEgASgLMhwud2FudHN0dW'
        'R5LnYxLkxlYXJuaW5nU291cmNlUgZzb3VyY2USKQoQZXhwZWN0ZWRfdmVyc2lvbhgCIAEoA1IP'
        'ZXhwZWN0ZWRWZXJzaW9u');

@$core.Deprecated('Use createSectionRequestDescriptor instead')
const CreateSectionRequest$json = {
  '1': 'CreateSectionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'position', '3': 5, '4': 1, '5': 5, '10': 'position'},
  ],
};

/// Descriptor for `CreateSectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSectionRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVTZWN0aW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSGQoIc3R1ZHlfaWQYAiABKA'
    'lSB3N0dWR5SWQSGwoJc291cmNlX2lkGAMgASgJUghzb3VyY2VJZBIUCgV0aXRsZRgEIAEoCVIF'
    'dGl0bGUSGgoIcG9zaXRpb24YBSABKAVSCHBvc2l0aW9u');

@$core.Deprecated('Use updateSectionRequestDescriptor instead')
const UpdateSectionRequest$json = {
  '1': 'UpdateSectionRequest',
  '2': [
    {
      '1': 'section',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Section',
      '10': 'section'
    },
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateSectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSectionRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVTZWN0aW9uUmVxdWVzdBIvCgdzZWN0aW9uGAEgASgLMhUud2FudHN0dWR5LnYxLl'
    'NlY3Rpb25SB3NlY3Rpb24SKQoQZXhwZWN0ZWRfdmVyc2lvbhgCIAEoA1IPZXhwZWN0ZWRWZXJz'
    'aW9u');

@$core.Deprecated('Use createLessonRequestDescriptor instead')
const CreateLessonRequest$json = {
  '1': 'CreateLessonRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 9, '10': 'sourceId'},
    {
      '1': 'section_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'sectionId',
      '17': true
    },
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'url', '3': 6, '4': 1, '5': 9, '10': 'url'},
    {'1': 'source_position', '3': 7, '4': 1, '5': 9, '10': 'sourcePosition'},
    {'1': 'export_slug', '3': 8, '4': 1, '5': 9, '10': 'exportSlug'},
    {'1': 'position', '3': 9, '4': 1, '5': 5, '10': 'position'},
    {
      '1': 'status',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.LessonStatus',
      '10': 'status'
    },
  ],
  '8': [
    {'1': '_section_id'},
  ],
};

/// Descriptor for `CreateLessonRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createLessonRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVMZXNzb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIZCghzdHVkeV9pZBgCIAEoCV'
    'IHc3R1ZHlJZBIbCglzb3VyY2VfaWQYAyABKAlSCHNvdXJjZUlkEiIKCnNlY3Rpb25faWQYBCAB'
    'KAlIAFIJc2VjdGlvbklkiAEBEhQKBXRpdGxlGAUgASgJUgV0aXRsZRIQCgN1cmwYBiABKAlSA3'
    'VybBInCg9zb3VyY2VfcG9zaXRpb24YByABKAlSDnNvdXJjZVBvc2l0aW9uEh8KC2V4cG9ydF9z'
    'bHVnGAggASgJUgpleHBvcnRTbHVnEhoKCHBvc2l0aW9uGAkgASgFUghwb3NpdGlvbhIyCgZzdG'
    'F0dXMYCiABKA4yGi53YW50c3R1ZHkudjEuTGVzc29uU3RhdHVzUgZzdGF0dXNCDQoLX3NlY3Rp'
    'b25faWQ=');

@$core.Deprecated('Use updateLessonRequestDescriptor instead')
const UpdateLessonRequest$json = {
  '1': 'UpdateLessonRequest',
  '2': [
    {
      '1': 'lesson',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Lesson',
      '10': 'lesson'
    },
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateLessonRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLessonRequestDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVMZXNzb25SZXF1ZXN0EiwKBmxlc3NvbhgBIAEoCzIULndhbnRzdHVkeS52MS5MZX'
    'Nzb25SBmxlc3NvbhIpChBleHBlY3RlZF92ZXJzaW9uGAIgASgDUg9leHBlY3RlZFZlcnNpb24=');

@$core.Deprecated('Use changeLessonStatusRequestDescriptor instead')
const ChangeLessonStatusRequest$json = {
  '1': 'ChangeLessonStatusRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.LessonStatus',
      '10': 'status'
    },
    {'1': 'expected_version', '3': 3, '4': 1, '5': 3, '10': 'expectedVersion'},
    {
      '1': 'acknowledge_open_homework',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'acknowledgeOpenHomework'
    },
  ],
};

/// Descriptor for `ChangeLessonStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeLessonStatusRequestDescriptor = $convert.base64Decode(
    'ChlDaGFuZ2VMZXNzb25TdGF0dXNSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIyCgZzdGF0dXMYAi'
    'ABKA4yGi53YW50c3R1ZHkudjEuTGVzc29uU3RhdHVzUgZzdGF0dXMSKQoQZXhwZWN0ZWRfdmVy'
    'c2lvbhgDIAEoA1IPZXhwZWN0ZWRWZXJzaW9uEjoKGWFja25vd2xlZGdlX29wZW5faG9tZXdvcm'
    'sYBCABKAhSF2Fja25vd2xlZGdlT3BlbkhvbWV3b3Jr');

@$core.Deprecated('Use getMaterialTreeRequestDescriptor instead')
const GetMaterialTreeRequest$json = {
  '1': 'GetMaterialTreeRequest',
  '2': [
    {'1': 'study_id', '3': 1, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'include_archived', '3': 2, '4': 1, '5': 8, '10': 'includeArchived'},
  ],
};

/// Descriptor for `GetMaterialTreeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMaterialTreeRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRNYXRlcmlhbFRyZWVSZXF1ZXN0EhkKCHN0dWR5X2lkGAEgASgJUgdzdHVkeUlkEikKEG'
        'luY2x1ZGVfYXJjaGl2ZWQYAiABKAhSD2luY2x1ZGVBcmNoaXZlZA==');

@$core.Deprecated('Use sourceNodeDescriptor instead')
const SourceNode$json = {
  '1': 'SourceNode',
  '2': [
    {
      '1': 'source',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.LearningSource',
      '10': 'source'
    },
    {
      '1': 'sections',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.Section',
      '10': 'sections'
    },
    {
      '1': 'lessons',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.Lesson',
      '10': 'lessons'
    },
  ],
};

/// Descriptor for `SourceNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sourceNodeDescriptor = $convert.base64Decode(
    'CgpTb3VyY2VOb2RlEjQKBnNvdXJjZRgBIAEoCzIcLndhbnRzdHVkeS52MS5MZWFybmluZ1NvdX'
    'JjZVIGc291cmNlEjEKCHNlY3Rpb25zGAIgAygLMhUud2FudHN0dWR5LnYxLlNlY3Rpb25SCHNl'
    'Y3Rpb25zEi4KB2xlc3NvbnMYAyADKAsyFC53YW50c3R1ZHkudjEuTGVzc29uUgdsZXNzb25z');

@$core.Deprecated('Use materialTreeDescriptor instead')
const MaterialTree$json = {
  '1': 'MaterialTree',
  '2': [
    {
      '1': 'study',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Study',
      '10': 'study'
    },
    {
      '1': 'sources',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.SourceNode',
      '10': 'sources'
    },
  ],
};

/// Descriptor for `MaterialTree`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List materialTreeDescriptor = $convert.base64Decode(
    'CgxNYXRlcmlhbFRyZWUSKQoFc3R1ZHkYASABKAsyEy53YW50c3R1ZHkudjEuU3R1ZHlSBXN0dW'
    'R5EjIKB3NvdXJjZXMYAiADKAsyGC53YW50c3R1ZHkudjEuU291cmNlTm9kZVIHc291cmNlcw==');

@$core.Deprecated('Use reorderItemDescriptor instead')
const ReorderItem$json = {
  '1': 'ReorderItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'position', '3': 2, '4': 1, '5': 5, '10': 'position'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `ReorderItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reorderItemDescriptor = $convert.base64Decode(
    'CgtSZW9yZGVySXRlbRIOCgJpZBgBIAEoCVICaWQSGgoIcG9zaXRpb24YAiABKAVSCHBvc2l0aW'
    '9uEikKEGV4cGVjdGVkX3ZlcnNpb24YAyABKANSD2V4cGVjdGVkVmVyc2lvbg==');

@$core.Deprecated('Use reorderMaterialRequestDescriptor instead')
const ReorderMaterialRequest$json = {
  '1': 'ReorderMaterialRequest',
  '2': [
    {'1': 'study_id', '3': 1, '4': 1, '5': 9, '10': 'studyId'},
    {
      '1': 'sources',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.ReorderItem',
      '10': 'sources'
    },
    {
      '1': 'sections',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.ReorderItem',
      '10': 'sections'
    },
    {
      '1': 'lessons',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.ReorderItem',
      '10': 'lessons'
    },
  ],
};

/// Descriptor for `ReorderMaterialRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reorderMaterialRequestDescriptor = $convert.base64Decode(
    'ChZSZW9yZGVyTWF0ZXJpYWxSZXF1ZXN0EhkKCHN0dWR5X2lkGAEgASgJUgdzdHVkeUlkEjMKB3'
    'NvdXJjZXMYAiADKAsyGS53YW50c3R1ZHkudjEuUmVvcmRlckl0ZW1SB3NvdXJjZXMSNQoIc2Vj'
    'dGlvbnMYAyADKAsyGS53YW50c3R1ZHkudjEuUmVvcmRlckl0ZW1SCHNlY3Rpb25zEjMKB2xlc3'
    'NvbnMYBCADKAsyGS53YW50c3R1ZHkudjEuUmVvcmRlckl0ZW1SB2xlc3NvbnM=');

@$core.Deprecated('Use getDashboardRequestDescriptor instead')
const GetDashboardRequest$json = {
  '1': 'GetDashboardRequest',
  '2': [
    {'1': 'study_id', '3': 1, '4': 1, '5': 9, '10': 'studyId'},
  ],
};

/// Descriptor for `GetDashboardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDashboardRequestDescriptor =
    $convert.base64Decode(
        'ChNHZXREYXNoYm9hcmRSZXF1ZXN0EhkKCHN0dWR5X2lkGAEgASgJUgdzdHVkeUlk');

@$core.Deprecated('Use progressDescriptor instead')
const Progress$json = {
  '1': 'Progress',
  '2': [
    {'1': 'completed', '3': 1, '4': 1, '5': 5, '10': 'completed'},
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `Progress`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List progressDescriptor = $convert.base64Decode(
    'CghQcm9ncmVzcxIcCgljb21wbGV0ZWQYASABKAVSCWNvbXBsZXRlZBIUCgV0b3RhbBgCIAEoBV'
    'IFdG90YWw=');

@$core.Deprecated('Use statusCountDescriptor instead')
const StatusCount$json = {
  '1': 'StatusCount',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.LessonStatus',
      '10': 'status'
    },
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `StatusCount`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusCountDescriptor = $convert.base64Decode(
    'CgtTdGF0dXNDb3VudBIyCgZzdGF0dXMYASABKA4yGi53YW50c3R1ZHkudjEuTGVzc29uU3RhdH'
    'VzUgZzdGF0dXMSFAoFY291bnQYAiABKAVSBWNvdW50');

@$core.Deprecated('Use dashboardDescriptor instead')
const Dashboard$json = {
  '1': 'Dashboard',
  '2': [
    {
      '1': 'material',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Progress',
      '10': 'material'
    },
    {
      '1': 'homework',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Progress',
      '10': 'homework'
    },
    {
      '1': 'lesson_statuses',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.StatusCount',
      '10': 'lessonStatuses'
    },
    {'1': 'study_revision', '3': 4, '4': 1, '5': 3, '10': 'studyRevision'},
  ],
};

/// Descriptor for `Dashboard`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dashboardDescriptor = $convert.base64Decode(
    'CglEYXNoYm9hcmQSMgoIbWF0ZXJpYWwYASABKAsyFi53YW50c3R1ZHkudjEuUHJvZ3Jlc3NSCG'
    '1hdGVyaWFsEjIKCGhvbWV3b3JrGAIgASgLMhYud2FudHN0dWR5LnYxLlByb2dyZXNzUghob21l'
    'd29yaxJCCg9sZXNzb25fc3RhdHVzZXMYAyADKAsyGS53YW50c3R1ZHkudjEuU3RhdHVzQ291bn'
    'RSDmxlc3NvblN0YXR1c2VzEiUKDnN0dWR5X3JldmlzaW9uGAQgASgDUg1zdHVkeVJldmlzaW9u');
