import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tabkha_app/Features/Authentication/Views/forgot_password_view.dart';
import 'package:tabkha_app/Features/Authentication/Views/sign_up_view.dart';
import 'package:tabkha_app/Features/Authentication/authentication_view_model.dart';
import 'package:tabkha_app/Features/Food/Widgets/food_ui.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';
import 'package:tabkha_app/Features/Food/food_strings.dart';
import 'package:tabkha_app/Features/Home/Views/app_shell.dart';
import 'package:tabkha_app/Localization/app_localization_context.dart';
import 'package:tabkha_app/Services/navigation_services.dart';
import 'package:tabkha_app/constants/app_colors.dart';
import 'package:tabkha_app/constants/app_status_enum.dart';

const _green = AppColors.greenBackground;

/// Sign in with Firebase, continue as a guest, or open a demo account for
/// any of the three sides of the app.
class LoginView extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enterAs(AppRole role) {
    ref.read(foodProvider.notifier).setRole(role);
    NavigationsServices.pushReplacementNamed(context, HomeView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final form = _form(context);
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: wide
            ? Row(children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: form),
                    ),
                  ),
                ),
              ])
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(children: [
                      Image.asset('assets/images/tabkha_logo_1.png', height: 150),
                      const SizedBox(height: 8),
                      form,
                    ]),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final auth = provider.Provider.of<AuthenticationViewModel>(context);
    InputDecoration field(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        );
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(context.t('Welcome back'), style: titleStyle.copyWith(fontSize: 28)),
        const SizedBox(height: 6),
        Text(context.t('Sign in to order, track and review.'), style: bodyStyle),
        const SizedBox(height: 22),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: field(context.loc.email, Icons.mail_outline_rounded),
          validator: (v) {
            if (v == null || v.isEmpty) return context.loc.pleaseEnterYourEmail;
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return context.loc.pleaseEnterValidEmail;
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _password,
          obscureText: _hidden,
          autofillHints: const [AutofillHints.password],
          decoration: field(
            context.loc.password,
            Icons.lock_outline_rounded,
            suffix: IconButton(
              tooltip: _hidden ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _hidden = !_hidden),
              icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
          validator: (v) => (v == null || v.isEmpty) ? context.loc.pleaseEnterYourPassword : null,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () => NavigationsServices.pushNamed(context, ForgotPasswordView.routeName),
            child: Text(context.loc.forgotPassword),
          ),
        ),
        SizedBox(
          height: 54,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: auth.status == Status.loading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      auth.login(_email.text.trim(), _password.text, context);
                    }
                  },
            child: auth.status == Status.loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(context.loc.login, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: _green,
            side: const BorderSide(color: _green),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => _enterAs(AppRole.customer),
          icon: const Icon(Icons.restaurant_menu_rounded),
          label: Text(context.loc.continueAsGuest, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(context.t('Try a demo account'), style: bodyStyle.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 12),
        for (final (role, icon, note) in const [
          (AppRole.customer, Icons.person_outline_rounded, 'Order food, track it and leave reviews'),
          (AppRole.restaurantAdmin, Icons.storefront_outlined, 'Run Koshary El Tahrir: orders, menu, reviews'),
          (AppRole.superAdmin, Icons.admin_panel_settings_outlined, 'Approve restaurants and watch the platform'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Panel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () => _enterAs(role),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: _green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: _green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(context.t(role.label), style: titleStyle.copyWith(fontSize: 14.5)),
                    Text(context.t(note), style: bodyStyle.copyWith(fontSize: 12)),
                  ]),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: inkMuted),
              ]),
            ),
          ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(context.loc.dontHaveAnAccount, style: bodyStyle.copyWith(fontSize: 13)),
          TextButton(
            onPressed: () => NavigationsServices.pushNamed(context, SignUpView.routeName),
            child: Text(context.loc.createAnAccount),
          ),
        ]),
      ]),
    );
  }
}

/// The left half on wide screens: brand, promise and what's inside.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_green, Color(0xFF14513A)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tabkha', style: TextStyle(fontFamily: 'Lobster', fontSize: 40, color: Colors.white)),
        const Spacer(),
        Text(context.t('Hungry? Home-style food,\ndelivered hot.'),
            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 40, height: 1.1, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 28),
        for (final (icon, text) in const [
          (Icons.delivery_dining_rounded, 'Restaurants near you, delivered hot'),
          (Icons.menu_book_rounded, 'Recipes with ingredients and steps'),
          (Icons.translate_rounded, 'English and Arabic'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 12),
              Text(context.t(text), style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 16)),
            ]),
          ),
        const Spacer(),
      ]),
    );
  }
}
