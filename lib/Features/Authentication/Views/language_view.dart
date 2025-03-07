import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Authentication/Views/login_view.dart';
import 'package:tabkha_app/Services/navigation_services.dart';
import 'package:tabkha_app/Services/preferences_service.dart';
import 'package:tabkha_app/common/flash_widgets.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';
import 'package:tabkha_app/constants/app_colors.dart';

class LanguageView extends ConsumerWidget {
  static const routeName = '/language';
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.greenBackground,
          ),
          Container(
            width: double.infinity,
            height: size.height * 0.7,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/tabkha_logo_1.png',
                scale: 2.5,
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.15,
            right: size.width * 0.1,
            child: Container(
              height: size.height * 0.3,
              width: size.width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.greenBackground,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {
                      ref
                          .read(preferencesStateProvider.notifier)
                          .updatePreferences(
                            languageCodeEnum: LanguageCodeEnum.en,
                          );
                      FlashWidgets.showSuccessBar(
                          context: context,
                          message: "Application Language was set to English");
                      NavigationsServices.pushReplacementNamed(
                          context, LoginView.routeName);
                    },
                    child: SizedBox(
                      width: size.width * 0.5,
                      height: size.height * 0.05,
                      child: Center(
                        child: Text(
                          'English',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Montserrat",
                          ),
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.greenBackground,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: () {
                      ref
                          .read(preferencesStateProvider.notifier)
                          .updatePreferences(
                            languageCodeEnum: LanguageCodeEnum.ar,
                          );
                      FlashWidgets.showSuccessBar(
                          context: context,
                          message: "تم ضبط لغة التطبيق على اللغة العربية");
                      NavigationsServices.pushReplacementNamed(
                          context, LoginView.routeName);
                    },
                    child: SizedBox(
                      width: size.width * 0.5,
                      height: size.height * 0.05,
                      child: Center(
                        child: Text(
                          'عربي',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Montserrat",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
