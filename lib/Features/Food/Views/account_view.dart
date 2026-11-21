import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Authentication/Views/login_view.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/Features/Food/Views/customer_views.dart';
import 'package:tabkha_app/Features/Food/Widgets/food_ui.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';
import 'package:tabkha_app/Features/Food/food_strings.dart';
import 'package:tabkha_app/Services/navigation_services.dart';
import 'package:tabkha_app/Services/preferences_service.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';

/// Profile, stats, demo roles, language and support. One column on phones,
/// two on tablets and desktops.
class AccountView extends ConsumerWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final prefs = ref.watch(preferencesStateProvider);
    final mine = food.myOrders;
    final delivered = mine.where((o) => o.status == OrderStatus.delivered).toList();
    final spent = delivered.fold<double>(0, (s, o) => s + o.total);
    final reviews = food.reviews.where((r) => r.author == 'You').length;

    final profile = Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(colors: [green, Color(0xFF14513A)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.t('Demo customer'),
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              const Text('6 Ibn Malek St, Giza', style: TextStyle(fontFamily: 'Montserrat', color: Colors.white70)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          _Stat('${mine.length}', context.t('Orders')),
          _Stat(egp(spent), context.t('Spent')),
          _Stat('$reviews', context.t('Reviews')),
        ]),
      ]),
    );

    final roles = _Section(
      title: context.t('View the app as'),
      subtitle: context.t('Demo mode: switch sides to see the whole product.'),
      child: Column(children: [
        for (final (role, icon) in const [
          (AppRole.customer, Icons.person_outline_rounded),
          (AppRole.restaurantAdmin, Icons.storefront_outlined),
          (AppRole.superAdmin, Icons.admin_panel_settings_outlined),
        ])
          _Tile(
            icon: icon,
            title: context.t(role.label),
            selected: food.role == role,
            onTap: () => ref.read(foodProvider.notifier).setRole(role),
          ),
      ]),
    );

    final settings = _Section(
      title: context.t('Preferences'),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            const Icon(Icons.translate_rounded, color: inkMuted),
            const SizedBox(width: 12),
            Expanded(child: Text(context.t('Language'), style: titleStyle.copyWith(fontSize: 14.5))),
            SegmentedButton<LanguageCodeEnum>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: green.withValues(alpha: 0.14),
                selectedForegroundColor: green,
              ),
              segments: const [
                ButtonSegment(value: LanguageCodeEnum.en, label: Text('English')),
                ButtonSegment(value: LanguageCodeEnum.ar, label: Text('العربية')),
              ],
              selected: {prefs.language},
              onSelectionChanged: (s) =>
                  ref.read(preferencesStateProvider.notifier).updatePreferences(languageCodeEnum: s.first),
            ),
          ]),
        ),
        _Tile(icon: Icons.location_on_outlined, title: context.t('Saved address'), trailing: 'Giza'),
        _Tile(icon: Icons.payments_outlined, title: context.t('Payment'), trailing: context.t('Cash on delivery').trim()),
        _Tile(
          icon: Icons.restart_alt_rounded,
          title: context.t('Reset demo data'),
          onTap: () {
            ref.read(foodProvider.notifier).reset();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(behavior: SnackBarBehavior.floating, content: Text(context.t('Demo data restored'))),
            );
          },
        ),
        _Tile(
          icon: Icons.logout_rounded,
          title: context.t('Sign out'),
          danger: true,
          onTap: () => NavigationsServices.pushReplacementNamed(context, LoginView.routeName),
        ),
      ]),
    );

    final recent = _Section(
      title: context.t('Recent orders'),
      child: mine.isEmpty
          ? Text(context.t('No orders yet. Your first one is a few taps away.'), style: bodyStyle)
          : Column(children: [
              for (final o in mine.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OrderCard(order: o, restaurant: food.restaurant(o.restaurantId)),
                ),
            ]),
    );

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 840;
      return ListView(
        padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 16, wide ? 32 : 20, 28),
        children: [
          Text(context.t('Account'), style: titleStyle.copyWith(fontSize: 26)),
          const SizedBox(height: 16),
          if (wide)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(children: [profile, const SizedBox(height: 16), roles])),
              const SizedBox(width: 20),
              Expanded(child: Column(children: [settings, const SizedBox(height: 16), recent])),
            ])
          else ...[
            profile,
            const SizedBox(height: 16),
            roles,
            const SizedBox(height: 16),
            settings,
            const SizedBox(height: 16),
            recent,
          ],
        ],
      );
    });
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Colors.white70)),
        ]),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Panel(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: titleStyle.copyWith(fontSize: 16)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: bodyStyle.copyWith(fontSize: 12.5)),
          ],
          const SizedBox(height: 10),
          child,
        ]),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.trailing, this.onTap, this.selected = false, this.danger = false});
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? tomato : (selected ? green : ink);
    return Material(
      color: selected ? green.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Row(children: [
            Icon(icon, color: danger ? tomato : (selected ? green : inkMuted)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: titleStyle.copyWith(fontSize: 14.5, color: color))),
            if (trailing != null) Text(trailing!, style: bodyStyle.copyWith(fontSize: 13)),
            if (selected) const Icon(Icons.check_circle_rounded, color: green, size: 20),
            if (onTap != null && !selected && !danger) const Icon(Icons.chevron_right_rounded, color: inkMuted),
          ]),
        ),
      ),
    );
  }
}
