import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  void _updateFavoriteStatus(bool status) {
    isFavorite = status;
    notifyListeners();
  }

  // optimistic updating
  Future<void> toggleFavoriteStatus(String? token, String? userId) async {
    var url = Uri.parse(
        'https://shop-app-8991f-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token'); // firebase will create collection for that (products), firebase requires .json extension

    bool? oldStatus = isFavorite;
    _updateFavoriteStatus(!isFavorite);

    final response =
        await http.put(url, body: json.encode(isFavorite));

    if (response.statusCode >= 400) {
      _updateFavoriteStatus(oldStatus);
      throw HttpException('Could not update the favorite status');
    }

    oldStatus = null;
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'title': title});
    result.addAll({'description': description});
    result.addAll({'price': price});
    result.addAll({'imageUrl': imageUrl});
    result.addAll({'isFavorite': isFavorite});

    return result;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}
