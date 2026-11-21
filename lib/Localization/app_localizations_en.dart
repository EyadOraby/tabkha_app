// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get hello => 'Hello';

  @override
  String get forgot => 'FORGOT';

  @override
  String get password => 'Password';

  @override
  String get troubleLoggingIn => 'Trouble Logging in?';

  @override
  String get enterEmailForPasswordReset =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get email => 'Email';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get returnToLoginPage => 'Return to Login Page';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get login => 'Login';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get createYour => 'Create your';

  @override
  String get account => 'account';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get username => 'Username';

  @override
  String get pleaseEnterYourUserName => 'Please enter your username';

  @override
  String get repeatPassword => 'Repeat Password';

  @override
  String get pleaseConfirmYourPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get createAccount => 'Create Account';

  @override
  String get location => 'Location';

  @override
  String get searchHere => 'Search here';

  @override
  String get signOut => 'Sign Out';

  @override
  String get whatToCook => 'What would you like to cook today?';

  @override
  String get searchRecipes => 'Search recipes';

  @override
  String get categories => 'Categories';

  @override
  String popularIn(String category) {
    return 'Popular in $category';
  }

  @override
  String resultsFor(String query) {
    return 'Results for “$query”';
  }

  @override
  String get noRecipesFound => 'No recipes found. Try another search.';

  @override
  String get couldNotLoadRecipes =>
      'Couldn\'t load recipes. Check your connection and try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get steps => 'Steps';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get addToFavorites => 'Add to favourites';

  @override
  String get removeFromFavorites => 'Remove from favourites';

  @override
  String get recipeNotFound => 'This recipe is no longer available.';
}
