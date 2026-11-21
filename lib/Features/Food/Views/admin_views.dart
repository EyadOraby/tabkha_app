import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/Features/Food/Views/customer_views.dart';
import 'package:tabkha_app/Features/Food/Widgets/food_ui.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';

/// A destination in an admin console.
class AdminTab {
  final IconData icon;
  final String label;
  final Widget Function() build;
  const AdminTab(this.icon, this.label, this.build);
}

/// Responsive console: a navigation rail on wide screens (the web dashboard)
/// and a bottom bar on phones.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.title, required this.subtitle, required this.tabs});

  final String title;
  final String subtitle;
  final List<AdminTab> tabs;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final body = Container(
      color: cream,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(wide ? 32 : 18, wide ? 28 : 14, wide ? 32 : 18, 32),
          children: [
            Text(widget.subtitle.toUpperCase(),
                style: bodyStyle.copyWith(fontSize: 11.5, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.tabs[_index].label, style: titleStyle.copyWith(fontSize: wide ? 30 : 24)),
            const SizedBox(height: 18),
            widget.tabs[_index].build(),
          ],
        ),
      ),
    );
    if (wide) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(
            backgroundColor: Colors.white,
            extended: MediaQuery.sizeOf(context).width >= 1200,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            indicatorColor: green.withValues(alpha: 0.14),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(children: [
                const Text('Tabkha', style: TextStyle(fontFamily: 'Lobster', fontSize: 26, color: green)),
                Text(widget.title, style: bodyStyle.copyWith(fontSize: 11)),
              ]),
            ),
            destinations: [
              for (final t in widget.tabs) NavigationRailDestination(icon: Icon(t.icon), label: Text(t.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ]),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: green.withValues(alpha: 0.14),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [for (final t in widget.tabs) NavigationDestination(icon: Icon(t.icon), label: t.label)],
      ),
    );
  }
}

/// Lays KPI cards out in as many columns as fit.
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final columns = (c.maxWidth / 220).floor().clamp(2, 4);
        final w = (c.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(spacing: 14, runSpacing: 14, children: [for (final s in children) SizedBox(width: w, child: s)]);
      });
}

// Restaurant admin

class RestaurantAdminView extends StatelessWidget {
  const RestaurantAdminView({super.key});

  @override
  Widget build(BuildContext context) => AdminShell(
        title: 'Restaurant console',
        subtitle: 'Koshary El Tahrir',
        tabs: [
          AdminTab(Icons.space_dashboard_outlined, 'Overview', () => const _RestaurantOverview()),
          AdminTab(Icons.receipt_long_outlined, 'Orders', () => const _OrdersBoard(restaurantId: managedRestaurantId)),
          AdminTab(Icons.restaurant_menu_outlined, 'Menu', () => const _MenuManager()),
          AdminTab(Icons.reviews_outlined, 'Reviews', () => const _ReviewsList()),
          AdminTab(Icons.manage_accounts_outlined, 'Account', () => const _AdminAccount()),
        ],
      );
}

class _RestaurantOverview extends ConsumerWidget {
  const _RestaurantOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final r = food.restaurant(managedRestaurantId);
    if (r == null) return const SizedBox();
    final orders = food.ordersOf(r.id);
    final active = orders.where((o) => o.status.isActive).toList();
    final menu = food.menuOf(r.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SwitchListTile(
          title: Text(r.isOpen ? 'Open for orders' : 'Closed', style: titleStyle.copyWith(fontSize: 16)),
          subtitle: Text(r.isOpen ? 'Customers can order now' : 'Customers see you as closed', style: bodyStyle),
          value: r.isOpen,
          activeThumbColor: green,
          onChanged: (v) => ref.read(foodProvider.notifier).setOpen(r.id, v),
        ),
      ),
      const SizedBox(height: 14),
      StatGrid(children: [
        StatCard(icon: Icons.local_fire_department_outlined, label: 'Active orders', value: '${active.length}', color: saffron),
        StatCard(icon: Icons.payments_outlined, label: 'Revenue (delivered)', value: egp(food.revenueOf(orders))),
        StatCard(icon: Icons.star_outline_rounded, label: 'Rating', value: food.ratingOf(r.id).toStringAsFixed(1), color: saffron),
        StatCard(
          icon: Icons.restaurant_menu_outlined,
          label: 'Dishes available',
          value: '${menu.where((m) => m.available).length}/${menu.length}',
          color: const Color(0xFF5B8DEF),
        ),
      ]),
      const SectionTitle('Needs your attention'),
      if (active.isEmpty) Text('All caught up.', style: bodyStyle),
      for (final o in active.take(4))
        Padding(padding: const EdgeInsets.only(bottom: 10), child: _AdminOrderTile(order: o)),
    ]);
  }
}

