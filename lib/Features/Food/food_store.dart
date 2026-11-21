import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/Services/caching_service.dart';

/// Who is using the app. The demo lets you switch to see every side.
enum AppRole { customer, restaurantAdmin, superAdmin }

extension AppRoleX on AppRole {
  String get label => switch (this) {
        AppRole.customer => 'Customer',
        AppRole.restaurantAdmin => 'Restaurant admin',
        AppRole.superAdmin => 'Super admin',
      };
}

/// The restaurant the demo restaurant admin manages.
const managedRestaurantId = 'r1';

class CartLine {
  final MenuItem item;
  final int quantity;
  const CartLine(this.item, this.quantity);
}

class FoodState {
  final List<Restaurant> restaurants;
  final List<MenuItem> menu;
  final List<FoodOrder> orders;
  final List<Review> reviews;
  final String? cartRestaurantId;
  final List<CartLine> cart;
  final AppRole role;
  final bool loaded;

  const FoodState({
    this.restaurants = const [],
    this.menu = const [],
    this.orders = const [],
    this.reviews = const [],
    this.cartRestaurantId,
    this.cart = const [],
    this.role = AppRole.customer,
    this.loaded = false,
  });

  FoodState copyWith({
    List<Restaurant>? restaurants,
    List<MenuItem>? menu,
    List<FoodOrder>? orders,
    List<Review>? reviews,
    String? Function()? cartRestaurantId,
    List<CartLine>? cart,
    AppRole? role,
    bool? loaded,
  }) =>
      FoodState(
        restaurants: restaurants ?? this.restaurants,
        menu: menu ?? this.menu,
        orders: orders ?? this.orders,
        reviews: reviews ?? this.reviews,
        cartRestaurantId: cartRestaurantId != null ? cartRestaurantId() : this.cartRestaurantId,
        cart: cart ?? this.cart,
        role: role ?? this.role,
        loaded: loaded ?? this.loaded,
      );

  Restaurant? restaurant(String id) => restaurants.where((r) => r.id == id).firstOrNull;
  List<MenuItem> menuOf(String restaurantId) => menu.where((m) => m.restaurantId == restaurantId).toList();
  List<Review> reviewsOf(String restaurantId) => reviews.where((r) => r.restaurantId == restaurantId).toList();
  List<FoodOrder> ordersOf(String restaurantId) => orders.where((o) => o.restaurantId == restaurantId).toList();
  double ratingOf(String restaurantId) => averageRating(reviewsOf(restaurantId));

  /// What customers can browse: approved restaurants, best rated first.
  List<Restaurant> get listed {
    final list = restaurants.where((r) => r.isListed).toList();
    list.sort((a, b) => ratingOf(b.id).compareTo(ratingOf(a.id)));
    return list;
  }

  /// The signed-in customer's own orders, newest first.
  List<FoodOrder> get myOrders => orders.where((o) => o.customer == 'You').toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int get cartCount => cart.fold(0, (s, l) => s + l.quantity);
  double get cartSubtotal => cart.fold(0, (s, l) => s + l.item.price * l.quantity);
  double get cartDeliveryFee => cartRestaurantId == null ? 0 : (restaurant(cartRestaurantId!)?.deliveryFee ?? 0);
  double get cartTotal => cartSubtotal + cartDeliveryFee;

  /// Revenue from delivered orders.
  double revenueOf(Iterable<FoodOrder> orders) =>
      orders.where((o) => o.status == OrderStatus.delivered).fold(0, (s, o) => s + o.total);

  Map<String, dynamic> toJson() => {
        'restaurants': restaurants.map((r) => r.toJson()).toList(),
        'menu': menu.map((m) => m.toJson()).toList(),
        'orders': orders.map((o) => o.toJson()).toList(),
        'reviews': reviews.map((r) => r.toJson()).toList(),
        'role': role.name,
      };
}

/// Where the delivery data is saved. Hive in the app, memory in tests.
abstract class FoodStorage {
  String? read();
  Future<void> write(String json);
}

class HiveFoodStorage implements FoodStorage {
  HiveFoodStorage(this._cache);
  final CachingService _cache;
  static const _key = 'FOOD_STATE';

  @override
  String? read() => _cache.get(_key) as String?;

  @override
  Future<void> write(String json) => _cache.put(_key, json);
}

class MemoryFoodStorage implements FoodStorage {
  String? value;
  @override
  String? read() => value;
  @override
  Future<void> write(String json) async => value = json;
}

final foodStorageProvider = Provider<FoodStorage>((ref) => HiveFoodStorage(ref.watch(cachingServiceProvider)));

/// Loads the bundled restaurants and menus on first run.
final foodSeedProvider = Provider<Future<String> Function()>((ref) => () => rootBundle.loadString('assets/food_seed.json'));

final foodProvider = NotifierProvider<FoodStore, FoodState>(FoodStore.new);

class FoodStore extends Notifier<FoodState> {
  late FoodStorage _storage;
  DateTime Function() clock = DateTime.now;

