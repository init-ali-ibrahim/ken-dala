// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'package:ken_dala/view/login_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   bool _isLoading = false;
//   Map<String, dynamic>? _profileData;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//   }
//
//   final storage = const FlutterSecureStorage();
//
//   Future<String?> _getToken() async {
//     return await storage.read(key: 'token');
//   }
//
//   Future<void> _fetchProfileData() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     String? lox = await storage.read(key: 'token');
//
//     final response = await http.get(
//       Uri.parse('http://192.168.0.219:80/api/v1/auth/profile'),
//       headers: <String, String>{
//         'Authorization': 'Bearer $lox',
//         'Accept': 'application/json',
//       },
//     );
//
//     print('$lox ТОКЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕЕен');
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       if (data['success']) {
//         setState(() {
//           _profileData = data['data'];
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load profile data';
//         });
//       }
//     } else {
//       setState(() {
//         _errorMessage = 'Server error: ${response.body}';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Profile'),
//       ),
//       body: FutureBuilder<String?>(
//         future: _getToken(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(body: Center(child: CircularProgressIndicator()));
//           } else if (snapshot.hasData && snapshot.data != null) {
//             return _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _profileData != null
//                     ? Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildProfileInfo('Name', '${_profileData!['name']} ${_profileData!['last_name']}'),
//                             _buildProfileInfo('Email', _profileData!['email']),
//                             _buildProfileInfo('Phone', _profileData!['phone']),
//                             _buildProfileInfo('Created At', _profileData!['created_at']),
//                             _buildProfileInfo('Updated At', _profileData!['updated_at']),
//                             _buildProfileInfo('Theme', _profileData!['theme']),
//                             _buildProfileInfo('Is Admin', _profileData!['is_admin'] == 1 ? 'Yes' : 'No'),
//                             const SizedBox(height: 20),
//                             if (_errorMessage != null)
//                               Text(
//                                 _errorMessage!,
//                                 style: const TextStyle(color: Colors.red),
//                               ),
//                           ],
//                         ),
//                       )
//                     : Center(child: ElevatedButton(onPressed: () {}, child: Text('No profile data available')));
//           } else {
//             return const LoginScreen();
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildProfileInfo(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             '$title:',
//             style: const TextStyle(color: Colors.white, fontSize: 16),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.grey, fontSize: 16),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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

    final response = await http.get(
      Uri.parse('http://192.168.0.219:80/api/v1/orders'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = jsonDecode(response.body);
      List<Order> orders = (data as List).map((order) => Order.fromJson(order)).toList();
      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
                    Navigator.pop(context, '/');
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            'Ali',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '+7 706 622 3709',
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _authService.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/profile', (Route<dynamic> route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                ),
                child: const Text(
                  'LogOut',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              FutureBuilder<List<Order>>(
                future: getOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    var orders = snapshot.data!;

                    if (orders.isEmpty) {
                      return Column(
                        children: [
                          const Icon(
                            Icons.history,
                            size: 60,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Your order history will appear here',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                            ),
                            child: const Text(
                              'LogOut',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: order.products.map((product) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Text('Product: ${product.name}'),
                                                // Text('Quantity: ${product.quantity}'),
                                                // Text('Price: ${product.price}'),
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(99),
                                                  child: Image.network(
                                                    product.imageUrl,
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  )),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          order.status,
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        Text(
                                          '20 T',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ));
                        }).toList(),
                      ),
                    );
                  } else {
                    return const Center(child: Text('No orders found'));
                  }
                },
              ),
            ],
          ),
        ));
  }
}
