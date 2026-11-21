import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tabkha_app/Features/Home/Views/home_view.dart';
import 'package:tabkha_app/Features/Recipes/Models/meal.dart';
import 'package:tabkha_app/Features/Recipes/Services/meal_api.dart';
import 'package:tabkha_app/Features/Recipes/Views/meal_details_view.dart';
import 'package:tabkha_app/deep_links.dart';

void main() {
  group('Meal.fromJson', () {
    test('keeps only filled ingredients, with their measures', () {
      final meal = Meal.fromJson({
        'idMeal': '1',
        'strMeal': ' Koshari ',
        'strMealThumb': 'https://example.com/k.jpg',
        'strCategory': 'Vegetarian',
        'strArea': 'Egyptian',
        'strInstructions': 'Boil the lentils.\r\n\r\nFry the onions.',
        'strIngredient1': 'Lentils',
        'strMeasure1': '1 cup',
        'strIngredient2': '',
        'strIngredient3': 'Onions',
        'strMeasure3': null,
        'strYoutube': '',
      });
      expect(meal.name, 'Koshari');
      expect(meal.ingredients.map((i) => i.name), ['Lentils', 'Onions']);
      expect(meal.ingredients.first.measure, '1 cup');
      expect(meal.ingredients.last.measure, '');
      expect(meal.steps, ['Boil the lentils.', 'Fry the onions.']);
      expect(meal.videoUrl, isNull);
    });

    test('drops step headings and numbering', () {
      expect(
        Meal.splitSteps('STEP 1\r\nChop.\r\nstep 2: Stir.\r\n3. Serve.\r\n.'),
        ['Chop.', 'Stir.', 'Serve.'],
      );
    });
  });

  group('MealApi', () {
    test('reads meals for a category', () async {
      final api = MealApi(
        client: MockClient((request) async {
          expect(request.url.path, endsWith('/filter.php'));
          expect(request.url.queryParameters['c'], 'Seafood');
          return http.Response(
            jsonEncode({
              'meals': [
                {'idMeal': '7', 'strMeal': 'Fish pie', 'strMealThumb': 't.jpg'},
              ],
            }),
            200,
          );
        }),
      );
      final meals = await api.byCategory('Seafood');
      expect(meals.single.name, 'Fish pie');
    });

    test('treats "meals": null as no results', () async {
      final api = MealApi(client: MockClient((_) async => http.Response('{"meals":null}', 200)));
      expect(await api.search('zzz'), isEmpty);
      expect(await api.meal('0'), isNull);
    });

    test('turns server errors into a friendly exception', () async {
      final api = MealApi(client: MockClient((_) async => http.Response('oops', 500)));
      expect(api.categories(), throwsA(isA<MealApiException>()));
    });
  });

  group('deep links', () {
    test('open the home screen or a recipe', () {
      expect(deepLinkedScreen(Uri.parse('https://x.test/?screen=home')), isA<HomeView>());
      expect(
        deepLinkedScreen(Uri.parse('https://x.test/?screen=recipe&id=52772')),
        isA<MealDetailsView>(),
      );
    });

    test('ignore unknown screens and recipes without an id', () {
      expect(deepLinkedScreen(Uri.parse('https://x.test/?screen=nope')), isNull);
      expect(deepLinkedScreen(Uri.parse('https://x.test/?screen=recipe')), isNull);
    });
  });
}