  @override
  FoodState build() {
    _storage = ref.watch(foodStorageProvider);
    final saved = _storage.read();
    if (saved != null) {
      final json = jsonDecode(saved) as Map<String, dynamic>;
      return FoodState(
        restaurants: (json['restaurants'] as List).map((e) => Restaurant.fromJson(e as Map)).toList(),
        menu: (json['menu'] as List).map((e) => MenuItem.fromJson(e as Map)).toList(),
        orders: (json['orders'] as List).map((e) => FoodOrder.fromJson(e as Map)).toList(),
        reviews: (json['reviews'] as List).map((e) => Review.fromJson(e as Map)).toList(),
        role: AppRole.values.byName(json['role'] as String? ?? 'customer'),
        loaded: true,
      );
    }
    Future.microtask(_seed);
    return const FoodState();
  }

  Future<void> _seed() async {
    final json = jsonDecode(await ref.read(foodSeedProvider)()) as Map<String, dynamic>;
    final restaurants = (json['restaurants'] as List).map((e) => Restaurant.fromJson(e as Map)).toList();
    final menu = (json['menu'] as List).map((e) => MenuItem.fromJson(e as Map)).toList();
    final now = clock();
    _set(FoodState(
      restaurants: restaurants,
      menu: menu,
      reviews: seedReviews(restaurants, now),
      orders: seedOrders(menu, now),
      role: state.role,
      loaded: true,
    ));
  }

  void _set(FoodState next) {
    state = next;
    _storage.write(jsonEncode(next.toJson()));
  }

  void setRole(AppRole role) => _set(state.copyWith(role: role));

  // Customer: cart and ordering

  /// Adds an item. A cart holds one restaurant at a time; adding from another
  /// restaurant starts a new cart. Returns false for unavailable items.
  bool addToCart(MenuItem item) {
    if (!item.available) return false;
    final sameRestaurant = state.cartRestaurantId == item.restaurantId;
    final lines = sameRestaurant ? [...state.cart] : <CartLine>[];
    final i = lines.indexWhere((l) => l.item.id == item.id);
    if (i >= 0) {
      lines[i] = CartLine(item, lines[i].quantity + 1);
    } else {
      lines.add(CartLine(item, 1));
    }
    state = state.copyWith(cart: lines, cartRestaurantId: () => item.restaurantId);
    return true;
  }

  void setQuantity(String itemId, int quantity) {
    final lines = [
      for (final l in state.cart)
        if (l.item.id != itemId) l else if (quantity > 0) CartLine(l.item, quantity),
    ];
    state = state.copyWith(cart: lines, cartRestaurantId: () => lines.isEmpty ? null : state.cartRestaurantId);
  }

  FoodOrder? placeOrder({required String address}) {
    final rid = state.cartRestaurantId;
    if (rid == null || state.cart.isEmpty) return null;
    final now = clock();
    final order = FoodOrder(
      id: 'TB-${now.millisecondsSinceEpoch.toString().substring(6)}',
      restaurantId: rid,
      customer: 'You',
      address: address,
      lines: [for (final l in state.cart) OrderLine(itemId: l.item.id, name: l.item.name, price: l.item.price, quantity: l.quantity)],
      deliveryFee: state.cartDeliveryFee,
      status: OrderStatus.placed,
      createdAt: now,
    );
    _set(state.copyWith(orders: [order, ...state.orders], cart: const [], cartRestaurantId: () => null));
    return order;
  }

  bool cancelOrder(String orderId) {
    final order = state.orders.where((o) => o.id == orderId).firstOrNull;
    if (order == null || !order.status.canCancel) return false;
    _replaceOrder(order.copyWith(status: OrderStatus.cancelled));
    return true;
  }

  /// Leaves a review for a delivered order, once.
  bool review(String orderId, int stars, String comment) {
    final order = state.orders.where((o) => o.id == orderId).firstOrNull;
    if (order == null || order.status != OrderStatus.delivered || order.reviewed) return false;
    final review = Review(
      restaurantId: order.restaurantId,
      author: 'You',
      stars: stars.clamp(1, 5),
      comment: comment.trim(),
      createdAt: clock(),
    );
    _set(state.copyWith(
      reviews: [review, ...state.reviews],
      orders: [for (final o in state.orders) o.id == orderId ? o.copyWith(reviewed: true) : o],
    ));
    return true;
  }

  // Restaurant admin

  /// Moves an order to its next status. Returns false when it's finished.
  bool advanceOrder(String orderId) {
    final order = state.orders.where((o) => o.id == orderId).firstOrNull;
    final next = order?.status.next;
    if (order == null || next == null) return false;
    _replaceOrder(order.copyWith(status: next));
    return true;
  }

  bool rejectOrder(String orderId) {
    final order = state.orders.where((o) => o.id == orderId).firstOrNull;
    if (order == null || order.status != OrderStatus.placed) return false;
    _replaceOrder(order.copyWith(status: OrderStatus.cancelled));
    return true;
  }

