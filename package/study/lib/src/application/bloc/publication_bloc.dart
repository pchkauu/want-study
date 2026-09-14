import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:equatable/equatable.dart';
import 'package:study/src/application/safe_call.dart';
import 'package:study/src/domain/error/study_error.dart';
import 'package:study/src/domain/model/publication.dart';
import 'package:study/src/domain/model/study.dart';
import 'package:study/src/domain/model/study_enum.dart';
import 'package:study/src/domain/repository/study_publication_repository.dart';

enum PublicationLoadStateV1 {
  initial,
  preparing,
  ready,
  publishing,
  published,
  pushFailed,
  failed,
}

sealed class PublicationEventV1 {
  const PublicationEventV1();
}

final class PublicationPreviewRequestedV1 extends PublicationEventV1 {
  final StudyV1 study;

  const PublicationPreviewRequestedV1(this.study);
}

final class PublicationConfirmedV1 extends PublicationEventV1 {
  final String commitMessage;

  const PublicationConfirmedV1(this.commitMessage);
}

final class PublicationPushRetriedV1 extends PublicationEventV1 {
  const PublicationPushRetriedV1();
}

sealed class PublicationEffectV1 {
  const PublicationEffectV1();
}

final class PublicationFailureEffectV1 extends PublicationEffectV1 {
  final String errorIdentifier;

  const PublicationFailureEffectV1(this.errorIdentifier);

  @override
  String toString() => 'PublicationFailureEffectV1($errorIdentifier)';
}

final class PublicationSuccessEffectV1 extends PublicationEffectV1 {
  const PublicationSuccessEffectV1();

  @override
  String toString() => 'PublicationSuccessEffectV1';
}

final class PublicationBlocStateV1 extends Equatable {
  final PublicationLoadStateV1 loadState;
  final StudyV1? study;
  final ExportSnapshotV1? snapshot;
  final PublicationPreviewV1? preview;
  final PublicationV1? publication;
  final String? errorIdentifier;

  const PublicationBlocStateV1({
    this.loadState = PublicationLoadStateV1.initial,
    this.study,
    this.snapshot,
    this.preview,
    this.publication,
    this.errorIdentifier,
  });

  PublicationBlocStateV1 copyWith({
    PublicationLoadStateV1? loadState,
    StudyV1? Function()? study,
    ExportSnapshotV1? Function()? snapshot,
    PublicationPreviewV1? Function()? preview,
    PublicationV1? Function()? publication,
    String? Function()? errorIdentifier,
  }) {
    return PublicationBlocStateV1(
      loadState: loadState ?? this.loadState,
      study: study == null ? this.study : study(),
      snapshot: snapshot == null ? this.snapshot : snapshot(),
      preview: preview == null ? this.preview : preview(),
      publication: publication == null ? this.publication : publication(),
      errorIdentifier: errorIdentifier == null
          ? this.errorIdentifier
          : errorIdentifier(),
    );
  }

  @override
  List<Object?> get props => [
    loadState,
    study,
    snapshot,
    preview,
    publication,
    errorIdentifier,
  ];
}

final class PublicationBlocV1
    extends
        BlocWithEffects<
          PublicationEventV1,
          PublicationBlocStateV1,
          PublicationEffectV1
        > {
  final StudyPublicationRepositoryV1 repository;

  PublicationBlocV1(this.repository) : super(const PublicationBlocStateV1()) {
    on<PublicationPreviewRequestedV1>(
      _onPreviewRequested,
      transformer: restartable(),
    );
    on<PublicationConfirmedV1>(_onConfirmed, transformer: droppable());
    on<PublicationPushRetriedV1>(_onPushRetried, transformer: droppable());
  }

  Future<void> _onPreviewRequested(
    PublicationPreviewRequestedV1 event,
    Emitter<PublicationBlocStateV1> emit,
  ) async {
    emit(
      state.copyWith(
        loadState: PublicationLoadStateV1.preparing,
        study: () => event.study,
        snapshot: () => null,
        preview: () => null,
        publication: () => null,
        errorIdentifier: () => null,
      ),
    );
    final result = await studySafeCallV1('publication.preview', () async {
      final snapshot = await repository.renderStudyExport(
        event.study.id,
        expectedContentRevision: event.study.contentRevision,
      );
      final preview = await repository.preview(
        study: event.study,
        snapshot: snapshot,
      );
      return (snapshot, preview);
    });
    result.fold(
      (error) => _emitFailure(error, emit),
      (data) => emit(
        state.copyWith(
          loadState: PublicationLoadStateV1.ready,
          snapshot: () => data.$1,
          preview: () => data.$2,
        ),
      ),
    );
  }

  Future<void> _onConfirmed(
    PublicationConfirmedV1 event,
    Emitter<PublicationBlocStateV1> emit,
  ) async {
    final study = state.study;
    final snapshot = state.snapshot;
    if (study == null || snapshot == null) {
      return;
    }
    emit(state.copyWith(loadState: PublicationLoadStateV1.publishing));
    final result = await studySafeCallV1(
      'publication.publish',
      () => repository.publish(
        study: study,
        snapshot: snapshot,
        commitMessage: event.commitMessage,
      ),
    );
    result.fold((error) => _emitFailure(error, emit), (publication) {
      final loadState = publication.state == PublicationStateV1.pushFailed
          ? PublicationLoadStateV1.pushFailed
          : PublicationLoadStateV1.published;
      emit(
        state.copyWith(loadState: loadState, publication: () => publication),
      );
      if (loadState == PublicationLoadStateV1.published) {
        emitEffect(const PublicationSuccessEffectV1());
      }
    });
  }

  Future<void> _onPushRetried(
    PublicationPushRetriedV1 event,
    Emitter<PublicationBlocStateV1> emit,
  ) async {
    final publication = state.publication;
    if (publication == null) {
      return;
    }
    emit(state.copyWith(loadState: PublicationLoadStateV1.publishing));
    final result = await studySafeCallV1(
      'publication.retryPush',
      () => repository.retryPush(publication),
    );
    result.fold((error) => _emitFailure(error, emit), (value) {
      emit(
        state.copyWith(
          loadState: PublicationLoadStateV1.published,
          publication: () => value,
        ),
      );
      emitEffect(const PublicationSuccessEffectV1());
    });
  }

  void _emitFailure(Object error, Emitter<PublicationBlocStateV1> emit) {
    final identifier = error is StudyErrorV1
        ? error.typeIdentifier
        : 'UnexpectedErrorV1';
    emit(
      state.copyWith(
        loadState: PublicationLoadStateV1.failed,
        errorIdentifier: () => identifier,
      ),
    );
    emitEffect(PublicationFailureEffectV1(identifier));
  }
}
