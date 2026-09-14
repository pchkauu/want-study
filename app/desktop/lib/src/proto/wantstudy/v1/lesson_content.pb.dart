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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'lesson_content.pbenum.dart';
import 'study.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'lesson_content.pbenum.dart';

class NoteBlock extends $pb.GeneratedMessage {
  factory NoteBlock({
    $core.String? id,
    $core.String? studyId,
    $core.String? lessonId,
    NoteBlockType? type,
    $core.String? markdown,
    $core.String? sourceUrl,
    $core.String? sourcePosition,
    $core.int? position,
    $fixnum.Int64? version,
  }) {
    final result = NoteBlock._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (lessonId != null) result.lessonId = lessonId;
    if (type != null) result.type = type;
    if (markdown != null) result.markdown = markdown;
    if (sourceUrl != null) result.sourceUrl = sourceUrl;
    if (sourcePosition != null) result.sourcePosition = sourcePosition;
    if (position != null) result.position = position;
    if (version != null) result.version = version;
    return result;
  }

  NoteBlock._();

  factory NoteBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NoteBlock()..mergeFromBuffer(data, registry);
  factory NoteBlock.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      NoteBlock()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NoteBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: NoteBlock.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'lessonId')
    ..aE<NoteBlockType>(4, _omitFieldNames ? '' : 'type',
        enumValues: NoteBlockType.values)
    ..aOS(5, _omitFieldNames ? '' : 'markdown')
    ..aOS(6, _omitFieldNames ? '' : 'sourceUrl')
    ..aOS(7, _omitFieldNames ? '' : 'sourcePosition')
    ..aI(8, _omitFieldNames ? '' : 'position')
    ..aInt64(9, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NoteBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NoteBlock copyWith(void Function(NoteBlock) updates) =>
      super.copyWith((message) => updates(message as NoteBlock)) as NoteBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use NoteBlock() / NoteBlock.new instead')
  static NoteBlock create() => NoteBlock._();
  static $pb.GeneratedMessage $_createMessage() => NoteBlock._();
  @$core.override
  NoteBlock createEmptyInstance() => NoteBlock._();
  @$core.pragma('dart2js:noInline')
  static NoteBlock getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NoteBlock>(NoteBlock.$_createMessage);
  static NoteBlock? _defaultInstance;

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
  $core.String get lessonId => $_getSZ(2);
  @$pb.TagNumber(3)
  set lessonId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLessonId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLessonId() => $_clearField(3);

  @$pb.TagNumber(4)
  NoteBlockType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(NoteBlockType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get markdown => $_getSZ(4);
  @$pb.TagNumber(5)
  set markdown($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMarkdown() => $_has(4);
  @$pb.TagNumber(5)
  void clearMarkdown() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get sourceUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set sourceUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourceUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourceUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get sourcePosition => $_getSZ(6);
  @$pb.TagNumber(7)
  set sourcePosition($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourcePosition() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourcePosition() => $_clearField(7);

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
}

class HomeworkTask extends $pb.GeneratedMessage {
  factory HomeworkTask({
    $core.String? id,
    $core.String? studyId,
    $core.String? lessonId,
    $core.String? promptMarkdown,
    $core.String? solutionMarkdown,
    HomeworkStatus? status,
    $fixnum.Int64? dueAtEpochMillis,
    $core.int? position,
    $fixnum.Int64? version,
  }) {
    final result = HomeworkTask._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (lessonId != null) result.lessonId = lessonId;
    if (promptMarkdown != null) result.promptMarkdown = promptMarkdown;
    if (solutionMarkdown != null) result.solutionMarkdown = solutionMarkdown;
    if (status != null) result.status = status;
    if (dueAtEpochMillis != null) result.dueAtEpochMillis = dueAtEpochMillis;
    if (position != null) result.position = position;
    if (version != null) result.version = version;
    return result;
  }

  HomeworkTask._();

  factory HomeworkTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeworkTask()..mergeFromBuffer(data, registry);
  factory HomeworkTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HomeworkTask()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HomeworkTask',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: HomeworkTask.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'lessonId')
    ..aOS(4, _omitFieldNames ? '' : 'promptMarkdown')
    ..aOS(5, _omitFieldNames ? '' : 'solutionMarkdown')
    ..aE<HomeworkStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: HomeworkStatus.values)
    ..aInt64(7, _omitFieldNames ? '' : 'dueAtEpochMillis')
    ..aI(8, _omitFieldNames ? '' : 'position')
    ..aInt64(9, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeworkTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HomeworkTask copyWith(void Function(HomeworkTask) updates) =>
      super.copyWith((message) => updates(message as HomeworkTask))
          as HomeworkTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HomeworkTask() / HomeworkTask.new instead')
  static HomeworkTask create() => HomeworkTask._();
  static $pb.GeneratedMessage $_createMessage() => HomeworkTask._();
  @$core.override
  HomeworkTask createEmptyInstance() => HomeworkTask._();
  @$core.pragma('dart2js:noInline')
  static HomeworkTask getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HomeworkTask>(
          HomeworkTask.$_createMessage);
  static HomeworkTask? _defaultInstance;

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
  $core.String get lessonId => $_getSZ(2);
  @$pb.TagNumber(3)
  set lessonId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLessonId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLessonId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get promptMarkdown => $_getSZ(3);
  @$pb.TagNumber(4)
  set promptMarkdown($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPromptMarkdown() => $_has(3);
  @$pb.TagNumber(4)
  void clearPromptMarkdown() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get solutionMarkdown => $_getSZ(4);
  @$pb.TagNumber(5)
  set solutionMarkdown($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSolutionMarkdown() => $_has(4);
  @$pb.TagNumber(5)
  void clearSolutionMarkdown() => $_clearField(5);

  @$pb.TagNumber(6)
  HomeworkStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(HomeworkStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get dueAtEpochMillis => $_getI64(6);
  @$pb.TagNumber(7)
  set dueAtEpochMillis($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDueAtEpochMillis() => $_has(6);
  @$pb.TagNumber(7)
  void clearDueAtEpochMillis() => $_clearField(7);

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
}

class CodeFile extends $pb.GeneratedMessage {
  factory CodeFile({
    $core.String? id,
    $core.String? studyId,
    $core.String? lessonId,
    $core.String? homeworkTaskId,
    $core.String? relativePath,
    $core.String? language,
    $core.String? content,
    $fixnum.Int64? version,
  }) {
    final result = CodeFile._();
    if (id != null) result.id = id;
    if (studyId != null) result.studyId = studyId;
    if (lessonId != null) result.lessonId = lessonId;
    if (homeworkTaskId != null) result.homeworkTaskId = homeworkTaskId;
    if (relativePath != null) result.relativePath = relativePath;
    if (language != null) result.language = language;
    if (content != null) result.content = content;
    if (version != null) result.version = version;
    return result;
  }

  CodeFile._();

  factory CodeFile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CodeFile()..mergeFromBuffer(data, registry);
  factory CodeFile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CodeFile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CodeFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CodeFile.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'studyId')
    ..aOS(3, _omitFieldNames ? '' : 'lessonId')
    ..aOS(4, _omitFieldNames ? '' : 'homeworkTaskId')
    ..aOS(5, _omitFieldNames ? '' : 'relativePath')
    ..aOS(6, _omitFieldNames ? '' : 'language')
    ..aOS(7, _omitFieldNames ? '' : 'content')
    ..aInt64(8, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CodeFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CodeFile copyWith(void Function(CodeFile) updates) =>
      super.copyWith((message) => updates(message as CodeFile)) as CodeFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CodeFile() / CodeFile.new instead')
  static CodeFile create() => CodeFile._();
  static $pb.GeneratedMessage $_createMessage() => CodeFile._();
  @$core.override
  CodeFile createEmptyInstance() => CodeFile._();
  @$core.pragma('dart2js:noInline')
  static CodeFile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CodeFile>(CodeFile.$_createMessage);
  static CodeFile? _defaultInstance;

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
  $core.String get lessonId => $_getSZ(2);
  @$pb.TagNumber(3)
  set lessonId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLessonId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLessonId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get homeworkTaskId => $_getSZ(3);
  @$pb.TagNumber(4)
  set homeworkTaskId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHomeworkTaskId() => $_has(3);
  @$pb.TagNumber(4)
  void clearHomeworkTaskId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get relativePath => $_getSZ(4);
  @$pb.TagNumber(5)
  set relativePath($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRelativePath() => $_has(4);
  @$pb.TagNumber(5)
  void clearRelativePath() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get language => $_getSZ(5);
  @$pb.TagNumber(6)
  set language($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLanguage() => $_has(5);
  @$pb.TagNumber(6)
  void clearLanguage() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get content => $_getSZ(6);
  @$pb.TagNumber(7)
  set content($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasContent() => $_has(6);
  @$pb.TagNumber(7)
  void clearContent() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get version => $_getI64(7);
  @$pb.TagNumber(8)
  set version($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearVersion() => $_clearField(8);
}

class GetLessonWorkspaceRequest extends $pb.GeneratedMessage {
  factory GetLessonWorkspaceRequest({
    $core.String? lessonId,
  }) {
    final result = GetLessonWorkspaceRequest._();
    if (lessonId != null) result.lessonId = lessonId;
    return result;
  }

  GetLessonWorkspaceRequest._();

  factory GetLessonWorkspaceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetLessonWorkspaceRequest()..mergeFromBuffer(data, registry);
  factory GetLessonWorkspaceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetLessonWorkspaceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLessonWorkspaceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: GetLessonWorkspaceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'lessonId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLessonWorkspaceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLessonWorkspaceRequest copyWith(
          void Function(GetLessonWorkspaceRequest) updates) =>
      super.copyWith((message) => updates(message as GetLessonWorkspaceRequest))
          as GetLessonWorkspaceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetLessonWorkspaceRequest() / GetLessonWorkspaceRequest.new instead')
  static GetLessonWorkspaceRequest create() => GetLessonWorkspaceRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      GetLessonWorkspaceRequest._();
  @$core.override
  GetLessonWorkspaceRequest createEmptyInstance() =>
      GetLessonWorkspaceRequest._();
  @$core.pragma('dart2js:noInline')
  static GetLessonWorkspaceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLessonWorkspaceRequest>(
          GetLessonWorkspaceRequest.$_createMessage);
  static GetLessonWorkspaceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get lessonId => $_getSZ(0);
  @$pb.TagNumber(1)
  set lessonId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLessonId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLessonId() => $_clearField(1);
}

class LessonWorkspace extends $pb.GeneratedMessage {
  factory LessonWorkspace({
    $1.Lesson? lesson,
    $core.Iterable<NoteBlock>? blocks,
    $core.Iterable<HomeworkTask>? tasks,
    $core.Iterable<CodeFile>? files,
    $core.Iterable<$core.String>? conceptIds,
  }) {
    final result = LessonWorkspace._();
    if (lesson != null) result.lesson = lesson;
    if (blocks != null) result.blocks.addAll(blocks);
    if (tasks != null) result.tasks.addAll(tasks);
    if (files != null) result.files.addAll(files);
    if (conceptIds != null) result.conceptIds.addAll(conceptIds);
    return result;
  }

  LessonWorkspace._();

  factory LessonWorkspace.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LessonWorkspace()..mergeFromBuffer(data, registry);
  factory LessonWorkspace.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LessonWorkspace()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LessonWorkspace',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: LessonWorkspace.$_createMessage)
    ..aOM<$1.Lesson>(1, _omitFieldNames ? '' : 'lesson',
        subBuilder: $1.Lesson.$_createMessage)
    ..pPM<NoteBlock>(2, _omitFieldNames ? '' : 'blocks',
        subBuilder: NoteBlock.$_createMessage)
    ..pPM<HomeworkTask>(3, _omitFieldNames ? '' : 'tasks',
        subBuilder: HomeworkTask.$_createMessage)
    ..pPM<CodeFile>(4, _omitFieldNames ? '' : 'files',
        subBuilder: CodeFile.$_createMessage)
    ..pPS(5, _omitFieldNames ? '' : 'conceptIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LessonWorkspace clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LessonWorkspace copyWith(void Function(LessonWorkspace) updates) =>
      super.copyWith((message) => updates(message as LessonWorkspace))
          as LessonWorkspace;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LessonWorkspace() / LessonWorkspace.new instead')
  static LessonWorkspace create() => LessonWorkspace._();
  static $pb.GeneratedMessage $_createMessage() => LessonWorkspace._();
  @$core.override
  LessonWorkspace createEmptyInstance() => LessonWorkspace._();
  @$core.pragma('dart2js:noInline')
  static LessonWorkspace getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LessonWorkspace>(
          LessonWorkspace.$_createMessage);
  static LessonWorkspace? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Lesson get lesson => $_getN(0);
  @$pb.TagNumber(1)
  set lesson($1.Lesson value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLesson() => $_has(0);
  @$pb.TagNumber(1)
  void clearLesson() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Lesson ensureLesson() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<NoteBlock> get blocks => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<HomeworkTask> get tasks => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<CodeFile> get files => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get conceptIds => $_getList(4);
}

class CreateNoteBlockRequest extends $pb.GeneratedMessage {
  factory CreateNoteBlockRequest({
    NoteBlock? block,
  }) {
    final result = CreateNoteBlockRequest._();
    if (block != null) result.block = block;
    return result;
  }

  CreateNoteBlockRequest._();

  factory CreateNoteBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateNoteBlockRequest()..mergeFromBuffer(data, registry);
  factory CreateNoteBlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateNoteBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateNoteBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateNoteBlockRequest.$_createMessage)
    ..aOM<NoteBlock>(1, _omitFieldNames ? '' : 'block',
        subBuilder: NoteBlock.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateNoteBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateNoteBlockRequest copyWith(
          void Function(CreateNoteBlockRequest) updates) =>
      super.copyWith((message) => updates(message as CreateNoteBlockRequest))
          as CreateNoteBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateNoteBlockRequest() / CreateNoteBlockRequest.new instead')
  static CreateNoteBlockRequest create() => CreateNoteBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateNoteBlockRequest._();
  @$core.override
  CreateNoteBlockRequest createEmptyInstance() => CreateNoteBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateNoteBlockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateNoteBlockRequest>(
          CreateNoteBlockRequest.$_createMessage);
  static CreateNoteBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  NoteBlock get block => $_getN(0);
  @$pb.TagNumber(1)
  set block(NoteBlock value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlock() => $_clearField(1);
  @$pb.TagNumber(1)
  NoteBlock ensureBlock() => $_ensure(0);
}

class UpdateNoteBlockRequest extends $pb.GeneratedMessage {
  factory UpdateNoteBlockRequest({
    NoteBlock? block,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateNoteBlockRequest._();
    if (block != null) result.block = block;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateNoteBlockRequest._();

  factory UpdateNoteBlockRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateNoteBlockRequest()..mergeFromBuffer(data, registry);
  factory UpdateNoteBlockRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateNoteBlockRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateNoteBlockRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateNoteBlockRequest.$_createMessage)
    ..aOM<NoteBlock>(1, _omitFieldNames ? '' : 'block',
        subBuilder: NoteBlock.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNoteBlockRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNoteBlockRequest copyWith(
          void Function(UpdateNoteBlockRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateNoteBlockRequest))
          as UpdateNoteBlockRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateNoteBlockRequest() / UpdateNoteBlockRequest.new instead')
  static UpdateNoteBlockRequest create() => UpdateNoteBlockRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateNoteBlockRequest._();
  @$core.override
  UpdateNoteBlockRequest createEmptyInstance() => UpdateNoteBlockRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateNoteBlockRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNoteBlockRequest>(
          UpdateNoteBlockRequest.$_createMessage);
  static UpdateNoteBlockRequest? _defaultInstance;

  @$pb.TagNumber(1)
  NoteBlock get block => $_getN(0);
  @$pb.TagNumber(1)
  set block(NoteBlock value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlock() => $_clearField(1);
  @$pb.TagNumber(1)
  NoteBlock ensureBlock() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);
}

class CreateHomeworkTaskRequest extends $pb.GeneratedMessage {
  factory CreateHomeworkTaskRequest({
    HomeworkTask? task,
  }) {
    final result = CreateHomeworkTaskRequest._();
    if (task != null) result.task = task;
    return result;
  }

  CreateHomeworkTaskRequest._();

  factory CreateHomeworkTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateHomeworkTaskRequest()..mergeFromBuffer(data, registry);
  factory CreateHomeworkTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateHomeworkTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateHomeworkTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateHomeworkTaskRequest.$_createMessage)
    ..aOM<HomeworkTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: HomeworkTask.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateHomeworkTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateHomeworkTaskRequest copyWith(
          void Function(CreateHomeworkTaskRequest) updates) =>
      super.copyWith((message) => updates(message as CreateHomeworkTaskRequest))
          as CreateHomeworkTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateHomeworkTaskRequest() / CreateHomeworkTaskRequest.new instead')
  static CreateHomeworkTaskRequest create() => CreateHomeworkTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      CreateHomeworkTaskRequest._();
  @$core.override
  CreateHomeworkTaskRequest createEmptyInstance() =>
      CreateHomeworkTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateHomeworkTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateHomeworkTaskRequest>(
          CreateHomeworkTaskRequest.$_createMessage);
  static CreateHomeworkTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HomeworkTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(HomeworkTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  HomeworkTask ensureTask() => $_ensure(0);
}

class UpdateHomeworkTaskRequest extends $pb.GeneratedMessage {
  factory UpdateHomeworkTaskRequest({
    HomeworkTask? task,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateHomeworkTaskRequest._();
    if (task != null) result.task = task;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateHomeworkTaskRequest._();

  factory UpdateHomeworkTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateHomeworkTaskRequest()..mergeFromBuffer(data, registry);
  factory UpdateHomeworkTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateHomeworkTaskRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateHomeworkTaskRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateHomeworkTaskRequest.$_createMessage)
    ..aOM<HomeworkTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: HomeworkTask.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateHomeworkTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateHomeworkTaskRequest copyWith(
          void Function(UpdateHomeworkTaskRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateHomeworkTaskRequest))
          as UpdateHomeworkTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateHomeworkTaskRequest() / UpdateHomeworkTaskRequest.new instead')
  static UpdateHomeworkTaskRequest create() => UpdateHomeworkTaskRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      UpdateHomeworkTaskRequest._();
  @$core.override
  UpdateHomeworkTaskRequest createEmptyInstance() =>
      UpdateHomeworkTaskRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateHomeworkTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateHomeworkTaskRequest>(
          UpdateHomeworkTaskRequest.$_createMessage);
  static UpdateHomeworkTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HomeworkTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(HomeworkTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  HomeworkTask ensureTask() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);
}

class CreateCodeFileRequest extends $pb.GeneratedMessage {
  factory CreateCodeFileRequest({
    CodeFile? file,
  }) {
    final result = CreateCodeFileRequest._();
    if (file != null) result.file = file;
    return result;
  }

  CreateCodeFileRequest._();

  factory CreateCodeFileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCodeFileRequest()..mergeFromBuffer(data, registry);
  factory CreateCodeFileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCodeFileRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCodeFileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: CreateCodeFileRequest.$_createMessage)
    ..aOM<CodeFile>(1, _omitFieldNames ? '' : 'file',
        subBuilder: CodeFile.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCodeFileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCodeFileRequest copyWith(
          void Function(CreateCodeFileRequest) updates) =>
      super.copyWith((message) => updates(message as CreateCodeFileRequest))
          as CreateCodeFileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CreateCodeFileRequest() / CreateCodeFileRequest.new instead')
  static CreateCodeFileRequest create() => CreateCodeFileRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateCodeFileRequest._();
  @$core.override
  CreateCodeFileRequest createEmptyInstance() => CreateCodeFileRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateCodeFileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCodeFileRequest>(
          CreateCodeFileRequest.$_createMessage);
  static CreateCodeFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  CodeFile get file => $_getN(0);
  @$pb.TagNumber(1)
  set file(CodeFile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);
  @$pb.TagNumber(1)
  CodeFile ensureFile() => $_ensure(0);
}

class UpdateCodeFileRequest extends $pb.GeneratedMessage {
  factory UpdateCodeFileRequest({
    CodeFile? file,
    $fixnum.Int64? expectedVersion,
  }) {
    final result = UpdateCodeFileRequest._();
    if (file != null) result.file = file;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    return result;
  }

  UpdateCodeFileRequest._();

  factory UpdateCodeFileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateCodeFileRequest()..mergeFromBuffer(data, registry);
  factory UpdateCodeFileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateCodeFileRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCodeFileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: UpdateCodeFileRequest.$_createMessage)
    ..aOM<CodeFile>(1, _omitFieldNames ? '' : 'file',
        subBuilder: CodeFile.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCodeFileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCodeFileRequest copyWith(
          void Function(UpdateCodeFileRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateCodeFileRequest))
          as UpdateCodeFileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use UpdateCodeFileRequest() / UpdateCodeFileRequest.new instead')
  static UpdateCodeFileRequest create() => UpdateCodeFileRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateCodeFileRequest._();
  @$core.override
  UpdateCodeFileRequest createEmptyInstance() => UpdateCodeFileRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateCodeFileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCodeFileRequest>(
          UpdateCodeFileRequest.$_createMessage);
  static UpdateCodeFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  CodeFile get file => $_getN(0);
  @$pb.TagNumber(1)
  set file(CodeFile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);
  @$pb.TagNumber(1)
  CodeFile ensureFile() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expectedVersion => $_getI64(1);
  @$pb.TagNumber(2)
  set expectedVersion($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpectedVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpectedVersion() => $_clearField(2);
}

class DeleteContentRequest extends $pb.GeneratedMessage {
  factory DeleteContentRequest({
    $core.String? id,
    $fixnum.Int64? expectedVersion,
    $core.bool? confirmed,
  }) {
    final result = DeleteContentRequest._();
    if (id != null) result.id = id;
    if (expectedVersion != null) result.expectedVersion = expectedVersion;
    if (confirmed != null) result.confirmed = confirmed;
    return result;
  }

  DeleteContentRequest._();

  factory DeleteContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteContentRequest()..mergeFromBuffer(data, registry);
  factory DeleteContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteContentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: DeleteContentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'expectedVersion')
    ..aOB(3, _omitFieldNames ? '' : 'confirmed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentRequest copyWith(void Function(DeleteContentRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteContentRequest))
          as DeleteContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DeleteContentRequest() / DeleteContentRequest.new instead')
  static DeleteContentRequest create() => DeleteContentRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteContentRequest._();
  @$core.override
  DeleteContentRequest createEmptyInstance() => DeleteContentRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteContentRequest>(
          DeleteContentRequest.$_createMessage);
  static DeleteContentRequest? _defaultInstance;

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

class DeleteContentResponse extends $pb.GeneratedMessage {
  factory DeleteContentResponse({
    $core.String? id,
  }) {
    final result = DeleteContentResponse._();
    if (id != null) result.id = id;
    return result;
  }

  DeleteContentResponse._();

  factory DeleteContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteContentResponse()..mergeFromBuffer(data, registry);
  factory DeleteContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteContentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteContentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: DeleteContentResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteContentResponse copyWith(
          void Function(DeleteContentResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteContentResponse))
          as DeleteContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use DeleteContentResponse() / DeleteContentResponse.new instead')
  static DeleteContentResponse create() => DeleteContentResponse._();
  static $pb.GeneratedMessage $_createMessage() => DeleteContentResponse._();
  @$core.override
  DeleteContentResponse createEmptyInstance() => DeleteContentResponse._();
  @$core.pragma('dart2js:noInline')
  static DeleteContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteContentResponse>(
          DeleteContentResponse.$_createMessage);
  static DeleteContentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ReorderLessonContentRequest extends $pb.GeneratedMessage {
  factory ReorderLessonContentRequest({
    $core.String? lessonId,
    $core.Iterable<$1.ReorderItem>? blocks,
    $core.Iterable<$1.ReorderItem>? tasks,
  }) {
    final result = ReorderLessonContentRequest._();
    if (lessonId != null) result.lessonId = lessonId;
    if (blocks != null) result.blocks.addAll(blocks);
    if (tasks != null) result.tasks.addAll(tasks);
    return result;
  }

  ReorderLessonContentRequest._();

  factory ReorderLessonContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReorderLessonContentRequest()..mergeFromBuffer(data, registry);
  factory ReorderLessonContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReorderLessonContentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReorderLessonContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'wantstudy.v1'),
      createEmptyInstance: ReorderLessonContentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'lessonId')
    ..pPM<$1.ReorderItem>(2, _omitFieldNames ? '' : 'blocks',
        subBuilder: $1.ReorderItem.$_createMessage)
    ..pPM<$1.ReorderItem>(3, _omitFieldNames ? '' : 'tasks',
        subBuilder: $1.ReorderItem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderLessonContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReorderLessonContentRequest copyWith(
          void Function(ReorderLessonContentRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ReorderLessonContentRequest))
          as ReorderLessonContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ReorderLessonContentRequest() / ReorderLessonContentRequest.new instead')
  static ReorderLessonContentRequest create() =>
      ReorderLessonContentRequest._();
  static $pb.GeneratedMessage $_createMessage() =>
      ReorderLessonContentRequest._();
  @$core.override
  ReorderLessonContentRequest createEmptyInstance() =>
      ReorderLessonContentRequest._();
  @$core.pragma('dart2js:noInline')
  static ReorderLessonContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReorderLessonContentRequest>(
          ReorderLessonContentRequest.$_createMessage);
  static ReorderLessonContentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get lessonId => $_getSZ(0);
  @$pb.TagNumber(1)
  set lessonId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLessonId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLessonId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$1.ReorderItem> get blocks => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$1.ReorderItem> get tasks => $_getList(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
