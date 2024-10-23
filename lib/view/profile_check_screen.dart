import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:ken_dala/constants/app_colors.dart';
import 'package:ken_dala/services/auth_service.dart';
import 'package:ken_dala/view/profile_screen.dart';
import 'package:ken_dala/view/widgets/custom_button.dart';

class ProfileCheckScreen extends StatefulWidget {
  const ProfileCheckScreen({super.key});

  @override
  _ProfileCheckScreenState createState() => _ProfileCheckScreenState();
}

class _ProfileCheckScreenState extends State<ProfileCheckScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  void _checkToken() async {
    bool hasToken = await _authService.hasToken();
    setState(() {
      _isAuthenticated = hasToken;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isAuthenticated ? ProfileScreen() : const EmptyScreen();
  }
}

class EmptyScreen extends StatefulWidget {
  const EmptyScreen({super.key});

  @override
  State<EmptyScreen> createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  // Проверка подключения к интернету
  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();

    // Проверяем доступность интернет-соединения через пинг
    bool isConnected = await _hasInternetConnection();

    setState(() {
      if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
        _connectionStatus = isConnected ? 'Connected to the Internet' : 'No Internet Connection';
      } else {
        _connectionStatus = 'No Internet Connection';
      }
    });
  }

  // Функция для пинга интернет-соединения
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
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
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - kToolbarHeight - 30,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [


                SizedBox(height: 100),

                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     Text(
                //       'Connection Status:',
                //       style: TextStyle(fontSize: 20),
                //     ),
                //     SizedBox(height: 20),
                //     Text(
                //       _connectionStatus,
                //       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                //     ),
                //     SizedBox(height: 20),
                //     ElevatedButton(
                //       onPressed: _checkConnection,
                //       child: Text('Check Connection'),
                //     ),
                //   ],
                // ),
                SizedBox(height: MediaQuery.of(context).size.height / 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Image.asset(
                        'assets/images/empty_profile.png',
                        height: 300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Вы не вошли в систему',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Пожалуйста, войдите в систему.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomButton(
                      background_color: Colors.white,
                      text_color: AppColors.primary_color,
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      text: 'Войти',
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      text: 'Зарегистрироваться',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
