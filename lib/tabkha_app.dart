// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/deep_links.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tabkha_app/Features/Authentication/Views/forgot_password_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/language_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/login_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/onboarding_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/sign_up_view.dart';
import 'package:tabkha_app/Features/Home/Views/app_shell.dart';
import 'package:tabkha_app/Services/preferences_service.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';
import 'package:tabkha_app/constants/app_colors.dart';
import 'package:tabkha_app/constants/app_constants.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Features/Authentication/Views/splash_view.dart';
import 'package:tabkha_app/Localization/app_localizations.dart';

class TabkhaApp extends ConsumerStatefulWidget {
  const TabkhaApp({super.key});
  static BuildContext? appBuildContext;
  static bool isLangChanged = false;
  @override
  ConsumerState<TabkhaApp> createState() => _TabkhaAppState();
}

class _TabkhaAppState extends ConsumerState<TabkhaApp> {
  AuthenticationViewModel authenticationViewModel = AuthenticationViewModel();

  GlobalKey<NavigatorState>? navigatorKey = GlobalKey();
  late Future myFuture;

  @override
  void initState() {
    AppConstants.navigatorKey = navigatorKey;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesStateProvider);

    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider.value(
          value: authenticationViewModel,
        ),
      ],
      child: provider.Consumer<AuthenticationViewModel>(
        builder: (ctx, auth, _) => MaterialApp(
          // `?lang=ar` or `?lang=en` on the web overrides the saved language.
          locale: switch (Uri.base.queryParameters['lang']) {
            'ar' => const Locale('ar'),
            'en' => const Locale('en'),
            _ => preferences.language == LanguageCodeEnum.ar ? const Locale('ar') : const Locale('en'),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          title: 'Tabkha',
          theme: ThemeData(
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: AppColors.primaryColor,
                ),
            primaryColor: AppColors.primaryColor,
            focusColor: AppColors.primaryColor,
            appBarTheme: const AppBarTheme(
              foregroundColor: AppColors.primaryColor,
              backgroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.light,
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent),
            ),
          ),
          home: deepLinkedScreen() ?? SplashView(),
          navigatorKey: navigatorKey,
          routes: {
            SplashView.routeName: (ctx) => SplashView(),
            LoginView.routeName: (ctx) => const LoginView(),
            LanguageView.routeName: (ctx) => const LanguageView(),
            SignUpView.routeName: (ctx) => const SignUpView(),
            ForgotPasswordView.routeName: (ctx) => const ForgotPasswordView(),
            OnboardingView.routeName: (ctx) => OnboardingView(),
            HomeView.routeName: (ctx) => const HomeView(),
          },
        ),
      ),
    );
  }
}
