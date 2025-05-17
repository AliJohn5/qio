import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _key = 'my_string_list';

  Future<List<String>> getList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> addString(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = prefs.getStringList(_key) ?? [];

    if (!currentList.contains(value)) {
      currentList.add(value);
      await prefs.setStringList(_key, currentList);
    }
  }

  /// Syncs the stored list with the provided one:
  /// - Removes stored values not in [newList]
  /// - Ignores values already in [newList] from adding again
  /// - Final stored list = intersection of both
  Future<List<String>> syncWithList(List<String> newList) async {
    final prefs = await SharedPreferences.getInstance();
    final storedList = prefs.getStringList(_key) ?? [];

    // Remove items from stored that are not in newList
    final updatedList =
        storedList.where((item) => newList.contains(item)).toList();

    // Add remaining new items

    List<String> ans = [];

    for (var item in newList) {
      if (!updatedList.contains(item)) {
        ans.add(item);
      }
    }

    await prefs.setStringList(_key, updatedList);

    return ans;
  }
}
