import 'package:flutter_test/flutter_test.dart';
import 'package:study/src/application/_barrel.dart';
import 'package:study/study.dart';

void main() {
  group('domain V1', () {
    test('entities compare by ID and hide sensitive content', () {
      final first = StudyV1(
        id: 'study-id',
        title: 'C++',
        goal: 'secret goal',
        localRepositoryPath: '/private/repository',
      );
      final second = StudyV1(id: 'study-id', title: 'Different title');

      expect(first, second);
      expect(first.toString(), isNot(contains('C++')));
      expect(first.toString(), isNot(contains('secret goal')));
      expect(first.toString(), isNot(contains('/private/repository')));
    });

    test('value objects compare by full value', () {
      expect(
        ProgressIndicatorV1(completed: 1, total: 2),
        ProgressIndicatorV1(completed: 1, total: 2),
      );
      expect(
        ProgressIndicatorV1(completed: 1, total: 2),
        isNot(ProgressIndicatorV1(completed: 2, total: 2)),
      );
    });

    test('lesson status timestamps stay consistent', () {
      expect(
        () => LessonV1(
          id: 'lesson-id',
          studyId: 'study-id',
          sourceId: 'source-id',
          title: 'Lesson',
          exportSlug: 'lesson',
          position: 0,
          status: LessonStatusV1.mastered,
        ),
        throwsA(isA<ValidationErrorV1>()),
      );
    });

    test('collections are immutable', () {
      final concept = ConceptV1(
        id: 'concept-id',
        studyId: 'study-id',
        title: 'RAII',
        exportSlug: 'raii',
        aliases: const ['Resource management', 'resource management'],
      );

      expect(concept.aliases, ['Resource management']);
      expect(() => concept.aliases.add('Lifetime'), throwsUnsupportedError);
    });

    test('aggregate value objects compare complete snapshots', () {
      final lesson = LessonV1(
        id: 'lesson-id',
        studyId: 'study-id',
        sourceId: 'source-id',
        title: 'Lesson',
        exportSlug: 'lesson',
        position: 0,
      );
      final first = LessonWorkspaceV1(
        lesson: lesson,
        block: [
          NoteBlockV1(
            id: 'block-id',
            studyId: 'study-id',
            lessonId: 'lesson-id',
            type: NoteBlockTypeV1.text,
            position: 0,
            markdown: 'first',
          ),
        ],
      );

      expect(
        first,
        isNot(
          first.copyWith(
            block: [first.block.single.copyWith(markdown: 'second')],
          ),
        ),
      );
    });

    test('catalog state detects updated entity snapshots', () {
      final study = StudyV1(id: 'study-id', title: 'First');
      final state = CatalogStateV2(study: [study]);

      expect(
        state,
        isNot(state.copyWith(study: [study.copyWith(title: 'Second')])),
      );
    });

    test('content limit counts UTF-8 bytes', () {
      final oversized = List.filled(262145, '🙂').join();

      expect(
        () => NoteBlockV1(
          id: 'block-id',
          studyId: 'study-id',
          lessonId: 'lesson-id',
          type: NoteBlockTypeV1.text,
          position: 0,
          markdown: oversized,
        ),
        throwsA(isA<ValidationErrorV1>()),
      );
    });

    test('copyWith clears nullable values through callbacks', () {
      final lesson = LessonV1(
        id: 'lesson-id',
        studyId: 'study-id',
        sourceId: 'source-id',
        sectionId: 'section-id',
        title: 'Lesson',
        exportSlug: 'lesson',
        position: 0,
      );

      expect(lesson.copyWith(sectionId: () => null).sectionId, isNull);
    });

    test('concept search accepts only limits from 1 through 100', () {
      expect(ConceptSearchV1(limit: 1).limit, 1);
      expect(ConceptSearchV1(limit: 100).limit, 100);
      expect(
        () => ConceptSearchV1(limit: 0),
        throwsA(isA<ValidationErrorV1>()),
      );
      expect(
        () => ConceptSearchV1(limit: 101),
        throwsA(isA<ValidationErrorV1>()),
      );
    });

    test('debug strings redact notes, URLs and paths', () {
      final block = NoteBlockV1(
        id: 'block-id',
        studyId: 'study-id',
        lessonId: 'lesson-id',
        type: NoteBlockTypeV1.text,
        markdown: 'private note',
        sourceUrl: 'https://example.com/private',
        position: 0,
      );
      final file = CodeFileV1(
        id: 'file-id',
        studyId: 'study-id',
        lessonId: 'lesson-id',
        relativePath: 'private/main.dart',
        content: 'secret content',
      );

      expect(block.toDebugString(), isNot(contains('private note')));
      expect(block.toDebugString(), isNot(contains('example.com')));
      expect(file.toDebugString(), isNot(contains('private/main.dart')));
      expect(file.toDebugString(), isNot(contains('secret content')));
    });

    test('error equality ignores cause and stack trace', () {
      final first = UnexpectedErrorV1(
        cause: StateError('first'),
        stackTrace: StackTrace.current,
      );
      final second = UnexpectedErrorV1(
        cause: StateError('second'),
        stackTrace: StackTrace.empty,
      );

      expect(first, second);
      expect(first.typeIdentifier, 'UnexpectedErrorV1');
    });

    test('all concrete errors keep stable type identifiers', () {
      expect(
        const ValidationErrorV1('field').typeIdentifier,
        'ValidationErrorV1',
      );
      expect(const NotFoundErrorV1('study').typeIdentifier, 'NotFoundErrorV1');
      expect(const ConflictErrorV1('study').typeIdentifier, 'ConflictErrorV1');
      expect(const OpenHomeworkErrorV1().typeIdentifier, 'OpenHomeworkErrorV1');
      expect(const UnavailableErrorV1().typeIdentifier, 'UnavailableErrorV1');
      expect(
        const PublicationErrorV1('preflight').typeIdentifier,
        'PublicationErrorV1',
      );
    });

    test('snapshot factories and copyWith preserve invariants', () {
      final source = LearningSourceV1(
        id: 'source-id',
        studyId: 'study-id',
        type: LearningSourceTypeV1.book,
        title: 'Book',
        exportSlug: 'book',
        position: 0,
      );
      final input = <LearningSourceNodeV1>[
        LearningSourceNodeV1(source: source),
      ];
      final tree = MaterialTreeV1(
        study: StudyV1(id: 'study-id', title: 'Study'),
        source: input,
      );
      input.clear();

      expect(tree.source, hasLength(1));
      expect(tree.source.clear, throwsUnsupportedError);
      expect(
        () => tree.copyWith(
          study: StudyV1(id: 'another-study', title: 'Study'),
        ),
        throwsA(isA<ValidationErrorV1>()),
      );
    });

    test('controller event strings do not expose editor content', () {
      final event = LessonEditorFileChangedV2(
        CodeFileV1(
          id: 'file-id',
          studyId: 'study-id',
          lessonId: 'lesson-id',
          relativePath: 'private/main.dart',
          content: 'secret content',
        ),
      );

      expect(event.toString(), isNot(contains('private/main.dart')));
      expect(event.toString(), isNot(contains('secret content')));
    });
  });
}
