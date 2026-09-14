// This is a generated file - do not edit.
//
// Generated from wantstudy/v1/knowledge.proto.

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

import 'knowledge.pb.dart' as $0;
import 'study.pb.dart' as $1;

export 'knowledge.pb.dart';

@$pb.GrpcServiceName('wantstudy.v1.KnowledgeService')
class KnowledgeServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  KnowledgeServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.Concept> createConcept(
    $0.CreateConceptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createConcept, request, options: options);
  }

  $grpc.ResponseFuture<$0.Concept> updateConcept(
    $0.UpdateConceptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateConcept, request, options: options);
  }

  $grpc.ResponseFuture<$0.Concept> archiveConcept(
    $1.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$archiveConcept, request, options: options);
  }

  $grpc.ResponseFuture<$0.Concept> restoreConcept(
    $1.ChangeArchiveRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restoreConcept, request, options: options);
  }

  $grpc.ResponseFuture<$0.Concept> addConceptAlias(
    $0.ChangeConceptAliasRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addConceptAlias, request, options: options);
  }

  $grpc.ResponseFuture<$0.Concept> removeConceptAlias(
    $0.ChangeConceptAliasRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeConceptAlias, request, options: options);
  }

  $grpc.ResponseFuture<$0.Concept> linkBlockConcept(
    $0.ChangeBlockConceptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$linkBlockConcept, request, options: options);
  }

  $grpc.ResponseFuture<$0.Concept> unlinkBlockConcept(
    $0.ChangeBlockConceptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unlinkBlockConcept, request, options: options);
  }

  $grpc.ResponseFuture<$0.ConceptRelation> putConceptRelation(
    $0.PutConceptRelationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$putConceptRelation, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteConceptRelationResponse> deleteConceptRelation(
    $0.DeleteConceptRelationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteConceptRelation, request, options: options);
  }

  $grpc.ResponseFuture<$0.SearchConceptsResponse> searchConcepts(
    $0.SearchConceptsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$searchConcepts, request, options: options);
  }

  $grpc.ResponseFuture<$0.ConceptGraph> getConceptGraph(
    $0.GetConceptGraphRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getConceptGraph, request, options: options);
  }

  // method descriptors

  static final _$createConcept =
      $grpc.ClientMethod<$0.CreateConceptRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/CreateConcept',
          ($0.CreateConceptRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$updateConcept =
      $grpc.ClientMethod<$0.UpdateConceptRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/UpdateConcept',
          ($0.UpdateConceptRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$archiveConcept =
      $grpc.ClientMethod<$1.ChangeArchiveRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/ArchiveConcept',
          ($1.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$restoreConcept =
      $grpc.ClientMethod<$1.ChangeArchiveRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/RestoreConcept',
          ($1.ChangeArchiveRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$addConceptAlias =
      $grpc.ClientMethod<$0.ChangeConceptAliasRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/AddConceptAlias',
          ($0.ChangeConceptAliasRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$removeConceptAlias =
      $grpc.ClientMethod<$0.ChangeConceptAliasRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/RemoveConceptAlias',
          ($0.ChangeConceptAliasRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$linkBlockConcept =
      $grpc.ClientMethod<$0.ChangeBlockConceptRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/LinkBlockConcept',
          ($0.ChangeBlockConceptRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$unlinkBlockConcept =
      $grpc.ClientMethod<$0.ChangeBlockConceptRequest, $0.Concept>(
          '/wantstudy.v1.KnowledgeService/UnlinkBlockConcept',
          ($0.ChangeBlockConceptRequest value) => value.writeToBuffer(),
          $0.Concept.fromBuffer);
  static final _$putConceptRelation =
      $grpc.ClientMethod<$0.PutConceptRelationRequest, $0.ConceptRelation>(
          '/wantstudy.v1.KnowledgeService/PutConceptRelation',
          ($0.PutConceptRelationRequest value) => value.writeToBuffer(),
          $0.ConceptRelation.fromBuffer);
  static final _$deleteConceptRelation = $grpc.ClientMethod<
          $0.DeleteConceptRelationRequest, $0.DeleteConceptRelationResponse>(
      '/wantstudy.v1.KnowledgeService/DeleteConceptRelation',
      ($0.DeleteConceptRelationRequest value) => value.writeToBuffer(),
      $0.DeleteConceptRelationResponse.fromBuffer);
  static final _$searchConcepts =
      $grpc.ClientMethod<$0.SearchConceptsRequest, $0.SearchConceptsResponse>(
          '/wantstudy.v1.KnowledgeService/SearchConcepts',
          ($0.SearchConceptsRequest value) => value.writeToBuffer(),
          $0.SearchConceptsResponse.fromBuffer);
  static final _$getConceptGraph =
      $grpc.ClientMethod<$0.GetConceptGraphRequest, $0.ConceptGraph>(
          '/wantstudy.v1.KnowledgeService/GetConceptGraph',
          ($0.GetConceptGraphRequest value) => value.writeToBuffer(),
          $0.ConceptGraph.fromBuffer);
}

@$pb.GrpcServiceName('wantstudy.v1.KnowledgeService')
abstract class KnowledgeServiceBase extends $grpc.Service {
  $core.String get $name => 'wantstudy.v1.KnowledgeService';

  KnowledgeServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateConceptRequest, $0.Concept>(
        'CreateConcept',
        createConcept_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateConceptRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateConceptRequest, $0.Concept>(
        'UpdateConcept',
        updateConcept_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateConceptRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.ChangeArchiveRequest, $0.Concept>(
        'ArchiveConcept',
        archiveConcept_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.ChangeArchiveRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.ChangeArchiveRequest, $0.Concept>(
        'RestoreConcept',
        restoreConcept_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.ChangeArchiveRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeConceptAliasRequest, $0.Concept>(
        'AddConceptAlias',
        addConceptAlias_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeConceptAliasRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeConceptAliasRequest, $0.Concept>(
        'RemoveConceptAlias',
        removeConceptAlias_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeConceptAliasRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeBlockConceptRequest, $0.Concept>(
        'LinkBlockConcept',
        linkBlockConcept_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeBlockConceptRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangeBlockConceptRequest, $0.Concept>(
        'UnlinkBlockConcept',
        unlinkBlockConcept_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ChangeBlockConceptRequest.fromBuffer(value),
        ($0.Concept value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.PutConceptRelationRequest, $0.ConceptRelation>(
            'PutConceptRelation',
            putConceptRelation_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.PutConceptRelationRequest.fromBuffer(value),
            ($0.ConceptRelation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteConceptRelationRequest,
            $0.DeleteConceptRelationResponse>(
        'DeleteConceptRelation',
        deleteConceptRelation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteConceptRelationRequest.fromBuffer(value),
        ($0.DeleteConceptRelationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SearchConceptsRequest,
            $0.SearchConceptsResponse>(
        'SearchConcepts',
        searchConcepts_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SearchConceptsRequest.fromBuffer(value),
        ($0.SearchConceptsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetConceptGraphRequest, $0.ConceptGraph>(
        'GetConceptGraph',
        getConceptGraph_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetConceptGraphRequest.fromBuffer(value),
        ($0.ConceptGraph value) => value.writeToBuffer()));
  }

  $async.Future<$0.Concept> createConcept_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateConceptRequest> $request) async {
    return createConcept($call, await $request);
  }

  $async.Future<$0.Concept> createConcept(
      $grpc.ServiceCall call, $0.CreateConceptRequest request);

  $async.Future<$0.Concept> updateConcept_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateConceptRequest> $request) async {
    return updateConcept($call, await $request);
  }

  $async.Future<$0.Concept> updateConcept(
      $grpc.ServiceCall call, $0.UpdateConceptRequest request);

  $async.Future<$0.Concept> archiveConcept_Pre($grpc.ServiceCall $call,
      $async.Future<$1.ChangeArchiveRequest> $request) async {
    return archiveConcept($call, await $request);
  }

  $async.Future<$0.Concept> archiveConcept(
      $grpc.ServiceCall call, $1.ChangeArchiveRequest request);

  $async.Future<$0.Concept> restoreConcept_Pre($grpc.ServiceCall $call,
      $async.Future<$1.ChangeArchiveRequest> $request) async {
    return restoreConcept($call, await $request);
  }

  $async.Future<$0.Concept> restoreConcept(
      $grpc.ServiceCall call, $1.ChangeArchiveRequest request);

  $async.Future<$0.Concept> addConceptAlias_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeConceptAliasRequest> $request) async {
    return addConceptAlias($call, await $request);
  }

  $async.Future<$0.Concept> addConceptAlias(
      $grpc.ServiceCall call, $0.ChangeConceptAliasRequest request);

  $async.Future<$0.Concept> removeConceptAlias_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeConceptAliasRequest> $request) async {
    return removeConceptAlias($call, await $request);
  }

  $async.Future<$0.Concept> removeConceptAlias(
      $grpc.ServiceCall call, $0.ChangeConceptAliasRequest request);

  $async.Future<$0.Concept> linkBlockConcept_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeBlockConceptRequest> $request) async {
    return linkBlockConcept($call, await $request);
  }

  $async.Future<$0.Concept> linkBlockConcept(
      $grpc.ServiceCall call, $0.ChangeBlockConceptRequest request);

  $async.Future<$0.Concept> unlinkBlockConcept_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ChangeBlockConceptRequest> $request) async {
    return unlinkBlockConcept($call, await $request);
  }

  $async.Future<$0.Concept> unlinkBlockConcept(
      $grpc.ServiceCall call, $0.ChangeBlockConceptRequest request);

  $async.Future<$0.ConceptRelation> putConceptRelation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PutConceptRelationRequest> $request) async {
    return putConceptRelation($call, await $request);
  }

  $async.Future<$0.ConceptRelation> putConceptRelation(
      $grpc.ServiceCall call, $0.PutConceptRelationRequest request);

  $async.Future<$0.DeleteConceptRelationResponse> deleteConceptRelation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteConceptRelationRequest> $request) async {
    return deleteConceptRelation($call, await $request);
  }

  $async.Future<$0.DeleteConceptRelationResponse> deleteConceptRelation(
      $grpc.ServiceCall call, $0.DeleteConceptRelationRequest request);

  $async.Future<$0.SearchConceptsResponse> searchConcepts_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SearchConceptsRequest> $request) async {
    return searchConcepts($call, await $request);
  }

  $async.Future<$0.SearchConceptsResponse> searchConcepts(
      $grpc.ServiceCall call, $0.SearchConceptsRequest request);

  $async.Future<$0.ConceptGraph> getConceptGraph_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetConceptGraphRequest> $request) async {
    return getConceptGraph($call, await $request);
  }

  $async.Future<$0.ConceptGraph> getConceptGraph(
      $grpc.ServiceCall call, $0.GetConceptGraphRequest request);
}
