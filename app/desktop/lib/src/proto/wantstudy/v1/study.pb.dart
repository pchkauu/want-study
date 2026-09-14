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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'study.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'study.pbenum.dart';

class Study extends $pb.GeneratedMessage {
  factory Study({
    $core.String? id,
    $core.String? title,
    $core.String? goal,
    $core.String? localRepositoryPath,
    $fixnum.Int64? version,
    $fixnum.Int64? contentRevision,
    $core.bool? archived,
    $fixnum.Int64? createdAtEpochMillis,
    $fixnum.Int64? updatedAtEpochMillis,
  }) {
    final result = Study._();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (goal != null) result.goal = goal;
    if (localRepositoryPath != null)
      result.localRepositoryPath = localRepositoryPath;
    if (version != null) result.version = version;
    if (contentRevision != null) result.contentRevision = contentRevision;
    if (archived != null) result.archived = archived;
    if (createdAtEpochMillis != null)
      result.createdAtEpochMillis = createdAtEpochMillis;
    if (updatedAtEpochMillis != null)
      result.updatedAtEpochMillis = updatedAtEpochMillis;
    return result;
  }

  Study._();

  factory Study.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Study()..mergeFromBuffer(data, registry);
  factory Study.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Study()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Study',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: Study.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'goal')
    ..aOS(4, _omitFieldNames ? '' : 'localRepositoryPath')
    ..aInt64(5, _omitFieldNames ? '' : 'version')
    ..aInt64(6, _omitFieldNames ? '' : 'contentRevision')
    ..aOB(7, _omitFieldNames ? '' : 'archived')
    ..aInt64(8, _omitFieldNames ? '' : 'createdAtEpochMillis')
    ..aInt64(9, _omitFieldNames ? '' : 'updatedAtEpochMillis')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Study clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Study copyWith(void Function(Study) updates) =>
      super.copyWith((message) => updates(message as Study)) as Study;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Study() / Study.new instead')
  static Study create() => Study._();
  static $pb.GeneratedMessage $_createMessage() => Study._();
  @$core.override
  Study createEmptyInstance() => Study._();
  @$core.pragma('dart2js:noInline')
  static Study getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Study>(Study.$_createMessage);
  static Study? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get goal => $_getSZ(2);
  @$pb.TagNumber(3)
  set goal($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGoal() => $_has(2);
  @$pb.TagNumber(3)
  void clearGoal() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get localRepositoryPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set localRepositoryPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocalRepositoryPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalRepositoryPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get version => $_getI64(4);
  @$pb.TagNumber(5)
  set version($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get contentRevision => $_getI64(5);
  @$pb.TagNumber(6)
  set contentRevision($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContentRevision() => $_has(5);
  @$pb.TagNumber(6)
  void clearContentRevision() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get archived => $_getBF(6);
  @$pb.TagNumber(7)
  set archived($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasArchived() => $_has(6);
  @$pb.TagNumber(7)
  void clearArchived() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAtEpochMillis => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAtEpochMillis($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAtEpochMillis() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAtEpochMillis() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get updatedAtEpochMillis => $_getI64(8);
  @$pb.TagNumber(9)
  set updatedAtEpochMillis($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAtEpochMillis() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAtEpochMillis() => $_clearField(9);
}

class LearningSource extends $pb.GeneratedMessage {
  factory LearningSource({
    $core.String? id,
    $core.String? studyId,
    LearningSourceType? type,
    $core.String? title,
    $core.String? author,
    $core.String? url,
    $core.String? exportSlug,
    $core.int? position,
    $fixnum.Int64? version,
    $core.bool? archived,
  }) {
    final result = LearningSource._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (author != null) result.author = author;
    if (url != null) result.url = url;
    if (exportSlug != null) result.exportSlug = exportSlug;
    if (position != null) result.position = position;
    if (version != null) result.version = version;
    if (archived != null) result.archived = archived;
    return result;
  }

  LearningSource._();

  factory LearningSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LearningSource()..mergeFromBuffer(data, registry);
  factory LearningSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LearningSource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LearningSource',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: LearningSource.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aE<LearningSourceType>(3, _omitFieldNames ? '' : 'type',
        enumValues: LearningSourceType.values)
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'author')
    ..aOS(6, _omitFieldNames ? '' : 'url')
    ..aOS(7, _omitFieldNames ? '' : 'exportSlug')
    ..aI(8, _omitFieldNames ? '' : 'position')
    ..aInt64(9, _omitFieldNames ? '' : 'version')
    ..aOB(10, _omitFieldNames ? '' : 'archived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LearningSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LearningSource copyWith(void Function(LearningSource) updates) =>
      super.copyWith((message) => updates(message as LearningSource))
          as LearningSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LearningSource() / LearningSource.new instead')
  static LearningSource create() => LearningSource._();
  static $pb.GeneratedMessage $_createMessage() => LearningSource._();
  @$core.override
  LearningSource createEmptyInstance() => LearningSource._();
  @$core.pragma('dart2js:noInline')
  static LearningSource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LearningSource>(
          LearningSource.$_createMessage);
  static LearningSource? _defaultInstance;

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
  LearningSourceType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(LearningSourceType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get author => $_getSZ(4);
  @$pb.TagNumber(5)
  set author($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAuthor() => $_has(4);
  @$pb.TagNumber(5)
  void clearAuthor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get exportSlug => $_getSZ(6);
  @$pb.TagNumber(7)
  set exportSlug($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExportSlug() => $_has(6);
  @$pb.TagNumber(7)
  void clearExportSlug() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get position => $_getIZ(7);
  @$pb.TagNumber(8)
  set position($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPosition() => $_has(7);
  @$pb.TagNumber(8)
  void clearPosition() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get version => $_getI64(8);
  @$pb.TagNumber(9)
  set version($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasVersion() => $_has(8);
  @$pb.TagNumber(9)
  void clearVersion() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get archived => $_getBF(9);
  @$pb.TagNumber(10)
  set archived($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasArchived() => $_has(9);
  @$pb.TagNumber(10)
  void clearArchived() => $_clearField(10);
}

class Section extends $pb.GeneratedMessage {
  factory Section({
    $core.String? id,
    $core.String? studyId,
    $core.String? sourceId,
    $core.String? title,
    $core.int? position,
    $fixnum.Int64? version,
    $core.bool? archived,
  }) {
    final result = Section._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (sourceId != null) result.sourceId = sourceId;
    if (title != null) result.title = title;
    if (position != null) result.position = position;
    if (version != null) result.version = version;
    if (archived != null) result.archived = archived;
    return result;
  }

  Section._();

  factory Section.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Section()..mergeFromBuffer(data, registry);
  factory Section.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Section()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Section',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: Section.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aI(5, _omitFieldNames ? '' : 'position')
    ..aInt64(6, _omitFieldNames ? '' : 'version')
    ..aOB(7, _omitFieldNames ? '' : 'archived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Section clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Section copyWith(void Function(Section) updates) =>
      super.copyWith((message) => updates(message as Section)) as Section;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Section() / Section.new instead')
  static Section create() => Section._();
  static $pb.GeneratedMessage $_createMessage() => Section._();
  @$core.override
  Section createEmptyInstance() => Section._();
  @$core.pragma('dart2js:noInline')
  static Section getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Section>(Section.$_createMessage);
  static Section? _defaultInstance;

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
  $core.String get sourceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get position => $_getIZ(4);
  @$pb.TagNumber(5)
  set position($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPosition() => $_has(4);
  @$pb.TagNumber(5)
  void clearPosition() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get version => $_getI64(5);
  @$pb.TagNumber(6)
  set version($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get archived => $_getBF(6);
  @$pb.TagNumber(7)
  set archived($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasArchived() => $_has(6);
  @$pb.TagNumber(7)
  void clearArchived() => $_clearField(7);
}

class Lesson extends $pb.GeneratedMessage {
  factory Lesson({
    $core.String? id,
    $core.String? studyId,
    $core.String? sourceId,
    $core.String? sectionId,
    $core.String? title,
    $core.String? url,
    $core.String? sourcePosition,
    $core.String? exportSlug,
    $core.int? position,
    LessonStatus? status,
    $fixnum.Int64? startedAtEpochMillis,
    $fixnum.Int64? masteredAtEpochMillis,
    $fixnum.Int64? version,
    $core.bool? archived,
  }) {
    final result = Lesson._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (sourceId != null) result.sourceId = sourceId;
    if (sectionId != null) result.sectionId = sectionId;
    if (title != null) result.title = title;
    if (url != null) result.url = url;
    if (sourcePosition != null) result.sourcePosition = sourcePosition;
    if (exportSlug != null) result.exportSlug = exportSlug;
    if (position != null) result.position = position;
    if (status != null) result.status = status;
    if (startedAtEpochMillis != null)
      result.startedAtEpochMillis = startedAtEpochMillis;
    if (masteredAtEpochMillis != null)
      result.masteredAtEpochMillis = masteredAtEpochMillis;
    if (version != null) result.version = version;
    if (archived != null) result.archived = archived;
    return result;
  }

  Lesson._();

  factory Lesson.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Lesson()..mergeFromBuffer(data, registry);
  factory Lesson.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Lesson()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Lesson',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: Lesson.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceId')
    ..aOS(4, _omitFieldNames ? '' : 'sectionId')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'url')
    ..aOS(7, _omitFieldNames ? '' : 'sourcePosition')
    ..aOS(8, _omitFieldNames ? '' : 'exportSlug')
    ..aI(9, _omitFieldNames ? '' : 'position')
    ..aE<LessonStatus>(10, _omitFieldNames ? '' : 'status',
        enumValues: LessonStatus.values)
    ..aInt64(11, _omitFieldNames ? '' : 'startedAtEpochMillis')
    ..aInt64(12, _omitFieldNames ? '' : 'masteredAtEpochMillis')
    ..aInt64(13, _omitFieldNames ? '' : 'version')
    ..aOB(14, _omitFieldNames ? '' : 'archived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lesson clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lesson copyWith(void Function(Lesson) updates) =>
      super.copyWith((message) => updates(message as Lesson)) as Lesson;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Lesson() / Lesson.new instead')
  static Lesson create() => Lesson._();
  static $pb.GeneratedMessage $_createMessage() => Lesson._();
  @$core.override
  Lesson createEmptyInstance() => Lesson._();
  @$core.pragma('dart2js:noInline')
  static Lesson getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Lesson>(Lesson.$_createMessage);
  static Lesson? _defaultInstance;

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
  $core.String get sourceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sectionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sectionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSectionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSectionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get sourcePosition => $_getSZ(6);
  @$pb.TagNumber(7)
  set sourcePosition($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourcePosition() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourcePosition() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get exportSlug => $_getSZ(7);
  @$pb.TagNumber(8)
  set exportSlug($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExportSlug() => $_has(7);
  @$pb.TagNumber(8)
  void clearExportSlug() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get position => $_getIZ(8);
  @$pb.TagNumber(9)
  set position($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPosition() => $_has(8);
  @$pb.TagNumber(9)
  void clearPosition() => $_clearField(9);

  @$pb.TagNumber(10)
  LessonStatus get status => $_getN(9);
  @$pb.TagNumber(10)
  set status(LessonStatus value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatus() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get startedAtEpochMillis => $_getI64(10);
  @$pb.TagNumber(11)
  set startedAtEpochMillis($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStartedAtEpochMillis() => $_has(10);
  @$pb.TagNumber(11)
  void clearStartedAtEpochMillis() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get masteredAtEpochMillis => $_getI64(11);
  @$pb.TagNumber(12)
  set masteredAtEpochMillis($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMasteredAtEpochMillis() => $_has(11);
  @$pb.TagNumber(12)
  void clearMasteredAtEpochMillis() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get version => $_getI64(12);
  @$pb.TagNumber(13)
  set version($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasVersion() => $_has(12);
  @$pb.TagNumber(13)
  void clearVersion() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get archived => $_getBF(13);
  @$pb.TagNumber(14)
  set archived($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasArchived() => $_has(13);
  @$pb.TagNumber(14)
  void clearArchived() => $_clearField(14);
}

class CreateStudyRequest extends $pb.GeneratedMessage {
  factory CreateStudyRequest({
    $core.String? id,
    $core.String? title,
    $core.String? goal,
    $core.String? localRepositoryPath,
  }) {
    final result = CreateStudyRequest._();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (goal != null) result.goal = goal;
    if (localRepositoryPath != null)
      result.localRepositoryPath = localRepositoryPath;
    return result;
  }

  CreateStudyRequest._();

  factory CreateStudyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateStudyRequest()..mergeFromBuffer(data, registry);
  factory CreateStudyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateStudyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateStudyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateStudyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'goal')
    ..aOS(4, _omitFieldNames ? '' : 'localRepositoryPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateStudyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateStudyRequest copyWith(void Function(CreateStudyRequest) updates) =>
      super.copyWith((message) => updates(message as CreateStudyRequest))
          as CreateStudyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateStudyRequest() / CreateStudyRequest.new instead')
  static CreateStudyRequest create() => CreateStudyRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateStudyRequest._();
  @$core.override
  CreateStudyRequest createEmptyInstance() => CreateStudyRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateStudyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateStudyRequest>(
          CreateStudyRequest.$_createMessage);
  static CreateStudyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get goal => $_getSZ(2);
  @$pb.TagNumber(3)
  set goal($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGoal() => $_has(2);
  @$pb.TagNumber(3)
  void clearGoal() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get localRepositoryPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set localRepositoryPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocalRepositoryPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalRepositoryPath() => $_clearField(4);
}

class GetStudyRequest extends $pb.GeneratedMessage {
  factory GetStudyRequest({
    $core.String? id,
  }) {
    final result = GetStudyRequest._();
    if (id != null) result.id = id;
    return result;
  }

  GetStudyRequest._();

  factory GetStudyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStudyRequest()..mergeFromBuffer(data, registry);
  factory GetStudyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStudyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetStudyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: GetStudyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStudyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStudyRequest copyWith(void Function(GetStudyRequest) updates) =>
      super.copyWith((message) => updates(message as GetStudyRequest))
          as GetStudyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetStudyRequest() / GetStudyRequest.new instead')
  static GetStudyRequest create() => GetStudyRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetStudyRequest._();
  @$core.override
  GetStudyRequest createEmptyInstance() => GetStudyRequest._();
  @$core.pragma('dart2js:noInline')
  static GetStudyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStudyRequest>(
          GetStudyRequest.$_createMessage);
  static GetStudyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ListStudiesRequest extends $pb.GeneratedMessage {
  factory ListStudiesRequest({
    $core.bool? includeArchived,
  }) {
    final result = ListStudiesRequest._();
    if (includeArchived != null) result.includeArchived = includeArchived;
    return result;
  }

  ListStudiesRequest._();

  factory ListStudiesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListStudiesRequest()..mergeFromBuffer(data, registry);
  factory ListStudiesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListStudiesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListStudiesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ListStudiesRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'includeArchived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStudiesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStudiesRequest copyWith(void Function(ListStudiesRequest) updates) =>
      super.copyWith((message) => updates(message as ListStudiesRequest))
          as ListStudiesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListStudiesRequest() / ListStudiesRequest.new instead')
  static ListStudiesRequest create() => ListStudiesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListStudiesRequest._();
  @$core.override
  ListStudiesRequest createEmptyInstance() => ListStudiesRequest._();
  @$core.pragma('dart2js:noInline')
  static ListStudiesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListStudiesRequest>(
          ListStudiesRequest.$_createMessage);
  static ListStudiesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get includeArchived => $_getBF(0);
  @$pb.TagNumber(1)
  set includeArchived($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIncludeArchived() => $_has(0);
  @$pb.TagNumber(1)
  void clearIncludeArchived() => $_clearField(1);
}

class ListStudiesResponse extends $pb.GeneratedMessage {
  factory ListStudiesResponse({
    $core.Iterable<Study>? studies,
  }) {
    final result = ListStudiesResponse._();
    if (studies != null) result.studies.addAll(studies);
    return result;
  }

  ListStudiesResponse._();

  factory ListStudiesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListStudiesResponse()..mergeFromBuffer(data, registry);
  factory ListStudiesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListStudiesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListStudiesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ListStudiesResponse.$_createMessage)
    ..pPM<Study>(1, _omitFieldNames ? '' : 'studies',
        subBuilder: Study.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStudiesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStudiesResponse copyWith(void Function(ListStudiesResponse) updates) =>
      super.copyWith((message) => updates(message as ListStudiesResponse))
          as ListStudiesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ListStudiesResponse() / ListStudiesResponse.new instead')
  static ListStudiesResponse create() => ListStudiesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListStudiesResponse._();
  @$core.override
  ListStudiesResponse createEmptyInstance() => ListStudiesResponse._();
  @$core.pragma('dart2js:noInline')
  static ListStudiesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListStudiesResponse>(
          ListStudiesResponse.$_createMessage);
  static ListStudiesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Study> get studies => $_getList(0);
}

class UpdateStudyRequest extends $pb.GeneratedMessage {
  factory UpdateStudyRequest({
    $core.String? id,
    $core.String? title,
    $core.String? goal,
    $core.String? localRepositoryPath,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateStudyRequest._();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (goal != null) result.goal = goal;
    if (localRepositoryPath != null)
      result.localRepositoryPath = localRepositoryPath;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateStudyRequest._();

  factory UpdateStudyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateStudyRequest()..mergeFromBuffer(data, registry);
  factory UpdateStudyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateStudyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateStudyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateStudyRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'goal')
    ..aOS(4, _omitFieldNames ? '' : 'localRepositoryPath')
    ..aInt64(5, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStudyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateStudyRequest copyWith(void Function(UpdateStudyRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateStudyRequest))
          as UpdateStudyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateStudyRequest() / UpdateStudyRequest.new instead')
  static UpdateStudyRequest create() => UpdateStudyRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateStudyRequest._();
  @$core.override
  UpdateStudyRequest createEmptyInstance() => UpdateStudyRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateStudyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateStudyRequest>(
          UpdateStudyRequest.$_createMessage);
  static UpdateStudyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get goal => $_getSZ(2);
  @$pb.TagNumber(3)
  set goal($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGoal() => $_has(2);
  @$pb.TagNumber(3)
  void clearGoal() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get localRepositoryPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set localRepositoryPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocalRepositoryPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalRepositoryPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expectedVersion => $_getI64(4);
  @$pb.TagNumber(5)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedVersion() => $_clearField(5);
}

class ChangeArchiveRequest extends $pb.GeneratedMessage {
  factory ChangeArchiveRequest({
    $core.String? id,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = ChangeArchiveRequest._();
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  ChangeArchiveRequest._();

  factory ChangeArchiveRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeArchiveRequest()..mergeFromBuffer(data, registry);
  factory ChangeArchiveRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeArchiveRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeArchiveRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ChangeArchiveRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeArchiveRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeArchiveRequest copyWith(void Function(ChangeArchiveRequest) updates) =>
      super.copyWith((message) => updates(message as ChangeArchiveRequest))
          as ChangeArchiveRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChangeArchiveRequest() / ChangeArchiveRequest.new instead')
  static ChangeArchiveRequest create() => ChangeArchiveRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChangeArchiveRequest._();
  @$core.override
  ChangeArchiveRequest createEmptyInstance() => ChangeArchiveRequest._();
  @$core.pragma('dart2js:noInline')
  static ChangeArchiveRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeArchiveRequest>(
          ChangeArchiveRequest.$_createMessage);
  static ChangeArchiveRequest? _defaultInstance;

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
}

class CreateLearningSourceRequest extends $pb.GeneratedMessage {
  factory CreateLearningSourceRequest({
    $core.String? id,
    $core.String? studyId,
    LearningSourceType? type,
    $core.String? title,
    $core.String? author,
    $core.String? url,
    $core.String? exportSlug,
    $core.int? position,
  }) {
    final result = CreateLearningSourceRequest._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (author != null) result.author = author;
    if (url != null) result.url = url;
    if (exportSlug != null) result.exportSlug = exportSlug;
    if (position != null) result.position = position;
    return result;
  }

  CreateLearningSourceRequest._();

  factory CreateLearningSourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateLearningSourceRequest()..mergeFromBuffer(data, registry);
  factory CreateLearningSourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateLearningSourceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateLearningSourceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateLearningSourceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aE<LearningSourceType>(3, _omitFieldNames ? '' : 'type',
        enumValues: LearningSourceType.values)
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'author')
    ..aOS(6, _omitFieldNames ? '' : 'url')
    ..aOS(7, _omitFieldNames ? '' : 'exportSlug')
    ..aI(8, _omitFieldNames ? '' : 'position')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateLearningSourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateLearningSourceRequest copyWith(
          void Function(CreateLearningSourceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateLearningSourceRequest))
          as CreateLearningSourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateLearningSourceRequest() / CreateLearningSourceRequest.new instead')
  static CreateLearningSourceRequest create() =>
      CreateLearningSourceRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateLearningSourceRequest._();
  @$core.override
  CreateLearningSourceRequest createEmptyInstance() =>
      CreateLearningSourceRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateLearningSourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateLearningSourceRequest>(
          CreateLearningSourceRequest.$_createMessage);
  static CreateLearningSourceRequest? _defaultInstance;

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
  LearningSourceType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(LearningSourceType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get author => $_getSZ(4);
  @$pb.TagNumber(5)
  set author($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAuthor() => $_has(4);
  @$pb.TagNumber(5)
  void clearAuthor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get exportSlug => $_getSZ(6);
  @$pb.TagNumber(7)
  set exportSlug($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExportSlug() => $_has(6);
  @$pb.TagNumber(7)
  void clearExportSlug() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get position => $_getIZ(7);
  @$pb.TagNumber(8)
  set position($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPosition() => $_has(7);
  @$pb.TagNumber(8)
  void clearPosition() => $_clearField(8);
}

class UpdateLearningSourceRequest extends $pb.GeneratedMessage {
  factory UpdateLearningSourceRequest({
    LearningSource? source,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateLearningSourceRequest._();
    if (source != null) result.source = source;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateLearningSourceRequest._();

  factory UpdateLearningSourceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateLearningSourceRequest()..mergeFromBuffer(data, registry);
  factory UpdateLearningSourceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateLearningSourceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLearningSourceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateLearningSourceRequest.$_createMessage)
    ..aOM<LearningSource>(1, _omitFieldNames ? '' : 'source',
        subBuilder: LearningSource.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLearningSourceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLearningSourceRequest copyWith(
          void Function(UpdateLearningSourceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateLearningSourceRequest))
          as UpdateLearningSourceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateLearningSourceRequest() / UpdateLearningSourceRequest.new instead')
  static UpdateLearningSourceRequest create() =>
      UpdateLearningSourceRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      UpdateLearningSourceRequest._();
  @$core.override
  UpdateLearningSourceRequest createEmptyInstance() =>
      UpdateLearningSourceRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateLearningSourceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLearningSourceRequest>(
          UpdateLearningSourceRequest.$_createMessage);
  static UpdateLearningSourceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  LearningSource get source => $_getN(0);
  @$pb.TagNumber(1)
  set source(LearningSource value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSource() => $_has(0);
  @$pb.TagNumber(1)
  void clearSource() => $_clearField(1);
  @$pb.TagNumber(1)
  LearningSource ensureSource() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);
}

class CreateSectionRequest extends $pb.GeneratedMessage {
  factory CreateSectionRequest({
    $core.String? id,
    $core.String? studyId,
    $core.String? sourceId,
    $core.String? title,
    $core.int? position,
  }) {
    final result = CreateSectionRequest._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (sourceId != null) result.sourceId = sourceId;
    if (title != null) result.title = title;
    if (position != null) result.position = position;
    return result;
  }

  CreateSectionRequest._();

  factory CreateSectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSectionRequest()..mergeFromBuffer(data, registry);
  factory CreateSectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSectionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSectionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateSectionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceId')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aI(5, _omitFieldNames ? '' : 'position')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSectionRequest copyWith(void Function(CreateSectionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSectionRequest))
          as CreateSectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateSectionRequest() / CreateSectionRequest.new instead')
  static CreateSectionRequest create() => CreateSectionRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateSectionRequest._();
  @$core.override
  CreateSectionRequest createEmptyInstance() => CreateSectionRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateSectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSectionRequest>(
          CreateSectionRequest.$_createMessage);
  static CreateSectionRequest? _defaultInstance;

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
  $core.String get sourceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get position => $_getIZ(4);
  @$pb.TagNumber(5)
  set position($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPosition() => $_has(4);
  @$pb.TagNumber(5)
  void clearPosition() => $_clearField(5);
}

class UpdateSectionRequest extends $pb.GeneratedMessage {
  factory UpdateSectionRequest({
    Section? section,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateSectionRequest._();
    if (section != null) result.section = section;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateSectionRequest._();

  factory UpdateSectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateSectionRequest()..mergeFromBuffer(data, registry);
  factory UpdateSectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateSectionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSectionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateSectionRequest.$_createMessage)
    ..aOM<Section>(1, _omitFieldNames ? '' : 'section',
        subBuilder: Section.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSectionRequest copyWith(void Function(UpdateSectionRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateSectionRequest))
          as UpdateSectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateSectionRequest() / UpdateSectionRequest.new instead')
  static UpdateSectionRequest create() => UpdateSectionRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateSectionRequest._();
  @$core.override
  UpdateSectionRequest createEmptyInstance() => UpdateSectionRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateSectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSectionRequest>(
          UpdateSectionRequest.$_createMessage);
  static UpdateSectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Section get section => $_getN(0);
  @$pb.TagNumber(1)
  set section(Section value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSection() => $_has(0);
  @$pb.TagNumber(1)
  void clearSection() => $_clearField(1);
  @$pb.TagNumber(1)
  Section ensureSection() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);
}

class CreateLessonRequest extends $pb.GeneratedMessage {
  factory CreateLessonRequest({
    $core.String? id,
    $core.String? studyId,
    $core.String? sourceId,
    $core.String? sectionId,
    $core.String? title,
    $core.String? url,
    $core.String? sourcePosition,
    $core.String? exportSlug,
    $core.int? position,
    LessonStatus? status,
  }) {
    final result = CreateLessonRequest._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (sourceId != null) result.sourceId = sourceId;
    if (sectionId != null) result.sectionId = sectionId;
    if (title != null) result.title = title;
    if (url != null) result.url = url;
    if (sourcePosition != null) result.sourcePosition = sourcePosition;
    if (exportSlug != null) result.exportSlug = exportSlug;
    if (position != null) result.position = position;
    if (status != null) result.status = status;
    return result;
  }

  CreateLessonRequest._();

  factory CreateLessonRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateLessonRequest()..mergeFromBuffer(data, registry);
  factory CreateLessonRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateLessonRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateLessonRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateLessonRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'sourceId')
    ..aOS(4, _omitFieldNames ? '' : 'sectionId')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'url')
    ..aOS(7, _omitFieldNames ? '' : 'sourcePosition')
    ..aOS(8, _omitFieldNames ? '' : 'exportSlug')
    ..aI(9, _omitFieldNames ? '' : 'position')
    ..aE<LessonStatus>(10, _omitFieldNames ? '' : 'status',
        enumValues: LessonStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateLessonRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateLessonRequest copyWith(void Function(CreateLessonRequest) updates) =>
      super.copyWith((message) => updates(message as CreateLessonRequest))
          as CreateLessonRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use CreateLessonRequest() / CreateLessonRequest.new instead')
  static CreateLessonRequest create() => CreateLessonRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateLessonRequest._();
  @$core.override
  CreateLessonRequest createEmptyInstance() => CreateLessonRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateLessonRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateLessonRequest>(
          CreateLessonRequest.$_createMessage);
  static CreateLessonRequest? _defaultInstance;

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
  $core.String get sourceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sectionId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sectionId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSectionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSectionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get sourcePosition => $_getSZ(6);
  @$pb.TagNumber(7)
  set sourcePosition($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourcePosition() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourcePosition() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get exportSlug => $_getSZ(7);
  @$pb.TagNumber(8)
  set exportSlug($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExportSlug() => $_has(7);
  @$pb.TagNumber(8)
  void clearExportSlug() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get position => $_getIZ(8);
  @$pb.TagNumber(9)
  set position($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPosition() => $_has(8);
  @$pb.TagNumber(9)
  void clearPosition() => $_clearField(9);

  @$pb.TagNumber(10)
  LessonStatus get status => $_getN(9);
  @$pb.TagNumber(10)
  set status(LessonStatus value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatus() => $_clearField(10);
}

class UpdateLessonRequest extends $pb.GeneratedMessage {
  factory UpdateLessonRequest({
    Lesson? lesson,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateLessonRequest._();
    if (lesson != null) result.lesson = lesson;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateLessonRequest._();

  factory UpdateLessonRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateLessonRequest()..mergeFromBuffer(data, registry);
  factory UpdateLessonRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateLessonRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateLessonRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateLessonRequest.$_createMessage)
    ..aOM<Lesson>(1, _omitFieldNames ? '' : 'lesson',
        subBuilder: Lesson.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLessonRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateLessonRequest copyWith(void Function(UpdateLessonRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateLessonRequest))
          as UpdateLessonRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use UpdateLessonRequest() / UpdateLessonRequest.new instead')
  static UpdateLessonRequest create() => UpdateLessonRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateLessonRequest._();
  @$core.override
  UpdateLessonRequest createEmptyInstance() => UpdateLessonRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateLessonRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateLessonRequest>(
          UpdateLessonRequest.$_createMessage);
  static UpdateLessonRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Lesson get lesson => $_getN(0);
  @$pb.TagNumber(1)
  set lesson(Lesson value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLesson() => $_has(0);
  @$pb.TagNumber(1)
  void clearLesson() => $_clearField(1);
  @$pb.TagNumber(1)
  Lesson ensureLesson() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);
}

class ChangeLessonStatusRequest extends $pb.GeneratedMessage {
  factory ChangeLessonStatusRequest({
    $core.String? id,
    LessonStatus? status,
    $fixnum.Int64? expectedVersion,
    $core.bool? acknowledgeOpenHomework,
  }) {
    final result = ChangeLessonStatusRequest._();
    if (id != null) result.id = id;
    if (status != null) result.status = status;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (acknowledgeOpenHomework != null)
      result.acknowledgeOpenHomework = acknowledgeOpenHomework;
    return result;
  }

  ChangeLessonStatusRequest._();

  factory ChangeLessonStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeLessonStatusRequest()..mergeFromBuffer(data, registry);
  factory ChangeLessonStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangeLessonStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChangeLessonStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ChangeLessonStatusRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<LessonStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: LessonStatus.values)
    ..aInt64(3, _omitFieldNames ? '' : 'expectedVersion')
    ..aOB(4, _omitFieldNames ? '' : 'acknowledgeOpenHomework')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeLessonStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangeLessonStatusRequest copyWith(
          void Function(ChangeLessonStatusRequest) updates) =>
      super.copyWith((message) => updates(message as ChangeLessonStatusRequest))
          as ChangeLessonStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ChangeLessonStatusRequest() / ChangeLessonStatusRequest.new instead')
  static ChangeLessonStatusRequest create() => ChangeLessonStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ChangeLessonStatusRequest._();
  @$core.override
  ChangeLessonStatusRequest createEmptyInstance() =>
      ChangeLessonStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static ChangeLessonStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangeLessonStatusRequest>(
          ChangeLessonStatusRequest.$_createMessage);
  static ChangeLessonStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  LessonStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(LessonStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expectedVersion => $_getI64(2);
  @$pb.TagNumber(3)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get acknowledgeOpenHomework => $_getBF(3);
  @$pb.TagNumber(4)
  set acknowledgeOpenHomework($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAcknowledgeOpenHomework() => $_has(3);
  @$pb.TagNumber(4)
  void clearAcknowledgeOpenHomework() => $_clearField(4);
}

class GetMaterialTreeRequest extends $pb.GeneratedMessage {
  factory GetMaterialTreeRequest({
    $core.String? studyId,
    $core.bool? includeArchived,
  }) {
    final result = GetMaterialTreeRequest._();
    if (studyId != null) result.studyId = studyId;
    if (includeArchived != null) result.includeArchived = includeArchived;
    return result;
  }

  GetMaterialTreeRequest._();

  factory GetMaterialTreeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMaterialTreeRequest()..mergeFromBuffer(data, registry);
  factory GetMaterialTreeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMaterialTreeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMaterialTreeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: GetMaterialTreeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'studyId')
    ..aOB(2, _omitFieldNames ? '' : 'includeArchived')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMaterialTreeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMaterialTreeRequest copyWith(
          void Function(GetMaterialTreeRequest) updates) =>
      super.copyWith((message) => updates(message as GetMaterialTreeRequest))
          as GetMaterialTreeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetMaterialTreeRequest() / GetMaterialTreeRequest.new instead')
  static GetMaterialTreeRequest create() => GetMaterialTreeRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetMaterialTreeRequest._();
  @$core.override
  GetMaterialTreeRequest createEmptyInstance() => GetMaterialTreeRequest._();
  @$core.pragma('dart2js:noInline')
  static GetMaterialTreeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMaterialTreeRequest>(
          GetMaterialTreeRequest.$_createMessage);
  static GetMaterialTreeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get studyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set studyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStudyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeArchived => $_getBF(1);
  @$pb.TagNumber(2)
  set includeArchived($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncludeArchived() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeArchived() => $_clearField(2);
}

class SourceNode extends $pb.GeneratedMessage {
  factory SourceNode({
    LearningSource? source,
    $core.Iterable<Section>? sections,
    $core.Iterable<Lesson>? lessons,
  }) {
    final result = SourceNode._();
    if (source != null) result.source = source;
    if (sections != null) result.sections.addAll(sections);
    if (lessons != null) result.lessons.addAll(lessons);
    return result;
  }

  SourceNode._();

  factory SourceNode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SourceNode()..mergeFromBuffer(data, registry);
  factory SourceNode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SourceNode()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SourceNode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: SourceNode.$_createMessage)
    ..aOM<LearningSource>(1, _omitFieldNames ? '' : 'source',
        subBuilder: LearningSource.$_createMessage)
    ..pPM<Section>(2, _omitFieldNames ? '' : 'sections',
        subBuilder: Section.$_createMessage)
    ..pPM<Lesson>(3, _omitFieldNames ? '' : 'lessons',
        subBuilder: Lesson.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SourceNode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SourceNode copyWith(void Function(SourceNode) updates) =>
      super.copyWith((message) => updates(message as SourceNode)) as SourceNode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SourceNode() / SourceNode.new instead')
  static SourceNode create() => SourceNode._();
  static $pb.GeneratedMessage $_createMessage() => SourceNode._();
  @$core.override
  SourceNode createEmptyInstance() => SourceNode._();
  @$core.pragma('dart2js:noInline')
  static SourceNode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SourceNode>(SourceNode.$_createMessage);
  static SourceNode? _defaultInstance;

  @$pb.TagNumber(1)
  LearningSource get source => $_getN(0);
  @$pb.TagNumber(1)
  set source(LearningSource value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSource() => $_has(0);
  @$pb.TagNumber(1)
  void clearSource() => $_clearField(1);
  @$pb.TagNumber(1)
  LearningSource ensureSource() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Section> get sections => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<Lesson> get lessons => $_getList(2);
}

class MaterialTree extends $pb.GeneratedMessage {
  factory MaterialTree({
    Study? study,
    $core.Iterable<SourceNode>? sources,
  }) {
    final result = MaterialTree._();
    if (study != null) result.study = study;
    if (sources != null) result.sources.addAll(sources);
    return result;
  }

  MaterialTree._();

  factory MaterialTree.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MaterialTree()..mergeFromBuffer(data, registry);
  factory MaterialTree.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MaterialTree()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MaterialTree',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: MaterialTree.$_createMessage)
    ..aOM<Study>(1, _omitFieldNames ? '' : 'study',
        subBuilder: Study.$_createMessage)
    ..pPM<SourceNode>(2, _omitFieldNames ? '' : 'sources',
        subBuilder: SourceNode.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MaterialTree clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MaterialTree copyWith(void Function(MaterialTree) updates) =>
      super.copyWith((message) => updates(message as MaterialTree))
          as MaterialTree;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MaterialTree() / MaterialTree.new instead')
  static MaterialTree create() => MaterialTree._();
  static $pb.GeneratedMessage $_createMessage() => MaterialTree._();
  @$core.override
  MaterialTree createEmptyInstance() => MaterialTree._();
  @$core.pragma('dart2js:noInline')
  static MaterialTree getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MaterialTree>(
          MaterialTree.$_createMessage);
  static MaterialTree? _defaultInstance;

  @$pb.TagNumber(1)
  Study get study => $_getN(0);
  @$pb.TagNumber(1)
  set study(Study value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStudy() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudy() => $_clearField(1);
  @$pb.TagNumber(1)
  Study ensureStudy() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<SourceNode> get sources => $_getList(1);
}

class ReorderItem extends $pb.GeneratedMessage {
  factory ReorderItem({
    $core.String? id,
    $core.int? position,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = ReorderItem._();
    if (id != null) result.id = id;
    if (position != null) result.position = position;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  ReorderItem._();

  factory ReorderItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReorderItem()..mergeFromBuffer(data, registry);
  factory ReorderItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReorderItem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReorderItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ReorderItem.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'position')
    ..aInt64(3, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderItem copyWith(void Function(ReorderItem) updates) =>
      super.copyWith((message) => updates(message as ReorderItem))
          as ReorderItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReorderItem() / ReorderItem.new instead')
  static ReorderItem create() => ReorderItem._();
  static $pb.GeneratedMessage $_createMessage() => ReorderItem._();
  @$core.override
  ReorderItem createEmptyInstance() => ReorderItem._();
  @$core.pragma('dart2js:noInline')
  static ReorderItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReorderItem>(
          ReorderItem.$_createMessage);
  static ReorderItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get position => $_getIZ(1);
  @$pb.TagNumber(2)
  set position($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expectedVersion => $_getI64(2);
  @$pb.TagNumber(3)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpectedVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpectedVersion() => $_clearField(3);
}

class ReorderMaterialRequest extends $pb.GeneratedMessage {
  factory ReorderMaterialRequest({
    $core.String? studyId,
    $core.Iterable<ReorderItem>? sources,
    $core.Iterable<ReorderItem>? sections,
    $core.Iterable<ReorderItem>? lessons,
  }) {
    final result = ReorderMaterialRequest._();
    if (studyId != null) result.studyId = studyId;
    if (sources != null) result.sources.addAll(sources);
    if (sections != null) result.sections.addAll(sections);
    if (lessons != null) result.lessons.addAll(lessons);
    return result;
  }

  ReorderMaterialRequest._();

  factory ReorderMaterialRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReorderMaterialRequest()..mergeFromBuffer(data, registry);
  factory ReorderMaterialRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReorderMaterialRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReorderMaterialRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ReorderMaterialRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'studyId')
    ..pPM<ReorderItem>(2, _omitFieldNames ? '' : 'sources',
        subBuilder: ReorderItem.$_createMessage)
    ..pPM<ReorderItem>(3, _omitFieldNames ? '' : 'sections',
        subBuilder: ReorderItem.$_createMessage)
    ..pPM<ReorderItem>(4, _omitFieldNames ? '' : 'lessons',
        subBuilder: ReorderItem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderMaterialRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderMaterialRequest copyWith(
          void Function(ReorderMaterialRequest) updates) =>
      super.copyWith((message) => updates(message as ReorderMaterialRequest))
          as ReorderMaterialRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReorderMaterialRequest() / ReorderMaterialRequest.new instead')
  static ReorderMaterialRequest create() => ReorderMaterialRequest._();
  static $pb.GeneratedMessage $_createMessage() => ReorderMaterialRequest._();
  @$core.override
  ReorderMaterialRequest createEmptyInstance() => ReorderMaterialRequest._();
  @$core.pragma('dart2js:noInline')
  static ReorderMaterialRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReorderMaterialRequest>(
          ReorderMaterialRequest.$_createMessage);
  static ReorderMaterialRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get studyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set studyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStudyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ReorderItem> get sources => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<ReorderItem> get sections => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<ReorderItem> get lessons => $_getList(3);
}

class GetDashboardRequest extends $pb.GeneratedMessage {
  factory GetDashboardRequest({
    $core.String? studyId,
  }) {
    final result = GetDashboardRequest._();
    if (studyId != null) result.studyId = studyId;
    return result;
  }

  GetDashboardRequest._();

  factory GetDashboardRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDashboardRequest()..mergeFromBuffer(data, registry);
  factory GetDashboardRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDashboardRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDashboardRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: GetDashboardRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'studyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDashboardRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDashboardRequest copyWith(void Function(GetDashboardRequest) updates) =>
      super.copyWith((message) => updates(message as GetDashboardRequest))
          as GetDashboardRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use GetDashboardRequest() / GetDashboardRequest.new instead')
  static GetDashboardRequest create() => GetDashboardRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetDashboardRequest._();
  @$core.override
  GetDashboardRequest createEmptyInstance() => GetDashboardRequest._();
  @$core.pragma('dart2js:noInline')
  static GetDashboardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDashboardRequest>(
          GetDashboardRequest.$_createMessage);
  static GetDashboardRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get studyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set studyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStudyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStudyId() => $_clearField(1);
}

class Progress extends $pb.GeneratedMessage {
  factory Progress({
    $core.int? completed,
    $core.int? total,
  }) {
    final result = Progress._();
    if (completed != null) result.completed = completed;
    if (total != null) result.total = total;
    return result;
  }

  Progress._();

  factory Progress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Progress()..mergeFromBuffer(data, registry);
  factory Progress.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Progress()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Progress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: Progress.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'completed')
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Progress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Progress copyWith(void Function(Progress) updates) =>
      super.copyWith((message) => updates(message as Progress)) as Progress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Progress() / Progress.new instead')
  static Progress create() => Progress._();
  static $pb.GeneratedMessage $_createMessage() => Progress._();
  @$core.override
  Progress createEmptyInstance() => Progress._();
  @$core.pragma('dart2js:noInline')
  static Progress getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Progress>(Progress.$_createMessage);
  static Progress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get completed => $_getIZ(0);
  @$pb.TagNumber(1)
  set completed($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCompleted() => $_has(0);
  @$pb.TagNumber(1)
  void clearCompleted() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class StatusCount extends $pb.GeneratedMessage {
  factory StatusCount({
    LessonStatus? status,
    $core.int? count,
  }) {
    final result = StatusCount._();
    if (status != null) result.status = status;
    if (count != null) result.count = count;
    return result;
  }

  StatusCount._();

  factory StatusCount.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatusCount()..mergeFromBuffer(data, registry);
  factory StatusCount.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StatusCount()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusCount',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: StatusCount.$_createMessage)
    ..aE<LessonStatus>(1, _omitFieldNames ? '' : 'status',
        enumValues: LessonStatus.values)
    ..aI(2, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusCount clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusCount copyWith(void Function(StatusCount) updates) =>
      super.copyWith((message) => updates(message as StatusCount))
          as StatusCount;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StatusCount() / StatusCount.new instead')
  static StatusCount create() => StatusCount._();
  static $pb.GeneratedMessage $_createMessage() => StatusCount._();
  @$core.override
  StatusCount createEmptyInstance() => StatusCount._();
  @$core.pragma('dart2js:noInline')
  static StatusCount getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatusCount>(
          StatusCount.$_createMessage);
  static StatusCount? _defaultInstance;

  @$pb.TagNumber(1)
  LessonStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(LessonStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

class Dashboard extends $pb.GeneratedMessage {
  factory Dashboard({
    Progress? material,
    Progress? homework,
    $core.Iterable<StatusCount>? lessonStatuses,
    $fixnum.Int64? studyRevision,
  }) {
    final result = Dashboard._();
    if (material != null) result.material = material;
    if (homework != null) result.homework = homework;
    if (lessonStatuses != null) result.lessonStatuses.addAll(lessonStatuses);
    if (studyRevision != null) result.studyRevision = studyRevision;
    return result;
  }

  Dashboard._();

  factory Dashboard.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Dashboard()..mergeFromBuffer(data, registry);
  factory Dashboard.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Dashboard()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Dashboard',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: Dashboard.$_createMessage)
    ..aOM<Progress>(1, _omitFieldNames ? '' : 'material',
        subBuilder: Progress.$_createMessage)
    ..aOM<Progress>(2, _omitFieldNames ? '' : 'homework',
        subBuilder: Progress.$_createMessage)
    ..pPM<StatusCount>(3, _omitFieldNames ? '' : 'lessonStatuses',
        subBuilder: StatusCount.$_createMessage)
    ..aInt64(4, _omitFieldNames ? '' : 'studyRevision')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dashboard clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Dashboard copyWith(void Function(Dashboard) updates) =>
      super.copyWith((message) => updates(message as Dashboard)) as Dashboard;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Dashboard() / Dashboard.new instead')
  static Dashboard create() => Dashboard._();
  static $pb.GeneratedMessage $_createMessage() => Dashboard._();
  @$core.override
  Dashboard createEmptyInstance() => Dashboard._();
  @$core.pragma('dart2js:noInline')
  static Dashboard getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Dashboard>(Dashboard.$_createMessage);
  static Dashboard? _defaultInstance;

  @$pb.TagNumber(1)
  Progress get material => $_getN(0);
  @$pb.TagNumber(1)
  set material(Progress value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMaterial() => $_has(0);
  @$pb.TagNumber(1)
  void clearMaterial() => $_clearField(1);
  @$pb.TagNumber(1)
  Progress ensureMaterial() => $_ensure(0);

  @$pb.TagNumber(2)
  Progress get homework => $_getN(1);
  @$pb.TagNumber(2)
  set homework(Progress value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasHomework() => $_has(1);
  @$pb.TagNumber(2)
  void clearHomework() => $_clearField(2);
  @$pb.TagNumber(2)
  Progress ensureHomework() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<StatusCount> get lessonStatuses => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get studyRevision => $_getI64(3);
  @$pb.TagNumber(4)
  set studyRevision($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStudyRevision() => $_has(3);
  @$pb.TagNumber(4)
  void clearStudyRevision() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
