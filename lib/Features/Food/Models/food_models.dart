/// Restaurants, menus, orders and reviews for Tabkha's delivery side.
library;

enum OrderStatus { placed, accepted, preparing, onTheWay, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.placed => 'Placed',
        OrderStatus.accepted => 'Accepted',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.onTheWay => 'On the way',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };

  /// The next step in the delivery flow, or null when the order is finished.
  OrderStatus? get next => switch (this) {
        OrderStatus.placed => OrderStatus.accepted,
        OrderStatus.accepted => OrderStatus.preparing,
        OrderStatus.preparing => OrderStatus.onTheWay,
        OrderStatus.onTheWay => OrderStatus.delivered,
        _ => null,
      };

  bool get isActive => this != OrderStatus.delivered && this != OrderStatus.cancelled;

  /// Only orders that haven't started cooking can be cancelled.
  bool get canCancel => this == OrderStatus.placed || this == OrderStatus.accepted;
}

enum RestaurantStatus { pending, approved, suspended }

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String image;
  final int deliveryMinutes;
  final double deliveryFee;
  final bool isOpen;
  final RestaurantStatus status;
  final String area;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.image,
    required this.deliveryMinutes,
    required this.deliveryFee,
    required this.area,
    this.isOpen = true,
    this.status = RestaurantStatus.approved,
  });

  /// Customers only see approved restaurants.
  bool get isListed => status == RestaurantStatus.approved;

  Restaurant copyWith({bool? isOpen, RestaurantStatus? status}) => Restaurant(
        id: id,
        name: name,
        cuisine: cuisine,
        image: image,
        deliveryMinutes: deliveryMinutes,
        deliveryFee: deliveryFee,
        area: area,
        isOpen: isOpen ?? this.isOpen,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cuisine': cuisine,
        'image': image,
        'deliveryMinutes': deliveryMinutes,
        'deliveryFee': deliveryFee,
        'area': area,
        'isOpen': isOpen,
        'status': status.name,
      };

  factory Restaurant.fromJson(Map json) => Restaurant(
        id: json['id'] as String,
        name: json['name'] as String,
        cuisine: json['cuisine'] as String,
        image: json['image'] as String,
        deliveryMinutes: json['deliveryMinutes'] as int,
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
        area: json['area'] as String,
        isOpen: json['isOpen'] as bool,
        status: RestaurantStatus.values.byName(json['status'] as String),
      );
}

class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String image;
  final String section;
  final bool available;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.section,
    this.available = true,
  });

  MenuItem copyWith({bool? available, double? price, String? description}) => MenuItem(
        id: id,
        restaurantId: restaurantId,
        name: name,
        description: description ?? this.description,
        price: price ?? this.price,
        image: image,
        section: section,
        available: available ?? this.available,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantId': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'section': section,
        'available': available,
      };

  factory MenuItem.fromJson(Map json) => MenuItem(
        id: json['id'] as String,
        restaurantId: json['restaurantId'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String,
        section: json['section'] as String,
        available: json['available'] as bool,
      );
}

class OrderLine {
  final String itemId;
  final String name;
  final double price;
  final int quantity;

  const OrderLine({required this.itemId, required this.name, required this.price, required this.quantity});

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {'itemId': itemId, 'name': name, 'price': price, 'quantity': quantity};

  factory OrderLine.fromJson(Map json) => OrderLine(
        itemId: json['itemId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );
}

class FoodOrder {
  final String id;
  final String restaurantId;
  final String customer;
  final String address;
  final List<OrderLine> lines;
  final double deliveryFee;
  final OrderStatus status;
  final DateTime createdAt;
  final bool reviewed;

  /// A note for the kitchen, e.g. "No onions, please".
  final String note;

  const FoodOrder({
    required this.id,
    required this.restaurantId,
    required this.customer,
    required this.address,
    required this.lines,
    required this.deliveryFee,
    required this.status,
    required this.createdAt,
    this.reviewed = false,
    this.note = '',
  });

  double get subtotal => lines.fold(0, (sum, l) => sum + l.total);
  double get total => subtotal + deliveryFee;
  int get itemCount => lines.fold(0, (sum, l) => sum + l.quantity);

  FoodOrder copyWith({OrderStatus? status, bool? reviewed}) => FoodOrder(
        id: id,
        restaurantId: restaurantId,
        customer: customer,
        address: address,
        lines: lines,
        deliveryFee: deliveryFee,
        status: status ?? this.status,
        createdAt: createdAt,
        reviewed: reviewed ?? this.reviewed,
        note: note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantId': restaurantId,
        'customer': customer,
        'address': address,
        'lines': lines.map((l) => l.toJson()).toList(),
        'deliveryFee': deliveryFee,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'reviewed': reviewed,
        if (note.isNotEmpty) 'note': note,
      };

  factory FoodOrder.fromJson(Map json) => FoodOrder(
        id: json['id'] as String,
        restaurantId: json['restaurantId'] as String,
        customer: json['customer'] as String,
        address: json['address'] as String,
        lines: (json['lines'] as List).map((l) => OrderLine.fromJson(l as Map)).toList(),
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
        status: OrderStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        reviewed: json['reviewed'] as bool? ?? false,
        note: json['note'] as String? ?? '',
      );
}

class Review {
  final String restaurantId;
  final String author;
  final int stars;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.restaurantId,
    required this.author,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'restaurantId': restaurantId,
        'author': author,
        'stars': stars,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Review.fromJson(Map json) => Review(
        restaurantId: json['restaurantId'] as String,
        author: json['author'] as String,
        stars: json['stars'] as int,
        comment: json['comment'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Average star rating, or 0 with no reviews.
double averageRating(Iterable<Review> reviews) {
  if (reviews.isEmpty) return 0;
  return reviews.fold<int>(0, (s, r) => s + r.stars) / reviews.length;
}
