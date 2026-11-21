import 'package:flutter/material.dart';
import 'package:tabkha_app/Features/Food/food_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/Features/Food/Views/account_view.dart';
import 'package:tabkha_app/Features/Food/Views/admin_views.dart';
import 'package:tabkha_app/Features/Food/Views/customer_views.dart';
import 'package:tabkha_app/Features/Food/Widgets/food_ui.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';
import 'package:tabkha_app/Features/Home/Views/home_view.dart';

/// The signed-in app. Customers get food delivery and recipes; restaurant
/// and platform admins get their consoles.
class HomeView extends ConsumerWidget {
  static const String routeName = '/home';
  const HomeView({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(foodProvider.select((s) => s.role));
    return switch (role) {
      AppRole.customer => CustomerShell(initialTab: initialTab),
      AppRole.restaurantAdmin => RestaurantAdminView(),
      AppRole.superAdmin => SuperAdminView(),
    };
  }
}

class CustomerShell extends ConsumerStatefulWidget {
  const CustomerShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends ConsumerState<CustomerShell> {
  late int _index = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(foodProvider.select((s) => s.myOrders.where((o) => o.status.isActive).length));
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final tabs = [
      (Icons.delivery_dining_outlined, Icons.delivery_dining, context.t('Order food'), 0),
      (Icons.menu_book_outlined, Icons.menu_book, context.t('Recipes'), 0),
      (Icons.receipt_long_outlined, Icons.receipt_long, context.t('Orders'), active),
      (Icons.person_outline, Icons.person, context.t('Account'), 0),
    ];
    final body = IndexedStack(
      index: _index,
      children: const [DiscoverView(), RecipesView(), MyOrdersView(), AccountView()],
    );
    if (wide) {
      return Scaffold(
        backgroundColor: cream,
        body: SafeArea(
          child: Row(children: [
            NavigationRail(
              backgroundColor: Colors.white,
              extended: MediaQuery.sizeOf(context).width >= 1200,
              indicatorColor: green.withValues(alpha: 0.14),
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text('Tabkha', style: TextStyle(fontFamily: 'Lobster', fontSize: 26, color: green)),
              ),
              destinations: [
                for (final (icon, selected, label, badge) in tabs)
                  NavigationRailDestination(
                    icon: Badge(isLabelVisible: badge > 0, label: Text('$badge'), child: Icon(icon)),
                    selectedIcon: Icon(selected),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: body),
              ),
            ),
          ]),
        ),
      );
    }
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: green.withValues(alpha: 0.14),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final (icon, selected, label, badge) in tabs)
            NavigationDestination(
              icon: Badge(isLabelVisible: badge > 0, label: Text('$badge'), child: Icon(icon)),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}
