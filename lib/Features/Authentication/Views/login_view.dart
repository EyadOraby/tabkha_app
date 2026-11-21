import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabkha_app/Features/Authentication/Views/forgot_password_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/onboarding_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/sign_up_view.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/Services/navigation_services.dart';
import 'package:tabkha_app/common/custom_text_form_field.dart';
import 'package:tabkha_app/constants/app_colors.dart';
import 'package:tabkha_app/constants/app_status_enum.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isChecked = false;
  late AuthenticationViewModel authViewModel;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final node = FocusScope.of(context);
    authViewModel = Provider.of<AuthenticationViewModel>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.greenBackground,
          ),
          Container(
            width: double.infinity,
            height: size.height * 0.65,
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
            bottom: size.height * 0.07,
            right: size.width * 0.1,
            child: Container(
              height: size.height * 0.45,
              width: size.width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    CustomTextFormField(
                      controller: _emailController,
                      hintText: context.loc.email,
                      prefixIcon: Icons.account_circle_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      width: size.width * 0.65,
                      iconSize: size.width * 0.07,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.loc.pleaseEnterYourEmail;
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return context.loc.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                      onEditingComplete: () => node.nextFocus(),
                    ),
                    Spacer(),
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: context.loc.password,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureText,
                      width: size.width * 0.65,
                      iconSize: size.width * 0.06,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.greyColor,
                          size: size.width * 0.06,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.loc.pleaseEnterYourPassword;
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.02),
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: 0.6,
                            child: Checkbox(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                              checkColor: AppColors.white,
                              value: _isChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isChecked = value ?? false;
                                });
                              },
                            ),
                          ),
                          Text(
                            context.loc.rememberMe,
                            style: TextStyle(
                              fontSize: size.width * 0.024,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryColor,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              NavigationsServices.pushNamed(
                                  context, ForgotPasswordView.routeName);
                            },
                            child: Text(
                              context.loc.forgotPassword,
                              style: TextStyle(
                                fontSize: size.width * 0.024,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.65,
                      height: size.height * 0.06,
                      child: authViewModel.status == Status.loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : FilledButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  authViewModel.login(
                                    _emailController.text,
                                    _passwordController.text,
                                    context,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.greenBackground,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                context.loc.login,
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => NavigationsServices.pushReplacementNamed(
                            context, OnboardingView.routeName),
                        icon: const Icon(Icons.restaurant_menu_rounded,
                            color: AppColors.greenBackground),
                        label: Text(
                          context.loc.continueAsGuest,
                          style: const TextStyle(
                            color: AppColors.greenBackground,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Row(
                        spacing: 0,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.loc.dontHaveAnAccount,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: size.width * 0.022,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              NavigationsServices.pushNamed(
                                  context, SignUpView.routeName);
                            },
                            child: Text(
                              context.loc.createAnAccount,
                              style: TextStyle(
                                fontSize: size.width * 0.022,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
