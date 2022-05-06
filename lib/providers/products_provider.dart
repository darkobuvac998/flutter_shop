import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/shared_data.dart';
import './product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoriteOnly = false;

  String? authToken;
  String? userId;

  ProductsProvider(this._items, {this.authToken, this.userId});

  List<Product> get items {
    // if(_showFavoriteOnly){
    //   return _items.where((element) => element.isFavorite,).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        '${Urls.products}.json?auth=$authToken&$filterString'); // token for authentification, firebase supports it as query parameter
    // orderBy="creatorId"&equalTo="userId" firebase mechanism for filtering data
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        return;
      }

      var urlFavorites = Uri.parse(
          '${Urls.userFavorites}/$userId.json?auth=$authToken'); // firebase will create collection for that (products), firebase requires .json extension

      final favoriteResponse = await http.get(urlFavorites);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData) {
          var tempDate = prodData as Map<String, dynamic>;
          tempDate.addAll({'id': prodId});
          // tempDate.update(
          //     'isFavorite',
          //     (_) => favoriteData[prodId] == null
          //         ? false
          //         : favoriteData[prodId] ?? false,
          //     ifAbsent: (() => favoriteData[prodId] == null
          //         ? false
          //         : favoriteData[prodId] ?? false));
          tempDate['isFavorite'] = favoriteData[prodId];
          print(tempDate);
          loadedProducts.add(Product.fromMap(tempDate));
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    // async all code inside body is wrapped inside the future and that future is returned automatically, one benefit is that you can remove then and catchError from code
    var url = Uri.parse(
        '${Urls.products}.json?auth=$authToken'); // firebase will create collection for that (products), firebase requires .json extension

    try {
      // next code is invisibally wrapped into then block
      var bodyData = product.toMap()..remove('isFavorite');
      bodyData.addAll({'creatorId': userId});

      final response = await http.post(
        url,
        body: json.encode(bodyData),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      // throw error;
      rethrow;
    }

    // return Future.value(); // won't work because this return value from anonymous function you need to return from addProduct function so inside it's scope
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      var url = Uri.parse(
          '${Urls.products}/$id.json?auth=$authToken'); // firebase will create collection for that (products), firebase requires .json extension
      var data = newProduct.toMap();
      data.remove('isFavorite');
      await http.patch(url, body: json.encode(data));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProduct(String id) async {
    var url = Uri.parse(
        '${Urls.products}/$id.json?auth=$authToken'); // firebase will create collection for that (products), firebase requires .json extension
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;

    //optimising updating pattern, if deletnig fails we rollback out deleted product
  }

  // void showFavoriteOnly(){
  //   _showFavoriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll(){
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  List<Product> searchItemsByTitle(String term) {
    return _items.where(
      (element) {
        print(element.title.contains(term));
        return element.title.contains(term);
      },
    ).toList();
  }
}
  // chamge data only from insade of the class because, in that
  // way you can call notifyListeners to tell other widget that depend on data
  // that data changed

  //if data would chande directly from any widget, other widget then wouldn't know about changes

// with keyword -> creates mixins
// it is similar to extending a class but it's more like a merging properties
// merge some properties or some methods into your existing class, yout don't make your class into instance of that inherited class
// inheritance lite
