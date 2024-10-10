import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;
  final int productId;
  final String name;
  final String slug;
  final String price;
  final String images;
  int quantity;

  Product({
    required this.productId,
    required this.name,
    required this.slug,
    required this.price,
    required this.images,
    required this.quantity,
  });
}

class ProductService {
  final Isar isar;
  final ValueNotifier<int> totalPriceNotifier = ValueNotifier(0);
  final ValueNotifier<int> quantitySingleProductNotifier = ValueNotifier(0);

  ProductService(this.isar){
    _updateTotalPrice();
  }

  Future<List<Product>> getAllProducts() async {
    return await isar.products.where().findAll();
  }

  Future<void> addProduct(Product product) async {
    try {
      await isar.writeTxn(() async {
        await isar.products.put(product);
      });
    } catch (e, stackTrace) {
      print("Error in addProduct: $e");
      print("Stack trace: $stackTrace");
    }

    await _updateTotalPrice();
  }

  Future<void> updateQuantity(Product product, int quantity) async {
    try {
      await isar.writeTxn(() async {
        if (quantity <= 0) {
          await isar.products.delete(product.id);
        } else if (quantity > 10) {
          product.quantity = 10;
          await isar.products.put(product);
        } else {
          product.quantity = quantity;
          await isar.products.put(product);
        }
      });
    } catch (e, stackTrace) {
      print("Error in updateQuantity: $e");
      print("Stack trace: $stackTrace");
    }

    await _updateTotalPrice();
  }

  Future<void> deleteProduct(int id) async {
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });

    await _updateTotalPrice();
  }

  Future clearProducts() async {
    final allProduct = await getAllProducts();
    await isar.writeTxn(() async {
      for (var product in allProduct) {
        await isar.products.delete(product.id);
      }
    });
  }

  Future<void> _updateTotalPrice() async {
    int totalPrice = (await calculateTotalPrice());
    totalPriceNotifier.value = totalPrice;
  }

  Future<int> calculateTotalPrice() async {
    int totalPrice = 0;

    final allProducts = await getAllProducts();

    for (var product in allProducts) {
      totalPrice += int.parse(product.price) * product.quantity;
    }

    return totalPrice;
  }
}
