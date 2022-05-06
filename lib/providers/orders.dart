import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/shared_data.dart';
import '../providers/cart_provider.dart' show CartItem;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'amount': amount});
    result.addAll({'products': products.map((x) => x.toMap()).toList()});
    result.addAll({'dateTime': dateTime.toIso8601String()});

    return result;
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      products:
          List<CartItem>.from(map['products']?.map((x) => CartItem.fromMap(x))),
      dateTime: DateTime.parse(
        map['dateTime'],
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String? authToken;
  String? userId;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Orders(this._orders, {this.authToken, this.userId});

  Future<void> fetchAndStoreOrders() async {
    var url = Uri.parse('${Urls.orders}/$userId.json?auth=$authToken');

    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem.fromMap(orderData));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var url = Uri.parse(
        '${Urls.orders}/$userId.json?auth=$authToken'); // firebase will create collection for that (products), firebase requires .json extension

    var item = OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now());

    var itemMap = item.toMap();
    itemMap.remove('id');

    final response = await http.post(url, body: json.encode(item.toMap()));

    itemMap.addAll({'id': json.decode(response.body)['name']});

    _orders.insert(0, OrderItem.fromMap(itemMap));

    notifyListeners();
  }
}
