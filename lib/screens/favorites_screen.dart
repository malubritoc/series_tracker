import 'package:flutter/material.dart';

import '../models/series.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_service.dart';
import 'series_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favorites = FavoritesService();
  final TmdbService _tmdb = TmdbService();

  late Future<List<Series>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _load();
  }

  Future<List<Series>> _load() async {
    final ids = await _favorites.getIds();
    if (ids.isEmpty) return const [];
    final futures = ids.map(_tmdb.fetchDetail);
    return Future.wait(futures);
  }

  void reload() {
    if (!mounted) return;
    setState(() {
      _favoritesFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: FutureBuilder<List<Series>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final favorites = snapshot.data ?? const [];
          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Você ainda não favoritou nenhuma série.\nToque no coração em alguma para começar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final series = favorites[index];
              return _FavoriteTile(
                series: series,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SeriesDetailScreen(
                        seriesId: series.id,
                        initialName: series.name,
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

class _FavoriteTile extends StatelessWidget {
  final Series series;
  final VoidCallback onTap;
  const _FavoriteTile({required this.series, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFF8000)),
                      const SizedBox(width: 4),
                      Text(
                        series.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (series.yearLabel.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Text(
                          series.yearLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ],
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
