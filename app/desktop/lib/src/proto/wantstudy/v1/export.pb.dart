// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/export.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class RenderStudyExportRequest extends $pb.GeneratedMessage {
  factory RenderStudyExportRequest({
    $core.String? studyId,
    $fixnum.Int64? expectedContentRevision,
  }) {
    final result = RenderStudyExportRequest._();
    if (studyId != null) result.studyId = studyId;
    if (expectedContentRevision != null)
      result.expectedContentRevision = expectedContentRevision;
    return result;
  }

  RenderStudyExportRequest._();

  factory RenderStudyExportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RenderStudyExportRequest()..mergeFromBuffer(data, registry);
  factory RenderStudyExportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RenderStudyExportRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RenderStudyExportRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: RenderStudyExportRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'studyId')
    ..aInt64(2, _omitFieldNames ? '' : 'expectedContentRevision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenderStudyExportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenderStudyExportRequest copyWith(
          void Function(RenderStudyExportRequest) updates) =>
      super.copyWith((message) => updates(message as RenderStudyExportRequest))
          as RenderStudyExportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RenderStudyExportRequest() / RenderStudyExportRequest.new instead')
  static RenderStudyExportRequest create() => RenderStudyExportRequest._();
  static $pb.GeneratedMessage $_createMessage() => RenderStudyExportRequest._();
  @$core.override
  RenderStudyExportRequest createEmptyInstance() =>
      RenderStudyExportRequest._();
  @$core.pragma('dart2js:noInline')
  static RenderStudyExportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RenderStudyExportRequest>(
          RenderStudyExportRequest.$_createMessage);
  static RenderStudyExportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get studyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set studyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStudyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedContentRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedContentRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedContentRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedContentRevision() => $_clearField(2);
}

class ExportHeader extends $pb.GeneratedMessage {
  factory ExportHeader({
    $core.String? studyId,
    $fixnum.Int64? studyRevision,
    $fixnum.Int64? totalBytes,
    $core.int? fileCount,
  }) {
    final result = ExportHeader._();
    if (studyId != null) result.studyId = studyId;
    if (studyRevision != null) result.studyRevision = studyRevision;
    if (totalBytes != null) result.totalBytes = totalBytes;
    if (fileCount != null) result.fileCount = fileCount;
    return result;
  }

  ExportHeader._();

  factory ExportHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportHeader()..mergeFromBuffer(data, registry);
  factory ExportHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportHeader()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ExportHeader.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'studyId')
    ..aInt64(2, _omitFieldNames ? '' : 'studyRevision')
    ..aInt64(3, _omitFieldNames ? '' : 'totalBytes')
    ..aI(4, _omitFieldNames ? '' : 'fileCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportHeader copyWith(void Function(ExportHeader) updates) =>
      super.copyWith((message) => updates(message as ExportHeader))
          as ExportHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportHeader() / ExportHeader.new instead')
  static ExportHeader create() => ExportHeader._();
  static $pb.GeneratedMessage $_createMessage() => ExportHeader._();
  @$core.override
  ExportHeader createEmptyInstance() => ExportHeader._();
  @$core.pragma('dart2js:noInline')
  static ExportHeader getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExportHeader>(
          ExportHeader.$_createMessage);
  static ExportHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get studyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set studyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStudyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get studyRevision => $_getI64(1);
  @$pb.TagNumber(2)
  set studyRevision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStudyRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearStudyRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set totalBytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get fileCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set fileCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFileCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileCount() => $_clearField(4);
}

class ExportFile extends $pb.GeneratedMessage {
  factory ExportFile({
    $core.String? path,
    $core.List<$core.int>? content,
    $core.String? sha256,
  }) {
    final result = ExportFile._();
    if (path != null) result.path = path;
    if (content != null) result.content = content;
    if (sha256 != null) result.sha256 = sha256;
    return result;
  }

  ExportFile._();

  factory ExportFile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportFile()..mergeFromBuffer(data, registry);
  factory ExportFile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportFile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ExportFile.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'sha256')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportFile copyWith(void Function(ExportFile) updates) =>
      super.copyWith((message) => updates(message as ExportFile)) as ExportFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportFile() / ExportFile.new instead')
  static ExportFile create() => ExportFile._();
  static $pb.GeneratedMessage $_createMessage() => ExportFile._();
  @$core.override
  ExportFile createEmptyInstance() => ExportFile._();
  @$core.pragma('dart2js:noInline')
  static ExportFile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportFile>(ExportFile.$_createMessage);
  static ExportFile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sha256 => $_getSZ(2);
  @$pb.TagNumber(3)
  set sha256($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSha256() => $_has(2);
  @$pb.TagNumber(3)
  void clearSha256() => $_clearField(3);
}

enum ExportChunk_Value { header, file, notSet }

class ExportChunk extends $pb.GeneratedMessage {
  factory ExportChunk({
    ExportHeader? header,
    ExportFile? file,
  }) {
    final result = ExportChunk._();
    if (header != null) result.header = header;
    if (file != null) result.file = file;
    return result;
  }

  ExportChunk._();

  factory ExportChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportChunk()..mergeFromBuffer(data, registry);
  factory ExportChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportChunk()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ExportChunk_Value> _ExportChunk_ValueByTag =
      {
    1: ExportChunk_Value.header,
    2: ExportChunk_Value.file,
    0: ExportChunk_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ExportChunk.$_createMessage)
    ..oo(0, [1, 2])
    ..aOM<ExportHeader>(1, _omitFieldNames ? '' : 'header',
        subBuilder: ExportHeader.$_createMessage)
    ..aOM<ExportFile>(2, _omitFieldNames ? '' : 'file',
        subBuilder: ExportFile.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportChunk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportChunk copyWith(void Function(ExportChunk) updates) =>
      super.copyWith((message) => updates(message as ExportChunk))
          as ExportChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportChunk() / ExportChunk.new instead')
  static ExportChunk create() => ExportChunk._();
  static $pb.GeneratedMessage $_createMessage() => ExportChunk._();
  @$core.override
  ExportChunk createEmptyInstance() => ExportChunk._();
  @$core.pragma('dart2js:noInline')
  static ExportChunk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExportChunk>(
          ExportChunk.$_createMessage);
  static ExportChunk? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ExportChunk_Value whichValue() => _ExportChunk_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ExportHeader get header => $_getN(0);
  @$pb.TagNumber(1)
  set header(ExportHeader value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeader() => $_clearField(1);
  @$pb.TagNumber(1)
  ExportHeader ensureHeader() => $_ensure(0);

  @$pb.TagNumber(2)
  ExportFile get file => $_getN(1);
  @$pb.TagNumber(2)
  set file(ExportFile value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFile() => $_has(1);
  @$pb.TagNumber(2)
  void clearFile() => $_clearField(2);
  @$pb.TagNumber(2)
  ExportFile ensureFile() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
