import 'package:shared_preferences/shared_preferences.dart';

class WatchedService {
  static const String _seriesIdsKey = 'watched_series_ids';
  static String _episodesKey(int seriesId) => 'watched_episodes_$seriesId';

  Future<Set<int>> getWatchedSeriesIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_seriesIdsKey) ?? const [];
    return raw.map(int.parse).toSet();
  }

  Future<Set<String>> getWatchedEpisodes(int seriesId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_episodesKey(seriesId)) ?? const [];
    return raw.toSet();
  }

  Future<int> getWatchedCount(int seriesId) async {
    final episodes = await getWatchedEpisodes(seriesId);
    return episodes.length;
  }

  Future<bool> isWatched(int seriesId, int season, int episode) async {
    final episodes = await getWatchedEpisodes(seriesId);
    return episodes.contains('$season.$episode');
  }

  Future<bool> toggleEpisode(int seriesId, int season, int episode) async {
    final prefs = await SharedPreferences.getInstance();
    final episodes = await getWatchedEpisodes(seriesId);
    final key = '$season.$episode';
    final nowWatched = !episodes.contains(key);

    if (nowWatched) {
      episodes.add(key);
    } else {
      episodes.remove(key);
    }

    if (episodes.isEmpty) {
      await prefs.remove(_episodesKey(seriesId));
    } else {
      await prefs.setStringList(_episodesKey(seriesId), episodes.toList());
    }

    final seriesIds = await getWatchedSeriesIds();
    if (episodes.isEmpty) {
      seriesIds.remove(seriesId);
    } else {
      seriesIds.add(seriesId);
    }
    await prefs.setStringList(
      _seriesIdsKey,
      seriesIds.map((e) => e.toString()).toList(),
    );

    return nowWatched;
  }
}
