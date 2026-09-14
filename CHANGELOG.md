# Changelog

All notable changes to Want Study are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-14

### Added

- Desktop workspace for organizing studies, sources, sections, and lessons.
- Focused Markdown lesson editor with reading mode, autosave, slash commands, source references, homework, and UTF-8 code files.
- Independent material and homework progress tracking with four lesson statuses: planned, studying, homework, and mastered.
- Concept search and graph with aliases, relations, backlinks, and note-block links.
- Deterministic English GitHub Markdown export for studies, sources, lessons, files, and concepts.
- Protected Git publication workflow with preflight checks, diff preview, commit, push, and failed-push retry.
- Transactional `cpp-study` importer with dry-run support and duplicate-import protection.
- Local diagnostics, structured error handling, gRPC health checks, and PostgreSQL persistence.

### Fixed

- Prevented stale asynchronous results from replacing the active study, lesson, concept graph, or publication preview.
- Preserved note, homework, and file drafts across save failures and version conflicts.
- Stabilized concept graph rendering for isolated, connected, and large graphs.
- Required a fresh publication preview after content changes and prevented duplicate commits after push failures.
- Removed layout overflows and lifecycle errors across supported desktop sizes.

[1.0.0]: https://github.com/pchkauu/want-study/releases/tag/v1.0.0
