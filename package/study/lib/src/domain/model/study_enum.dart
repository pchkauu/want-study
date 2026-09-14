enum LearningSourceTypeV1 { course, book, article, video, other }

enum LessonStatusV1 { planned, studying, homework, mastered }

enum NoteBlockTypeV1 {
  text,
  definition,
  claim,
  quote,
  example,
  question,
  summary,
}

enum HomeworkStatusV1 { todo, done }

enum ConceptRelationTypeV1 {
  relatedTo,
  partOf,
  prerequisiteFor,
  contrastsWith,
  appliesTo,
}

enum PublicationStateV1 { preview, committed, pushFailed, published }

enum SaveStateV1 { clean, dirty, saving, saved, failed, conflict }
