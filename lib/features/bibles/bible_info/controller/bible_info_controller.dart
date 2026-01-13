import '../../all_bibles/controller/all_bibles_controller.dart';

class BibleInfoController {
  static List<String> availableVersions() {
    return ['KJV', 'KJVA', 'KJV+'];
  }

  static List<int> chaptersFor(Book book) {
    return List<int>.generate(book.chapters, (i) => i + 1);
  }

  static String categoryFor(Book book) {
    for (final entry in AllBiblesController.categories.entries) {
      if (entry.value.any((b) => b.id == book.id)) return entry.key;
    }
    return 'Unknown';
  }
}
