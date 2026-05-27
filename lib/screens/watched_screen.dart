import 'package:flutter/material.dart';

import '../models/series.dart';
import '../services/tmdb_service.dart';
import '../services/watched_service.dart';
import 'series_detail_screen.dart';

class WatchedScreen extends StatefulWidget {
  const WatchedScreen({super.key});

  @override
  State<WatchedScreen> createState() => WatchedScreenState();
}

class _WatchedEntry {
  final Series series;
  final int watchedCount;
  const _WatchedEntry({required this.series, required this.watchedCount});
}

class WatchedScreenState extends State<WatchedScreen> {
  final WatchedService _watched = WatchedService();
  final TmdbService _tmdb = TmdbService();

  late Future<List<_WatchedEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _load();
  }

  Future<List<_WatchedEntry>> _load() async {
    final ids = await _watched.getWatchedSeriesIds();
    if (ids.isEmpty) return const [];

    final entries = await Future.wait(
      ids.map((id) async {
        final series = await _tmdb.fetchDetail(id);
        final count = await _watched.getWatchedCount(id);
        return _WatchedEntry(series: series, watchedCount: count);
      }),
    );
    return entries;
  }

  void reload() {
    if (!mounted) return;
    setState(() {
      _entriesFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistidos')),
      body: FutureBuilder<List<_WatchedEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro: ${snapshot.error}'),
              ),
            );
          }
          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Você ainda não marcou nenhum episódio.\nAbra uma série e marque os episódios que já viu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _WatchedTile(
                entry: entry,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeriesDetailScreen(
                        seriesId: entry.series.id,
                        initialName: entry.series.name,
                      ),
                    ),
                  );
                  reload();
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WatchedTile extends StatelessWidget {
  final _WatchedEntry entry;
  final VoidCallback onTap;
  const _WatchedTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final series = entry.series;
    final total = series.numberOfEpisodes ?? 0;
    final progress = total > 0 ? entry.watchedCount / total : 0.0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 60,
                height: 90,
                child: series.posterUrl != null
                    ? Image.network(series.posterUrl!, fit: BoxFit.cover)
                    : Container(color: Colors.white12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    total > 0
                        ? '${entry.watchedCount} / $total episódios'
                        : '${entry.watchedCount} episódios',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (total > 0)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF8000),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
