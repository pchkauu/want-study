// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/knowledge.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ConceptRelationType extends $pb.ProtobufEnum {
  static const ConceptRelationType CONCEPT_RELATION_TYPE_UNSPECIFIED =
      ConceptRelationType._(
          0, _omitEnumNames ? '' : 'CONCEPT_RELATION_TYPE_UNSPECIFIED');
  static const ConceptRelationType CONCEPT_RELATION_TYPE_RELATED_TO =
      ConceptRelationType._(
          1, _omitEnumNames ? '' : 'CONCEPT_RELATION_TYPE_RELATED_TO');
  static const ConceptRelationType CONCEPT_RELATION_TYPE_PART_OF =
      ConceptRelationType._(
          2, _omitEnumNames ? '' : 'CONCEPT_RELATION_TYPE_PART_OF');
  static const ConceptRelationType CONCEPT_RELATION_TYPE_PREREQUISITE_FOR =
      ConceptRelationType._(
          3, _omitEnumNames ? '' : 'CONCEPT_RELATION_TYPE_PREREQUISITE_FOR');
  static const ConceptRelationType CONCEPT_RELATION_TYPE_CONTRASTS_WITH =
      ConceptRelationType._(
          4, _omitEnumNames ? '' : 'CONCEPT_RELATION_TYPE_CONTRASTS_WITH');
  static const ConceptRelationType CONCEPT_RELATION_TYPE_APPLIES_TO =
      ConceptRelationType._(
          5, _omitEnumNames ? '' : 'CONCEPT_RELATION_TYPE_APPLIES_TO');

  static const $core.List<ConceptRelationType> values = <ConceptRelationType>[
    CONCEPT_RELATION_TYPE_UNSPECIFIED,
    CONCEPT_RELATION_TYPE_RELATED_TO,
    CONCEPT_RELATION_TYPE_PART_OF,
    CONCEPT_RELATION_TYPE_PREREQUISITE_FOR,
    CONCEPT_RELATION_TYPE_CONTRASTS_WITH,
    CONCEPT_RELATION_TYPE_APPLIES_TO,
  ];

  static final $core.List<ConceptRelationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ConceptRelationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ConceptRelationType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
