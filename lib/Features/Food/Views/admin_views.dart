import 'package:material_ui/material_ui.dart';
import 'package:tabkha_app/Features/Food/food_strings.dart';
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
            Text(context.t(widget.subtitle).toUpperCase(),
                style: bodyStyle.copyWith(fontSize: 11.5, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text(context.t(widget.tabs[_index].label), style: titleStyle.copyWith(fontSize: wide ? 30 : 24)),
            SizedBox(height: 18),
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
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Column(children: [
                Text('Tabkha', style: TextStyle(fontFamily: 'YoungSerif', fontSize: 26, color: green)),
                Text(context.t(widget.title), style: bodyStyle.copyWith(fontSize: 11)),
              ]),
            ),
            destinations: [
              for (final t in widget.tabs) NavigationRailDestination(icon: Icon(t.icon), label: Text(context.t(t.label))),
            ],
          ),
          VerticalDivider(width: 1),
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
        destinations: [for (final t in widget.tabs) NavigationDestination(icon: Icon(t.icon), label: context.t(t.label))],
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
        title: context.t('Restaurant console'),
        subtitle: 'Koshary El Tahrir',
        tabs: [
          AdminTab(Icons.space_dashboard_outlined, context.t('Overview'), () => _RestaurantOverview()),
          AdminTab(Icons.receipt_long_outlined, 'Orders', () => _OrdersBoard(restaurantId: managedRestaurantId)),
          AdminTab(Icons.restaurant_menu_outlined, context.t('Menu'), () => _MenuManager()),
          AdminTab(Icons.reviews_outlined, context.t('Reviews'), () => _ReviewsList()),
          AdminTab(Icons.manage_accounts_outlined, context.t('Account'), () => _AdminAccount()),
        ],
      );
}

