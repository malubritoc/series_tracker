class Episode {
  final int id;
  final String name;
  final int episodeNumber;
  final int seasonNumber;
  final String overview;
  final String? stillPath;
  final String airDate;

  const Episode({
    required this.id,
    required this.name,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.overview,
    required this.stillPath,
    required this.airDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      episodeNumber: json['episode_number'] as int,
      seasonNumber: json['season_number'] as int,
      overview: (json['overview'] as String?) ?? '',
      stillPath: json['still_path'] as String?,
      airDate: (json['air_date'] as String?) ?? '',
    );
  }

  String? get stillUrl =>
      stillPath == null ? null : 'https://image.tmdb.org/t/p/w300$stillPath';

  String get code => 'S${seasonNumber}E$episodeNumber';

  String get watchedKey => '$seasonNumber.$episodeNumber';
}
