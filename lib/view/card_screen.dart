import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:ken_dala/model/product.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  final Isar isar;

  const ProductListScreen({super.key, required this.isar});


  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductService productService;
  late Future<List<Product>> productListFuture;

  late FlutterSecureStorage secureStorage;

  String sendUrl = 'http://192.168.43.174:80/api/v1/orders';

  @override
  void initState() {
    super.initState();
    secureStorage = const FlutterSecureStorage();
    productService = ProductService(widget.isar);
    productListFuture = productService.getAllProducts();
  }

  Future<void> sendFoodCard() async {
    String? authToken = await secureStorage.read(key: 'token');

    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Токен не найден, пожалуйста, авторизуйтесь')),
      );
      return;
    }

    List<Product> products = await productService.getAllProducts();
    List<Map<String, dynamic>> productData =
        products.where((product) => product.quantity > 0).map((product) => {"product_id": product.id, "quantity": product.quantity}).toList();

    if (productData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Корзина пуста')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(sendUrl),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"products": productData, "name": "assylzhan", "phone": "77077701465", "delivery_type": "pickup"}),
    );

    print('Отправляем на сервер:');
    print('Токен: $authToken');
    print('Тело запроса: ${jsonEncode({"products": productData, "name": "assylzhan", "phone": "77077701465", "delivery_type": "pickup"})}');

    print('');

    print('Тело ответа: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Успешно отправлено')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при отправке')),
      );
    }
  }

  Future<void> clearProduct() async {
    await productService.clearProducts();
    setState(() {
      productListFuture = productService.getAllProducts();
    });
  }

  Future<void> updateProductQuantity(Product product, int quantity) async {
    await productService.updateQuantity(product, quantity);

    setState(() {
      productListFuture = productService.getAllProducts();
    });
  }

  Future<void> deleteProduct(Product product) async {
    await productService.deleteProduct(product.id);
    setState(() {
      productListFuture = productService.getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: const BorderRadius.all(Radius.circular(99)),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF4F4F6),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              const Text(
                'Корзина',
                style: TextStyle(color: Colors.black),
              ),
              InkWell(
                // onTap: () => clearProduct(),
                onTap: () => showCustomDialog(context),
                borderRadius: const BorderRadius.all(Radius.circular(99)),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF4F4F6),
                  ),
                  child: const Icon(
                    Icons.delete_outlined,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: productListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: double.infinity,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product.images,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        buildRichText(product.name, '₸ ${product.price.toString()}'),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () async {
                              if (product.quantity > 0) {
                                await updateProductQuantity(product, product.quantity - 1);
                              }
                            },
                          ),
                          Text(
                            '${product.quantity}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: () {
                              updateProductQuantity(product, product.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 160,
        margin: const EdgeInsets.only(top: 10),
        child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF13181E), borderRadius: BorderRadius.circular(99)),
                      padding: const EdgeInsets.all(15),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.white,
                            size: 30,
                          )
                        ],
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: productService.totalPriceNotifier,
                      builder: (context, totalPrice, child) {
                        return Text(
                          'Итого: \$${totalPrice.toStringAsFixed(2)}',
                        );
                      },
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: [
                    //     Text(
                    //       'Итого',
                    //       style: TextStyle(color: Colors.grey.shade600),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // checkAuthToken();
                    sendFoodCard();
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(55),
                    backgroundColor: const Color(0xFFDA3131),
                  ),
                  child: const Text(
                    'Оплатить',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget buildRichText(String topText, String bottomText) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$topText\n',
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          TextSpan(
            text: bottomText,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 10, right: 10),
            child: Text(
              'Очистить все товары из корзины',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Отмена'),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false),
              child: const Text(
                'Очистить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