class _RestaurantOverview extends ConsumerWidget {
  const _RestaurantOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final r = food.restaurant(managedRestaurantId);
    if (r == null) return SizedBox();
    final orders = food.ordersOf(r.id);
    final active = orders.where((o) => o.status.isActive).toList();
    final menu = food.menuOf(r.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SwitchListTile(
          title: Text(r.isOpen ? context.t('Open for orders') : context.t('Closed'), style: titleStyle.copyWith(fontSize: 16)),
          subtitle: Text(r.isOpen ? context.t('Customers can order now') : context.t('Customers see you as closed'), style: bodyStyle),
          value: r.isOpen,
          activeThumbColor: green,
          onChanged: (v) => ref.read(foodProvider.notifier).setOpen(r.id, v),
        ),
      ),
      SizedBox(height: 14),
      StatGrid(children: [
        StatCard(icon: Icons.local_fire_department_outlined, label: context.t('Active orders'), value: '${active.length}', color: saffron),
        StatCard(icon: Icons.payments_outlined, label: context.t('Revenue (delivered)'), value: egp(food.revenueOf(orders))),
        StatCard(icon: Icons.star_outline_rounded, label: context.t('Rating'), value: food.ratingOf(r.id).toStringAsFixed(1), color: saffron),
        StatCard(
          icon: Icons.restaurant_menu_outlined,
          label: context.t('Dishes available'),
          value: '${menu.where((m) => m.available).length}/${menu.length}',
          color: Color(0xFF5E8A84),
        ),
      ]),
      SectionTitle(context.t('Needs your attention')),
      if (active.isEmpty) Text(context.t('All caught up.'), style: bodyStyle),
      for (final o in active.take(4))
        Padding(padding: EdgeInsets.only(bottom: 10), child: _AdminOrderTile(order: o)),
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
            Text('${context.t(title)}  ${orders.where((o) => statuses.contains(o.status)).length}', style: titleStyle.copyWith(fontSize: 15)),
            SizedBox(height: 10),
            for (final o in orders.where((o) => statuses.contains(o.status)))
              Padding(padding: EdgeInsets.only(bottom: 10), child: _AdminOrderTile(order: o)),
            SizedBox(height: 14),
          ]),
      ];
      if (!wide) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: groups);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final g in groups) Expanded(child: Padding(padding: EdgeInsets.only(right: 14), child: g))],
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
          Spacer(),
          StatusChip(order.status),
        ]),
        SizedBox(height: 4),
        Text('${order.customer} · ${order.itemCount} ${context.t('items')} · ${egp(order.total)} · ${_ago(context, minutes)}',
            style: bodyStyle.copyWith(fontSize: 12.5)),
        SizedBox(height: 6),
        Text(order.lines.map((l) => '${l.quantity}× ${l.name}').join(', '),
            maxLines: 2, overflow: TextOverflow.ellipsis, style: bodyStyle.copyWith(fontSize: 12.5, color: ink)),
        if (order.note.isNotEmpty) ...[
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Color(0xFFFFF1D6), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.sticky_note_2_outlined, size: 16, color: Color(0xFF8A5A00)),
              SizedBox(width: 6),
              Expanded(child: Text(order.note, style: bodyStyle.copyWith(fontSize: 12.5, color: ink))),
            ]),
          ),
        ],
        if (next != null) ...[
          SizedBox(height: 10),
          Row(children: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: green),
              onPressed: () => store.advanceOrder(order.id),
              child: Text(switch (next) {
                OrderStatus.accepted => context.t('Accept'),
                OrderStatus.preparing => context.t('Start preparing'),
                OrderStatus.onTheWay => context.t('Hand to driver'),
                _ => context.t('Mark delivered'),
              }),
            ),
            if (order.status == OrderStatus.placed) ...[
              SizedBox(width: 8),
              TextButton(
                onPressed: () => store.rejectOrder(order.id),
                child: Text(context.t('Reject'), style: TextStyle(color: tomato)),
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
          icon: Icon(Icons.add_rounded),
          label: Text(context.t('Add a dish')),
        ),
      ),
      SizedBox(height: 14),
      for (final m in menu)
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Panel(
            padding: EdgeInsets.all(10),
            child: Row(children: [
              SizedBox(width: 56, height: 56, child: NetImage(m.image, radius: 12)),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.name, style: titleStyle.copyWith(fontSize: 14)),
                  Text('${m.section} · ${egp(m.price)}', style: bodyStyle.copyWith(fontSize: 12.5)),
                ]),
              ),
              Text(m.available ? context.t('Available') : context.t('Sold out'), style: bodyStyle.copyWith(fontSize: 12)),
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
    final dish = await showDialog<({String name, double price, String section})>(
      context: context,
      builder: (_) => const _AddDishDialog(),
    );
    if (dish == null) return;
    ref.read(foodProvider.notifier).addMenuItem(
          restaurantId: managedRestaurantId,
          name: dish.name,
          price: dish.price,
          section: dish.section,
        );
  }
}

/// Asks for a dish's name, price and section. It owns its text controllers,
/// so they stay alive until the dialog has finished closing.
class _AddDishDialog extends StatefulWidget {
  const _AddDishDialog();

  @override
  State<_AddDishDialog> createState() => _AddDishDialogState();
}

class _AddDishDialogState extends State<_AddDishDialog> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  var _section = 'Mains';

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t('Add a dish')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: context.t('Name'))),
        TextField(controller: _price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: context.t('Price (EGP)'))),
        SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _section,
          decoration: InputDecoration(labelText: context.t('Section')),
          items: [for (final s in ['Popular', 'Mains', 'Sides & more']) DropdownMenuItem(value: s, child: Text(s))],
          onChanged: (v) => setState(() => _section = v ?? _section),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(context.t('Cancel'))),
        FilledButton(
          onPressed: () {
            final p = double.tryParse(_price.text);
            if (_name.text.trim().isEmpty || p == null || p <= 0) return;
            Navigator.pop(context, (name: _name.text, price: p, section: _section));
          },
          child: Text(context.t('Add')),
        ),
      ],
    );
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
        SizedBox(width: 10),
        Text('${context.t('from')} ${reviews.length} ${context.t('reviews')}', style: bodyStyle),
      ]),
      SizedBox(height: 12),
      for (final r in reviews) Padding(padding: EdgeInsets.only(bottom: 10), child: ReviewTile(review: r)),
    ]);
  }
}

