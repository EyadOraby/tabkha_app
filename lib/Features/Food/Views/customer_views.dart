import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/Features/Food/Widgets/food_ui.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';
import 'package:tabkha_app/Services/preferences_service.dart';
import 'package:tabkha_app/commonModels/user_preferences.dart';
import 'package:tabkha_app/constants/app_colors.dart';

const green = AppColors.greenBackground;

/// Restaurants near you: search, cuisines, a featured strip and the list.
class DiscoverView extends ConsumerStatefulWidget {
  const DiscoverView({super.key});

  @override
  ConsumerState<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends ConsumerState<DiscoverView> {
  String _query = '';
  String? _cuisine;

  @override
  Widget build(BuildContext context) {
    final food = ref.watch(foodProvider);
    if (!food.loaded) return const Center(child: CircularProgressIndicator(color: green));
    final cuisines = {for (final r in food.listed) r.cuisine}.toList();
    final list = food.listed.where((r) {
      final q = _query.toLowerCase();
      final matches = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.cuisine.toLowerCase().contains(q) ||
          food.menuOf(r.id).any((m) => m.name.toLowerCase().contains(q));
      return matches && (_cuisine == null || r.cuisine == _cuisine);
    }).toList();
    final active = food.myOrders.where((o) => o.status.isActive).firstOrNull;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverList.list(children: [
            Row(
              children: [
                const Text('Tabkha', style: TextStyle(fontFamily: 'Lobster', fontSize: 30, color: green)),
                const Spacer(),
                const Icon(Icons.location_on_rounded, color: tomato, size: 18),
                Text(' Cairo', style: bodyStyle.copyWith(fontWeight: FontWeight.w700, color: ink)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Hungry? Home-style food,\ndelivered hot.', style: titleStyle.copyWith(fontSize: 26, height: 1.15)),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search restaurants or dishes',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            if (active != null) ...[
              const SizedBox(height: 14),
              _ActiveOrderBanner(order: active, restaurant: food.restaurant(active.restaurantId)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _CuisineChip(label: 'All', selected: _cuisine == null, onTap: () => setState(() => _cuisine = null)),
                  for (final c in cuisines)
                    _CuisineChip(label: c, selected: _cuisine == c, onTap: () => setState(() => _cuisine = c)),
                ],
              ),
            ),
            SectionTitle(_query.isEmpty && _cuisine == null ? 'Top rated near you' : '${list.length} restaurants'),
          ]),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) => RestaurantCard(restaurant: list[i]),
          ),
        ),
      ],
    );
  }
}

class _CuisineChip extends StatelessWidget {
  const _CuisineChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          showCheckmark: false,
          selectedColor: green,
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          labelStyle: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, color: selected ? Colors.white : ink),
        ),
      );
}

