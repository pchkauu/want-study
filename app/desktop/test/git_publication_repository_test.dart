import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:domain_error/domain_error.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/infrastructure/git_publication_repository.dart';
import 'package:want_study_desktop/src/infrastructure/grpc_repository.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/export.pbgrpc.dart';

void main() {
  test('renders latest snapshot when study revision is stale', () async {
    final service = _ExportService();
    final server = Server.create(services: [service]);
    await server.serve(address: InternetAddress.loopbackIPv4, port: 0);
    final channel = ClientChannel(
      InternetAddress.loopbackIPv4.address,
      port: server.port!,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    addTearDown(() async {
      await channel.shutdown();
      await server.shutdown();
    });
    const errorReporter = _ErrorReporter();
    final publication = GitPublicationRepositoryV2(
      GrpcExportGatewayV1(ExportServiceClient(channel), errorReporter),
      _StudyRepositoryMock(),
      errorReporter,
    );

    final snapshot = await publication.renderStudyExport(
      StudyV1(
        id: 'study-id',
        title: 'Study',
        localRepositoryPath: '/unused',
        contentRevision: 31,
      ),
    );

    expect(snapshot.studyRevision, 32);
    expect(service.request?.hasExpectedContentRevision(), isFalse);
  });

  test('recognizes only the verified cpp-study legacy snapshot', () {
    final hashes = {
      'README.md':
          '4fc6b1239165a24aae19dcc18c9259e14a487f530c85da13e946eb7cdecc60ed',
      'stepik/193691/README.md':
          'b1bc0adce3e40a92fdbcb2e284a8664f62f4190590e884fd83893b36cdfa3d92',
      'stepik/193691/source_code/1/4/main.c':
          '527e610de25ae829b41374b108d57bf5b02d836add2f6b848e76166e5a64ce5e',
    };

    expect(
      GitPublicationRepositoryV2.matchesCppStudyLegacySnapshotV1(hashes),
      isTrue,
    );
    hashes['README.md'] = 'changed';
    expect(
      GitPublicationRepositoryV2.matchesCppStudyLegacySnapshotV1(hashes),
      isFalse,
    );
  });

  test('protects files, rejects stale snapshots, and retries push', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'want-study-git-test-',
    );
    addTearDown(() => temporary.delete(recursive: true));
    final remote = Directory('${temporary.path}/remote.git');
    final repository = Directory('${temporary.path}/repository');
    await _git(temporary.path, ['init', '--bare', remote.path]);
    await _git(temporary.path, ['init', '-b', 'main', repository.path]);
    await _git(repository.path, ['config', 'user.name', 'Want Study']);
    await _git(repository.path, [
      'config',
      'user.email',
      'want-study@example.invalid',
    ]);
    const initialReadme = '# Existing study\n';
    await File('${repository.path}/README.md').writeAsString(initialReadme);
    await File('${repository.path}/.gitignore').writeAsString('local\n');
    await _git(repository.path, ['add', '.gitignore', 'README.md']);
    await _git(repository.path, [
      'commit',
      '-m',
      'test: initialize repository',
    ]);
    const remoteUrl = 'https://github.com/want-study-test/repository.git';
    await _git(repository.path, ['remote', 'add', 'origin', remoteUrl]);
    await _git(repository.path, [
      'config',
      'url.file://${remote.path}/.insteadOf',
      remoteUrl,
    ]);
    await _git(repository.path, ['push', '-u', 'origin', 'main']);

    final readme = utf8.encode('# Study\n');
    final manifest = utf8.encode(
      '${const JsonEncoder.withIndent('  ').convert({
        'formatVersion': 1,
        'studyId': 'study-id',
        'studyRevision': 2,
        'files': [
          {'path': 'README.md', 'sha256': sha256.convert(readme).toString()},
        ],
      })}\n',
    );
    final snapshot = ExportSnapshotV1(
      studyId: 'study-id',
      studyRevision: 2,
      file: [
        ExportFileV1(
          path: '.want-study/manifest.json',
          content: manifest,
          sha256: sha256.convert(manifest).toString(),
        ),
        ExportFileV1(
          path: 'README.md',
          content: readme,
          sha256: sha256.convert(readme).toString(),
        ),
      ],
    );
    final channel = ClientChannel(
      '127.0.0.1',
      port: 1,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    addTearDown(channel.shutdown);
    final study = StudyV1(
      id: 'study-id',
      title: 'Study',
      localRepositoryPath: repository.path,
      contentRevision: 2,
    );
    var currentStudy = study;
    final studyRepository = _StudyRepositoryMock();
    when(() => studyRepository.getMaterialTree(study: study))
        .thenAnswer((_) async => MaterialTreeV1(study: currentStudy));
    when(
      () => studyRepository.listStudies(scope: ArchiveScopeV1.includeArchived),
    ).thenAnswer((_) async => [currentStudy]);
    const errorReporter = _ErrorReporter();
    final publication = GitPublicationRepositoryV2(
      GrpcExportGatewayV1(ExportServiceClient(channel), errorReporter),
      studyRepository,
      errorReporter,
    );

    await File('${repository.path}/README.md').writeAsString('# Local draft\n');
    await expectLater(
      publication.preview(study: study, snapshot: snapshot),
      throwsA(
        isA<PublicationErrorV1>().having(
          (error) => error.reason,
          'reason',
          'managed_path_collision',
        ),
      ),
    );
    await File('${repository.path}/README.md').writeAsString(initialReadme);

    final preview = await publication.preview(study: study, snapshot: snapshot);
    expect(preview.changedPath, ['.want-study/manifest.json', 'README.md']);
    expect(preview.diff, contains('-# Existing study'));
    expect(preview.diff, contains('# Study'));
    expect(preview.diff, isNot(contains(temporary.path)));

    currentStudy = study.copyWith(contentRevision: 3);
    await expectLater(
      publication.publish(
        study: study,
        snapshot: snapshot,
        commit: PublicationCommitV1(
          message: 'docs(study): reject stale snapshot',
        ),
      ),
      throwsA(isA<ConflictErrorV1>()),
    );
    expect(
      await File('${repository.path}/README.md').readAsString(),
      initialReadme,
    );

    currentStudy = study;
    final published = await publication.publish(
      study: study,
      snapshot: snapshot,
      commit: PublicationCommitV1(message: 'docs(study): test publication'),
    );
    expect(published.state, PublicationStateV1.published);
    expect(published.commitSha, isNotEmpty);
    expect(
      await _git(temporary.path, [
        '--git-dir',
        remote.path,
        'show',
        'main:README.md',
      ]),
      '# Study\n',
    );
    expect(
      await File('${repository.path}/.gitignore').readAsString(),
      'local\n',
    );

    final unchanged = await publication.preview(
      study: study,
      snapshot: snapshot,
    );
    expect(unchanged.changedPath, isEmpty);

    final updatedReadme = utf8.encode('# Updated study\n');
    final updatedManifest = utf8.encode(
      '${const JsonEncoder.withIndent('  ').convert({
        'formatVersion': 1,
        'studyId': 'study-id',
        'studyRevision': 3,
        'files': [
          {'path': 'README.md', 'sha256': sha256.convert(updatedReadme).toString()},
        ],
      })}\n',
    );
    final updatedSnapshot = ExportSnapshotV1(
      studyId: 'study-id',
      studyRevision: 3,
      file: [
        ExportFileV1(
          path: '.want-study/manifest.json',
          content: updatedManifest,
          sha256: sha256.convert(updatedManifest).toString(),
        ),
        ExportFileV1(
          path: 'README.md',
          content: updatedReadme,
          sha256: sha256.convert(updatedReadme).toString(),
        ),
      ],
    );
    currentStudy = study.copyWith(contentRevision: 3);
    await publication.preview(study: currentStudy, snapshot: updatedSnapshot);
    final hook = File('${remote.path}/hooks/pre-receive');
    await hook.writeAsString('#!/bin/sh\nexit 1\n');
    final chmod = await Process.run('/bin/chmod', ['+x', hook.path]);
    expect(chmod.exitCode, 0);

    final pushFailed = await publication.publish(
      study: currentStudy,
      snapshot: updatedSnapshot,
      commit: PublicationCommitV1(message: 'docs(study): update snapshot'),
    );
    expect(pushFailed.state, PublicationStateV1.pushFailed);
    expect(
      await _git(temporary.path, [
        '--git-dir',
        remote.path,
        'show',
        'main:README.md',
      ]),
      '# Study\n',
    );

    await hook.delete();
    final retried = await publication.retryPush(pushFailed);
    expect(retried.state, PublicationStateV1.published);
    expect(retried.commitSha, pushFailed.commitSha);
    expect(
      await _git(temporary.path, [
        '--git-dir',
        remote.path,
        'show',
        'main:README.md',
      ]),
      '# Updated study\n',
    );
  });
}

final class _StudyRepositoryMock extends Mock implements StudyRepositoryV2 {}

final class _ExportService extends ExportServiceBase {
  RenderStudyExportRequest? request;

  @override
  Stream<ExportChunk> renderStudyExport(
    ServiceCall call,
    RenderStudyExportRequest request,
  ) async* {
    this.request = request;
    yield ExportChunk(
      header: ExportHeader(
        studyId: request.studyId,
        studyRevision: Int64(32),
        totalBytes: Int64.ZERO,
      ),
    );
  }
}

final class _ErrorReporter implements StudyErrorReporterV2 {
  const _ErrorReporter();

  @override
  Future<void> reportDomainError({
    required StudyErrorContextV1 context,
    required DomainError error,
    required StackTrace stackTrace,
  }) async {}

  @override
  Future<void> reportObserverError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  }) async {}

  @override
  Future<void> reportRawError({
    required StudyErrorContextV1 context,
    required Object error,
    required StackTrace stackTrace,
  }) async {}
}

Future<String> _git(String workingDirectory, List<String> arguments) async {
  final result = await Process.run(
    '/usr/bin/git',
    arguments,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) {
    throw ProcessException('/usr/bin/git', arguments, '', result.exitCode);
  }
  return result.stdout as String;
}
