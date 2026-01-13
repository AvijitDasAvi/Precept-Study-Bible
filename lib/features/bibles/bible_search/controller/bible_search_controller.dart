import '../../all_bibles/controller/all_bibles_controller.dart';
import '../../each_category_collection/controller/each_category_collection_controller.dart';

class BibleSearchController {
  static final Map<String, List<Book>> _remoteCache = {};

  static List<Book> allLocalBooks() {
    return AllBiblesController.categories.values.expand((v) => v).toList();
  }

  static Future<void> _ensureRemoteLoaded() async {
    final categories = ['KJV', 'KJVA', 'KJV+'];
    final futures = <Future>[];
    for (final c in categories) {
      if (!_remoteCache.containsKey(c)) {
        futures.add(
          EachCategoryCollectionController.getBooksForCategory(c)
              .then((list) => _remoteCache[c] = list)
              .catchError((_) => _remoteCache[c] = []),
        );
      }
    }
    if (futures.isNotEmpty) await Future.wait(futures);
  }

  static Future<List<Map<String, dynamic>>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    await _ensureRemoteLoaded();

    final results = <Map<String, dynamic>>[];

    for (final b in allLocalBooks()) {
      if (b.title.toLowerCase().contains(q)) {
        results.add({'book': b, 'version': 'local'});
      }
    }

    for (final entry in _remoteCache.entries) {
      final version = entry.key; // 'KJV' etc
      for (final b in entry.value) {
        if (b.title.toLowerCase().contains(q)) {
          results.add({'book': b, 'version': version});
        }
      }
    }

    return results;
  }
}