class _ActiveOrderBanner extends StatelessWidget {
  const _ActiveOrderBanner({required this.order, required this.restaurant});
  final FoodOrder order;
  final Restaurant? restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [green, Color(0xFF3AA374)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your order is ${order.status.label.toLowerCase()}',
                    style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontWeight: FontWeight.w800)),
                Text('${restaurant?.name ?? ''} · about ${restaurant?.deliveryMinutes ?? 30} min',
                    style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white70, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantCard extends ConsumerWidget {
  const RestaurantCard({super.key, required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final reviews = food.reviewsOf(restaurant.id);
    return Panel(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RestaurantView(restaurantId: restaurant.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(tag: 'r-${restaurant.id}', child: NetImage(restaurant.image, radius: 0)),
                if (!restaurant.isOpen)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: const Text('Closed now',
                        style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                Positioned(top: 12, right: 12, child: RatingPill(rating: averageRating(reviews), count: reviews.length, light: true)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: titleStyle.copyWith(fontSize: 17)),
                const SizedBox(height: 4),
                Text('${restaurant.cuisine} · ${restaurant.area}', style: bodyStyle.copyWith(fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 16, color: inkMuted),
                    Text(' ${restaurant.deliveryMinutes} min', style: bodyStyle.copyWith(fontSize: 12.5)),
                    const SizedBox(width: 14),
                    const Icon(Icons.delivery_dining_outlined, size: 16, color: inkMuted),
                    Text(' ${egp(restaurant.deliveryFee)}', style: bodyStyle.copyWith(fontSize: 12.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A restaurant: hero photo, info, the menu by section and reviews.
class RestaurantView extends ConsumerWidget {
  const RestaurantView({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final r = food.restaurant(restaurantId);
    if (r == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: green)));
    final menu = food.menuOf(r.id);
    final sections = {for (final m in menu) m.section}.toList();
    final reviews = food.reviewsOf(r.id);
    final inCart = food.cartRestaurantId == r.id ? food.cartCount : 0;

    return Scaffold(
      backgroundColor: cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: green,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(r.name, style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 17)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: 'r-${r.id}', child: NetImage(r.image, radius: 0)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            sliver: SliverList.list(children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RatingPill(rating: averageRating(reviews), count: reviews.length),
                  _Fact(Icons.restaurant_menu_rounded, r.cuisine),
                  _Fact(Icons.schedule_rounded, '${r.deliveryMinutes} min'),
                  _Fact(Icons.delivery_dining_outlined, egp(r.deliveryFee)),
                  _Fact(r.isOpen ? Icons.check_circle_outline : Icons.do_not_disturb_on_outlined, r.isOpen ? 'Open' : 'Closed'),
                ],
              ),
              for (final section in sections) ...[
                SectionTitle(section),
                for (final item in menu.where((m) => m.section == section))
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: _MenuRow(item: item, open: r.isOpen)),
              ],
              SectionTitle('Reviews', trailing: Text('${reviews.length}', style: bodyStyle)),
              for (final review in reviews.take(6))
                Padding(padding: const EdgeInsets.only(bottom: 10), child: ReviewTile(review: review)),
            ]),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: inCart == 0
          ? null
          : SizedBox(
              width: MediaQuery.sizeOf(context).width - 40,
              height: 58,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutView())),
                child: Row(
                  children: [
                    CircleAvatar(radius: 14, backgroundColor: Colors.white24, child: Text('$inCart', style: const TextStyle(color: Colors.white, fontSize: 13))),
                    const SizedBox(width: 12),
                    const Text('View basket', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 16)),
                    const Spacer(),
                    Text(egp(food.cartSubtotal), style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: inkMuted),
          const SizedBox(width: 4),
          Text(text, style: bodyStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      );
}

class _MenuRow extends ConsumerWidget {
  const _MenuRow({required this.item, required this.open});
  final MenuItem item;
  final bool open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canOrder = item.available && open;
    return Panel(
      padding: const EdgeInsets.all(10),
      child: Opacity(
        opacity: item.available ? 1 : 0.5,
        child: Row(
          children: [
            SizedBox(width: 86, height: 86, child: NetImage(item.image, radius: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: titleStyle.copyWith(fontSize: 14.5)),
                  const SizedBox(height: 4),
                  Text(item.available ? item.description : 'Sold out today',
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: bodyStyle.copyWith(fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(egp(item.price), style: titleStyle.copyWith(fontSize: 14, color: green)),
                ],
              ),
            ),
            IconButton.filled(
              tooltip: 'Add ${item.name}',
              style: IconButton.styleFrom(backgroundColor: green),
              onPressed: !canOrder
                  ? null
                  : () {
                      final switching = ref.read(foodProvider).cartRestaurantId != item.restaurantId &&
                          ref.read(foodProvider).cart.isNotEmpty;
                      ref.read(foodProvider.notifier).addToCart(item);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(switching ? 'Started a new basket with ${item.name}' : 'Added ${item.name}'),
                        ));
                    },
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) => Panel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: green.withValues(alpha: 0.12),
              child: Text(review.author[0], style: titleStyle.copyWith(color: green)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(review.author, style: titleStyle.copyWith(fontSize: 14)),
                    const Spacer(),
                    for (var i = 0; i < 5; i++)
                      Icon(i < review.stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 15, color: saffron),
                  ]),
                  const SizedBox(height: 4),
                  Text(review.comment.isEmpty ? 'No comment' : review.comment, style: bodyStyle.copyWith(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Basket, delivery address and placing the order.
class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({super.key});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  final _address = TextEditingController(text: '6 Ibn Malek St, Giza');

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = ref.watch(foodProvider);
    final r = food.cartRestaurantId == null ? null : food.restaurant(food.cartRestaurantId!);
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(backgroundColor: cream, title: Text('Your basket', style: titleStyle.copyWith(fontSize: 20))),
      body: food.cart.isEmpty
          ? Center(child: Text('Your basket is empty', style: bodyStyle))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                if (r != null) Text('From ${r.name}', style: bodyStyle.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                for (final l in food.cart)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Panel(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(width: 56, height: 56, child: NetImage(l.item.image, radius: 12)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(l.item.name, style: titleStyle.copyWith(fontSize: 14))),
                          IconButton(
                            tooltip: 'One less',
                            onPressed: () => ref.read(foodProvider.notifier).setQuantity(l.item.id, l.quantity - 1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${l.quantity}', style: titleStyle),
                          IconButton(
                            tooltip: 'One more',
                            onPressed: () => ref.read(foodProvider.notifier).setQuantity(l.item.id, l.quantity + 1),
                            icon: const Icon(Icons.add_circle_outline, color: green),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SectionTitle('Deliver to'),
                TextField(
                  controller: _address,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SectionTitle('Summary'),
                Panel(
                  child: Column(children: [
                    _Line('Subtotal', egp(food.cartSubtotal)),
                    _Line('Delivery', egp(food.cartDeliveryFee)),
                    const Divider(height: 22),
                    _Line('Total', egp(food.cartTotal), bold: true),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.payments_outlined, size: 18, color: inkMuted),
                      Text('  Cash on delivery', style: bodyStyle.copyWith(fontSize: 13)),
                    ]),
                  ]),
                ),
              ],
            ),
      bottomNavigationBar: food.cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () {
                    final order = ref.read(foodProvider.notifier).placeOrder(address: _address.text.trim());
                    if (order == null) return;
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OrderTrackingView(orderId: order.id)));
                  },
                  child: Text('Place order · ${egp(food.cartTotal)}',
                      style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Text(label, style: bold ? titleStyle.copyWith(fontSize: 17) : bodyStyle),
          const Spacer(),
          Text(value, style: bold ? titleStyle.copyWith(fontSize: 17) : titleStyle.copyWith(fontSize: 14)),
        ]),
      );
}

/// Live status of one order, with cancel and review.
class OrderTrackingView extends ConsumerWidget {
  const OrderTrackingView({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final order = food.orders.where((o) => o.id == orderId).firstOrNull;
    if (order == null) return const Scaffold(body: SizedBox());
    final r = food.restaurant(order.restaurantId);
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(backgroundColor: cream, title: Text('Order ${order.id}', style: titleStyle.copyWith(fontSize: 18))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [OrderCard(order: order, restaurant: r, expanded: true)],
      ),
    );
  }
}

class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order, required this.restaurant, this.expanded = false});
  final FoodOrder order;
  final Restaurant? restaurant;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(foodProvider.notifier);
    return Panel(
      onTap: expanded ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderTrackingView(orderId: order.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(width: 44, height: 44, child: NetImage(restaurant?.image ?? '', radius: 12)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(restaurant?.name ?? '', style: titleStyle.copyWith(fontSize: 15)),
                Text('${order.itemCount} items · ${egp(order.total)}', style: bodyStyle.copyWith(fontSize: 12.5)),
              ]),
            ),
            StatusChip(order.status),
          ]),
          if (order.status != OrderStatus.cancelled) ...[
            const SizedBox(height: 16),
            OrderTimeline(status: order.status),
          ],
          if (expanded) ...[
            const SizedBox(height: 16),
            for (final l in order.lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Text('${l.quantity}×  ', style: titleStyle.copyWith(fontSize: 13, color: green)),
                  Expanded(child: Text(l.name, style: bodyStyle.copyWith(color: ink))),
                  Text(egp(l.total), style: bodyStyle),
                ]),
              ),
            Text('Delivering to ${order.address}', style: bodyStyle.copyWith(fontSize: 12.5)),
          ],
          if (order.status.canCancel || (order.status == OrderStatus.delivered && !order.reviewed)) ...[
            const SizedBox(height: 12),
            Row(children: [
              if (order.status.canCancel)
                TextButton.icon(
                  onPressed: () => store.cancelOrder(order.id),
                  icon: const Icon(Icons.close_rounded, color: tomato),
                  label: const Text('Cancel order', style: TextStyle(color: tomato)),
                ),
              if (order.status == OrderStatus.delivered && !order.reviewed)
                FilledButton.tonalIcon(
                  onPressed: () => showReviewDialog(context, ref, order),
                  icon: const Icon(Icons.star_outline_rounded),
                  label: const Text('Rate this order'),
                ),
            ]),
          ],
        ],
      ),
    );
  }
}