  void toggleAvailability(String itemId) => _set(state.copyWith(
        menu: [for (final m in state.menu) m.id == itemId ? m.copyWith(available: !m.available) : m],
      ));

  void addMenuItem({required String restaurantId, required String name, required double price, required String section}) {
    final image = state.menuOf(restaurantId).firstOrNull?.image ?? '';
    final item = MenuItem(
      id: '$restaurantId-n${clock().millisecondsSinceEpoch}',
      restaurantId: restaurantId,
      name: name.trim(),
      description: 'New on the menu.',
      price: price,
      image: image,
      section: section,
    );
    _set(state.copyWith(menu: [...state.menu, item]));
  }

  void setOpen(String restaurantId, bool open) => _updateRestaurant(restaurantId, (r) => r.copyWith(isOpen: open));

  // Super admin

  void setRestaurantStatus(String restaurantId, RestaurantStatus status) =>
      _updateRestaurant(restaurantId, (r) => r.copyWith(status: status));

  void _updateRestaurant(String id, Restaurant Function(Restaurant) change) => _set(state.copyWith(
        restaurants: [for (final r in state.restaurants) r.id == id ? change(r) : r],
      ));

  void _replaceOrder(FoodOrder order) =>
      _set(state.copyWith(orders: [for (final o in state.orders) o.id == order.id ? order : o]));

  /// Clears everything and reloads the demo data.
  Future<void> reset() async {
    state = FoodState(role: state.role);
    await _seed();
  }
}

/// A few reviews so ratings mean something on first launch.
List<Review> seedReviews(List<Restaurant> restaurants, DateTime now) {
  const names = ['Mariam', 'Omar', 'Nour', 'Youssef', 'Salma', 'Karim'];
  const comments = [
    'Arrived hot and on time. Will order again.',
    'Generous portions and great flavour.',
    'Good, but the delivery took a little longer than expected.',
    'My go-to place on busy nights.',
    'Fresh, tasty and well packed.',
  ];
  final reviews = <Review>[];
  for (var i = 0; i < restaurants.length; i++) {
    for (var j = 0; j < 3 + i % 3; j++) {
      reviews.add(Review(
        restaurantId: restaurants[i].id,
        author: names[(i + j) % names.length],
        stars: [5, 4, 5, 3, 4][(i * 2 + j) % 5],
        comment: comments[(i + j) % comments.length],
        createdAt: now.subtract(Duration(days: j * 3 + i)),
      ));
    }
  }
  return reviews;
}

/// Orders from other customers, so the dashboards have something to show.
List<FoodOrder> seedOrders(List<MenuItem> menu, DateTime now) {
  const customers = ['Mariam S.', 'Omar K.', 'Nour A.', 'Youssef H.', 'Salma M.'];
  const statuses = [
    OrderStatus.placed,
    OrderStatus.preparing,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
    OrderStatus.delivered,
    OrderStatus.accepted,
  ];
  final orders = <FoodOrder>[];
  final byRestaurant = <String, List<MenuItem>>{};
  for (final m in menu) {
    byRestaurant.putIfAbsent(m.restaurantId, () => []).add(m);
  }
  var n = 0;
  byRestaurant.forEach((rid, items) {
    for (var i = 0; i < (rid == managedRestaurantId ? 6 : 3); i++) {
      final a = items[i % items.length];
      final b = items[(i + 2) % items.length];
      orders.add(FoodOrder(
        id: 'TB-${(4120 + n).toString()}',
        restaurantId: rid,
        customer: customers[n % customers.length],
        address: 'Cairo',
        lines: [
          OrderLine(itemId: a.id, name: a.name, price: a.price, quantity: 1 + i % 2),
          OrderLine(itemId: b.id, name: b.name, price: b.price, quantity: 1),
        ],
        deliveryFee: 15,
        status: statuses[(i + n) % statuses.length],
        createdAt: now.subtract(Duration(minutes: 12 + n * 37)),
      ));
      n++;
    }
  });
  // Two of "your" orders: one on its way, one delivered and waiting for a review.
  final mineFrom = [byRestaurant['r2'], byRestaurant['r3']].whereType<List<MenuItem>>().toList();
  for (var i = 0; i < mineFrom.length; i++) {
    final items = mineFrom[i];
    orders.add(FoodOrder(
      id: 'TB-${3990 + i}',
      restaurantId: items.first.restaurantId,
      customer: 'You',
      address: '6 Ibn Malek St, Giza',
      lines: [
        OrderLine(itemId: items[0].id, name: items[0].name, price: items[0].price, quantity: 2),
        if (items.length > 1) OrderLine(itemId: items[1].id, name: items[1].name, price: items[1].price, quantity: 1),
      ],
      deliveryFee: 15,
      status: i == 0 ? OrderStatus.onTheWay : OrderStatus.delivered,
      createdAt: now.subtract(Duration(minutes: i == 0 ? 18 : 60 * 26)),
    ));
  }
  return orders;
}
