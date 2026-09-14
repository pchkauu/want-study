import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:study/src/application/service/_barrel.dart';
import 'package:study/src/application/use_case/publication/contract/_barrel.dart';
import 'package:study/src/domain/_barrel.dart';

@lazySingleton
final class PublicationUseCase {
  final StudyPublicationRepositoryV2 _repository;
  final StudyUseCaseExecutor _executor;

  const PublicationUseCase(this._repository, this._executor);

  FutureResult<PublicationPrepareResultV1> prepareV1({
    required PublicationPrepareParamsV1 params,
  }) {
    const op = 'PublicationUseCase.prepareV1():';
    return _executor.call(
      operation: op,
      body: () async {
        final snapshot = await _repository.renderStudyExport(params.study);
        final preview = await _repository.preview(
          study: params.study,
          snapshot: snapshot,
        );
        return PublicationPrepareResultV1(snapshot: snapshot, preview: preview);
      },
    );
  }

  FutureResult<PublicationPublishResultV1> publishV1({
    required PublicationPublishParamsV1 params,
  }) {
    const op = 'PublicationUseCase.publishV1():';
    return _executor.call(
      operation: op,
      body: () async => PublicationPublishResultV1(
        await _repository.publish(
          study: params.study,
          snapshot: params.snapshot,
          commit: params.commit,
        ),
      ),
    );
  }

  FutureResult<PublicationPublishResultV1> retryPushV1({
    required PublicationRetryPushParamsV1 params,
  }) {
    const op = 'PublicationUseCase.retryPushV1():';
    return _executor.call(
      operation: op,
      body: () async => PublicationPublishResultV1(
        await _repository.retryPush(params.publication),
      ),
    );
  }
}
