import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/secrets.dart';
import '../models/series.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $tmdbBearerToken',
        'Accept': 'application/json',
      };

  Future<List<Series>> fetchPopular({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/popular?language=pt-BR&page=$page'),
      headers: _headers,
    );
    _ensureOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((item) => Series.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Series> fetchDetail(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/$id?language=pt-BR'),
      headers: _headers,
    );
    _ensureOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Series.fromJson(data);
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('TMDB respondeu ${response.statusCode}');
    }
  }
}
