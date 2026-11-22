import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/common/custom_text_form_field.dart';
import 'package:tabkha_app/constants/app_colors.dart';
import 'package:tabkha_app/constants/app_status_enum.dart';

class SignUpView extends StatefulWidget {
  static const String routeName = '/signup';
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late AuthenticationViewModel authViewModel;

  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final node = FocusScope.of(context);
    authViewModel = Provider.of<AuthenticationViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.17,
        automaticallyImplyLeading: false,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        backgroundColor: AppColors.greenBackground,
        foregroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_circle_left_rounded,
                    size: size.width * 0.1,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.menu_rounded,
                  size: size.width * 0.1,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              '${context.loc.createYour.toUpperCase()}\n${context.loc.account.toUpperCase()}',
              style: TextStyle(
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 1),
                  ),
                ],
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w600,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.backGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.07, vertical: size.height * 0.02),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: size.height * 0.005,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: context.loc.email,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  fillColor: AppColors.white,
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
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: _nameController,
                  hintText: context.loc.fullName,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  fillColor: AppColors.white,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.loc.pleaseEnterYourName;
                    }
                    return null;
                  },
                  onEditingComplete: () => node.nextFocus(),
                ),
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: _usernameController,
                  hintText: context.loc.username,
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  fillColor: AppColors.white,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.loc.pleaseEnterYourUserName;
                    }
                    return null;
                  },
                  onEditingComplete: () => node.nextFocus(),
                ),
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: _passwordController,
                  hintText: context.loc.password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureText,
                  textInputAction: TextInputAction.next,
                  fillColor: AppColors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
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
                  onEditingComplete: () => node.nextFocus(),
                ),
                SizedBox(height: size.height * 0.02),
                CustomTextFormField(
                  controller: _confirmPasswordController,
                  hintText: context.loc.repeatPassword,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmText,
                  textInputAction: TextInputAction.done,
                  fillColor: AppColors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.greyColor,
                      size: size.width * 0.06,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmText = !_obscureConfirmText;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.loc.pleaseConfirmYourPassword;
                    }
                    if (value != _passwordController.text) {
                      return context.loc.passwordsDoNotMatch;
                    }
                    return null;
                  },
                  onEditingComplete: () => node.unfocus(),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: size.width * 0.85,
                  height: size.height * 0.06,
                  child: authViewModel.status == Status.loading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : FilledButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              authViewModel.signUp(
                                _emailController.text,
                                _passwordController.text,
                                _nameController.text,
                                _usernameController.text,
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
                            context.loc.createAccount,
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                            ),
                          ),
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
