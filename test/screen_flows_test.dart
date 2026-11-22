import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tabkha_app/Features/Authentication/Views/forgot_password_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/onboarding_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/sign_up_view.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';
import 'package:tabkha_app/Localization/app_localizations.dart';
import 'package:tabkha_app/Localization/delegates.dart';
import 'package:tabkha_app/Services/caching_service.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';
import 'package:tabkha_app/constants/app_theme.dart';
import 'package:tabkha_app/deep_links.dart';

final _seed = File('assets/food_seed.json').readAsStringSync();

Future<void> pumpPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(430, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      foodStorageProvider.overrideWithValue(MemoryFoodStorage()),
      cachingServiceProvider.overrideWithValue(CachingService()),
      foodSeedProvider.overrideWithValue(() async => _seed),
    ],
    child: provider.ChangeNotifierProvider(
      create: (_) => AuthenticationViewModel(),
      child: MaterialApp(
        theme: tabkhaTheme(),
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: page,
      ),
    ),
  ));
  await tester.pump();
}

/// The text field showing [hint] as its placeholder.
Finder field(String hint) => find.ancestor(
      of: find.text(hint),
      matching: find.byType(TextFormField),
    );

void main() {
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('tabkha_auth_test').path);
    Hive.registerAdapter(UserPreferencesAdapter());
    Hive.registerAdapter(LanguageCodeEnumAdapter());
    await Hive.openBox(userPreferences);
    Future<ByteData> load(String path) =>
        File(path).readAsBytes().then((b) => ByteData.sublistView(b));
    for (final (family, file) in [
      ('Nunito', 'Nunito.ttf'),
      ('YoungSerif', 'YoungSerif.ttf'),
    ]) {
      await (FontLoader(family)..addFont(load('assets/fonts/brand/$file')))
          .load();
    }
  });

  orderFlowTests();

  testWidgets('sign-up asks for every field before creating an account',
      (tester) async {
    await pumpPage(tester, const SignUpView());

    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);

    await tester.enterText(field('Email'), 'mona');
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('sign-up catches passwords that do not match', (tester) async {
    await pumpPage(tester, const SignUpView());
    final password = find.byType(TextFormField).at(3);
    final repeat = find.byType(TextFormField).at(4);
    await tester.enterText(password, 'secret-one');
    await tester.enterText(repeat, 'secret-two');
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('forgot password checks the email first', (tester) async {
    await pumpPage(tester, const ForgotPasswordView());

    await tester.tap(find.text('Reset Password'));
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.tap(find.text('Reset Password'));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('onboarding steps through three pages to Get Started',
      (tester) async {
    await pumpPage(tester, const OnboardingView());
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void orderFlowTests() {
  testWidgets('a customer adds a dish, opens the basket and places the order',
      (tester) async {
    await tester.runAsync(() async {
      await pumpPage(
        tester,
        deepLinkedScreen(Uri.parse('https://x.test/?screen=restaurant&id=r1'))!,
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    final dish = find.text('Ful Medames').first;
    await tester.ensureVisible(dish);
    await tester.tap(dish);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Add 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View basket'));
    await tester.pumpAndSettle();
    expect(find.text('Your basket'), findsOneWidget);
    expect(find.text('Ful Medames'), findsWidgets);

    final place = find.textContaining('Place order');
    await tester.ensureVisible(place);
    await tester.tap(place);
    await tester.pumpAndSettle();
    expect(find.textContaining('Your food is being made with love'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
