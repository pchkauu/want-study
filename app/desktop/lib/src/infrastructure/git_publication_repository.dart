// ignore_for_file: avoid_slow_async_io

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:study/study.dart';
import 'package:want_study_desktop/src/infrastructure/grpc_repository.dart';

final class _GitState {
  final String root;
  final String branch;
  final String remote;
  final String upstreamBranch;

  const _GitState({
    required this.root,
    required this.branch,
    required this.remote,
    required this.upstreamBranch,
  });
}

final class _Manifest {
  final String studyId;
  final int revision;
  final Map<String, String> hashByPath;

  const _Manifest({
    required this.studyId,
    required this.revision,
    required this.hashByPath,
  });
}

final class _CommandResult {
  final int exitCode;
  final String stdout;

  const _CommandResult(this.exitCode, this.stdout);
}

@LazySingleton(as: StudyPublicationRepositoryV1)
final class GitPublicationRepositoryV1 implements StudyPublicationRepositoryV1 {
  static const _manifestPath = '.want-study/manifest.json';
  static const _cppStudyLegacyHash = <String, String>{
    'README.md':
        '4fc6b1239165a24aae19dcc18c9259e14a487f530c85da13e946eb7cdecc60ed',
    'stepik/193691/README.md':
        'b1bc0adce3e40a92fdbcb2e284a8664f62f4190590e884fd83893b36cdfa3d92',
    'stepik/193691/source_code/1/4/main.c':
        '527e610de25ae829b41374b108d57bf5b02d836add2f6b848e76166e5a64ce5e',
  };

  final GrpcExportGatewayV1 _export;
  final StudyRepositoryV1 _studyRepository;

  const GitPublicationRepositoryV1(this._export, this._studyRepository);

  @override
  Future<ExportSnapshotV1> renderStudyExport(
    String studyId, {
    int? expectedContentRevision,
  }) =>
      _export.render(studyId, expectedContentRevision: expectedContentRevision);

  @override
  Future<PublicationPreviewV1> preview({
    required StudyV1 study,
    required ExportSnapshotV1 snapshot,
  }) => _guard(() => _preview(study, snapshot));

  Future<PublicationPreviewV1> _preview(
    StudyV1 study,
    ExportSnapshotV1 snapshot,
  ) async {
    final git = await _preflight(study.localRepositoryPath);
    final manifest = await _readManifest(git.root, study.id);
    await _validateSnapshot(snapshot);
    await _validateCurrentFiles(git.root, manifest, snapshot);
    final changedPath = _changedPath(manifest, snapshot);
    final diff = await _createDiff(git.root, manifest, snapshot);
    return PublicationPreviewV1(
      studyId: study.id,
      studyRevision: snapshot.studyRevision,
      diff: diff,
      changedPath: changedPath,
    );
  }

  @override
  Future<PublicationV1> publish({
    required StudyV1 study,
    required ExportSnapshotV1 snapshot,
    required String commitMessage,
  }) => _guard(() => _publish(study, snapshot, commitMessage));