Future<void> showReviewDialog(BuildContext context, WidgetRef ref, FoodOrder order) async {
  var stars = 5;
  final comment = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('How was your food?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: '$i stars',
                  onPressed: () => setState(() => stars = i),
                  icon: Icon(i <= stars ? Icons.star_rounded : Icons.star_outline_rounded, color: saffron, size: 34),
                ),
            ],
          ),
          TextField(controller: comment, maxLines: 3, decoration: const InputDecoration(hintText: 'Tell others what you liked')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
          FilledButton(
            onPressed: () {
              ref.read(foodProvider.notifier).review(order.id, stars, comment.text);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );
  comment.dispose();
}

class MyOrdersView extends ConsumerWidget {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final orders = food.myOrders;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Your orders', style: titleStyle.copyWith(fontSize: 26)),
        const SizedBox(height: 16),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(children: [
              const Icon(Icons.receipt_long_outlined, size: 56, color: inkMuted),
              const SizedBox(height: 12),
              Text('No orders yet. Your first one is a few taps away.', style: bodyStyle, textAlign: TextAlign.center),
            ]),
          ),
        for (final o in orders)
          Padding(padding: const EdgeInsets.only(bottom: 14), child: OrderCard(order: o, restaurant: food.restaurant(o.restaurantId))),
      ],
    );
  }
}

