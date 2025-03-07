import 'package:flutter/material.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/common/custom_text_form_field.dart';
import 'package:tabkha_app/constants/app_colors.dart';

class HomeView extends StatelessWidget {
  static const String routeName = '/home';
  HomeView({super.key});
  final AuthenticationViewModel authenticationViewModel =
      AuthenticationViewModel();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Tabkha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lobster",
                    color: AppColors.greenBackground,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: size.width * 0.11),
                    Text(
                      context.loc.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                        fontFamily: "Montserrat",
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.support_agent_rounded,
                        size: size.width * 0.11, color: AppColors.inkLight),
                    SizedBox(width: size.width * 0.025),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomTextFormField(
                      hintText: context.loc.searchHere,
                      hintStyle: TextStyle(fontSize: size.width * 0.035),
                      fillColor: AppColors.homeSearchFormTextField,
                      prefixIcon: Icons.search_rounded,
                      prefixIconColor: AppColors.black,
                      suffixIcon: Icon(Icons.mic_rounded),
                      controller: TextEditingController(),
                      width: size.width * 0.7,
                      height: size.height * 0.065,
                      iconSize: size.width * 0.07,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      onEditingComplete: () {},
                    ),
                    Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border:
                                Border.all(color: AppColors.greenBackground)),
                        child: Padding(
                          padding: EdgeInsets.all(size.width * 0.008),
                          child: Icon(Icons.tune_rounded,
                              color: AppColors.greenBackground,
                              size: size.width * 0.07),
                        )),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Container(
                  height: size.height * 0.22,
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.greenBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Culinary\n Journey Starts Here",
                              style: TextStyle(
                                fontSize: size.width * 0.045,
                                fontFamily: "Lobster",
                                color: AppColors.white,
                              ),
                            ),
                            SizedBox(height: size.height * 0.015),
                            SizedBox(
                              width: size.width * 0.5,
                              child: Text(
                                "Where every craving is met with an array of delightful options.",
                                style: TextStyle(
                                  fontSize: size.width * 0.03,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Image.asset(
                          "assets/images/home_image.png",
                          width: size.width * 0.3,
                          height: size.height * 0.2,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.22),
                Align(
                  alignment: Alignment.center,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.greenBackground,
                    ),
                    onPressed: () {
                      authenticationViewModel.logout(context);
                    },
                    child: Text(context.loc.signOut),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
