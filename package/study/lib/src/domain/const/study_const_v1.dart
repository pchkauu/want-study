abstract final class StudyConstV1 {
  const StudyConstV1._();

  static int get maxTitleLength => 200;

  static int get maxContentBytes => 1024 * 1024;

  static int get maxExportSnapshotBytes => 50 * 1024 * 1024;

  static int get minConceptSearchLimit => 1;

  static int get maxConceptSearchLimit => 100;

  static int get defaultConceptSearchLimit => 50;

  static Duration get autosaveDelay => const Duration(milliseconds: 750);
}
