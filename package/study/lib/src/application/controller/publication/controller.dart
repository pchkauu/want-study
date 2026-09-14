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
  var _previewEpoch = 0;

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
    if (state.loadState == PublicationLoadStateV2.publishing ||
        state.loadState == PublicationLoadStateV2.pushFailed) {
      return;
    }
    final epoch = ++_previewEpoch;
    if (event.study.localRepositoryPath.trim().isEmpty) {
      emit(
        state.copyWith(
          loadState: PublicationLoadStateV2.initial,
          study: () => event.study,
          snapshot: () => null,
          preview: () => null,
          publication: () => null,
          failure: () => null,
        ),
      );
      return;
    }
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
    if (!_isCurrentPreview(event.study.id, epoch, emit)) return;
    await result.fold(
      (error) => _emitFailure(
        error,
        emit,
        'PublicationControllerV2.prepare():',
        isCurrent: () => _isCurrentPreview(event.study.id, epoch, emit),
      ),
      (value) async {
        if (!_isCurrentPreview(event.study.id, epoch, emit)) return;
        emit(
          state.copyWith(
            loadState: PublicationLoadStateV2.ready,
            snapshot: () => value.snapshot,
            preview: () => value.preview,
          ),
        );
      },
    );
  }

  Future<void> _onConfirmed(
    PublicationConfirmedV2 event,
    Emitter<PublicationStateV2> emit,
  ) async {
    if (state.loadState != PublicationLoadStateV2.ready) return;
    final study = state.study;
    final snapshot = state.snapshot;
    final preview = state.preview;
    if (study == null ||
        snapshot == null ||
        preview == null ||
        snapshot.studyId != study.id ||
        preview.studyId != study.id) {
      return;
    }
    final studyId = study.id;
    emit(state.copyWith(loadState: PublicationLoadStateV2.publishing));
    final result = await _useCase.publishV1(
      params: PublicationPublishParamsV1(
        study: study,
        snapshot: snapshot,
        commit: event.commit,
      ),
    );
    if (emit.isDone || state.study?.id != studyId) return;
    await result.fold(
      (error) => _emitFailure(
        error,
        emit,
        'PublicationControllerV2.publish():',
        isCurrent: () => !emit.isDone && state.study?.id == studyId,
      ),
      (value) async {
        if (!emit.isDone && state.study?.id == studyId) {
          _emitPublication(value.publication, emit);
        }
      },
    );
  }

  Future<void> _onPushRetried(
    PublicationPushRetriedV2 event,
    Emitter<PublicationStateV2> emit,
  ) async {
    if (state.loadState != PublicationLoadStateV2.pushFailed) return;
    final publication = state.publication;
    if (publication == null) return;
    final studyId = publication.studyId;
    emit(state.copyWith(loadState: PublicationLoadStateV2.publishing));
    final result = await _useCase.retryPushV1(
      params: PublicationRetryPushParamsV1(publication),
    );
    if (emit.isDone || state.study?.id != studyId) return;
    await result.fold(
      (error) => _emitFailure(
        error,
        emit,
        'PublicationControllerV2.retryPush():',
        loadState: PublicationLoadStateV2.pushFailed,
        isCurrent: () => !emit.isDone && state.study?.id == studyId,
      ),
      (value) async {
        if (!emit.isDone && state.study?.id == studyId) {
          _emitPublication(value.publication, emit);
        }
      },
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
    String operation, {
    PublicationLoadStateV2 loadState = PublicationLoadStateV2.failed,
    bool Function()? isCurrent,
  }) async {
    if (emit.isDone || !(isCurrent?.call() ?? true)) return;
    await _reporter.reportDomainError(
      context: StudyErrorContextV1(
        operation: operation,
        layer: StudyErrorLayerV1.controller,
      ),
      error: error,
      stackTrace: error.stackTrace ?? StackTrace.current,
    );
    if (emit.isDone || !(isCurrent?.call() ?? true)) return;
    final failure = studyFailureKindV1(error);
    final invalidatePreview = failure == StudyFailureKindV1.conflict;
    emit(
      state.copyWith(
        loadState: loadState,
        snapshot: invalidatePreview ? () => null : null,
        preview: invalidatePreview ? () => null : null,
        failure: () => failure,
      ),
    );
    emitEffect(PublicationFailureEffectV2(failure));
  }

  bool _isCurrentPreview(
    String studyId,
    int epoch,
    Emitter<PublicationStateV2> emit,
  ) => !emit.isDone && _previewEpoch == epoch && state.study?.id == studyId;

  static void _requireForeground() {
    if (!LaunchMode.isForeground) {
      throw StateError(
        'PublicationControllerV2 requires foreground launch mode.',
      );
    }
  }
}
