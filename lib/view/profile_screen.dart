import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ken_dala/services/auth_service.dart';
import 'package:ken_dala/view/widgets/custom_row2.dart';
import 'package:ken_dala/view/widgets/custom_row_data.dart';

import '../constants/app_colors.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final int price;
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
    var productsList = (json['products'] as List)
        .map((product) => Product.fromJson(product))
        .toList();
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
  final AuthService _authService = AuthService();
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

      List<Order> orders =
          (data as List).map((order) => Order.fromJson(order)).toList();
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
                onTap: () {
                  _authService.logout();
                  Navigator.pop(context);
                },
                borderRadius: const BorderRadius.all(Radius.circular(99)),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary_color.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.logout),
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
                      // onTap: () {
                      // },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor:
                                      AppColors.primary_color.withOpacity(0.2),
                                  child: const Icon(Icons.person,
                                      color: AppColors.primary_color, size: 30),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${userData!['data']['name'] ?? 'error'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary_color,
                                      ),
                                    ),
                                    Text(
                                      '${userData['data']['phone'] ?? 'error'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // const Icon(Icons.arrow_forward_ios, size: 20),
                              ],
                            ),
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    InkWell(
                      splashFactory: NoSplash.splashFactory,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.pushNamed(context, '/map');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Алматы, 11-й микрорайон, 36',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_sharp,
                                size: 20,
                              )
                            ],
                          ),
                          RichText(
                              text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            children: [
                              TextSpan(text: 'Бесплатная доставка, '),
                              TextSpan(
                                text: 'через 33 минуты',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Мои заказы',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        Column(
                          children: orders.map((order) {
                            return InkWell(
                              onTap: () {
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    5,
                                                  ),
                                                  color:
                                                      AppColors.primary_color,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: SizedBox(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Детали заказа',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: AppColors
                                                                .dark_grey_color,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Оплачен',
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              size: 30,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Заказ сделан',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          '2024-10-16 10:37:04',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: AppColors
                                                                .dark_primary_color,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Доставка',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: AppColors
                                                            .dark_grey_color,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      height: 60,
                                                      width: double.maxFinite,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        color: const Color(
                                                            0xFFF4F4F6),
                                                      ),
                                                      child: const Center(
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              size: 30,
                                                              Icons
                                                                  .location_pin,
                                                              color: Colors.red,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              'Жетысу 3, д.25/б',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const CustomRowData(
                                                      name: "Номер заказа",
                                                      value: '1729075024',
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const CustomRowData(
                                                      name: 'Имя клиента',
                                                      value: 'assylzhan',
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const CustomRowData(
                                                      name: 'Номер телефона',
                                                      value: '+7 707 770 14 65',
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Вы заказали',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: AppColors
                                                            .dark_grey_color,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      height: 110,
                                                      width: double.maxFinite,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        color: const Color(
                                                            0xFFF4F4F6),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 120,
                                                            height: 120,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/pizza.png',
                                                                height: 90,
                                                                width: 90,
                                                              ),
                                                            ),
                                                          ),
                                                          const Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                13.0,
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Пицца с грибами',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                  CustomRow2(
                                                                      name:
                                                                          'Кол-во',
                                                                      size1: 14,
                                                                      value:
                                                                          'х1'),
                                                                  CustomRow2(
                                                                      name:
                                                                          'Стоимость',
                                                                      size1: 14,
                                                                      value:
                                                                          '20 Т'),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Итого',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: AppColors
                                                            .dark_grey_color,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    const CustomRow2(
                                                      name: 'Общая стоимость',
                                                      weight: FontWeight.bold,
                                                      color1: Colors.black,
                                                      value: '20 T',
                                                      size1: 20,
                                                      size2: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(15),
                                height: 160,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F4F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order ${order.id} - ${order.name}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: AppColors.primary_color,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('${order.orderedAt}'),
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: order.products
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int index = entry.key;
                                              var product = entry.value;

                                              if (index < 2) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            99),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            99),
                                                    child: Container(
                                                      height: 60,
                                                      width: 60,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                          Icons.more_horiz,
                                                          size: 30),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Container();
                                            }).toList(),
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          order.status,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          '20 T',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const CartEmpty();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CartEmpty extends StatelessWidget {
  const CartEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const SizedBox(height: 30),
        const Text(
          'Мои заказы',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          //   ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    'assets/images/empty_b.png',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                textAlign: TextAlign.center,
                'Ваша корзина пуста, вы можете добавить новые товары',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