/// Profile, language, role switch (demo) and reset.
class AccountView extends ConsumerWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ref.watch(foodProvider);
    final prefs = ref.watch(preferencesStateProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Account', style: titleStyle.copyWith(fontSize: 26)),
        const SizedBox(height: 16),
        Panel(
          child: Row(children: [
            const CircleAvatar(radius: 28, backgroundColor: green, child: Icon(Icons.person, color: Colors.white, size: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Guest', style: titleStyle.copyWith(fontSize: 17)),
                Text('${food.myOrders.length} orders · Giza', style: bodyStyle.copyWith(fontSize: 13)),
              ]),
            ),
          ]),
        ),
        const SectionTitle('View the app as'),
        RoleSwitcher(current: food.role),
        const SectionTitle('Preferences'),
        Panel(
          padding: EdgeInsets.zero,
          child: Column(children: [
            SwitchListTile(
              secondary: const Icon(Icons.translate_rounded),
              title: const Text('العربية'),
              value: prefs.language == LanguageCodeEnum.ar,
              activeThumbColor: green,
              onChanged: (ar) => ref
                  .read(preferencesStateProvider.notifier)
                  .updatePreferences(languageCodeEnum: ar ? LanguageCodeEnum.ar : LanguageCodeEnum.en),
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: const Text('Reset demo data'),
              onTap: () => ref.read(foodProvider.notifier).reset(),
            ),
          ]),
        ),
      ],
    );
  }
}

class RoleSwitcher extends ConsumerWidget {
  const RoleSwitcher({super.key, required this.current});
  final AppRole current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const icons = {
      AppRole.customer: Icons.person_outline,
      AppRole.restaurantAdmin: Icons.storefront_outlined,
      AppRole.superAdmin: Icons.admin_panel_settings_outlined,
    };
    return SegmentedButton<AppRole>(
      segments: [
        for (final r in AppRole.values) ButtonSegment(value: r, icon: Icon(icons[r]), label: Text(r.label)),
      ],
      selected: {current},
      showSelectedIcon: false,
      onSelectionChanged: (s) => ref.read(foodProvider.notifier).setRole(s.first),
    );
  }
}
