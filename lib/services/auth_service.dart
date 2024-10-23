import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String registerUrl = 'http://192.168.0.103:80/api/v1/auth/register';
  final String loginUrl = 'http://192.168.0.103:80/api/v1/auth/login';

  final messaging = FirebaseMessaging.instance;


  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register(String name, String lastName, String phone, String email, String password, String passwordConfirmation, String notificationToken) async {
    final requestBody = {
      'name': name,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'device_token': notificationToken
    };

    print('Отправляемые данные: $requestBody');

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Ответ сервера: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          await secureStorage.write(key: 'token', value: data['token']);
        }
        return data;
      } else {
        final data = jsonDecode(response.body);
        throw Exception('Failed to register user: ${data['message'] ?? 'Unknown error'}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        await secureStorage.write(key: 'token', value: data['token']);
      }
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: 'token');
  }

  Future<bool> hasToken() async {
    final token = await secureStorage.read(key: 'token');
    return token != null;
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
  }
}
