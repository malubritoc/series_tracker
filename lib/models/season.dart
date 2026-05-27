class Season {
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? posterPath;

  const Season({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    required this.posterPath,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonNumber: json['season_number'] as int,
      name: (json['name'] as String?) ?? '',
      episodeCount: (json['episode_count'] as int?) ?? 0,
      posterPath: json['poster_path'] as String?,
    );
  }
}
