import 'package:flutter/material.dart';

import '../models/series.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_service.dart';

class SeriesDetailScreen extends StatefulWidget {
  final int seriesId;
  final String? initialName;

  const SeriesDetailScreen({
    super.key,
    required this.seriesId,
    this.initialName,
  });

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  final TmdbService _tmdb = TmdbService();
  final FavoritesService _favorites = FavoritesService();

  late Future<Series> _detailFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _tmdb.fetchDetail(widget.seriesId);
    _favorites.isFavorite(widget.seriesId).then((value) {
      if (mounted) setState(() => _isFavorite = value);
    });
  }

  Future<void> _toggleFavorite() async {
    final nowFavorite = await _favorites.toggle(widget.seriesId);
    if (mounted) setState(() => _isFavorite = nowFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialName ?? ''),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? const Color(0xFFFF8000) : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Series>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final series = snapshot.data!;
          return _DetailBody(series: series);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Series series;
  const _DetailBody({required this.series});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (series.posterUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(series.posterUrl!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (series.tagline != null && series.tagline!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    series.tagline!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 18, color: Color(0xFFFF8000)),
                    const SizedBox(width: 4),
                    Text(
                      series.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    if (series.yearLabel.isNotEmpty)
                      Text(
                        series.yearLabel,
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
                if (series.genres != null && series.genres!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: series.genres!
                        .map(
                          (g) => Chip(
                            label: Text(g),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Sinopse',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  series.overview.isEmpty
                      ? 'Sem sinopse disponível.'
                      : series.overview,
                  style: const TextStyle(height: 1.4),
                ),
                const SizedBox(height: 20),
                _MetaRow(
                  items: [
                    if (series.numberOfSeasons != null)
                      ('Temporadas', series.numberOfSeasons.toString()),
                    if (series.numberOfEpisodes != null)
                      ('Episódios', series.numberOfEpisodes.toString()),
                    if (series.status != null && series.status!.isNotEmpty)
                      ('Status', series.status!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final List<(String, String)> items;
  const _MetaRow({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Column(
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