class _AdminAccount extends ConsumerWidget {
  const _AdminAccount();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(context.t('View the app as'), style: titleStyle.copyWith(fontSize: 15)),
        SizedBox(height: 10),
        RoleSwitcher(current: ref.watch(foodProvider).role),
        SizedBox(height: 14),
        Panel(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Icons.restart_alt_rounded),
            title: Text(context.t('Reset demo data')),
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
        title: context.t('Platform admin'),
        subtitle: context.t('Tabkha platform'),
        tabs: [
          AdminTab(Icons.insights_outlined, context.t('Overview'), () => _PlatformOverview()),
          AdminTab(Icons.storefront_outlined, context.t('Restaurants'), () => _RestaurantsAdmin()),
          AdminTab(Icons.receipt_long_outlined, context.t('All orders'), () => _AllOrders()),
          AdminTab(Icons.manage_accounts_outlined, context.t('Account'), () => _AdminAccount()),
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
        StatCard(icon: Icons.storefront_outlined, label: context.t('Live restaurants'), value: '${food.restaurants.where((r) => r.isListed).length}'),
        StatCard(icon: Icons.pending_actions_outlined, label: context.t('Awaiting approval'), value: '${pending.length}', color: saffron),
        StatCard(icon: Icons.receipt_long_outlined, label: context.t('Orders'), value: '${food.orders.length}', color: Color(0xFF5B8DEF)),
        StatCard(icon: Icons.payments_outlined, label: context.t('Gross sales (delivered)'), value: egp(food.revenueOf(food.orders))),
      ]),
      if (pending.isNotEmpty) ...[
        SectionTitle(context.t('Waiting for approval')),
        for (final r in pending) _RestaurantAdminTile(restaurant: r),
      ],
      SectionTitle(context.t('Top restaurants by sales')),
      Panel(
        child: Column(children: [
          for (final r in ranked)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 7),
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
      RestaurantStatus.pending => (context.t('Pending'), saffron),
      RestaurantStatus.approved => (context.t('Live'), green),
      RestaurantStatus.suspended => (context.t('Suspended'), tomato),
    };
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Panel(
        padding: EdgeInsets.all(12),
        child: Row(children: [
          SizedBox(width: 56, height: 56, child: NetImage(r.image, radius: 14)),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.name, style: titleStyle.copyWith(fontSize: 15)),
              Text('${r.cuisine} · ${r.area} · ${food.ordersOf(r.id).length} orders · ★ ${food.ratingOf(r.id).toStringAsFixed(1)}',
                  style: bodyStyle.copyWith(fontSize: 12.5)),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
            child: Text(context.t(label), style: TextStyle(fontFamily: 'Nunito', fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
          SizedBox(width: 6),
          PopupMenuButton<RestaurantStatus>(
            tooltip: context.t('Change status'),
            onSelected: (s) => store.setRestaurantStatus(r.id, s),
            itemBuilder: (_) => [
              if (r.status != RestaurantStatus.approved)
                PopupMenuItem(value: RestaurantStatus.approved, child: Text(context.t('Approve and list'))),
              if (r.status != RestaurantStatus.suspended)
                PopupMenuItem(value: RestaurantStatus.suspended, child: Text(context.t('Suspend'))),
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
      padding: EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: titleStyle.copyWith(fontSize: 13),
          dataTextStyle: bodyStyle.copyWith(fontSize: 13, color: ink),
          columns: [
            DataColumn(label: Text(context.t('Order'))),
            DataColumn(label: Text(context.t('Restaurant'))),
            DataColumn(label: Text(context.t('Customer'))),
            DataColumn(label: Text(context.t('Items')), numeric: true),
            DataColumn(label: Text(context.t('Total')), numeric: true),
            DataColumn(label: Text(context.t('Status'))),
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

/// "12 min ago" / "منذ 12 دقيقة".
String _ago(BuildContext context, int minutes) {
  final hours = minutes ~/ 60;
  if (context.isArabic) return minutes < 60 ? 'منذ $minutes دقيقة' : 'منذ $hours ساعة';
  return minutes < 60 ? '$minutes min ago' : '$hours h ago';
}