  Future<PublicationV1> _publish(
    StudyV1 study,
    ExportSnapshotV1 snapshot,
    String commitMessage,
  ) async {
    final message = commitMessage.trim();
    if (message.isEmpty || message.length > 200 || message.contains('\n')) {
      throw const PublicationErrorV1('invalid_commit_message');
    }
    final git = await _preflight(study.localRepositoryPath);
    final tree = await _studyRepository.getMaterialTree(study.id);
    if (tree.study.contentRevision != snapshot.studyRevision) {
      throw ConflictErrorV1('study/${study.id}/content');
    }
    final manifest = await _readManifest(git.root, study.id);
    await _validateSnapshot(snapshot);
    await _validateCurrentFiles(git.root, manifest, snapshot);
    final changedPath = _changedPath(manifest, snapshot);
    if (changedPath.isEmpty) {
      throw const PublicationErrorV1('nothing_to_commit');
    }

    final backup = await Directory.systemTemp.createTemp('want-study-backup-');
    final managedPath = <String>{
      ...manifest.hashByPath.keys,
      _manifestPath,
      ...snapshot.file.map((file) => file.path),
    }.toList()..sort();
    final existed = <String>{};
    var committed = false;
    try {
      for (final item in managedPath) {
        final source = File(path.joinAll([git.root, ...item.split('/')]));
        if (await source.exists()) {
          existed.add(item);
          final destination = File(
            path.joinAll([backup.path, ...item.split('/')]),
          );
          await destination.parent.create(recursive: true);
          await source.copy(destination.path);
        }
      }
      await _writeSnapshot(git.root, manifest, snapshot);
      await _runGit(git.root, ['add', '-A', '--', ...managedPath]);
      final commit = await _runGit(git.root, ['commit', '-m', message]);
      if (commit.exitCode != 0) {
        throw const PublicationErrorV1('commit_failed');
      }
      committed = true;
      final sha = (await _runGit(git.root, [
        'rev-parse',
        'HEAD',
      ])).stdout.trim();
      final push = await _runGit(git.root, [
        'push',
        git.remote,
        'HEAD:refs/heads/${git.upstreamBranch}',
      ]);
      return PublicationV1(
        studyId: study.id,
        studyRevision: snapshot.studyRevision,
        changedPath: changedPath,
        commitSha: sha,
        state: push.exitCode == 0
            ? PublicationStateV1.published
            : PublicationStateV1.pushFailed,
      );
    } on Object catch (error, stackTrace) {
      if (!committed) {
        await _restore(git.root, backup.path, managedPath, existed);
      }
      if (error is DomainError) {
        Error.throwWithStackTrace(error, stackTrace);
      }
      throw PublicationErrorV1(
        'write_failed',
        cause: error,
        stackTrace: stackTrace,
      );
    } finally {
      await backup.delete(recursive: true);
    }
  }

  @override
  Future<PublicationV1> retryPush(PublicationV1 publication) =>
      _guard(() => _retryPush(publication));

  Future<PublicationV1> _retryPush(PublicationV1 publication) async {
    final tree = await _studyRepository.getMaterialTree(publication.studyId);
    final git = await _preflight(tree.study.localRepositoryPath);
    final head = (await _runGit(git.root, ['rev-parse', 'HEAD'])).stdout.trim();
    if (head != publication.commitSha) {
      throw const PublicationErrorV1('head_changed');
    }
    final push = await _runGit(git.root, [
      'push',
      git.remote,
      'HEAD:refs/heads/${git.upstreamBranch}',
    ]);
    if (push.exitCode != 0) {
      throw const PublicationErrorV1('push_failed');
    }
    return PublicationV1(
      studyId: publication.studyId,
      studyRevision: publication.studyRevision,
      changedPath: publication.changedPath,
      commitSha: publication.commitSha,
      state: PublicationStateV1.published,
    );
  }

