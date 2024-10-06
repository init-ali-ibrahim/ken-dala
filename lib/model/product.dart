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

  ProductService(this.isar);


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
  }

  Future<void> updateQuantity(Product product, int quantity) async {
    try {
      await isar.writeTxn(() async {
        if (quantity <= 0) {
          await isar.products.delete(product.id);
        } else if (quantity > 30) {
          product.quantity = 30;
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
  }

  Future<void> deleteProduct(int id) async {
    await isar.writeTxn(() async {
      await isar.products.delete(id);
    });
  }

  Future clearProducts() async {
    final allProduct = await getAllProducts();
    await isar.writeTxn(() async {
      for (var product in allProduct) {
        await isar.products.delete(product.id);
      }
    });
  }
}
