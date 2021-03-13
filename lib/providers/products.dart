import 'dart:convert'; //offers tools to convert data
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';

// changeNotifier is a Dart Method it give the access to notityListeners()
class Products with ChangeNotifier {
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

  //var _showFavoritesOnly = false;
  final String authToken;

  Products(this.authToken, this._items);

  List<Product> get items {
    //if (_showFavoritesOnly) {
    //  return _items.where((prodItem) => prodItem.isFavorite).toList();
    //}
    return [..._items]; // crea una copia di items
  }

  /*List<Product> get items {
    return [..._items]; 
  }*/
  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  //void showFavoritesOnly() {
  //  _showFavoritesOnly = true;
  //  notifyListeners();
  //}

  //void showAll() {
  //  _showFavoritesOnly = false;
  //  notifyListeners();
  //}

  Future<void> fetchAndSetProducts() async {
    final url =
        'https://flutter-e-commerce-8ea1f-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    const url =
        'https://flutter-e-commerce-8ea1f-default-rtdb.firebaseio.com/products.json';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorite': product.isFavorite
        }),
      );
      print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(
            response.body)['name'], //prende ID generato in auto da Firebase
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-e-commerce-8ea1f-default-rtdb.firebaseio.com/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    final url =
        'https://flutter-e-commerce-8ea1f-default-rtdb.firebaseio.com/products/$id.json';
    final existingProductIndex = _items.indexWhere(
        (prod) => prod.id == id); // get id of product that i want to remove
    var existingProduct = _items[existingProductIndex];
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw Exception();
      }
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex,
          existingProduct); // if it fail, re-insert the prod in the list
      notifyListeners();
    });
    _items.removeAt(existingProductIndex); // remove prod from list
    notifyListeners();
  }
}