  Future<_GitState> _preflight(String requestedRoot) async {
    if (requestedRoot.trim().isEmpty) {
      throw const PublicationErrorV1('repository_not_selected');
    }
    final requested = await Directory(requestedRoot).resolveSymbolicLinks();
    final rootResult = await _runGit(requested, [
      'rev-parse',
      '--show-toplevel',
    ]);
    if (rootResult.exitCode != 0) {
      throw const PublicationErrorV1('not_git_repository');
    }
    final root = await Directory(rootResult.stdout.trim())
        .resolveSymbolicLinks();
    if (!path.equals(path.normalize(root), path.normalize(requested))) {
      throw const PublicationErrorV1('repository_root_mismatch');
    }
    final branchResult = await _runGit(root, [
      'symbolic-ref',
      '--quiet',
      '--short',
      'HEAD',
    ]);
    if (branchResult.exitCode != 0 || branchResult.stdout.trim().isEmpty) {
      throw const PublicationErrorV1('detached_head');
    }
    final upstreamResult = await _runGit(root, [
      'rev-parse',
      '--abbrev-ref',
      '--symbolic-full-name',
      '@{upstream}',
    ]);
    final upstream = upstreamResult.stdout.trim();
    final separator = upstream.indexOf('/');
    if (upstreamResult.exitCode != 0 || separator <= 0) {
      throw const PublicationErrorV1('upstream_missing');
    }
    final remote = upstream.substring(0, separator);
    final upstreamBranch = upstream.substring(separator + 1);
    final remoteResult = await _runGit(root, [
      'config',
      '--get',
      'remote.$remote.url',
    ]);
    if (remoteResult.exitCode != 0 || !_isGitHubRemote(remoteResult.stdout)) {
      throw const PublicationErrorV1('github_remote_missing');
    }
    final staged = await _runGit(root, ['diff', '--cached', '--quiet']);
    if (staged.exitCode != 0) {
      throw const PublicationErrorV1('staged_files_present');
    }
    final fetch = await _runGit(root, ['fetch', remote]);
    if (fetch.exitCode != 0) {
      throw const PublicationErrorV1('fetch_failed');
    }
    final divergence = await _runGit(root, [
      'rev-list',
      '--left-right',
      '--count',
      'HEAD...@{upstream}',
    ]);
    final count = divergence.stdout.trim().split(RegExp(r'\s+'));
    if (divergence.exitCode != 0 || count.length != 2) {
      throw const PublicationErrorV1('upstream_check_failed');
    }
    final behind = int.tryParse(count[1]);
    if (behind == null || behind > 0) {
      throw const PublicationErrorV1('branch_behind_or_diverged');
    }
    return _GitState(
      root: root,
      branch: branchResult.stdout.trim(),
      remote: remote,
      upstreamBranch: upstreamBranch,
    );
  }

  bool _isGitHubRemote(String value) {
    final remote = value.trim().toLowerCase();
    return remote.startsWith('git@github.com:') ||
        remote.startsWith('ssh://git@github.com/') ||
        remote.startsWith('https://github.com/');
  }

