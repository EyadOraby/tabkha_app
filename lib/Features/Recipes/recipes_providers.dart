import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Recipes/Models/meal.dart';
import 'package:tabkha_app/Features/Recipes/Services/meal_api.dart';
import 'package:tabkha_app/Services/caching_service.dart';

final mealApiProvider = Provider<MealApi>((ref) => MealApi());

final categoriesProvider = FutureProvider<List<MealCategory>>(
  (ref) => ref.watch(mealApiProvider).categories(),
);

/// The category chip that is selected on the home screen.
class SelectedCategory extends Notifier<String> {
  @override
  String build() => 'Chicken';

  void select(String category) => state = category;
}

final selectedCategoryProvider = NotifierProvider<SelectedCategory, String>(SelectedCategory.new);

/// What the visitor typed in the search box (already trimmed).
class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query.trim();
}

final searchQueryProvider = NotifierProvider<SearchQuery, String>(SearchQuery.new);

/// The grid on the home screen: search results while searching,
/// otherwise the selected category.
final mealsProvider = FutureProvider<List<MealSummary>>((ref) {
  final api = ref.watch(mealApiProvider);
  final query = ref.watch(searchQueryProvider);
  if (query.isNotEmpty) return api.search(query);
  return api.byCategory(ref.watch(selectedCategoryProvider));
});

final mealProvider = FutureProvider.family<Meal?, String>(
  (ref, id) => ref.watch(mealApiProvider).meal(id),
);

const favoritesKey = 'FAVORITE_MEALS';

/// Favourite recipe ids, saved in Hive so they survive restarts.
class Favorites extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final saved = ref.watch(cachingServiceProvider).get(favoritesKey);
    return saved is List ? saved.cast<String>().toSet() : <String>{};
  }

  void toggle(String id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
    ref.read(cachingServiceProvider).put(favoritesKey, state.toList());
  }
}

final favoritesProvider = NotifierProvider<Favorites, Set<String>>(Favorites.new);
