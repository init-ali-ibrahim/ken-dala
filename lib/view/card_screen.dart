import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:isar/isar.dart';
import 'package:ken_dala/constants/app_colors.dart';
import 'package:ken_dala/model/product.dart';
import 'package:ken_dala/view/widgets/custom_textfield.dart';

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
  late Map<String, dynamic> dataUser = {};

  String sendUrl = 'http://192.168.0.103:80/api/v1/orders';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    secureStorage = const FlutterSecureStorage();
    productService = ProductService(widget.isar);
    productListFuture = productService.getAllProducts();

    getUserData();
  }

  Future<void> getUserData() async {
    String? authToken = await secureStorage.read(key: 'token');
    const url = 'http://192.168.0.103:80/api/v1/auth/check';
    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $authToken',
    });

    print(authToken);

    // Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(jsonDecode(response.body));

      dataUser = jsonDecode(response.body);

      // print(dataUser);
      // print(dataUser['data']['name']);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> sendFoodCard() async {
    String? authToken = await secureStorage.read(key: 'token');

    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Токен не найден, пожалуйста, авторизуйтесь')),
      );
      return;
    }

    List<Product> products = await productService.getAllProducts();
    List<Map<String, dynamic>> productData = products
        .where((product) => product.quantity > 0)
        .map((product) =>
            {"product_id": product.productId, "quantity": product.quantity})
        .toList();

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
      body: jsonEncode({
        "products": productData,
        "name": dataUser['data']['name'],
        "phone": dataUser['data']['phone'],
        "delivery_type": "pickup"
      }),
    );

    print('Отправляем на сервер:');
    print('Токен: $authToken');
    print('Тело запроса: ${jsonEncode({
          "products": productData,
          "name": "assylzhan",
          "phone": "77077701465",
          "delivery_type": "pickup"
        })}');
    print('Тело ответа: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Успешно отправлено')),
      );
      clearProduct();
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
                  border:
                      Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: Image.network(
                            product.images,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 160,
                          child: buildRichText(
                              product.name, '₸ ${product.price.toString()}'),
                        )
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
                                await updateProductQuantity(
                                    product, product.quantity - 1);
                              }
                              productService
                                  .checkAndNavigateIfNoProducts(context);
                            },
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            child: Text(
                              '${product.quantity}',
                              key: ValueKey<int>(product.quantity),
                            ),
                          ),
                          IconButton(
                            icon: product.quantity >= 10
                                ? Icon(Icons.add,
                                    size: 20, color: Colors.grey.shade300)
                                : const Icon(Icons.add, size: 20),
                            onPressed: product.quantity >= 10
                                ? null
                                : () {
                                    updateProductQuantity(
                                        product, product.quantity + 1);
                                  },
                          ),

                          // Text(dataUser['data']['name']),
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
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(width: 1, color: Colors.grey))),
        height: 160,
        margin: const EdgeInsets.only(top: 10),
        child: Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 10),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashFactory: NoSplash.splashFactory,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Метод оплаты',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFF4F4F6),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F4F6),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.credit_card,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'New card',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.check,
                                        color: AppColors.primary_color,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F4F6),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.credit_card,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'New card',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.check,
                                        color: AppColors.primary_color,
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
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFF13181E),
                          borderRadius: BorderRadius.circular(99)),
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
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Итого:'),
                      ValueListenableBuilder<int>(
                        valueListenable: productService.totalPriceNotifier,
                        builder: (context, totalPrice, child) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              '₸ $totalPrice',
                              key: ValueKey<int>(totalPrice),
                              style: const TextStyle(fontSize: 24),
                            ),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    builder: (context) {
                      return DraggableScrollableSheet(
                        initialChildSize: 0.5,
                        minChildSize: 0.20,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) =>
                            SingleChildScrollView(
                          controller: scrollController,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -15,
                                child: Container(
                                  width: 60,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      5,
                                    ),
                                    color: AppColors.primary_color,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SizedBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Детали заказа',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      CustomTextfield(
                                        controller: _nameController,
                                        label: 'Введите имя',
                                        icon: const Icon(
                                          Icons.account_circle_outlined,
                                          color: AppColors.primary_color,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      CustomTextfield(
                                        controller: _nameController,
                                        label: 'Введите номер телефона',
                                        icon: const Icon(
                                          Icons.phone,
                                          color: AppColors.primary_color,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(25.0),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary_color
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: const Text(
                                                textAlign: TextAlign.center,
                                                'Самовывоз',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/map');
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary_color
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: const Text(
                                                  'Выбрать местоположение',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 30),
                                      TextButton(
                                        onPressed: () {
                                          sendFoodCard();
                                        },
                                        style: TextButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(55),
                                          backgroundColor:
                                              AppColors.primary_color,
                                        ),
                                        child: const Text(
                                          'Оплатить',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                  backgroundColor: AppColors.primary_color,
                ),
                child: const Text(
                  'Оплатить',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: const Padding(
            padding: EdgeInsets.only(top: 10, right: 10),
            child: Text(
              'Очистить все товары из корзины',
              style: TextStyle(fontSize: 15, color: Colors.black),
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
              onPressed: () async {
                await clearProduct();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (Route<dynamic> route) => false);
              },
              child: const Text(
                'Очистить',
                style: TextStyle(color: AppColors.primary_color),
              ),
            ),
          ],
        );
      },
    );
  }
}
