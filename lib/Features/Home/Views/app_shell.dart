import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
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
      AppRole.restaurantAdmin => const RestaurantAdminView(),
      AppRole.superAdmin => const SuperAdminView(),
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
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [DiscoverView(), RecipesView(), MyOrdersView(), AccountView()],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: green.withValues(alpha: 0.14),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.delivery_dining_outlined), selectedIcon: Icon(Icons.delivery_dining), label: 'Order food'),
          const NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Recipes'),
          NavigationDestination(
            icon: Badge(isLabelVisible: active > 0, label: Text('$active'), child: const Icon(Icons.receipt_long_outlined)),
            selectedIcon: const Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
