// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/knowledge.proto.

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

@$core.Deprecated('Use conceptRelationTypeDescriptor instead')
const ConceptRelationType$json = {
  '1': 'ConceptRelationType',
  '2': [
    {'1': 'CONCEPT_RELATION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'CONCEPT_RELATION_TYPE_RELATED_TO', '2': 1},
    {'1': 'CONCEPT_RELATION_TYPE_PART_OF', '2': 2},
    {'1': 'CONCEPT_RELATION_TYPE_PREREQUISITE_FOR', '2': 3},
    {'1': 'CONCEPT_RELATION_TYPE_CONTRASTS_WITH', '2': 4},
    {'1': 'CONCEPT_RELATION_TYPE_APPLIES_TO', '2': 5},
  ],
};

/// Descriptor for `ConceptRelationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List conceptRelationTypeDescriptor = $convert.base64Decode(
    'ChNDb25jZXB0UmVsYXRpb25UeXBlEiUKIUNPTkNFUFRfUkVMQVRJT05fVFlQRV9VTlNQRUNJRk'
    'lFRBAAEiQKIENPTkNFUFRfUkVMQVRJT05fVFlQRV9SRUxBVEVEX1RPEAESIQodQ09OQ0VQVF9S'
    'RUxBVElPTl9UWVBFX1BBUlRfT0YQAhIqCiZDT05DRVBUX1JFTEFUSU9OX1RZUEVfUFJFUkVRVU'
    'lTSVRFX0ZPUhADEigKJENPTkNFUFRfUkVMQVRJT05fVFlQRV9DT05UUkFTVFNfV0lUSBAEEiQK'
    'IENPTkNFUFRfUkVMQVRJT05fVFlQRV9BUFBMSUVTX1RPEAU=');

@$core.Deprecated('Use conceptDescriptor instead')
const Concept$json = {
  '1': 'Concept',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'description_markdown',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'descriptionMarkdown'
    },
    {'1': 'export_slug', '3': 5, '4': 1, '5': 9, '10': 'exportSlug'},
    {'1': 'aliases', '3': 6, '4': 3, '5': 9, '10': 'aliases'},
    {'1': 'block_ids', '3': 7, '4': 3, '5': 9, '10': 'blockIds'},
    {'1': 'version', '3': 8, '4': 1, '5': 3, '10': 'version'},
    {'1': 'archived', '3': 9, '4': 1, '5': 8, '10': 'archived'},
  ],
};

/// Descriptor for `Concept`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conceptDescriptor = $convert.base64Decode(
    'CgdDb25jZXB0Eg4KAmlkGAEgASgJUgJpZBIZCghzdHVkeV9pZBgCIAEoCVIHc3R1ZHlJZBIUCg'
    'V0aXRsZRgDIAEoCVIFdGl0bGUSMQoUZGVzY3JpcHRpb25fbWFya2Rvd24YBCABKAlSE2Rlc2Ny'
    'aXB0aW9uTWFya2Rvd24SHwoLZXhwb3J0X3NsdWcYBSABKAlSCmV4cG9ydFNsdWcSGAoHYWxpYX'
    'NlcxgGIAMoCVIHYWxpYXNlcxIbCglibG9ja19pZHMYByADKAlSCGJsb2NrSWRzEhgKB3ZlcnNp'
    'b24YCCABKANSB3ZlcnNpb24SGgoIYXJjaGl2ZWQYCSABKAhSCGFyY2hpdmVk');

