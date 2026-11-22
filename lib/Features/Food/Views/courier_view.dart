import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/Features/Food/Views/admin_views.dart';
import 'package:tabkha_app/Features/Food/Views/customer_views.dart';
import 'package:tabkha_app/Features/Food/Widgets/food_ui.dart';
import 'package:tabkha_app/Features/Food/Widgets/kitchen_art.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';
import 'package:tabkha_app/Features/Food/food_strings.dart';

/// The courier's side: orders ready to pick up and on the way, with one
/// action each, and what was delivered.
class CourierView extends StatelessWidget {
  const CourierView({super.key});

  @override
  Widget build(BuildContext context) => AdminShell(
        title: context.t('Deliveries'),
        subtitle: context.t('Courier'),
        tabs: [
          AdminTab(Icons.delivery_dining_outlined, context.t('Deliveries'),
              () => const _Deliveries()),
          AdminTab(Icons.task_alt_rounded, context.t('Delivered'),
              () => const _Delivered()),
          AdminTab(Icons.manage_accounts_outlined, context.t('Account'),
              () => const _CourierAccount()),
        ],
      );
}

class _Deliveries extends ConsumerWidget {
  const _Deliveries();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final ready =
        food.orders.where((o) => o.status == OrderStatus.preparing).toList();
    final onTheWay =
        food.orders.where((o) => o.status == OrderStatus.onTheWay).toList();
    if (ready.isEmpty && onTheWay.isEmpty) {
      return KitchenEmptyState(
        title: context.t('Nothing to deliver right now.'),
        message: context.t(
            'New orders show up here as soon as a kitchen starts cooking them.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onTheWay.isNotEmpty) ...[
          SectionTitle('${context.t('On the way')} (${onTheWay.length})'),
          for (final o in onTheWay) _DeliveryCard(order: o),
        ],
        if (ready.isNotEmpty) ...[
          SectionTitle('${context.t('Ready for pickup')} (${ready.length})'),
          for (final o in ready) _DeliveryCard(order: o),
        ],
      ],
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  const _DeliveryCard({required this.order});
  final FoodOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(foodProvider).restaurant(order.restaurantId);
    final pickingUp = order.status == OrderStatus.preparing;
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(order.id, style: titleStyle.copyWith(fontSize: 15)),
            Spacer(),
            StatusChip(order.status),
          ]),
          SizedBox(height: 10),
          _Leg(
              icon: Icons.storefront_outlined,
              label: context.t('Pick up from'),
              value: r == null ? '—' : '${r.name} · ${context.t(r.area)}'),
          _Leg(
              icon: Icons.location_on_outlined,
              label: context.t('Deliver to'),
              value: order.address),
          if (order.note.isNotEmpty)
            _Leg(
                icon: Icons.sticky_note_2_outlined,
                label: context.t('Note'),
                value: order.note),
          SizedBox(height: 6),
          Row(children: [
            Icon(Icons.payments_outlined, size: 18, color: inkMuted),
            SizedBox(width: 6),
            Text(
                '${context.t('Collect')} ${egp(order.total)} · ${order.itemCount} ${context.t('items')}',
                style: bodyStyle.copyWith(color: ink)),
          ]),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: pickingUp ? crust : green,
                  minimumSize: Size.fromHeight(50)),
              onPressed: () =>
                  ref.read(foodProvider.notifier).advanceOrder(order.id),
              icon: Icon(pickingUp
                  ? Icons.shopping_bag_outlined
                  : Icons.check_rounded),
              label: Text(pickingUp
                  ? context.t('Picked up')
                  : context.t('Mark delivered')),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Leg extends StatelessWidget {
  const _Leg({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: green),
          SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: bodyStyle.copyWith(fontSize: 12)),
              Text(value,
                  style: bodyStyle.copyWith(
                      color: ink, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      );
}

class _Delivered extends ConsumerWidget {
  const _Delivered();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref
        .watch(foodProvider)
        .orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (done.isEmpty) {
      return KitchenEmptyState(title: context.t('No deliveries yet.'));
    }
    final collected = done.fold<double>(0, (s, o) => s + o.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCard(
            icon: Icons.payments_outlined,
            label: context.t('Cash collected'),
            value: egp(collected)),
        SizedBox(height: 12),
        for (final o in done)
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Panel(
              padding: EdgeInsets.all(14),
              child: Row(children: [
                Icon(Icons.task_alt_rounded, color: green),
                SizedBox(width: 10),
                Expanded(
                    child: Text('${o.id} · ${o.address}',
                        style: bodyStyle.copyWith(color: ink))),
                Text(egp(o.total), style: titleStyle.copyWith(fontSize: 14)),
              ]),
            ),
          ),
      ],
    );
  }
}

class _CourierAccount extends StatelessWidget {
  const _CourierAccount();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('View the app as'),
              style: titleStyle.copyWith(fontSize: 18)),
          SizedBox(height: 12),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: RoleSwitcher(current: AppRole.courier)),
        ],
      );
}
