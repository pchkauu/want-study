import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:domain_error/domain_error.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:study/src/application/controller/failure/_barrel.dart';
import 'package:study/src/application/service/_barrel.dart';
import 'package:study/src/application/use_case/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

part 'effect.dart';
part 'event.dart';
part 'state.dart';

@lazySingleton
final class PublicationControllerV2
    extends
        BlocWithEffects<
          PublicationEventV2,
          PublicationStateV2,
          PublicationEffectV2
        > {
  final PublicationUseCase _useCase;
  final StudyErrorReporterV2 _reporter;

  PublicationControllerV2(this._useCase, this._reporter)
    : super(const PublicationStateV2()) {
    _requireForeground();
    on<PublicationPreviewRequestedV2>(
      _onPreviewRequested,
      transformer: restartable(),
    );
    on<PublicationConfirmedV2>(_onConfirmed, transformer: droppable());
    on<PublicationPushRetriedV2>(_onPushRetried, transformer: droppable());
  }

  Future<void> _onPreviewRequested(
    PublicationPreviewRequestedV2 event,
    Emitter<PublicationStateV2> emit,
  ) async {
    emit(
      state.copyWith(
        loadState: PublicationLoadStateV2.preparing,
        study: () => event.study,
        snapshot: () => null,
        preview: () => null,
        publication: () => null,
        failure: () => null,
      ),
    );
    final result = await _useCase.prepareV1(
      params: PublicationPrepareParamsV1(event.study),
    );
    await result.fold(
      (error) =>
          _emitFailure(error, emit, 'PublicationControllerV2.prepare():'),
      (value) async => emit(
        state.copyWith(
          loadState: PublicationLoadStateV2.ready,
          snapshot: () => value.snapshot,
          preview: () => value.preview,
        ),
      ),
    );
  }

  Future<void> _onConfirmed(
    PublicationConfirmedV2 event,
    Emitter<PublicationStateV2> emit,
  ) async {
    final study = state.study;
    final snapshot = state.snapshot;
    if (study == null || snapshot == null) return;
    emit(state.copyWith(loadState: PublicationLoadStateV2.publishing));
    final result = await _useCase.publishV1(
      params: PublicationPublishParamsV1(
        study: study,
        snapshot: snapshot,
        commit: event.commit,
      ),
    );
    await result.fold(
      (error) =>
          _emitFailure(error, emit, 'PublicationControllerV2.publish():'),
      (value) async => _emitPublication(value.publication, emit),
    );
  }

  Future<void> _onPushRetried(
    PublicationPushRetriedV2 event,
    Emitter<PublicationStateV2> emit,
  ) async {
    final publication = state.publication;
    if (publication == null) return;
    emit(state.copyWith(loadState: PublicationLoadStateV2.publishing));
    final result = await _useCase.retryPushV1(
      params: PublicationRetryPushParamsV1(publication),
    );
    await result.fold(
      (error) =>
          _emitFailure(error, emit, 'PublicationControllerV2.retryPush():'),
      (value) async => _emitPublication(value.publication, emit),
    );
  }

  void _emitPublication(
    PublicationV1 publication,
    Emitter<PublicationStateV2> emit,
  ) {
    final loadState = publication.state == PublicationStateV1.pushFailed
        ? PublicationLoadStateV2.pushFailed
        : PublicationLoadStateV2.published;
    emit(
      state.copyWith(
        loadState: loadState,
        publication: () => publication,
        failure: () => null,
      ),
    );
    if (loadState == PublicationLoadStateV2.published) {
      emitEffect(const PublicationSuccessEffectV2());
    }
  }

  Future<void> _emitFailure(
    DomainError error,
    Emitter<PublicationStateV2> emit,
    String operation,
  ) async {
    await _reporter.reportDomainError(
      context: StudyErrorContextV1(
        operation: operation,
        layer: StudyErrorLayerV1.controller,
      ),
      error: error,
      stackTrace: error.stackTrace ?? StackTrace.current,
    );
    final failure = studyFailureKindV1(error);
    emit(
      state.copyWith(
        loadState: PublicationLoadStateV2.failed,
        failure: () => failure,
      ),
    );
    emitEffect(PublicationFailureEffectV2(failure));
  }

  static void _requireForeground() {
    if (!LaunchMode.isForeground) {
      throw StateError(
        'PublicationControllerV2 requires foreground launch mode.',
      );
    }
  }
}
