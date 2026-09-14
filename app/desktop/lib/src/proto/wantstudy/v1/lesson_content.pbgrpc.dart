// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/lesson_content.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'lesson_content.pb.dart' as $0;

export 'lesson_content.pb.dart';

@$pb.GrpcServiceName('wantstudy.v1.LessonContentService')
class LessonContentServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  LessonContentServiceClient(super.channel,
      {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.LessonWorkspace> getLessonWorkspace(
    $0.GetLessonWorkspaceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLessonWorkspace, request, options: options);
  }

  $grpc.ResponseFuture<$0.NoteBlock> createNoteBlock(
    $0.CreateNoteBlockRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createNoteBlock, request, options: options);
  }

  $grpc.ResponseFuture<$0.NoteBlock> updateNoteBlock(
    $0.UpdateNoteBlockRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateNoteBlock, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteContentResponse> deleteNoteBlock(
    $0.DeleteContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteNoteBlock, request, options: options);
  }

  $grpc.ResponseFuture<$0.HomeworkTask> createHomeworkTask(
    $0.CreateHomeworkTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createHomeworkTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.HomeworkTask> updateHomeworkTask(
    $0.UpdateHomeworkTaskRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateHomeworkTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteContentResponse> deleteHomeworkTask(
    $0.DeleteContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteHomeworkTask, request, options: options);
  }

  $grpc.ResponseFuture<$0.CodeFile> createCodeFile(
    $0.CreateCodeFileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createCodeFile, request, options: options);
  }

  $grpc.ResponseFuture<$0.CodeFile> updateCodeFile(
    $0.UpdateCodeFileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateCodeFile, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteContentResponse> deleteCodeFile(
    $0.DeleteContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteCodeFile, request, options: options);
  }

  $grpc.ResponseFuture<$0.LessonWorkspace> reorderLessonContent(
    $0.ReorderLessonContentRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reorderLessonContent, request, options: options);
  }

  // method descriptors

  static final _$getLessonWorkspace =
      $grpc.ClientMethod<$0.GetLessonWorkspaceRequest, $0.LessonWorkspace>(
          '/wantstudy.v1.LessonContentService/GetLessonWorkspace',
          ($0.GetLessonWorkspaceRequest value) => value.writeToBuffer(),
          $0.LessonWorkspace.fromBuffer);
  static final _$createNoteBlock =
      $grpc.ClientMethod<$0.CreateNoteBlockRequest, $0.NoteBlock>(
          '/wantstudy.v1.LessonContentService/CreateNoteBlock',
          ($0.CreateNoteBlockRequest value) => value.writeToBuffer(),
          $0.NoteBlock.fromBuffer);
  static final _$updateNoteBlock =
      $grpc.ClientMethod<$0.UpdateNoteBlockRequest, $0.NoteBlock>(
          '/wantstudy.v1.LessonContentService/UpdateNoteBlock',
          ($0.UpdateNoteBlockRequest value) => value.writeToBuffer(),
          $0.NoteBlock.fromBuffer);
  static final _$deleteNoteBlock =
      $grpc.ClientMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
          '/wantstudy.v1.LessonContentService/DeleteNoteBlock',
          ($0.DeleteContentRequest value) => value.writeToBuffer(),
          $0.DeleteContentResponse.fromBuffer);
  static final _$createHomeworkTask =
      $grpc.ClientMethod<$0.CreateHomeworkTaskRequest, $0.HomeworkTask>(
          '/wantstudy.v1.LessonContentService/CreateHomeworkTask',
          ($0.CreateHomeworkTaskRequest value) => value.writeToBuffer(),
          $0.HomeworkTask.fromBuffer);
  static final _$updateHomeworkTask =
      $grpc.ClientMethod<$0.UpdateHomeworkTaskRequest, $0.HomeworkTask>(
          '/wantstudy.v1.LessonContentService/UpdateHomeworkTask',
          ($0.UpdateHomeworkTaskRequest value) => value.writeToBuffer(),
          $0.HomeworkTask.fromBuffer);
  static final _$deleteHomeworkTask =
      $grpc.ClientMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
          '/wantstudy.v1.LessonContentService/DeleteHomeworkTask',
          ($0.DeleteContentRequest value) => value.writeToBuffer(),
          $0.DeleteContentResponse.fromBuffer);
  static final _$createCodeFile =
      $grpc.ClientMethod<$0.CreateCodeFileRequest, $0.CodeFile>(
          '/wantstudy.v1.LessonContentService/CreateCodeFile',
          ($0.CreateCodeFileRequest value) => value.writeToBuffer(),
          $0.CodeFile.fromBuffer);
  static final _$updateCodeFile =
      $grpc.ClientMethod<$0.UpdateCodeFileRequest, $0.CodeFile>(
          '/wantstudy.v1.LessonContentService/UpdateCodeFile',
          ($0.UpdateCodeFileRequest value) => value.writeToBuffer(),
          $0.CodeFile.fromBuffer);
  static final _$deleteCodeFile =
      $grpc.ClientMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
          '/wantstudy.v1.LessonContentService/DeleteCodeFile',
          ($0.DeleteContentRequest value) => value.writeToBuffer(),
          $0.DeleteContentResponse.fromBuffer);
  static final _$reorderLessonContent =
      $grpc.ClientMethod<$0.ReorderLessonContentRequest, $0.LessonWorkspace>(
          '/wantstudy.v1.LessonContentService/ReorderLessonContent',
          ($0.ReorderLessonContentRequest value) => value.writeToBuffer(),
          $0.LessonWorkspace.fromBuffer);
}

@$pb.GrpcServiceName('wantstudy.v1.LessonContentService')
abstract class LessonContentServiceBase extends $grpc.Service {
  $core.String get $name => 'wantstudy.v1.LessonContentService';

  LessonContentServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetLessonWorkspaceRequest, $0.LessonWorkspace>(
            'GetLessonWorkspace',
            getLessonWorkspace_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetLessonWorkspaceRequest.fromBuffer(value),
            ($0.LessonWorkspace value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateNoteBlockRequest, $0.NoteBlock>(
        'CreateNoteBlock',
        createNoteBlock_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateNoteBlockRequest.fromBuffer(value),
        ($0.NoteBlock value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateNoteBlockRequest, $0.NoteBlock>(
        'UpdateNoteBlock',
        updateNoteBlock_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateNoteBlockRequest.fromBuffer(value),
        ($0.NoteBlock value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
            'DeleteNoteBlock',
            deleteNoteBlock_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteContentRequest.fromBuffer(value),
            ($0.DeleteContentResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateHomeworkTaskRequest, $0.HomeworkTask>(
            'CreateHomeworkTask',
            createHomeworkTask_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateHomeworkTaskRequest.fromBuffer(value),
            ($0.HomeworkTask value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateHomeworkTaskRequest, $0.HomeworkTask>(
            'UpdateHomeworkTask',
            updateHomeworkTask_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateHomeworkTaskRequest.fromBuffer(value),
            ($0.HomeworkTask value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
            'DeleteHomeworkTask',
            deleteHomeworkTask_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteContentRequest.fromBuffer(value),
            ($0.DeleteContentResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateCodeFileRequest, $0.CodeFile>(
        'CreateCodeFile',
        createCodeFile_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateCodeFileRequest.fromBuffer(value),
        ($0.CodeFile value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateCodeFileRequest, $0.CodeFile>(
        'UpdateCodeFile',
        updateCodeFile_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateCodeFileRequest.fromBuffer(value),
        ($0.CodeFile value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteContentRequest, $0.DeleteContentResponse>(
            'DeleteCodeFile',
            deleteCodeFile_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteContentRequest.fromBuffer(value),
            ($0.DeleteContentResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ReorderLessonContentRequest, $0.LessonWorkspace>(
            'ReorderLessonContent',
            reorderLessonContent_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ReorderLessonContentRequest.fromBuffer(value),
            ($0.LessonWorkspace value) => value.writeToBuffer()));
  }

  $async.Future<$0.LessonWorkspace> getLessonWorkspace_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetLessonWorkspaceRequest> $request) async {
    return getLessonWorkspace($call, await $request);
  }

  $async.Future<$0.LessonWorkspace> getLessonWorkspace(
      $grpc.ServiceCall call, $0.GetLessonWorkspaceRequest request);

  $async.Future<$0.NoteBlock> createNoteBlock_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateNoteBlockRequest> $request) async {
    return createNoteBlock($call, await $request);
  }

  $async.Future<$0.NoteBlock> createNoteBlock(
      $grpc.ServiceCall call, $0.CreateNoteBlockRequest request);

  $async.Future<$0.NoteBlock> updateNoteBlock_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateNoteBlockRequest> $request) async {
    return updateNoteBlock($call, await $request);
  }

  $async.Future<$0.NoteBlock> updateNoteBlock(
      $grpc.ServiceCall call, $0.UpdateNoteBlockRequest request);

  $async.Future<$0.DeleteContentResponse> deleteNoteBlock_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteContentRequest> $request) async {
    return deleteNoteBlock($call, await $request);
  }

  $async.Future<$0.DeleteContentResponse> deleteNoteBlock(
      $grpc.ServiceCall call, $0.DeleteContentRequest request);

  $async.Future<$0.HomeworkTask> createHomeworkTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateHomeworkTaskRequest> $request) async {
    return createHomeworkTask($call, await $request);
  }

  $async.Future<$0.HomeworkTask> createHomeworkTask(
      $grpc.ServiceCall call, $0.CreateHomeworkTaskRequest request);

  $async.Future<$0.HomeworkTask> updateHomeworkTask_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateHomeworkTaskRequest> $request) async {
    return updateHomeworkTask($call, await $request);
  }

  $async.Future<$0.HomeworkTask> updateHomeworkTask(
      $grpc.ServiceCall call, $0.UpdateHomeworkTaskRequest request);

  $async.Future<$0.DeleteContentResponse> deleteHomeworkTask_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteContentRequest> $request) async {
    return deleteHomeworkTask($call, await $request);
  }

  $async.Future<$0.DeleteContentResponse> deleteHomeworkTask(
      $grpc.ServiceCall call, $0.DeleteContentRequest request);

  $async.Future<$0.CodeFile> createCodeFile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateCodeFileRequest> $request) async {
    return createCodeFile($call, await $request);
  }

  $async.Future<$0.CodeFile> createCodeFile(
      $grpc.ServiceCall call, $0.CreateCodeFileRequest request);

  $async.Future<$0.CodeFile> updateCodeFile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateCodeFileRequest> $request) async {
    return updateCodeFile($call, await $request);
  }

  $async.Future<$0.CodeFile> updateCodeFile(
      $grpc.ServiceCall call, $0.UpdateCodeFileRequest request);

  $async.Future<$0.DeleteContentResponse> deleteCodeFile_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteContentRequest> $request) async {
    return deleteCodeFile($call, await $request);
  }

  $async.Future<$0.DeleteContentResponse> deleteCodeFile(
      $grpc.ServiceCall call, $0.DeleteContentRequest request);

  $async.Future<$0.LessonWorkspace> reorderLessonContent_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ReorderLessonContentRequest> $request) async {
    return reorderLessonContent($call, await $request);
  }

  $async.Future<$0.LessonWorkspace> reorderLessonContent(
      $grpc.ServiceCall call, $0.ReorderLessonContentRequest request);
}