  Future<_Manifest> _readManifest(String root, String studyId) async {
    final file = File(path.join(root, '.want-study', 'manifest.json'));
    if (!await file.exists()) {
      final legacy = await _cppStudyLegacyManifest(root, studyId);
      if (legacy != null) {
        return legacy;
      }
      return _Manifest(studyId: studyId, revision: 0, hashByPath: const {});
    }
    await _ensureNoSymlink(root, _manifestPath);
    try {
      final value = jsonDecode(await file.readAsString());
      if (value is! Map<String, Object?> ||
          value['formatVersion'] != 1 ||
          value['studyId'] != studyId ||
          value['studyRevision'] is! int ||
          value['files'] is! List<Object?>) {
        throw const PublicationErrorV1('invalid_manifest');
      }
      final hashes = <String, String>{};
      for (final item in value['files']! as List<Object?>) {
        if (item is! Map<String, Object?> ||
            item['path'] is! String ||
            item['sha256'] is! String) {
          throw const PublicationErrorV1('invalid_manifest');
        }
        final filePath = item['path']! as String;
        _validateRelativePath(filePath);
        if (hashes.containsKey(filePath)) {
          throw const PublicationErrorV1('invalid_manifest');
        }
        hashes[filePath] = item['sha256']! as String;
      }
      hashes[_manifestPath] = sha256
          .convert(await file.readAsBytes())
          .toString();
      return _Manifest(
        studyId: studyId,
        revision: value['studyRevision']! as int,
        hashByPath: Map.unmodifiable(hashes),
      );
    } on DomainError {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw PublicationErrorV1(
        'invalid_manifest',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<_Manifest?> _cppStudyLegacyManifest(
    String root,
    String studyId,
  ) async {
    final hashes = <String, String>{};
    for (final entry in _cppStudyLegacyHash.entries) {
      await _ensureNoSymlink(root, entry.key);
      final file = File(path.joinAll([root, ...entry.key.split('/')]));
      if (!await file.exists()) {
        return null;
      }
      final actual = sha256.convert(await file.readAsBytes()).toString();
      hashes[entry.key] = actual;
    }
    if (!matchesCppStudyLegacySnapshotV1(hashes)) {
      return null;
    }
    return _Manifest(
      studyId: studyId,
      revision: 0,
      hashByPath: Map.unmodifiable(hashes),
    );
  }

  static bool matchesCppStudyLegacySnapshotV1(Map<String, String> hashes) =>
      hashes.length == _cppStudyLegacyHash.length &&
      _cppStudyLegacyHash.entries.every(
        (entry) => hashes[entry.key] == entry.value,
      );

  Future<void> _validateSnapshot(ExportSnapshotV1 snapshot) async {
    if (snapshot.totalBytes > 50 * 1024 * 1024) {
      throw const PublicationErrorV1('snapshot_too_large');
    }
    String? previous;
    var hasManifest = false;
    final seen = <String>{};
    for (final file in snapshot.file) {
      _validateRelativePath(file.path);
      if (!seen.add(file.path) ||
          previous != null && previous.compareTo(file.path) >= 0) {
        throw const PublicationErrorV1('snapshot_not_sorted');
      }
      if (sha256.convert(file.content).toString() != file.sha256) {
        throw const PublicationErrorV1('snapshot_hash_mismatch');
      }
      hasManifest = hasManifest || file.path == _manifestPath;
      previous = file.path;
    }
    if (!hasManifest) {
      throw const PublicationErrorV1('snapshot_manifest_missing');
    }
  }

  Future<void> _validateCurrentFiles(
    String root,
    _Manifest manifest,
    ExportSnapshotV1 snapshot,
  ) async {
    for (final entry in manifest.hashByPath.entries) {
      await _ensureNoSymlink(root, entry.key);
      final file = File(path.joinAll([root, ...entry.key.split('/')]));
      if (!await file.exists() ||
          sha256.convert(await file.readAsBytes()).toString() != entry.value) {
        throw const PublicationErrorV1('managed_file_changed');
      }
    }
    for (final file in snapshot.file) {
      await _ensureNoSymlink(root, file.path);
      if (!manifest.hashByPath.containsKey(file.path) &&
          file.path != _manifestPath &&
          await File(path.joinAll([root, ...file.path.split('/')])).exists()) {
        throw const PublicationErrorV1('managed_path_collision');
      }
    }
  }

  List<String> _changedPath(_Manifest manifest, ExportSnapshotV1 snapshot) {
    final next = {for (final file in snapshot.file) file.path: file.sha256};
    final changed = <String>{};
    for (final entry in next.entries) {
      if (manifest.hashByPath[entry.key] != entry.value) {
        changed.add(entry.key);
      }
    }
    changed.addAll(
      manifest.hashByPath.keys.where((item) => !next.containsKey(item)),
    );
    final result = changed.toList()..sort();
    return result;
  }

  Future<String> _createDiff(
    String root,
    _Manifest manifest,
    ExportSnapshotV1 snapshot,
  ) async {
    final temporary = await Directory.systemTemp.createTemp('want-study-diff-');
    final before = Directory(path.join(temporary.path, 'before'));
    final after = Directory(path.join(temporary.path, 'after'));
    try {
      await before.create();
      await after.create();
      final union = <String>{
        ...manifest.hashByPath.keys,
        _manifestPath,
        ...snapshot.file.map((file) => file.path),
      };
      for (final item in union) {
        final source = File(path.joinAll([root, ...item.split('/')]));
        if (await source.exists()) {
          final destination = File(
            path.joinAll([before.path, ...item.split('/')]),
          );
          await destination.parent.create(recursive: true);
          await source.copy(destination.path);
        }
      }
      for (final file in snapshot.file) {
        final destination = File(
          path.joinAll([after.path, ...file.path.split('/')]),
        );
        await destination.parent.create(recursive: true);
        await destination.writeAsBytes(file.content, flush: true);
      }
      final result = await _runProcess('/usr/bin/git', [
        'diff',
        '--no-index',
        '--no-ext-diff',
        '--src-prefix=a/',
        '--dst-prefix=b/',
        '--',
        before.path,
        after.path,
      ], workingDirectory: root);
      if (result.exitCode != 0 && result.exitCode != 1) {
        throw const PublicationErrorV1('diff_failed');
      }
      return result.stdout
          .replaceAll('${before.path}/', '')
          .replaceAll('${after.path}/', '');
    } finally {
      await temporary.delete(recursive: true);
    }
  }

  Future<void> _writeSnapshot(
    String root,
    _Manifest manifest,
    ExportSnapshotV1 snapshot,
  ) async {
    final nextPath = snapshot.file.map((file) => file.path).toSet();
    for (final oldPath in manifest.hashByPath.keys) {
      if (!nextPath.contains(oldPath)) {
        final file = File(path.joinAll([root, ...oldPath.split('/')]));
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    for (final file in snapshot.file) {
      final target = File(path.joinAll([root, ...file.path.split('/')]));
      await target.parent.create(recursive: true);
      await target.writeAsBytes(file.content, flush: true);
    }
  }

  Future<void> _restore(
    String root,
    String backup,
    List<String> managedPath,
    Set<String> existed,
  ) async {
    await _runGit(root, ['restore', '--staged', '--', ...managedPath]);
    for (final item in managedPath) {
      final target = File(path.joinAll([root, ...item.split('/')]));
      if (existed.contains(item)) {
        final source = File(path.joinAll([backup, ...item.split('/')]));
        await target.parent.create(recursive: true);
        await source.copy(target.path);
      } else if (await target.exists()) {
        await target.delete();
      }
    }
  }

  void _validateRelativePath(String value) {
    final normalized = path.posix.normalize(value);
    if (value.isEmpty ||
        path.posix.isAbsolute(value) ||
        normalized != value ||
        value.startsWith('../') ||
        value.contains(r'\') ||
        value.split('/').any((part) => part.isEmpty || part == '..')) {
      throw const PublicationErrorV1('invalid_path');
    }
  }

  Future<void> _ensureNoSymlink(String root, String relativePath) async {
    _validateRelativePath(relativePath);
    var current = root;
    for (final part in relativePath.split('/')) {
      current = path.join(current, part);
      final type = await FileSystemEntity.type(current, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw const PublicationErrorV1('symlink_not_allowed');
      }
    }
    final target = path.normalize(current);
    if (!path.isWithin(root, target)) {
      throw const PublicationErrorV1('path_escape');
    }
  }

  Future<_CommandResult> _runGit(String root, List<String> arguments) =>
      _runProcess('/usr/bin/git', [
        '-C',
        root,
        ...arguments,
      ], workingDirectory: root);

  Future<_CommandResult> _runProcess(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  }) async {
    try {
      final process = await Process.start(
        executable,
        arguments,
        workingDirectory: workingDirectory,
        // Required for literal argument handling in Git publication.
        // ignore: avoid_redundant_argument_values
        runInShell: false,
      );
      final stdoutFuture = utf8.decoder.bind(process.stdout).join();
      final stderrFuture = process.stderr.drain<void>();
      final exitCode = await process.exitCode;
      final stdout = await stdoutFuture;
      await stderrFuture;
      return _CommandResult(exitCode, stdout);
    } on Object catch (error, stackTrace) {
      throw PublicationErrorV1(
        'process_failed',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DomainError {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw PublicationErrorV1(
        'unexpected_failure',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
