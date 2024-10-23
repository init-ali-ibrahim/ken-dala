import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ken_dala/constants/app_colors.dart';
import 'package:ken_dala/services/auth_service.dart';
import 'package:ken_dala/view/widgets/custom_button.dart';
import 'package:ken_dala/view/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  late String _fcmToken;

  @override
  void initState() {
    super.initState();

    final messaging = FirebaseMessaging.instance;

    messaging.getToken().then((token) {
      log('FCM Token: $token');
      _fcmToken = token!;
      // FirebaseMessaging.instance.subscribeToTopic("admin");
      // print('Subscribed to topic');
      print('$_fcmToken');
    });
  }

  void _register() async {
    try {
      final response = await _authService.register(_nameController.text, _lastNameController.text, _phoneController.text, _emailController.text, _passwordController.text,
          _passwordConfirmController.text, _fcmToken);

      print(response);

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response['message']}')),
        );
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Internet connection. Please try again later.')),
      );
      print('No Internet connection');
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bad response format from server.')),
      );
      print('Bad response format');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error: $e');
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
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.person_add, size: 80, color: AppColors.primary_color),
            const SizedBox(height: 20),
            const Text(
              'Cоздать аккаунт',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Зарегистрируйтесь, чтобы начать работу',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            // TextFormField(
            //   controller: _nameController,
            //   decoration: InputDecoration(
            //     labelText: 'Имя',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     prefixIcon: const Icon(Icons.person),
            //   ),
            // ),

            CustomTextfield(
              controller: _nameController,
              label: 'Имя',
              ktype: TextInputType.text,
              icon: const Icon(Icons.person),
            ),
            const SizedBox(height: 15),
            CustomTextfield(
              controller: _lastNameController,
              label: 'Фамилия',
              ktype: TextInputType.text,
              icon: const Icon(Icons.person_outline),
            ),
            // TextFormField(
            //   controller: _lastNameController,
            //   decoration: InputDecoration(
            //     labelText: 'Фамилия',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     prefixIcon: const Icon(Icons.person_outline),
            //   ),
            // ),
            const SizedBox(height: 15),
            CustomTextfield(
              controller: _phoneController,
              label: 'Номер телефонa',
              ktype: TextInputType.phone,
              icon: const Icon(Icons.phone),
            ),
            // TextFormField(
            //   controller: _phoneController,
            //   keyboardType: TextInputType.phone,
            //   decoration: InputDecoration(
            //     labelText: 'Номер телефона',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     prefixIcon: const Icon(Icons.phone),
            //   ),
            // ),
            const SizedBox(height: 15),
            CustomTextfield(
              controller: _emailController,
              label: 'Email',
              ktype: TextInputType.emailAddress,
              icon: const Icon(Icons.email),
            ),
            // TextFormField(
            //   controller: _emailController,
            //   keyboardType: TextInputType.emailAddress,
            //   decoration: InputDecoration(
            //     labelText: 'Email',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     prefixIcon: const Icon(Icons.email),
            //   ),
            // ),
            const SizedBox(height: 15),
            // TextFormField(
            //   controller: _passwordController,
            //   obscureText: true,
            //   decoration: InputDecoration(
            //     labelText: 'Пароль',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     prefixIcon: const Icon(Icons.lock),
            //   ),
            // ),
            CustomTextfield(
              controller: _passwordController,
              obs: true,
              label: 'Пароль',
              icon: const Icon(Icons.lock),
            ),
            const SizedBox(height: 15),
            // TextFormField(
            //   controller: _passwordConfirmController,
            //   obscureText: true,
            //   decoration: InputDecoration(
            //     labelText: 'Подтвердите пароль',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //     prefixIcon: const Icon(Icons.lock_outline),
            //   ),
            // ),
            CustomTextfield(
              controller: _passwordConfirmController,
              obs: true,
              label: 'Подтвердите пароль',
              icon: const Icon(Icons.lock_outline),
            ),
            const SizedBox(height: 25),
            // ElevatedButton(
            //   onPressed: _register,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.red,
            //     padding: const EdgeInsets.symmetric(vertical: 15),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //   ),
            //   child: const Text(
            //     'Войти',
            //     style: TextStyle(fontSize: 18, color: Colors.white),
            //   ),
            // ),
            CustomButton(onTap: _register, text: 'Войти'),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/login');
            //   },
            //   child: const Text(
            //     'Already have an account? Log In',
            //     style: TextStyle(fontSize: 16, color: Colors.red),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
