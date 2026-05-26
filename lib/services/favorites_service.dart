import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_series_ids';

  Future<Set<int>> getIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    return raw.map(int.parse).toSet();
  }

  Future<bool> isFavorite(int id) async {
    final ids = await getIds();
    return ids.contains(id);
  }

  Future<void> add(int id) async {
    final ids = await getIds()..add(id);
    await _save(ids);
  }

  Future<void> remove(int id) async {
    final ids = await getIds()..remove(id);
    await _save(ids);
  }

  Future<bool> toggle(int id) async {
    final ids = await getIds();
    final nowFavorite = !ids.contains(id);
    if (nowFavorite) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await _save(ids);
    return nowFavorite;
  }

  Future<void> _save(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.map((e) => e.toString()).toList());
  }
}
