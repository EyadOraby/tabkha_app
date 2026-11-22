import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tabkha_app/Features/Authentication/Views/language_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/login_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/onboarding_view.dart';
import 'package:tabkha_app/Features/Home/Views/app_shell.dart';
import 'package:tabkha_app/Features/Recipes/Models/meal.dart';
import 'package:tabkha_app/Features/Recipes/Views/meal_details_view.dart';
import 'package:tabkha_app/Features/Food/Views/admin_views.dart' deferred as admin;
import 'package:tabkha_app/Features/Food/Views/courier_view.dart' deferred as courier;
import 'package:tabkha_app/Features/Food/Views/customer_views.dart';
import 'package:tabkha_app/Features/Home/Views/home_view.dart';
import 'package:tabkha_app/deferred_view.dart';

/// Screens the web demo can open directly, e.g. `?screen=home` or
/// `?screen=recipe&id=52772`.
Widget? deepLinkedScreen([Uri? url]) {
  if (!kIsWeb && url == null) return null;
  final params = (url ?? Uri.base).queryParameters;
  switch (params['screen']) {
    case 'language':
      return const LanguageView();
    case 'login':
      return const LoginView();
    case 'onboarding':
      return OnboardingView();
    case 'home':
      return const HomeView();
    case 'recipes':
      return const Scaffold(body: SafeArea(child: RecipesView()));
    case 'orders':
      return const HomeView(initialTab: 2);
    case 'account':
      return const HomeView(initialTab: 3);
    case 'restaurant':
      return RestaurantView(restaurantId: params['id'] ?? 'r1');
    case 'admin':
      return DeferredView(load: admin.loadLibrary, builder: () => admin.RestaurantAdminView());
    case 'courier':
      return DeferredView(load: courier.loadLibrary, builder: () => courier.CourierView());
    case 'superadmin':
      return DeferredView(load: admin.loadLibrary, builder: () => admin.SuperAdminView());
    case 'recipe':
      final id = params['id'];
      if (id == null || id.isEmpty) return null;
      return MealDetailsView(summary: MealSummary(id: id, name: '', thumbnail: ''));
    default:
      return null;
  }
}
