// import 'package:collection/collection.dart';
// import 'package:flutter/foundation.dart';
// import 'package:ken_dala/model/product.dart';
//
// class CardProvider extends ChangeNotifier {
//   final List<Product> _items = [];
//
//   List<Product> get items => _items;
//
//   void addProduct(Product product) {
//     final existingProduct = _items.firstWhereOrNull((p) => p.id == product.id);
//     if (existingProduct != null) {
//       existingProduct.quantity++;
//     } else {
//       _items.add(product);
//     }
//     notifyListeners();
//   }
//
//   void addQuantity(Product product) {
//     final existingProductIndex = _items.indexWhere((p) => p.id == product.id);
//     if (existingProductIndex != -1 && _items[existingProductIndex].quantity < 20) {
//       _items[existingProductIndex].quantity++;
//     }
//     notifyListeners();
//   }
//
//   void removeQuantity(Product product) {
//     final existingProductIndex = _items.indexWhere((p) => p.id == product.id);
//     if (existingProductIndex != -1) {
//       if (_items[existingProductIndex].quantity > 1) {
//         // _items[existingProductIndex].quantity--;
//       } else {
//         _items.removeAt(existingProductIndex);
//       }
//     }
//     notifyListeners();
//   }
//
//   void removeProduct(Product product) {
//     _items.remove(product);
//     notifyListeners();
//   }
//
//   void clearCart() {
//     _items.clear();
//     notifyListeners();
//   }
// }
//
