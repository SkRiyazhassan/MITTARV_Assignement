import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  Map<int, int> _cartItems = {};

  Map<int, int> get cartItems => _cartItems;

  void addToCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id] = _cartItems[product.id]! + 1;
    } else {
      _cartItems[product.id] = 1;
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      if (_cartItems[product.id]! > 1) {
        _cartItems[product.id] = _cartItems[product.id]! - 1;
      } else {
        _cartItems.remove(product.id);
      }
    }
    notifyListeners();
  }

  double getTotalPrice(List<Product> products) {
    return _cartItems.entries.fold(0.0, (total, entry) {
      final product = products.firstWhere((prod) => prod.id == entry.key);
      return total + product.price * entry.value;
    });
  }
}
