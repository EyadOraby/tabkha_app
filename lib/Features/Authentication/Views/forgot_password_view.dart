import 'package:material_ui/material_ui.dart';
import 'package:tabkha_app/Features/Authentication/Views/login_view.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/common/custom_text_form_field.dart';
import 'package:tabkha_app/constants/app_colors.dart';
import 'package:tabkha_app/constants/app_status_enum.dart';

class ForgotPasswordView extends StatefulWidget {
  static const String routeName = '/forgotpassword';
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final AuthenticationViewModel authViewModel = AuthenticationViewModel();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final node = FocusScope.of(context);

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
            const SizedBox(height: 12),
            Text(
              '${context.loc.forgot.toUpperCase()}\n${context.loc.password.toUpperCase()}',
              style: TextStyle(
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
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
              horizontal: size.width * 0.05, vertical: size.height * 0.02),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.02),
                Stack(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: size.width * 0.3,
                      color: AppColors.errorColor,
                    ),
                    Positioned(
                      top: size.height * 0.03,
                      left: size.width * 0.075,
                      child: Icon(
                        Icons.lock_rounded,
                        size: size.width * 0.15,
                        color: AppColors.errorColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  context.loc.troubleLoggingIn,
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  context.loc.enterEmailForPasswordReset,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.03,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: size.height * 0.03),
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
                SizedBox(height: size.height * 0.03),
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
                              authViewModel.resetPassword(
                                _emailController.text,
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
                            context.loc.resetPassword,
                            style: TextStyle(
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                ),
                SizedBox(height: size.height * 0.03),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(LoginView.routeName);
                  },
                  child: Text(
                    context.loc.returnToLoginPage,
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      fontFamily: 'Nunito',
                      color: AppColors.primaryColor,
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
