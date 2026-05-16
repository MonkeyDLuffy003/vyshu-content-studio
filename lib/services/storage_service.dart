import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_item.dart';

class StorageService {
  static const String _storageKey = 'vyshu_content_items';
  static const int retentionDays = 7;

  /// Load all items, auto-deleting those older than 7 days
  static Future<List<ContentItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final now = DateTime.now();

    final valid = <ContentItem>[];
    final expired = <String>[];

    for (final s in raw) {
      try {
        final item = ContentItem.fromJsonString(s);
        final age = now.difference(item.createdAt).inDays;
        if (age < retentionDays) {
          valid.add(item);
        } else {
          expired.add(item.id);
        }
      } catch (_) {
        // Corrupt entry, skip
      }
    }

    // Persist cleaned list if anything expired
    if (expired.isNotEmpty) {
      await _persist(valid);
    }

    // Sort newest first
    valid.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return valid;
  }

  /// Save a new content item
  static Future<void> saveItem(ContentItem item) async {
    final items = await loadItems();
    items.insert(0, item);
    await _persist(items);
  }

  /// Delete a specific item by id
  static Future<void> deleteItem(String id) async {
    final items = await loadItems();
    items.removeWhere((i) => i.id == id);
    await _persist(items);
  }

  /// Clear all stored items
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Storage usage summary
  static Future<Map<String, int>> getStorageStats() async {
    final items = await loadItems();
    final now = DateTime.now();
    final stats = <String, int>{};
    for (var i = 0; i < retentionDays; i++) {
      final day = now.subtract(Duration(days: i));
      final label = '${day.day}/${day.month}';
      stats[label] = items
          .where((item) =>
              item.createdAt.day == day.day &&
              item.createdAt.month == day.month)
          .length;
    }
    return stats;
  }

  static Future<void> _persist(List<ContentItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _storageKey, items.map((i) => i.toJsonString()).toList());
  }
}
