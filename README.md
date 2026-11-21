# Tabkha

*Made with love.* A Flutter cooking app in English and Arabic: browse recipes by category, search, open a recipe for its ingredients and steps, and keep favourites.
**Try it in the browser:** [eyadoraby.github.io/tabkha_app](https://eyadoraby.github.io/tabkha_app/)


## Features

- **Recipes from [TheMealDB](https://www.themealdb.com)**: categories, search and full recipes with ingredients, measures and numbered steps
- **Favourites** saved on the device with Hive, so they survive restarts
- **English and Arabic** with a language picker, live switching and right-to-left layouts
- **Accounts** with Firebase Auth (sign up, sign in, password reset), or **continue as a guest**
- Onboarding, loading placeholders, pull to refresh and friendly errors with retry
- Responsive grid that adds columns on tablets and the web

## Architecture

```
lib/
  Features/
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
