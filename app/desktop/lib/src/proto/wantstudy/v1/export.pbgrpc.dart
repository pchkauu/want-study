// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/export.proto.

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

import 'export.pb.dart' as $0;

export 'export.pb.dart';

@$pb.GrpcServiceName('wantstudy.v1.ExportService')
class ExportServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ExportServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.ExportChunk> renderStudyExport(
    $0.RenderStudyExportRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$renderStudyExport, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$renderStudyExport =
      $grpc.ClientMethod<$0.RenderStudyExportRequest, $0.ExportChunk>(
          '/wantstudy.v1.ExportService/RenderStudyExport',
          ($0.RenderStudyExportRequest value) => value.writeToBuffer(),
          $0.ExportChunk.fromBuffer);
}

@$pb.GrpcServiceName('wantstudy.v1.ExportService')
abstract class ExportServiceBase extends $grpc.Service {
  $core.String get $name => 'wantstudy.v1.ExportService';

  ExportServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.RenderStudyExportRequest, $0.ExportChunk>(
        'RenderStudyExport',
        renderStudyExport_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.RenderStudyExportRequest.fromBuffer(value),
        ($0.ExportChunk value) => value.writeToBuffer()));
  }

  $async.Stream<$0.ExportChunk> renderStudyExport_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RenderStudyExportRequest> $request) async* {
    yield* renderStudyExport($call, await $request);
  }

  $async.Stream<$0.ExportChunk> renderStudyExport(
      $grpc.ServiceCall call, $0.RenderStudyExportRequest request);
}
