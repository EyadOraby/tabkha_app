# Tabkha

*Made with love.* A bilingual (English and Arabic) food app with three sides: customers order from restaurants and cook from recipes, restaurant admins run their kitchen, and platform admins run the marketplace.

**Try it in the browser:** [eyadoraby.github.io/tabkha_app](https://eyadoraby.github.io/tabkha_app/)

## Features

**Customers**
- Discover restaurants: search by restaurant or dish, cuisine filters, ratings, delivery time and fee, open or closed
- Restaurant pages with a hero photo, the menu by section, sold-out dishes and reviews
- One-restaurant basket, delivery address, cash on delivery and a live order timeline (placed, accepted, preparing, on the way, delivered)
- Cancel before cooking starts; rate and review delivered orders
- Recipes from [TheMealDB](https://www.themealdb.com) with ingredients, steps and favourites
- English and Arabic with live switching and right-to-left layouts; continue as a guest or sign in with Firebase Auth

**Restaurant admin** (`?screen=admin`)
- Overview: open/closed switch, active orders, revenue, rating and dish availability
- Orders board: accept or reject, start preparing, hand to the driver, mark delivered
- Menu: mark dishes sold out, add new dishes; reviews with the average rating

**Super admin** (`?screen=superadmin`)
- Platform KPIs: live restaurants, approvals waiting, orders and gross sales
- Approve, list or suspend restaurants; sales ranking; a table of every order

The admin consoles are responsive: a navigation rail on wide screens makes them a web dashboard, and a bottom bar on phones. In the app, switch roles from **Account → View the app as**.

## Architecture

```
lib/
  Features/
    Food/            restaurants, menus, orders, reviews; FoodStore (Riverpod) with Hive persistence; customer and admin views
    Authentication/  splash, language, onboarding, sign in and up (Provider view model + Firebase Auth)
    Home/            recipes home
    Recipes/         Models (Meal, MealCategory), Services (MealApi), Views, Widgets, providers
  Services/          Hive caching and preferences (Riverpod with code generation)
  Localization/      ARB files and generated localizations
```

Recipe state lives in Riverpod providers: the selected category and search query are notifiers, and the meal grid is a `FutureProvider` that switches between search results and the category. `MealApi` takes an injectable HTTP client, so tests run against a mock client.

## Running it

```bash
flutter pub get
dart run build_runner build -d   # after changing annotated providers or Hive models
flutter run
```

On the web, `?screen=home`, `?screen=login` or `?screen=recipe&id=52772` opens a screen directly.

## Tests and CI

`flutter test` covers recipe parsing (ingredients, measures, steps), the API client against a mock HTTP client, and deep links. GitHub Actions runs analyze, tests and a web build on every pull request.
