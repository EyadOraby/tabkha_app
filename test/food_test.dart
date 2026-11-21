import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabkha_app/Features/Food/Models/food_models.dart';
import 'package:tabkha_app/Features/Food/food_store.dart';

const _seed = {
  'restaurants': [
    {'id': 'r1', 'name': 'Koshary', 'cuisine': 'Egyptian', 'image': '', 'deliveryMinutes': 25, 'deliveryFee': 10, 'area': 'Downtown', 'isOpen': true, 'status': 'approved'},
    {'id': 'r2', 'name': 'Pasta', 'cuisine': 'Italian', 'image': '', 'deliveryMinutes': 35, 'deliveryFee': 15, 'area': 'Zamalek', 'isOpen': true, 'status': 'approved'},
    {'id': 'r7', 'name': 'Green', 'cuisine': 'Healthy', 'image': '', 'deliveryMinutes': 30, 'deliveryFee': 15, 'area': 'Dokki', 'isOpen': true, 'status': 'pending'},
  ],
  'menu': [
    {'id': 'a', 'restaurantId': 'r1', 'name': 'Koshary', 'description': '', 'price': 60, 'image': '', 'section': 'Popular', 'available': true},
    {'id': 'b', 'restaurantId': 'r1', 'name': 'Feteer', 'description': '', 'price': 90, 'image': '', 'section': 'Mains', 'available': false},
    {'id': 'c', 'restaurantId': 'r2', 'name': 'Lasagne', 'description': '', 'price': 150, 'image': '', 'section': 'Mains', 'available': true},
  ],
};

Future<(ProviderContainer, MemoryFoodStorage)> setUpStore() async {
  final storage = MemoryFoodStorage();
  final container = ProviderContainer(overrides: [
    foodStorageProvider.overrideWithValue(storage),
    foodSeedProvider.overrideWithValue(() async => jsonEncode(_seed)),
  ]);
  container.read(foodProvider);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  return (container, storage);
}

MenuItem item(ProviderContainer c, String id) => c.read(foodProvider).menu.firstWhere((m) => m.id == id);

void main() {
  test('seeds restaurants, reviews and sample orders on first run', () async {
    final (c, _) = await setUpStore();
    final s = c.read(foodProvider);
    expect(s.loaded, isTrue);
    expect(s.restaurants, hasLength(3));
    expect(s.listed.map((r) => r.id), isNot(contains('r7')), reason: 'pending restaurants stay hidden');
    expect(s.reviewsOf('r1'), isNotEmpty);
    expect(s.ordersOf('r1'), isNotEmpty);
  });

  test('the basket holds one restaurant and skips sold-out dishes', () async {
    final (c, _) = await setUpStore();
    final store = c.read(foodProvider.notifier);
    expect(store.addToCart(item(c, 'b')), isFalse);
    store.addToCart(item(c, 'a'));
    store.addToCart(item(c, 'a'));
    var s = c.read(foodProvider);
    expect(s.cartCount, 2);
    expect(s.cartTotal, 60 * 2 + 10);

    store.addToCart(item(c, 'c'));
    s = c.read(foodProvider);
    expect(s.cartRestaurantId, 'r2');
    expect(s.cartCount, 1);
  });

  test('an order moves through the kitchen and can be reviewed once delivered', () async {
    final (c, storage) = await setUpStore();
    final store = c.read(foodProvider.notifier);
    store.addToCart(item(c, 'a'));
    final order = store.placeOrder(address: 'Giza')!;
    expect(c.read(foodProvider).cart, isEmpty);
    expect(order.status, OrderStatus.placed);

    expect(store.review(order.id, 5, 'Great'), isFalse, reason: 'not delivered yet');
    for (var i = 0; i < 4; i++) {
      expect(store.advanceOrder(order.id), isTrue);
    }
    expect(c.read(foodProvider).orders.first.status, OrderStatus.delivered);
    expect(store.advanceOrder(order.id), isFalse);

    final before = c.read(foodProvider).reviewsOf('r1').length;
    expect(store.review(order.id, 4, 'Tasty'), isTrue);
    expect(store.review(order.id, 5, 'Again'), isFalse, reason: 'one review per order');
    expect(c.read(foodProvider).reviewsOf('r1').length, before + 1);
    expect(storage.value, contains('Tasty'), reason: 'saved to the device');
  });

  test('customers can cancel only before cooking starts', () async {
    final (c, _) = await setUpStore();
    final store = c.read(foodProvider.notifier);
    store.addToCart(item(c, 'a'));
    final first = store.placeOrder(address: 'Giza')!;
    expect(store.cancelOrder(first.id), isTrue);

    store.addToCart(item(c, 'a'));
    final second = store.placeOrder(address: 'Giza')!;
    store.advanceOrder(second.id);
    store.advanceOrder(second.id);
    expect(store.cancelOrder(second.id), isFalse);
  });

  test('restaurant admins manage availability, dishes and opening hours', () async {
    final (c, _) = await setUpStore();
    final store = c.read(foodProvider.notifier);
    store.toggleAvailability('b');
    expect(item(c, 'b').available, isTrue);
    store.addMenuItem(restaurantId: 'r1', name: ' Hawawshi ', price: 75, section: 'Mains');
    expect(c.read(foodProvider).menuOf('r1').last.name, 'Hawawshi');
    store.setOpen('r1', false);
    expect(c.read(foodProvider).restaurant('r1')!.isOpen, isFalse);
  });

  test('super admins approve and suspend restaurants', () async {
    final (c, _) = await setUpStore();
    final store = c.read(foodProvider.notifier);
    store.setRestaurantStatus('r7', RestaurantStatus.approved);
    expect(c.read(foodProvider).listed.map((r) => r.id), contains('r7'));
    store.setRestaurantStatus('r1', RestaurantStatus.suspended);
    expect(c.read(foodProvider).listed.map((r) => r.id), isNot(contains('r1')));
  });

  test('state survives a restart', () async {
    final (c, storage) = await setUpStore();
    c.read(foodProvider.notifier).setRole(AppRole.superAdmin);
    final restarted = ProviderContainer(overrides: [
      foodStorageProvider.overrideWithValue(storage),
      foodSeedProvider.overrideWithValue(() async => jsonEncode(_seed)),
    ]);
    expect(restarted.read(foodProvider).role, AppRole.superAdmin);
    expect(restarted.read(foodProvider).restaurants, hasLength(3));
  });

  test('order status flow and ratings', () {
    expect(OrderStatus.preparing.next, OrderStatus.onTheWay);
    expect(OrderStatus.delivered.next, isNull);
    expect(OrderStatus.accepted.canCancel, isTrue);
    expect(averageRating(const []), 0);
  });
}