class _OrdersBoard extends ConsumerWidget {
  const _OrdersBoard({required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(foodProvider).ordersOf(restaurantId)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    const columns = [
      ('New', [OrderStatus.placed]),
      ('In the kitchen', [OrderStatus.accepted, OrderStatus.preparing]),
      ('On the way', [OrderStatus.onTheWay]),
      ('Done', [OrderStatus.delivered, OrderStatus.cancelled]),
    ];
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 900;
      final groups = [
        for (final (title, statuses) in columns)
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('$title  ${orders.where((o) => statuses.contains(o.status)).length}', style: titleStyle.copyWith(fontSize: 15)),
            const SizedBox(height: 10),
            for (final o in orders.where((o) => statuses.contains(o.status)))
              Padding(padding: const EdgeInsets.only(bottom: 10), child: _AdminOrderTile(order: o)),
            const SizedBox(height: 14),
          ]),
      ];
      if (!wide) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: groups);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final g in groups) Expanded(child: Padding(padding: const EdgeInsets.only(right: 14), child: g))],
      );
    });
  }
}

class _AdminOrderTile extends ConsumerWidget {
  const _AdminOrderTile({required this.order});
  final FoodOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(foodProvider.notifier);
    final next = order.status.next;
    final minutes = DateTime.now().difference(order.createdAt).inMinutes;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(order.id, style: titleStyle.copyWith(fontSize: 14)),
          const Spacer(),
          StatusChip(order.status),
        ]),
        const SizedBox(height: 4),
        Text('${order.customer} · ${order.itemCount} items · ${egp(order.total)} · ${minutes < 60 ? '$minutes min ago' : '${minutes ~/ 60} h ago'}',
            style: bodyStyle.copyWith(fontSize: 12.5)),
        const SizedBox(height: 6),
        Text(order.lines.map((l) => '${l.quantity}× ${l.name}').join(', '),
            maxLines: 2, overflow: TextOverflow.ellipsis, style: bodyStyle.copyWith(fontSize: 12.5, color: ink)),
        if (next != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: green),
              onPressed: () => store.advanceOrder(order.id),
              child: Text(switch (next) {
                OrderStatus.accepted => 'Accept',
                OrderStatus.preparing => 'Start preparing',
                OrderStatus.onTheWay => 'Hand to driver',
                _ => 'Mark delivered',
              }),
            ),
            if (order.status == OrderStatus.placed) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => store.rejectOrder(order.id),
                child: const Text('Reject', style: TextStyle(color: tomato)),
              ),
            ],
          ]),
        ],
      ]),
    );
  }
}

class _MenuManager extends ConsumerWidget {
  const _MenuManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(foodProvider).menuOf(managedRestaurantId);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: green),
          onPressed: () => _addDish(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add a dish'),
        ),
      ),
      const SizedBox(height: 14),
      for (final m in menu)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Panel(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              SizedBox(width: 56, height: 56, child: NetImage(m.image, radius: 12)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.name, style: titleStyle.copyWith(fontSize: 14)),
                  Text('${m.section} · ${egp(m.price)}', style: bodyStyle.copyWith(fontSize: 12.5)),
                ]),
              ),
              Text(m.available ? 'Available' : 'Sold out', style: bodyStyle.copyWith(fontSize: 12)),
              Switch(
                value: m.available,
                activeThumbColor: green,
                onChanged: (_) => ref.read(foodProvider.notifier).toggleAvailability(m.id),
              ),
            ]),
          ),
        ),
    ]);
  }

  Future<void> _addDish(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final price = TextEditingController();
    var section = 'Mains';
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add a dish'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (EGP)')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: section,
              decoration: const InputDecoration(labelText: 'Section'),
              items: [for (final s in ['Popular', 'Mains', 'Sides & more']) DropdownMenuItem(value: s, child: Text(s))],
              onChanged: (v) => setState(() => section = v ?? section),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final p = double.tryParse(price.text);
                if (name.text.trim().isEmpty || p == null || p <= 0) return;
                ref.read(foodProvider.notifier).addMenuItem(
                      restaurantId: managedRestaurantId,
                      name: name.text,
                      price: p,
                      section: section,
                    );
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    price.dispose();
  }
}

class _ReviewsList extends ConsumerWidget {
  const _ReviewsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final reviews = food.reviewsOf(managedRestaurantId);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text(food.ratingOf(managedRestaurantId).toStringAsFixed(1), style: titleStyle.copyWith(fontSize: 40)),
        const SizedBox(width: 10),
        Text('from ${reviews.length} reviews', style: bodyStyle),
      ]),
      const SizedBox(height: 12),
      for (final r in reviews) Padding(padding: const EdgeInsets.only(bottom: 10), child: ReviewTile(review: r)),
    ]);
  }
}

class _AdminAccount extends ConsumerWidget {
  const _AdminAccount();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('View the app as', style: titleStyle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        RoleSwitcher(current: ref.watch(foodProvider).role),
        const SizedBox(height: 14),
        Panel(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: const Text('Reset demo data'),
            onTap: () => ref.read(foodProvider.notifier).reset(),
          ),
        ),
      ]);
}

// Super admin

class SuperAdminView extends StatelessWidget {
  const SuperAdminView({super.key});

