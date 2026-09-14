import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/study.dart';
import 'package:want_study_desktop/src/infrastructure/git_publication_repository.dart';
import 'package:want_study_desktop/src/infrastructure/grpc_repository.dart';
import 'package:want_study_desktop/src/proto/wantstudy/v1/export.pbgrpc.dart';

void main() {
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
      GitPublicationRepositoryV1.matchesCppStudyLegacySnapshotV1(hashes),
      isTrue,
    );
    hashes['README.md'] = 'changed';
    expect(
      GitPublicationRepositoryV1.matchesCppStudyLegacySnapshotV1(hashes),
      isFalse,
    );
  });

  test('previews managed files and detects an unchanged snapshot', () async {
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
    await File('${repository.path}/.gitignore').writeAsString('local\n');
    await _git(repository.path, ['add', '.gitignore']);
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
    final studyRepository = _StudyRepositoryMock();
    when(() => studyRepository.getMaterialTree('study-id'))
        .thenAnswer((_) async => MaterialTreeV1(study: study));
    final publication = GitPublicationRepositoryV1(
      GrpcExportGatewayV1(ExportServiceClient(channel)),
      studyRepository,
    );

    final preview = await publication.preview(study: study, snapshot: snapshot);
    expect(preview.changedPath, ['.want-study/manifest.json', 'README.md']);
    expect(preview.diff, contains('# Study'));
    expect(preview.diff, isNot(contains(temporary.path)));

    final published = await publication.publish(
      study: study,
      snapshot: snapshot,
      commitMessage: 'docs(study): test publication',
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
  });
}

final class _StudyRepositoryMock extends Mock implements StudyRepositoryV1 {}

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
