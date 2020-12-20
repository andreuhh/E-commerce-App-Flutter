import 'package:flutter/foundation.dart';
import '../models/products.dart';

// changeNotifier is a Dart Method it give the access to notityListeners()
class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items]; // crea una copia di items
  }

  void addProduct() {
    //_items.add(value);
    notifyListeners();
  }
}
