import 'package:flutter/material.dart';

import '../models/episode.dart';
import '../models/season.dart';
import '../models/series.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_service.dart';
import '../services/watched_service.dart';

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
  final WatchedService _watched = WatchedService();

  late Future<Series> _detailFuture;
  bool _isFavorite = false;
  Set<String> _watchedEpisodes = {};

  final Map<int, Future<List<Episode>>> _episodesBySeason = {};

  @override
  void initState() {
    super.initState();
    _detailFuture = _tmdb.fetchDetail(widget.seriesId);
    _favorites.isFavorite(widget.seriesId).then((value) {
      if (mounted) setState(() => _isFavorite = value);
    });
    _watched.getWatchedEpisodes(widget.seriesId).then((value) {
      if (mounted) setState(() => _watchedEpisodes = value);
    });
  }

  Future<void> _toggleFavorite() async {
    final nowFavorite = await _favorites.toggle(widget.seriesId);
    if (mounted) setState(() => _isFavorite = nowFavorite);
  }

  Future<void> _toggleEpisode(int season, int episode) async {
    await _watched.toggleEpisode(widget.seriesId, season, episode);
    final updated = await _watched.getWatchedEpisodes(widget.seriesId);
    if (mounted) setState(() => _watchedEpisodes = updated);
  }

  void _ensureSeasonLoaded(int seasonNumber) {
    if (_episodesBySeason.containsKey(seasonNumber)) return;
    setState(() {
      _episodesBySeason[seasonNumber] =
          _tmdb.fetchSeason(widget.seriesId, seasonNumber);
    });
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
          return _DetailBody(
            series: snapshot.data!,
            watchedEpisodes: _watchedEpisodes,
            episodesBySeason: _episodesBySeason,
            onExpandSeason: _ensureSeasonLoaded,
            onToggleEpisode: _toggleEpisode,
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Series series;
  final Set<String> watchedEpisodes;
  final Map<int, Future<List<Episode>>> episodesBySeason;
  final void Function(int seasonNumber) onExpandSeason;
  final Future<void> Function(int season, int episode) onToggleEpisode;

  const _DetailBody({
    required this.series,
    required this.watchedEpisodes,
    required this.episodesBySeason,
    required this.onExpandSeason,
    required this.onToggleEpisode,
  });

  @override
  Widget build(BuildContext context) {
    final seasons = series.seasons ?? const <Season>[];
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
              ],
            ),
          ),
          if (seasons.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Temporadas',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            ...seasons.map(
              (season) => _SeasonTile(
                season: season,
                episodesFuture: episodesBySeason[season.seasonNumber],
                watchedEpisodes: watchedEpisodes,
                onExpand: () => onExpandSeason(season.seasonNumber),
                onToggleEpisode: onToggleEpisode,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _SeasonTile extends StatelessWidget {
  final Season season;
  final Future<List<Episode>>? episodesFuture;
  final Set<String> watchedEpisodes;
  final VoidCallback onExpand;
  final Future<void> Function(int season, int episode) onToggleEpisode;

  const _SeasonTile({
    required this.season,
    required this.episodesFuture,
    required this.watchedEpisodes,
    required this.onExpand,
    required this.onToggleEpisode,
  });

  @override
  Widget build(BuildContext context) {
    final watchedInSeason = watchedEpisodes
        .where((k) => k.startsWith('${season.seasonNumber}.'))
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        color: const Color(0xFF1B2228),
        margin: EdgeInsets.zero,
        child: ExpansionTile(
          key: PageStorageKey('season_${season.seasonNumber}'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            season.name.isEmpty
                ? 'Temporada ${season.seasonNumber}'
                : season.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '$watchedInSeason / ${season.episodeCount} assistidos',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          onExpansionChanged: (expanded) {
            if (expanded) onExpand();
          },
          children: [_buildContent()],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (episodesFuture == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return FutureBuilder<List<Episode>>(
      future: episodesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erro ao carregar episódios.',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        final episodes = snapshot.data ?? const [];
        return Column(
          children: episodes.map((ep) {
            final watched = watchedEpisodes.contains(ep.watchedKey);
            return _EpisodeRow(
              episode: ep,
              watched: watched,
              onToggle: () => onToggleEpisode(ep.seasonNumber, ep.episodeNumber),
            );
          }).toList(),
        );
      },
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  final Episode episode;
  final bool watched;
  final VoidCallback onToggle;

  const _EpisodeRow({
    required this.episode,
    required this.watched,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 80,
                height: 50,
                child: episode.stillUrl != null
                    ? Image.network(
                        episode.stillUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.white10),
                      )
                    : Container(
                        color: Colors.white10,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 20,
                          color: Colors.white38,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.code,
                    style: const TextStyle(
                      color: Color(0xFFFF8000),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    episode.name.isEmpty ? 'Sem título' : episode.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: watched,
              onChanged: (_) => onToggle(),
              activeColor: const Color(0xFFFF8000),
              checkColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
