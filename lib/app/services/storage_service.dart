import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/search_history.dart';

class StorageService {
  // Shared Preferences untuk theme
  static const String _themeKey = 'isDarkMode';

  // SharedPreferences - Save & Get Theme
  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Hive - Search History
  Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SearchHistoryAdapter());
    await Hive.openBox<SearchHistory>('searchHistory');
  }

  Future<void> addSearchHistory(String term) async {
    final box = Hive.box<SearchHistory>('searchHistory');
    final history = SearchHistory(
      searchTerm: term,
      timestamp: DateTime.now(),
    );
    await box.add(history);
  }

  List<SearchHistory> getSearchHistory() {
    final box = Hive.box<SearchHistory>('searchHistory');
    return box.values.toList().reversed.take(10).toList();
  }

  Future<void> clearSearchHistory() async {
    final box = Hive.box<SearchHistory>('searchHistory');
    await box.clear();
  }
}
