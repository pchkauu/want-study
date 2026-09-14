import 'package:flutter_test/flutter_test.dart';
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
      final state = CatalogStateV1(study: [study]);

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
  });
}