  @override
  Widget build(BuildContext context) => AdminShell(
        title: 'Platform admin',
        subtitle: 'Tabkha platform',
        tabs: [
          AdminTab(Icons.insights_outlined, 'Overview', () => const _PlatformOverview()),
          AdminTab(Icons.storefront_outlined, 'Restaurants', () => const _RestaurantsAdmin()),
          AdminTab(Icons.receipt_long_outlined, 'All orders', () => const _AllOrders()),
          AdminTab(Icons.manage_accounts_outlined, 'Account', () => const _AdminAccount()),
        ],
      );
}

class _PlatformOverview extends ConsumerWidget {
  const _PlatformOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final pending = food.restaurants.where((r) => r.status == RestaurantStatus.pending).toList();
    final ranked = [...food.restaurants.where((r) => r.isListed)]
      ..sort((a, b) => food.revenueOf(food.ordersOf(b.id)).compareTo(food.revenueOf(food.ordersOf(a.id))));
    final maxRevenue = ranked.isEmpty ? 1.0 : food.revenueOf(food.ordersOf(ranked.first.id)).clamp(1, double.infinity);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      StatGrid(children: [
        StatCard(icon: Icons.storefront_outlined, label: 'Live restaurants', value: '${food.restaurants.where((r) => r.isListed).length}'),
        StatCard(icon: Icons.pending_actions_outlined, label: 'Awaiting approval', value: '${pending.length}', color: saffron),
        StatCard(icon: Icons.receipt_long_outlined, label: 'Orders', value: '${food.orders.length}', color: const Color(0xFF5B8DEF)),
        StatCard(icon: Icons.payments_outlined, label: 'Gross sales (delivered)', value: egp(food.revenueOf(food.orders))),
      ]),
      if (pending.isNotEmpty) ...[
        const SectionTitle('Waiting for approval'),
        for (final r in pending) _RestaurantAdminTile(restaurant: r),
      ],
      const SectionTitle('Top restaurants by sales'),
      Panel(
        child: Column(children: [
          for (final r in ranked)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                SizedBox(width: 140, child: Text(r.name, overflow: TextOverflow.ellipsis, style: titleStyle.copyWith(fontSize: 13))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: food.revenueOf(food.ordersOf(r.id)) / maxRevenue,
                      color: green,
                      backgroundColor: cream,
                    ),
                  ),
                ),
                SizedBox(
                  width: 92,
                  child: Text(egp(food.revenueOf(food.ordersOf(r.id))), textAlign: TextAlign.end, style: bodyStyle.copyWith(fontSize: 12.5)),
                ),
              ]),
            ),
        ]),
      ),
    ]);
  }
}

class _RestaurantsAdmin extends ConsumerWidget {
  const _RestaurantsAdmin();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(foodProvider).restaurants;
    return Column(children: [for (final r in restaurants) _RestaurantAdminTile(restaurant: r)]);
  }
}

class _RestaurantAdminTile extends ConsumerWidget {
  const _RestaurantAdminTile({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final store = ref.read(foodProvider.notifier);
    final r = restaurant;
    final (label, color) = switch (r.status) {
      RestaurantStatus.pending => ('Pending', saffron),
      RestaurantStatus.approved => ('Live', green),
      RestaurantStatus.suspended => ('Suspended', tomato),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Panel(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          SizedBox(width: 56, height: 56, child: NetImage(r.image, radius: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: titleStyle.copyWith(fontSize: 15)),
              Text('${r.cuisine} · ${r.area} · ${food.ordersOf(r.id).length} orders · ★ ${food.ratingOf(r.id).toStringAsFixed(1)}',
                  style: bodyStyle.copyWith(fontSize: 12.5)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<RestaurantStatus>(
            tooltip: 'Change status',
            onSelected: (s) => store.setRestaurantStatus(r.id, s),
            itemBuilder: (_) => [
              if (r.status != RestaurantStatus.approved)
                const PopupMenuItem(value: RestaurantStatus.approved, child: Text('Approve and list')),
              if (r.status != RestaurantStatus.suspended)
                const PopupMenuItem(value: RestaurantStatus.suspended, child: Text('Suspend')),
            ],
          ),
        ]),
      ),
    );
  }
}

class _AllOrders extends ConsumerWidget {
  const _AllOrders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final orders = [...food.orders]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Panel(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: titleStyle.copyWith(fontSize: 13),
          dataTextStyle: bodyStyle.copyWith(fontSize: 13, color: ink),
          columns: const [
            DataColumn(label: Text('Order')),
            DataColumn(label: Text('Restaurant')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Items'), numeric: true),
            DataColumn(label: Text('Total'), numeric: true),
            DataColumn(label: Text('Status')),
          ],
          rows: [
            for (final o in orders)
              DataRow(cells: [
                DataCell(Text(o.id)),
                DataCell(Text(food.restaurant(o.restaurantId)?.name ?? '')),
                DataCell(Text(o.customer)),
                DataCell(Text('${o.itemCount}')),
                DataCell(Text(egp(o.total))),
                DataCell(StatusChip(o.status)),
              ]),
          ],
        ),
      ),
    );
  }
}
