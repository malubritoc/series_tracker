class Series {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String firstAirDate;

  final List<String>? genres;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final String? status;
  final String? tagline;

  const Series({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.firstAirDate,
    this.genres,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.status,
    this.tagline,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'] as List<dynamic>?;
    return Series(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      firstAirDate: (json['first_air_date'] as String?) ?? '',
      genres: rawGenres
          ?.map((g) => (g as Map<String, dynamic>)['name'] as String)
          .toList(),
      numberOfSeasons: json['number_of_seasons'] as int?,
      numberOfEpisodes: json['number_of_episodes'] as int?,
      status: json['status'] as String?,
      tagline: json['tagline'] as String?,
    );
  }

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';

  String get yearLabel =>
      firstAirDate.length >= 4 ? firstAirDate.substring(0, 4) : '';
}