@$core.Deprecated('Use conceptRelationDescriptor instead')
const ConceptRelation$json = {
  '1': 'ConceptRelation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'study_id', '3': 2, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'source_concept_id', '3': 3, '4': 1, '5': 9, '10': 'sourceConceptId'},
    {'1': 'target_concept_id', '3': 4, '4': 1, '5': 9, '10': 'targetConceptId'},
    {
      '1': 'type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.wantstudy.v1.ConceptRelationType',
      '10': 'type'
    },
    {'1': 'version', '3': 6, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `ConceptRelation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conceptRelationDescriptor = $convert.base64Decode(
    'Cg9Db25jZXB0UmVsYXRpb24SDgoCaWQYASABKAlSAmlkEhkKCHN0dWR5X2lkGAIgASgJUgdzdH'
    'VkeUlkEioKEXNvdXJjZV9jb25jZXB0X2lkGAMgASgJUg9zb3VyY2VDb25jZXB0SWQSKgoRdGFy'
    'Z2V0X2NvbmNlcHRfaWQYBCABKAlSD3RhcmdldENvbmNlcHRJZBI1CgR0eXBlGAUgASgOMiEud2'
    'FudHN0dWR5LnYxLkNvbmNlcHRSZWxhdGlvblR5cGVSBHR5cGUSGAoHdmVyc2lvbhgGIAEoA1IH'
    'dmVyc2lvbg==');

@$core.Deprecated('Use createConceptRequestDescriptor instead')
const CreateConceptRequest$json = {
  '1': 'CreateConceptRequest',
  '2': [
    {
      '1': 'concept',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Concept',
      '10': 'concept'
    },
  ],
};

/// Descriptor for `CreateConceptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createConceptRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVDb25jZXB0UmVxdWVzdBIvCgdjb25jZXB0GAEgASgLMhUud2FudHN0dWR5LnYxLk'
    'NvbmNlcHRSB2NvbmNlcHQ=');

@$core.Deprecated('Use updateConceptRequestDescriptor instead')
const UpdateConceptRequest$json = {
  '1': 'UpdateConceptRequest',
  '2': [
    {
      '1': 'concept',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.Concept',
      '10': 'concept'
    },
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `UpdateConceptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateConceptRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVDb25jZXB0UmVxdWVzdBIvCgdjb25jZXB0GAEgASgLMhUud2FudHN0dWR5LnYxLk'
    'NvbmNlcHRSB2NvbmNlcHQSKQoQZXhwZWN0ZWRfdmVyc2lvbhgCIAEoA1IPZXhwZWN0ZWRWZXJz'
    'aW9u');

@$core.Deprecated('Use changeConceptAliasRequestDescriptor instead')
const ChangeConceptAliasRequest$json = {
  '1': 'ChangeConceptAliasRequest',
  '2': [
    {'1': 'concept_id', '3': 1, '4': 1, '5': 9, '10': 'conceptId'},
    {'1': 'alias', '3': 2, '4': 1, '5': 9, '10': 'alias'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `ChangeConceptAliasRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeConceptAliasRequestDescriptor = $convert.base64Decode(
    'ChlDaGFuZ2VDb25jZXB0QWxpYXNSZXF1ZXN0Eh0KCmNvbmNlcHRfaWQYASABKAlSCWNvbmNlcH'
    'RJZBIUCgVhbGlhcxgCIAEoCVIFYWxpYXMSKQoQZXhwZWN0ZWRfdmVyc2lvbhgDIAEoA1IPZXhw'
    'ZWN0ZWRWZXJzaW9u');

@$core.Deprecated('Use changeBlockConceptRequestDescriptor instead')
const ChangeBlockConceptRequest$json = {
  '1': 'ChangeBlockConceptRequest',
  '2': [
    {'1': 'concept_id', '3': 1, '4': 1, '5': 9, '10': 'conceptId'},
    {'1': 'block_id', '3': 2, '4': 1, '5': 9, '10': 'blockId'},
    {'1': 'expected_version', '3': 3, '4': 1, '5': 3, '10': 'expectedVersion'},
  ],
};

/// Descriptor for `ChangeBlockConceptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeBlockConceptRequestDescriptor = $convert.base64Decode(
    'ChlDaGFuZ2VCbG9ja0NvbmNlcHRSZXF1ZXN0Eh0KCmNvbmNlcHRfaWQYASABKAlSCWNvbmNlcH'
    'RJZBIZCghibG9ja19pZBgCIAEoCVIHYmxvY2tJZBIpChBleHBlY3RlZF92ZXJzaW9uGAMgASgD'
    'Ug9leHBlY3RlZFZlcnNpb24=');

@$core.Deprecated('Use putConceptRelationRequestDescriptor instead')
const PutConceptRelationRequest$json = {
  '1': 'PutConceptRelationRequest',
  '2': [
    {
      '1': 'relation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.wantstudy.v1.ConceptRelation',
      '10': 'relation'
    },
  ],
};

/// Descriptor for `PutConceptRelationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List putConceptRelationRequestDescriptor =
    $convert.base64Decode(
        'ChlQdXRDb25jZXB0UmVsYXRpb25SZXF1ZXN0EjkKCHJlbGF0aW9uGAEgASgLMh0ud2FudHN0dW'
        'R5LnYxLkNvbmNlcHRSZWxhdGlvblIIcmVsYXRpb24=');

@$core.Deprecated('Use deleteConceptRelationRequestDescriptor instead')
const DeleteConceptRelationRequest$json = {
  '1': 'DeleteConceptRelationRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'expected_version', '3': 2, '4': 1, '5': 3, '10': 'expectedVersion'},
    {'1': 'confirmed', '3': 3, '4': 1, '5': 8, '10': 'confirmed'},
  ],
};

/// Descriptor for `DeleteConceptRelationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteConceptRelationRequestDescriptor =
    $convert.base64Decode(
        'ChxEZWxldGVDb25jZXB0UmVsYXRpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIpChBleHBlY3'
        'RlZF92ZXJzaW9uGAIgASgDUg9leHBlY3RlZFZlcnNpb24SHAoJY29uZmlybWVkGAMgASgIUglj'
        'b25maXJtZWQ=');

@$core.Deprecated('Use deleteConceptRelationResponseDescriptor instead')
const DeleteConceptRelationResponse$json = {
  '1': 'DeleteConceptRelationResponse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteConceptRelationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteConceptRelationResponseDescriptor =
    $convert.base64Decode(
        'Ch1EZWxldGVDb25jZXB0UmVsYXRpb25SZXNwb25zZRIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use searchConceptsRequestDescriptor instead')
const SearchConceptsRequest$json = {
  '1': 'SearchConceptsRequest',
  '2': [
    {'1': 'study_id', '3': 1, '4': 1, '5': 9, '10': 'studyId'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
    {'1': 'include_archived', '3': 3, '4': 1, '5': 8, '10': 'includeArchived'},
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `SearchConceptsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchConceptsRequestDescriptor = $convert.base64Decode(
    'ChVTZWFyY2hDb25jZXB0c1JlcXVlc3QSGQoIc3R1ZHlfaWQYASABKAlSB3N0dWR5SWQSFAoFcX'
    'VlcnkYAiABKAlSBXF1ZXJ5EikKEGluY2x1ZGVfYXJjaGl2ZWQYAyABKAhSD2luY2x1ZGVBcmNo'
    'aXZlZBIUCgVsaW1pdBgEIAEoBVIFbGltaXQ=');

@$core.Deprecated('Use searchConceptsResponseDescriptor instead')
const SearchConceptsResponse$json = {
  '1': 'SearchConceptsResponse',
  '2': [
    {
      '1': 'concepts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.Concept',
      '10': 'concepts'
    },
  ],
};

/// Descriptor for `SearchConceptsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchConceptsResponseDescriptor =
    $convert.base64Decode(
        'ChZTZWFyY2hDb25jZXB0c1Jlc3BvbnNlEjEKCGNvbmNlcHRzGAEgAygLMhUud2FudHN0dWR5Ln'
        'YxLkNvbmNlcHRSCGNvbmNlcHRz');

@$core.Deprecated('Use getConceptGraphRequestDescriptor instead')
const GetConceptGraphRequest$json = {
  '1': 'GetConceptGraphRequest',
  '2': [
    {'1': 'study_id', '3': 1, '4': 1, '5': 9, '10': 'studyId'},
    {
      '1': 'selected_concept_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'selectedConceptId',
      '17': true
    },
  ],
  '8': [
    {'1': '_selected_concept_id'},
  ],
};

/// Descriptor for `GetConceptGraphRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConceptGraphRequestDescriptor = $convert.base64Decode(
    'ChZHZXRDb25jZXB0R3JhcGhSZXF1ZXN0EhkKCHN0dWR5X2lkGAEgASgJUgdzdHVkeUlkEjMKE3'
    'NlbGVjdGVkX2NvbmNlcHRfaWQYAiABKAlIAFIRc2VsZWN0ZWRDb25jZXB0SWSIAQFCFgoUX3Nl'
    'bGVjdGVkX2NvbmNlcHRfaWQ=');

@$core.Deprecated('Use conceptGraphDescriptor instead')
const ConceptGraph$json = {
  '1': 'ConceptGraph',
  '2': [
    {
      '1': 'concepts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.Concept',
      '10': 'concepts'
    },
    {
      '1': 'relations',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.wantstudy.v1.ConceptRelation',
      '10': 'relations'
    },
    {'1': 'truncated', '3': 3, '4': 1, '5': 8, '10': 'truncated'},
  ],
};

/// Descriptor for `ConceptGraph`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conceptGraphDescriptor = $convert.base64Decode(
    'CgxDb25jZXB0R3JhcGgSMQoIY29uY2VwdHMYASADKAsyFS53YW50c3R1ZHkudjEuQ29uY2VwdF'
    'IIY29uY2VwdHMSOwoJcmVsYXRpb25zGAIgAygLMh0ud2FudHN0dWR5LnYxLkNvbmNlcHRSZWxh'
    'dGlvblIJcmVsYXRpb25zEhwKCXRydW5jYXRlZBgDIAEoCFIJdHJ1bmNhdGVk');
