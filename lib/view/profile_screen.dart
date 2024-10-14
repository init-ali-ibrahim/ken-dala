import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ken_dala/services/auth_service.dart';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final int quantity;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      quantity: json['pivot']['quantity'],
      imageUrl: json['image'],
    );
  }
}

class Order {
  final int id;
  final String name;
  final String phone;
  final String status;
  final String deliveryType;
  final String orderedAt;
  final List<Product> products;

  Order({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.deliveryType,
    required this.orderedAt,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var productsList = (json['products'] as List).map((product) => Product.fromJson(product)).toList();
    return Order(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      status: json['status'],
      deliveryType: json['delivery_type'],
      orderedAt: json['ordered_at'],
      products: productsList,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final AuthService _authService = AuthService();
  late FlutterSecureStorage secureStorage;
  late Future<dynamic> ordersFuture;

  @override
  initState() {
    super.initState();
    secureStorage = const FlutterSecureStorage();
    ordersFuture = getOrders();
  }

  Future<List<Order>> getOrders() async {
    String? authToken = await secureStorage.read(key: 'token');

    const url = 'http://192.168.0.103:80/api/v1/orders';



    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = jsonDecode(response.body);
      print('Response data: $data');

      List<Order> orders = (data as List).map((order) => Order.fromJson(order)).toList();
      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    String? authToken = await secureStorage.read(key: 'token');
    const url = 'http://192.168.0.103:80/api/v1/auth/check';
    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $authToken',
    });

    Future.delayed(const Duration(seconds: 2));

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(jsonDecode(response.body));

      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          automaticallyImplyLeading: false,
          title: SizedBox(
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
                  'Профиль',
                  style: TextStyle(color: Colors.black),
                ),
                InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(99)),
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>>(
                future: getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const UserEmpty();
                  } else if (snapshot.hasError) {
                    return const UserEmpty();
                  } else if (snapshot.hasData) {
                    var userData = snapshot.data;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InkWell(
                        splashFactory: NoSplash.splashFactory,
                        onTap: () {
                          // Navigator.pushNamed(context, '/profile_edit');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${userData!['data']['name'] ?? 'error'}',
                                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${userData['data']['phone'] ?? 'error'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const UserEmpty();
                  }
                },
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Order>>(
                future: getOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CartEmpty();
                  } else if (snapshot.hasError) {
                    return const CartEmpty();
                  } else if (snapshot.hasData) {
                    var orders = snapshot.data!;

                    if (orders.isEmpty) {
                      return const CartEmpty();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Text('Заказы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Column(
                          children: orders.map((order) {
                            return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(15),
                                height: 160,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Order ${order.id} - ${order.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('${order.orderedAt}'),
                                        const SizedBox(height: 10),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: order.products.asMap().entries.map((entry) {
                                            int index = entry.key;
                                            var product = entry.value;

                                            if (index < 2) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(99),
                                                  child: Image.network(
                                                    product.imageUrl,
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              );
                                            } else if (index == 2) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(99),
                                                  child: Container(
                                                    height: 60,
                                                    width: 60,
                                                    color: Colors.grey[200],
                                                    child: const Icon(Icons.more_horiz, size: 30),
                                                  ),
                                                ),
                                              );
                                            }
                                            return Container();
                                          }).toList(),
                                        )
                                      ],
                                    )),
                                    Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            order.status,
                                            style: const TextStyle(color: Colors.green),
                                          ),
                                          const Text(
                                            '20 T',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ));
                          }).toList(),
                        )
                      ]),
                    );
                  } else {
                    return const CartEmpty();
                  }
                },
              ),
            ],
          ),
        ));
  }
}

class CartEmpty extends StatelessWidget {
  const CartEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.width - 40,
                  child: Image.asset(
                    'assets/images/cartEmpty.png',
                    fit: BoxFit.cover,
                  ),
                )),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.width - 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(60),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: const Text(
            textAlign: TextAlign.center,
            'У вас пока корзина пуста, можите добавить товары',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    ));
  }
}

class UserEmpty extends StatefulWidget {
  const UserEmpty({super.key});

  @override
  State<UserEmpty> createState() => _UserEmptyState();
}

class _UserEmptyState extends State<UserEmpty> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () {
          // Navigator.pushNamed(context, '/profile_edit');
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
