// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/study.proto.

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

import 'study.pb.dart' as $0;

export 'study.pb.dart';

@$pb.GrpcServiceName('wantstudy.v1.StudyCatalogService')
class StudyCatalogServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  StudyCatalogServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Study> createStudy(
    $0.CreateStudyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createStudy, request, options: options);
  }

  $grpc.ResponseFuture<$0.Study> getStudy(
    $0.GetStudyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStudy, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListStudiesResponse> listStudies(
    $0.ListStudiesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listStudies, request, options: options);
  }

  $grpc.ResponseFuture<$0.Study> updateStudy(
    $0.UpdateStudyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateStudy, request, options: options);
  }

  $grpc.ResponseFuture<$0.Study> archiveStudy(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archiveStudy, request, options: options);
  }

  $grpc.ResponseFuture<$0.Study> restoreStudy(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restoreStudy, request, options: options);
  }

  $grpc.ResponseFuture<$0.LearningSource> createLearningSource(
    $0.CreateLearningSourceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createLearningSource, request, options: options);
  }

  $grpc.ResponseFuture<$0.LearningSource> updateLearningSource(
    $0.UpdateLearningSourceRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateLearningSource, request, options: options);
  }

  $grpc.ResponseFuture<$0.LearningSource> archiveLearningSource(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archiveLearningSource, request, options: options);
  }

  $grpc.ResponseFuture<$0.LearningSource> restoreLearningSource(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restoreLearningSource, request, options: options);
  }

  $grpc.ResponseFuture<$0.Section> createSection(
    $0.CreateSectionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createSection, request, options: options);
  }

  $grpc.ResponseFuture<$0.Section> updateSection(
    $0.UpdateSectionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateSection, request, options: options);
  }

  $grpc.ResponseFuture<$0.Section> archiveSection(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archiveSection, request, options: options);
  }

  $grpc.ResponseFuture<$0.Section> restoreSection(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restoreSection, request, options: options);
  }

  $grpc.ResponseFuture<$0.Lesson> createLesson(
    $0.CreateLessonRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createLesson, request, options: options);
  }

  $grpc.ResponseFuture<$0.Lesson> updateLesson(
    $0.UpdateLessonRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateLesson, request, options: options);
  }

  $grpc.ResponseFuture<$0.Lesson> archiveLesson(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archiveLesson, request, options: options);
  }

  $grpc.ResponseFuture<$0.Lesson> restoreLesson(
    $0.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restoreLesson, request, options: options);
  }

  $grpc.ResponseFuture<$0.Lesson> changeLessonStatus(
    $0.ChangeLessonStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$changeLessonStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.MaterialTree> getMaterialTree(
    $0.GetMaterialTreeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMaterialTree, request, options: options);
  }

  $grpc.ResponseFuture<$0.MaterialTree> reorderMaterial(
    $0.ReorderMaterialRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$reorderMaterial, request, options: options);
  }

  $grpc.ResponseFuture<$0.Dashboard> getDashboard(
    $0.GetDashboardRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDashboard, request, options: options);
  }

  // method descriptors

  static final _$createStudy =
      $grpc.ClientMethod<$0.CreateStudyRequest, $0.Study>(
          '/wantstudy.v1.StudyCatalogService/CreateStudy',
          ($0.CreateStudyRequest value) => value.writeToBuffer(),
          $0.Study.fromBuffer);
  static final _$getStudy = $grpc.ClientMethod<$0.GetStudyRequest, $0.Study>(
      '/wantstudy.v1.StudyCatalogService/GetStudy',
      ($0.GetStudyRequest value) => value.writeToBuffer(),
      $0.Study.fromBuffer);
  static final _$listStudies =
      $grpc.ClientMethod<$0.ListStudiesRequest, $0.ListStudiesResponse>(
          '/wantstudy.v1.StudyCatalogService/ListStudies',
          ($0.ListStudiesRequest value) => value.writeToBuffer(),
          $0.ListStudiesResponse.fromBuffer);
  static final _$updateStudy =
      $grpc.ClientMethod<$0.UpdateStudyRequest, $0.Study>(
          '/wantstudy.v1.StudyCatalogService/UpdateStudy',
          ($0.UpdateStudyRequest value) => value.writeToBuffer(),
          $0.Study.fromBuffer);
  static final _$archiveStudy =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.Study>(
          '/wantstudy.v1.StudyCatalogService/ArchiveStudy',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Study.fromBuffer);
  static final _$restoreStudy =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.Study>(
          '/wantstudy.v1.StudyCatalogService/RestoreStudy',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Study.fromBuffer);
  static final _$createLearningSource =
      $grpc.ClientMethod<$0.CreateLearningSourceRequest, $0.LearningSource>(
          '/wantstudy.v1.StudyCatalogService/CreateLearningSource',
          ($0.CreateLearningSourceRequest value) => value.writeToBuffer(),
          $0.LearningSource.fromBuffer);
  static final _$updateLearningSource =
      $grpc.ClientMethod<$0.UpdateLearningSourceRequest, $0.LearningSource>(
          '/wantstudy.v1.StudyCatalogService/UpdateLearningSource',
          ($0.UpdateLearningSourceRequest value) => value.writeToBuffer(),
          $0.LearningSource.fromBuffer);
  static final _$archiveLearningSource =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.LearningSource>(
          '/wantstudy.v1.StudyCatalogService/ArchiveLearningSource',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.LearningSource.fromBuffer);
  static final _$restoreLearningSource =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.LearningSource>(
          '/wantstudy.v1.StudyCatalogService/RestoreLearningSource',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.LearningSource.fromBuffer);
  static final _$createSection =
      $grpc.ClientMethod<$0.CreateSectionRequest, $0.Section>(
          '/wantstudy.v1.StudyCatalogService/CreateSection',
          ($0.CreateSectionRequest value) => value.writeToBuffer(),
          $0.Section.fromBuffer);
  static final _$updateSection =
      $grpc.ClientMethod<$0.UpdateSectionRequest, $0.Section>(
          '/wantstudy.v1.StudyCatalogService/UpdateSection',
          ($0.UpdateSectionRequest value) => value.writeToBuffer(),
          $0.Section.fromBuffer);
  static final _$archiveSection =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.Section>(
          '/wantstudy.v1.StudyCatalogService/ArchiveSection',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Section.fromBuffer);
  static final _$restoreSection =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.Section>(
          '/wantstudy.v1.StudyCatalogService/RestoreSection',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Section.fromBuffer);
  static final _$createLesson =
      $grpc.ClientMethod<$0.CreateLessonRequest, $0.Lesson>(
          '/wantstudy.v1.StudyCatalogService/CreateLesson',
          ($0.CreateLessonRequest value) => value.writeToBuffer(),
          $0.Lesson.fromBuffer);
  static final _$updateLesson =
      $grpc.ClientMethod<$0.UpdateLessonRequest, $0.Lesson>(
          '/wantstudy.v1.StudyCatalogService/UpdateLesson',
          ($0.UpdateLessonRequest value) => value.writeToBuffer(),
          $0.Lesson.fromBuffer);
  static final _$archiveLesson =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.Lesson>(
          '/wantstudy.v1.StudyCatalogService/ArchiveLesson',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Lesson.fromBuffer);
  static final _$restoreLesson =
      $grpc.ClientMethod<$0.ChangeArchiveRequest, $0.Lesson>(
          '/wantstudy.v1.StudyCatalogService/RestoreLesson',
          ($0.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Lesson.fromBuffer);
  static final _$changeLessonStatus =
      $grpc.ClientMethod<$0.ChangeLessonStatusRequest, $0.Lesson>(
          '/wantstudy.v1.StudyCatalogService/ChangeLessonStatus',
          ($0.ChangeLessonStatusRequest value) => value.writeToBuffer(),
          $0.Lesson.fromBuffer);
  static final _$getMaterialTree =
      $grpc.ClientMethod<$0.GetMaterialTreeRequest, $0.MaterialTree>(
          '/wantstudy.v1.StudyCatalogService/GetMaterialTree',
          ($0.GetMaterialTreeRequest value) => value.writeToBuffer(),
          $0.MaterialTree.fromBuffer);
  static final _$reorderMaterial =
      $grpc.ClientMethod<$0.ReorderMaterialRequest, $0.MaterialTree>(
          '/wantstudy.v1.StudyCatalogService/ReorderMaterial',
          ($0.ReorderMaterialRequest value) => value.writeToBuffer(),
          $0.MaterialTree.fromBuffer);
  static final _$getDashboard =
      $grpc.ClientMethod<$0.GetDashboardRequest, $0.Dashboard>(
          '/wantstudy.v1.StudyCatalogService/GetDashboard',
          ($0.GetDashboardRequest value) => value.writeToBuffer(),
          $0.Dashboard.fromBuffer);
}

