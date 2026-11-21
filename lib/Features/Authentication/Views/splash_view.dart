// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tabkha_app/Features/Authentication/Views/language_view.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Features/Home/Views/home_view.dart';
import 'package:tabkha_app/Services/navigation_services.dart';
import 'package:tabkha_app/constants/app_colors.dart';

class SplashView extends StatefulWidget {
  static const routeName = '/splash';
  final AuthenticationViewModel authenticationViewModel =
      AuthenticationViewModel();
  SplashView({super.key});

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.isAnonymous) {
        NavigationsServices.pushReplacementNamed(context, HomeView.routeName);
      } else {
        NavigationsServices.pushReplacementNamed(
            context, LanguageView.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Image.asset(
          'assets/images/tabkha_logo_1.png',
          scale: 2,
        ),
      ),
    );
  }
}
