import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tabkha_app/Services/caching_service.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';
import 'package:tabkha_app/Localization/app_localizations.dart';
import 'package:tabkha_app/constants/app_theme.dart';
import 'package:tabkha_app/deep_links.dart';

/// Opens the main screens the way the web demo does (`?screen=`), in English
/// and Arabic, at phone and desktop widths, and fails on any layout overflow
/// or exception.
void main() {
  setUpAll(() async {
    // The app keeps preferences in a Hive box; open one in a temp folder.
    Hive.init(Directory.systemTemp.createTempSync('tabkha_test').path);
    Hive.registerAdapter(UserPreferencesAdapter());
    Hive.registerAdapter(LanguageCodeEnumAdapter());
    await Hive.openBox(userPreferences);
    Future<ByteData> load(String path) => File(path).readAsBytes().then((b) => ByteData.sublistView(b));
    for (final (family, file) in [
      ('Nunito', 'Nunito.ttf'),
      ('YoungSerif', 'YoungSerif.ttf'),
      ('Lalezar', 'Lalezar.ttf'),
      ('BalooBhaijaan2', 'BalooBhaijaan2.ttf'),
    ]) {
      await (FontLoader(family)..addFont(load('assets/fonts/brand/$file'))).load();
    }
  });

  final seed = File('assets/food_seed.json').readAsStringSync();
  const screens = ['home', 'orders', 'account', 'restaurant&id=r1', 'admin', 'superadmin', 'login'];

  for (final lang in ['en', 'ar']) {
    for (final size in [const Size(390, 844), const Size(1280, 800)]) {
      for (final screen in screens) {
        testWidgets('$screen renders ($lang, ${size.width.toInt()}px)', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          final page = deepLinkedScreen(Uri.parse('https://x.test/?screen=$screen'))!;
          await tester.runAsync(() async {
            await tester.pumpWidget(ProviderScope(
              overrides: [
                foodStorageProvider.overrideWithValue(MemoryFoodStorage()),
                // The app's provider closes the box on dispose; keep it open across tests.
                cachingServiceProvider.overrideWithValue(CachingService()),
                foodSeedProvider.overrideWithValue(() async => seed),
              ],
              child: provider.ChangeNotifierProvider(
                create: (_) => AuthenticationViewModel(),
                child: MaterialApp(
                  theme: tabkhaTheme(),
                  locale: Locale(lang),
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  home: page,
                ),
              ),
            ));
            await Future<void>.delayed(const Duration(milliseconds: 200));
          });
          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 200));
          }

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
