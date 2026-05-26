class Series {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String firstAirDate;

  const Series({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.firstAirDate,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      firstAirDate: (json['first_air_date'] as String?) ?? '',
    );
  }

  String? get posterUrl =>
      posterPath == null ? null : 'https://image.tmdb.org/t/p/w500$posterPath';
}
