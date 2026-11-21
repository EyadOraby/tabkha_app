import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tabkha_app/Features/Recipes/Models/meal.dart';

/// Thrown when recipes cannot be loaded.
class MealApiException implements Exception {
  final String message;
  const MealApiException(this.message);

  @override
  String toString() => message;
}

/// A small client for TheMealDB (https://www.themealdb.com/api.php).
class MealApi {
  MealApi({http.Client? client, this.baseUrl = 'https://www.themealdb.com/api/json/v1/1'})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$baseUrl/$path').replace(queryParameters: query);
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const MealApiException('Could not reach the recipe service.');
    }
    if (response.statusCode != 200) {
      throw MealApiException('The recipe service returned ${response.statusCode}.');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> body, String key) =>
      ((body[key] as List?) ?? const []).cast<Map<String, dynamic>>();

  Future<List<MealCategory>> categories() async =>
      _list(await _get('categories.php'), 'categories').map(MealCategory.fromJson).toList();

  Future<List<MealSummary>> byCategory(String category) async =>
      _list(await _get('filter.php', {'c': category}), 'meals').map(MealSummary.fromJson).toList();

  Future<List<MealSummary>> search(String query) async =>
      _list(await _get('search.php', {'s': query}), 'meals').map(MealSummary.fromJson).toList();

  Future<Meal?> meal(String id) async {
    final meals = _list(await _get('lookup.php', {'i': id}), 'meals');
    return meals.isEmpty ? null : Meal.fromJson(meals.first);
  }
}
