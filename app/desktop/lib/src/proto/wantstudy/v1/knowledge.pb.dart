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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'knowledge.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'knowledge.pbenum.dart';

class Concept extends $pb.GeneratedMessage {
  factory Concept({
    $core.String? id,
    $core.String? studyId,
    $core.String? title,
    $core.String? descriptionMarkdown,
    $core.String? exportSlug,
    $core.Iterable<$core.String>? aliases,
    $core.Iterable<$core.String>? blockIds,
    $fixnum.Int64? version,
    $core.bool? archived,
  }) {
    final result = Concept._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (title != null) result.title = title;
    if (descriptionMarkdown != null)
      result.descriptionMarkdown = descriptionMarkdown;
    if (exportSlug != null) result.exportSlug = exportSlug;
    if (aliases != null) result.aliases.addAll(aliases);
    if (blockIds != null) result.blockIds.addAll(blockIds);
    if (version != null) result.version = version;
    if (archived != null) result.archived = archived;
    return result;
  }

  Concept._();

  factory Concept.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Concept()..mergeFromBuffer(data, registry);
  factory Concept.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Concept()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Concept',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: Concept.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'descriptionMarkdown')
    ..aOS(5, _omitFieldNames ? '' : 'exportSlug')
    ..pPS(6, _omitFieldNames ? '' : 'aliases')
    ..pPS(7, _omitFieldNames ? '' : 'blockIds')
    ..aInt64(8, _omitFieldNames ? '' : 'version')
    ..aOB(9, _omitFieldNames ? '' : 'archived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Concept clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Concept copyWith(void Function(Concept) updates) =>
      super.copyWith((message) => updates(message as Concept)) as Concept;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Concept() / Concept.new instead')
  static Concept create() => Concept._();
  static $pb.GeneratedMessage $_createMessage() => Concept._();
  @$core.override
  Concept createEmptyInstance() => Concept._();
  @$core.pragma('dart2js:noInline')
  static Concept getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Concept>(Concept.$_createMessage);
  static Concept? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get studyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set studyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStudyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearStudyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get descriptionMarkdown => $_getSZ(3);
  @$pb.TagNumber(4)
  set descriptionMarkdown($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescriptionMarkdown() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescriptionMarkdown() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get exportSlug => $_getSZ(4);
  @$pb.TagNumber(5)
  set exportSlug($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExportSlug() => $_has(4);
  @$pb.TagNumber(5)
  void clearExportSlug() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get aliases => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get blockIds => $_getList(6);

  @$pb.TagNumber(8)
  $fixnum.Int64 get version => $_getI64(7);
  @$pb.TagNumber(8)
  set version($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get archived => $_getBF(8);
  @$pb.TagNumber(9)
  set archived($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasArchived() => $_has(8);
  @$pb.TagNumber(9)
  void clearArchived() => $_clearField(9);
}

class ConceptRelation extends $pb.GeneratedMessage {
  factory ConceptRelation({
    $core.String? id,
    $core.String? studyId,
    $core.String? sourceConceptId,
    $core.String? targetConceptId,
    ConceptRelationType? type,
    $fixnum.Int64? version,
  }) {
    final result = ConceptRelation._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (sourceConceptId != null) result.sourceConceptId = sourceConceptId;
    if (targetConceptId != null) result.targetConceptId = targetConceptId;
    if (type != null) result.type = type;
    if (version != null) result.version = version;
    return result;
  }

  ConceptRelation._();

  factory ConceptRelation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConceptRelation()..mergeFromBuffer(data, registry);
  factory ConceptRelation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConceptRelation()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConceptRelation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ConceptRelation.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceConceptId')
    ..aOS(4, _omitFieldNames ? '' : 'targetConceptId')
    ..aE<ConceptRelationType>(5, _omitFieldNames ? '' : 'type',
        enumValues: ConceptRelationType.values)
    ..aInt64(6, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConceptRelation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConceptRelation copyWith(void Function(ConceptRelation) updates) =>
      super.copyWith((message) => updates(message as ConceptRelation))
          as ConceptRelation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConceptRelation() / ConceptRelation.new instead')
  static ConceptRelation create() => ConceptRelation._();
  static $pb.GeneratedMessage $_createMessage() => ConceptRelation._();
  @$core.override
  ConceptRelation createEmptyInstance() => ConceptRelation._();
  @$core.pragma('dart2js:noInline')
  static ConceptRelation getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConceptRelation>(
          ConceptRelation.$_createMessage);
  static ConceptRelation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get studyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set studyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStudyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearStudyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sourceConceptId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceConceptId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceConceptId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceConceptId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get targetConceptId => $_getSZ(3);
  @$pb.TagNumber(4)
  set targetConceptId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetConceptId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetConceptId() => $_clearField(4);

  @$pb.TagNumber(5)
  ConceptRelationType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(ConceptRelationType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get version => $_getI64(5);
  @$pb.TagNumber(6)
  set version($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);
}

class CreateConceptRequest extends $pb.GeneratedMessage {
  factory CreateConceptRequest({
    Concept? concept,
  }) {
    final result = CreateConceptRequest._();
    if (concept != null) result.concept = concept;
    return result;
  }

  CreateConceptRequest._();

  factory CreateConceptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateConceptRequest()..mergeFromBuffer(data, registry);
  factory CreateConceptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateConceptRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateConceptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateConceptRequest.$_createMessage)
    ..aOM<Concept>(1, _omitFieldNames ? '' : 'concept',
        subBuilder: Concept.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConceptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateConceptRequest copyWith(void Function(CreateConceptRequest) updates) =>
      super.copyWith((message) => updates(message as CreateConceptRequest))
          as CreateConceptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateConceptRequest() / CreateConceptRequest.new instead')
  static CreateConceptRequest create() => CreateConceptRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateConceptRequest._();
  @$core.override
  CreateConceptRequest createEmptyInstance() => CreateConceptRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateConceptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateConceptRequest>(
          CreateConceptRequest.$_createMessage);
  static CreateConceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Concept get concept => $_getN(0);
  @$pb.TagNumber(1)
  set concept(Concept value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConcept() => $_has(0);
  @$pb.TagNumber(1)
  void clearConcept() => $_clearField(1);
  @$pb.TagNumber(1)
  Concept ensureConcept() => $_ensure(0);
}

class UpdateConceptRequest extends $pb.GeneratedMessage {
  factory UpdateConceptRequest({
    Concept? concept,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateConceptRequest._();
    if (concept != null) result.concept = concept;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateConceptRequest._();

  factory UpdateConceptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateConceptRequest()..mergeFromBuffer(data, registry);
  factory UpdateConceptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateConceptRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateConceptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateConceptRequest.$_createMessage)
    ..aOM<Concept>(1, _omitFieldNames ? '' : 'concept',
        subBuilder: Concept.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateConceptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateConceptRequest copyWith(void Function(UpdateConceptRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateConceptRequest))
          as UpdateConceptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateConceptRequest() / UpdateConceptRequest.new instead')
  static UpdateConceptRequest create() => UpdateConceptRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateConceptRequest._();
  @$core.override
  UpdateConceptRequest createEmptyInstance() => UpdateConceptRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateConceptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateConceptRequest>(
          UpdateConceptRequest.$_createMessage);
  static UpdateConceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Concept get concept => $_getN(0);
  @$pb.TagNumber(1)
  set concept(Concept value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConcept() => $_has(0);
  @$pb.TagNumber(1)
  void clearConcept() => $_clearField(1);
  @$pb.TagNumber(1)
  Concept ensureConcept() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);
}

class ChangeConceptAliasRequest extends $pb.GeneratedMessage {
  factory ChangeConceptAliasRequest({
    $core.String? conceptId,
    $core.String? alias,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = ChangeConceptAliasRequest._();
    if (conceptId != null) result.conceptId = conceptId;
    if (alias != null) result.alias = alias;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  ChangeConceptAliasRequest._();

  factory ChangeConceptAliasRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeConceptAliasRequest()..mergeFromBuffer(data, registry);
  factory ChangeConceptAliasRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeConceptAliasRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeConceptAliasRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ChangeConceptAliasRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'conceptId')
    ..aOS(2, _omitFieldNames ? '' : 'alias')
    ..aInt64(3, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeConceptAliasRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeConceptAliasRequest copyWith(
          void Function(ChangeConceptAliasRequest) updates) =>
      super.copyWith((message) => updates(message as ChangeConceptAliasRequest))
          as ChangeConceptAliasRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChangeConceptAliasRequest() / ChangeConceptAliasRequest.new instead')
  static ChangeConceptAliasRequest create() => ChangeConceptAliasRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ChangeConceptAliasRequest._();
  @$core.override
  ChangeConceptAliasRequest createEmptyInstance() =>
      ChangeConceptAliasRequest._();
  @$core.pragma('dart2js:noInline')
  static ChangeConceptAliasRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeConceptAliasRequest>(
          ChangeConceptAliasRequest.$_createMessage);
  static ChangeConceptAliasRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conceptId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conceptId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConceptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConceptId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get alias => $_getSZ(1);
  @$pb.TagNumber(2)
  set alias($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlias() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlias() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expectedVersion => $_getI64(2);
  @$pb.TagNumber(3)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);
}

class ChangeBlockConceptRequest extends $pb.GeneratedMessage {
  factory ChangeBlockConceptRequest({
    $core.String? conceptId,
    $core.String? blockId,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = ChangeBlockConceptRequest._();
    if (conceptId != null) result.conceptId = conceptId;
    if (blockId != null) result.blockId = blockId;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  ChangeBlockConceptRequest._();

  factory ChangeBlockConceptRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeBlockConceptRequest()..mergeFromBuffer(data, registry);
  factory ChangeBlockConceptRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeBlockConceptRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeBlockConceptRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ChangeBlockConceptRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'conceptId')
    ..aOS(2, _omitFieldNames ? '' : 'blockId')
    ..aInt64(3, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeBlockConceptRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeBlockConceptRequest copyWith(
          void Function(ChangeBlockConceptRequest) updates) =>
      super.copyWith((message) => updates(message as ChangeBlockConceptRequest))
          as ChangeBlockConceptRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChangeBlockConceptRequest() / ChangeBlockConceptRequest.new instead')
  static ChangeBlockConceptRequest create() => ChangeBlockConceptRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ChangeBlockConceptRequest._();
  @$core.override
  ChangeBlockConceptRequest createEmptyInstance() =>
      ChangeBlockConceptRequest._();
  @$core.pragma('dart2js:noInline')
  static ChangeBlockConceptRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeBlockConceptRequest>(
          ChangeBlockConceptRequest.$_createMessage);
  static ChangeBlockConceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conceptId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conceptId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConceptId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConceptId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockId => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expectedVersion => $_getI64(2);
  @$pb.TagNumber(3)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);
}

class PutConceptRelationRequest extends $pb.GeneratedMessage {
  factory PutConceptRelationRequest({
    ConceptRelation? relation,
  }) {
    final result = PutConceptRelationRequest._();
    if (relation != null) result.relation = relation;
    return result;
  }

  PutConceptRelationRequest._();

  factory PutConceptRelationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PutConceptRelationRequest()..mergeFromBuffer(data, registry);
  factory PutConceptRelationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PutConceptRelationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PutConceptRelationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: PutConceptRelationRequest.$_createMessage)
    ..aOM<ConceptRelation>(1, _omitFieldNames ? '' : 'relation',
        subBuilder: ConceptRelation.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutConceptRelationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PutConceptRelationRequest copyWith(
          void Function(PutConceptRelationRequest) updates) =>
      super.copyWith((message) => updates(message as PutConceptRelationRequest))
          as PutConceptRelationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PutConceptRelationRequest() / PutConceptRelationRequest.new instead')
  static PutConceptRelationRequest create() => PutConceptRelationRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      PutConceptRelationRequest._();
  @$core.override
  PutConceptRelationRequest createEmptyInstance() =>
      PutConceptRelationRequest._();
  @$core.pragma('dart2js:noInline')
  static PutConceptRelationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PutConceptRelationRequest>(
          PutConceptRelationRequest.$_createMessage);
  static PutConceptRelationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  ConceptRelation get relation => $_getN(0);
  @$pb.TagNumber(1)
  set relation(ConceptRelation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRelation() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelation() => $_clearField(1);
  @$pb.TagNumber(1)
  ConceptRelation ensureRelation() => $_ensure(0);
}

class DeleteConceptRelationRequest extends $pb.GeneratedMessage {
  factory DeleteConceptRelationRequest({
    $core.String? id,
    $fixnum.Int64? expectedVersion,
    $core.bool? confirmed,
  }) {
    final result = DeleteConceptRelationRequest._();
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (confirmed != null) result.confirmed = confirmed;
    return result;
  }

  DeleteConceptRelationRequest._();

  factory DeleteConceptRelationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteConceptRelationRequest()..mergeFromBuffer(data, registry);
  factory DeleteConceptRelationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteConceptRelationRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteConceptRelationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: DeleteConceptRelationRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..aOB(3, _omitFieldNames ? '' : 'confirmed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConceptRelationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConceptRelationRequest copyWith(
          void Function(DeleteConceptRelationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteConceptRelationRequest))
          as DeleteConceptRelationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DeleteConceptRelationRequest() / DeleteConceptRelationRequest.new instead')
  static DeleteConceptRelationRequest create() =>
      DeleteConceptRelationRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      DeleteConceptRelationRequest._();
  @$core.override
  DeleteConceptRelationRequest createEmptyInstance() =>
      DeleteConceptRelationRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteConceptRelationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteConceptRelationRequest>(
          DeleteConceptRelationRequest.$_createMessage);
  static DeleteConceptRelationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get confirmed => $_getBF(2);
  @$pb.TagNumber(3)
  set confirmed($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfirmed() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmed() => $_clearField(3);
}

class DeleteConceptRelationResponse extends $pb.GeneratedMessage {
  factory DeleteConceptRelationResponse({
    $core.String? id,
  }) {
    final result = DeleteConceptRelationResponse._();
    if (id != null) result.id = id;
    return result;
  }

  DeleteConceptRelationResponse._();

  factory DeleteConceptRelationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteConceptRelationResponse()..mergeFromBuffer(data, registry);
  factory DeleteConceptRelationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteConceptRelationResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteConceptRelationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: DeleteConceptRelationResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConceptRelationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteConceptRelationResponse copyWith(
          void Function(DeleteConceptRelationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteConceptRelationResponse))
          as DeleteConceptRelationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DeleteConceptRelationResponse() / DeleteConceptRelationResponse.new instead')
  static DeleteConceptRelationResponse create() =>
      DeleteConceptRelationResponse._();
  static $pb.GeneratedMessage $_createMessage() =>
      DeleteConceptRelationResponse._();
  @$core.override
  DeleteConceptRelationResponse createEmptyInstance() =>
      DeleteConceptRelationResponse._();
  @$core.pragma('dart2js:noInline')
  static DeleteConceptRelationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteConceptRelationResponse>(
          DeleteConceptRelationResponse.$_createMessage);
  static DeleteConceptRelationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SearchConceptsRequest extends $pb.GeneratedMessage {
  factory SearchConceptsRequest({
    $core.String? studyId,
    $core.String? query,
    $core.bool? includeArchived,
    $core.int? limit,
  }) {
    final result = SearchConceptsRequest._();
    if (studyId != null) result.studyId = studyId;
    if (query != null) result.query = query;
    if (includeArchived != null) result.includeArchived = includeArchived;
    if (limit != null) result.limit = limit;
    return result;
  }

  SearchConceptsRequest._();

  factory SearchConceptsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchConceptsRequest()..mergeFromBuffer(data, registry);
  factory SearchConceptsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchConceptsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchConceptsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: SearchConceptsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'studyId')
    ..aOS(2, _omitFieldNames ? '' : 'query')
    ..aOB(3, _omitFieldNames ? '' : 'includeArchived')
    ..aI(4, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchConceptsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchConceptsRequest copyWith(
          void Function(SearchConceptsRequest) updates) =>
      super.copyWith((message) => updates(message as SearchConceptsRequest))
          as SearchConceptsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SearchConceptsRequest() / SearchConceptsRequest.new instead')
  static SearchConceptsRequest create() => SearchConceptsRequest._();
  static $pb.GeneratedMessage $_createMessage() => SearchConceptsRequest._();
  @$core.override
  SearchConceptsRequest createEmptyInstance() => SearchConceptsRequest._();
  @$core.pragma('dart2js:noInline')
  static SearchConceptsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchConceptsRequest>(
          SearchConceptsRequest.$_createMessage);
  static SearchConceptsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get studyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set studyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStudyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get query => $_getSZ(1);
  @$pb.TagNumber(2)
  set query($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuery() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuery() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get includeArchived => $_getBF(2);
  @$pb.TagNumber(3)
  set includeArchived($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIncludeArchived() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncludeArchived() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);
}

class SearchConceptsResponse extends $pb.GeneratedMessage {
  factory SearchConceptsResponse({
    $core.Iterable<Concept>? concepts,
  }) {
    final result = SearchConceptsResponse._();
    if (concepts != null) result.concepts.addAll(concepts);
    return result;
  }

  SearchConceptsResponse._();

  factory SearchConceptsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchConceptsResponse()..mergeFromBuffer(data, registry);
  factory SearchConceptsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SearchConceptsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchConceptsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: SearchConceptsResponse.$_createMessage)
    ..pPM<Concept>(1, _omitFieldNames ? '' : 'concepts',
        subBuilder: Concept.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchConceptsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchConceptsResponse copyWith(
          void Function(SearchConceptsResponse) updates) =>
      super.copyWith((message) => updates(message as SearchConceptsResponse))
          as SearchConceptsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SearchConceptsResponse() / SearchConceptsResponse.new instead')
  static SearchConceptsResponse create() => SearchConceptsResponse._();
  static $pb.GeneratedMessage $_createMessage() => SearchConceptsResponse._();
  @$core.override
  SearchConceptsResponse createEmptyInstance() => SearchConceptsResponse._();
  @$core.pragma('dart2js:noInline')
  static SearchConceptsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchConceptsResponse>(
          SearchConceptsResponse.$_createMessage);
  static SearchConceptsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Concept> get concepts => $_getList(0);
}

class GetConceptGraphRequest extends $pb.GeneratedMessage {
  factory GetConceptGraphRequest({
    $core.String? studyId,
    $core.String? selectedConceptId,
  }) {
    final result = GetConceptGraphRequest._();
    if (studyId != null) result.studyId = studyId;
    if (selectedConceptId != null) result.selectedConceptId = selectedConceptId;
    return result;
  }

  GetConceptGraphRequest._();

  factory GetConceptGraphRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetConceptGraphRequest()..mergeFromBuffer(data, registry);
  factory GetConceptGraphRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetConceptGraphRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConceptGraphRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: GetConceptGraphRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'studyId')
    ..aOS(2, _omitFieldNames ? '' : 'selectedConceptId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConceptGraphRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConceptGraphRequest copyWith(
          void Function(GetConceptGraphRequest) updates) =>
      super.copyWith((message) => updates(message as GetConceptGraphRequest))
          as GetConceptGraphRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetConceptGraphRequest() / GetConceptGraphRequest.new instead')
  static GetConceptGraphRequest create() => GetConceptGraphRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetConceptGraphRequest._();
  @$core.override
  GetConceptGraphRequest createEmptyInstance() => GetConceptGraphRequest._();
  @$core.pragma('dart2js:noInline')
  static GetConceptGraphRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConceptGraphRequest>(
          GetConceptGraphRequest.$_createMessage);
  static GetConceptGraphRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get studyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set studyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStudyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get selectedConceptId => $_getSZ(1);
  @$pb.TagNumber(2)
  set selectedConceptId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSelectedConceptId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSelectedConceptId() => $_clearField(2);
}

class ConceptGraph extends $pb.GeneratedMessage {
  factory ConceptGraph({
    $core.Iterable<Concept>? concepts,
    $core.Iterable<ConceptRelation>? relations,
    $core.bool? truncated,
  }) {
    final result = ConceptGraph._();
    if (concepts != null) result.concepts.addAll(concepts);
    if (relations != null) result.relations.addAll(relations);
    if (truncated != null) result.truncated = truncated;
    return result;
  }

  ConceptGraph._();

  factory ConceptGraph.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConceptGraph()..mergeFromBuffer(data, registry);
  factory ConceptGraph.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConceptGraph()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConceptGraph',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ConceptGraph.$_createMessage)
    ..pPM<Concept>(1, _omitFieldNames ? '' : 'concepts',
        subBuilder: Concept.$_createMessage)
    ..pPM<ConceptRelation>(2, _omitFieldNames ? '' : 'relations',
        subBuilder: ConceptRelation.$_createMessage)
    ..aOB(3, _omitFieldNames ? '' : 'truncated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConceptGraph clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConceptGraph copyWith(void Function(ConceptGraph) updates) =>
      super.copyWith((message) => updates(message as ConceptGraph))
          as ConceptGraph;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConceptGraph() / ConceptGraph.new instead')
  static ConceptGraph create() => ConceptGraph._();
  static $pb.GeneratedMessage $_createMessage() => ConceptGraph._();
  @$core.override
  ConceptGraph createEmptyInstance() => ConceptGraph._();
  @$core.pragma('dart2js:noInline')
  static ConceptGraph getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConceptGraph>(
          ConceptGraph.$_createMessage);
  static ConceptGraph? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Concept> get concepts => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<ConceptRelation> get relations => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get truncated => $_getBF(2);
  @$pb.TagNumber(3)
  set truncated($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTruncated() => $_has(2);
  @$pb.TagNumber(3)
  void clearTruncated() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