@$pb.GrpcServiceName('wantstudy.v1.StudyCatalogService')
abstract class StudyCatalogServiceBase extends $grpc.Service {
  $core.String get $name => 'wantstudy.v1.StudyCatalogService';

  StudyCatalogServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateStudyRequest, $0.Study>(
        'CreateStudy',
        createStudy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateStudyRequest.fromBuffer(value),
        ($0.Study value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetStudyRequest, $0.Study>(
        'GetStudy',
        getStudy_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetStudyRequest.fromBuffer(value),
        ($0.Study value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListStudiesRequest, $0.ListStudiesResponse>(
            'ListStudies',
            listStudies_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListStudiesRequest.fromBuffer(value),
            ($0.ListStudiesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateStudyRequest, $0.Study>(
        'UpdateStudy',
        updateStudy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateStudyRequest.fromBuffer(value),
        ($0.Study value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.Study>(
        'ArchiveStudy',
        archiveStudy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.Study value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.Study>(
        'RestoreStudy',
        restoreStudy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.Study value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateLearningSourceRequest, $0.LearningSource>(
            'CreateLearningSource',
            createLearningSource_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateLearningSourceRequest.fromBuffer(value),
            ($0.LearningSource value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateLearningSourceRequest, $0.LearningSource>(
            'UpdateLearningSource',
            updateLearningSource_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateLearningSourceRequest.fromBuffer(value),
            ($0.LearningSource value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.LearningSource>(
        'ArchiveLearningSource',
        archiveLearningSource_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.LearningSource value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.LearningSource>(
        'RestoreLearningSource',
        restoreLearningSource_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.LearningSource value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateSectionRequest, $0.Section>(
        'CreateSection',
        createSection_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateSectionRequest.fromBuffer(value),
        ($0.Section value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateSectionRequest, $0.Section>(
        'UpdateSection',
        updateSection_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateSectionRequest.fromBuffer(value),
        ($0.Section value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.Section>(
        'ArchiveSection',
        archiveSection_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.Section value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.Section>(
        'RestoreSection',
        restoreSection_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.Section value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateLessonRequest, $0.Lesson>(
        'CreateLesson',
        createLesson_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateLessonRequest.fromBuffer(value),
        ($0.Lesson value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateLessonRequest, $0.Lesson>(
        'UpdateLesson',
        updateLesson_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateLessonRequest.fromBuffer(value),
        ($0.Lesson value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.Lesson>(
        'ArchiveLesson',
        archiveLesson_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.Lesson value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeArchiveRequest, $0.Lesson>(
        'RestoreLesson',
        restoreLesson_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeArchiveRequest.fromBuffer(value),
        ($0.Lesson value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeLessonStatusRequest, $0.Lesson>(
        'ChangeLessonStatus',
        changeLessonStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeLessonStatusRequest.fromBuffer(value),
        ($0.Lesson value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMaterialTreeRequest, $0.MaterialTree>(
        'GetMaterialTree',
        getMaterialTree_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetMaterialTreeRequest.fromBuffer(value),
        ($0.MaterialTree value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReorderMaterialRequest, $0.MaterialTree>(
        'ReorderMaterial',
        reorderMaterial_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ReorderMaterialRequest.fromBuffer(value),
        ($0.MaterialTree value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDashboardRequest, $0.Dashboard>(
        'GetDashboard',
        getDashboard_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDashboardRequest.fromBuffer(value),
        ($0.Dashboard value) => value.writeToBuffer()));
  }

  $async.Future<$0.Study> createStudy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateStudyRequest> $request) async {
    return createStudy($call, await $request);
  }

  $async.Future<$0.Study> createStudy(
      $grpc.ServiceCall call, $0.CreateStudyRequest request);

  $async.Future<$0.Study> getStudy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetStudyRequest> $request) async {
    return getStudy($call, await $request);
  }

  $async.Future<$0.Study> getStudy(
      $grpc.ServiceCall call, $0.GetStudyRequest request);

  $async.Future<$0.ListStudiesResponse> listStudies_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListStudiesRequest> $request) async {
    return listStudies($call, await $request);
  }

  $async.Future<$0.ListStudiesResponse> listStudies(
      $grpc.ServiceCall call, $0.ListStudiesRequest request);

  $async.Future<$0.Study> updateStudy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateStudyRequest> $request) async {
    return updateStudy($call, await $request);
  }

  $async.Future<$0.Study> updateStudy(
      $grpc.ServiceCall call, $0.UpdateStudyRequest request);

  $async.Future<$0.Study> archiveStudy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return archiveStudy($call, await $request);
  }

  $async.Future<$0.Study> archiveStudy(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.Study> restoreStudy_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return restoreStudy($call, await $request);
  }

  $async.Future<$0.Study> restoreStudy(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.LearningSource> createLearningSource_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateLearningSourceRequest> $request) async {
    return createLearningSource($call, await $request);
  }

  $async.Future<$0.LearningSource> createLearningSource(
      $grpc.ServiceCall call, $0.CreateLearningSourceRequest request);

  $async.Future<$0.LearningSource> updateLearningSource_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateLearningSourceRequest> $request) async {
    return updateLearningSource($call, await $request);
  }

  $async.Future<$0.LearningSource> updateLearningSource(
      $grpc.ServiceCall call, $0.UpdateLearningSourceRequest request);

  $async.Future<$0.LearningSource> archiveLearningSource_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return archiveLearningSource($call, await $request);
  }

  $async.Future<$0.LearningSource> archiveLearningSource(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.LearningSource> restoreLearningSource_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return restoreLearningSource($call, await $request);
  }

  $async.Future<$0.LearningSource> restoreLearningSource(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.Section> createSection_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateSectionRequest> $request) async {
    return createSection($call, await $request);
  }

  $async.Future<$0.Section> createSection(
      $grpc.ServiceCall call, $0.CreateSectionRequest request);

  $async.Future<$0.Section> updateSection_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateSectionRequest> $request) async {
    return updateSection($call, await $request);
  }

  $async.Future<$0.Section> updateSection(
      $grpc.ServiceCall call, $0.UpdateSectionRequest request);

  $async.Future<$0.Section> archiveSection_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return archiveSection($call, await $request);
  }

  $async.Future<$0.Section> archiveSection(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.Section> restoreSection_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return restoreSection($call, await $request);
  }

  $async.Future<$0.Section> restoreSection(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.Lesson> createLesson_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateLessonRequest> $request) async {
    return createLesson($call, await $request);
  }

  $async.Future<$0.Lesson> createLesson(
      $grpc.ServiceCall call, $0.CreateLessonRequest request);

  $async.Future<$0.Lesson> updateLesson_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateLessonRequest> $request) async {
    return updateLesson($call, await $request);
  }

  $async.Future<$0.Lesson> updateLesson(
      $grpc.ServiceCall call, $0.UpdateLessonRequest request);

  $async.Future<$0.Lesson> archiveLesson_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return archiveLesson($call, await $request);
  }

  $async.Future<$0.Lesson> archiveLesson(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.Lesson> restoreLesson_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeArchiveRequest> $request) async {
    return restoreLesson($call, await $request);
  }

  $async.Future<$0.Lesson> restoreLesson(
      $grpc.ServiceCall call, $0.ChangeArchiveRequest request);

  $async.Future<$0.Lesson> changeLessonStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeLessonStatusRequest> $request) async {
    return changeLessonStatus($call, await $request);
  }

  $async.Future<$0.Lesson> changeLessonStatus(
      $grpc.ServiceCall call, $0.ChangeLessonStatusRequest request);

  $async.Future<$0.MaterialTree> getMaterialTree_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetMaterialTreeRequest> $request) async {
    return getMaterialTree($call, await $request);
  }

  $async.Future<$0.MaterialTree> getMaterialTree(
      $grpc.ServiceCall call, $0.GetMaterialTreeRequest request);

  $async.Future<$0.MaterialTree> reorderMaterial_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ReorderMaterialRequest> $request) async {
    return reorderMaterial($call, await $request);
  }

  $async.Future<$0.MaterialTree> reorderMaterial(
      $grpc.ServiceCall call, $0.ReorderMaterialRequest request);

  $async.Future<$0.Dashboard> getDashboard_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetDashboardRequest> $request) async {
    return getDashboard($call, await $request);
  }

  $async.Future<$0.Dashboard> getDashboard(
      $grpc.ServiceCall call, $0.GetDashboardRequest request);
}
