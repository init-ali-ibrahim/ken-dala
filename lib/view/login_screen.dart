import 'package:flutter/material.dart';
import 'package:ken_dala/constants/app_colors.dart';
import 'package:ken_dala/services/auth_service.dart';
import 'package:ken_dala/view/widgets/custom_button.dart';
import 'package:ken_dala/view/widgets/custom_textfield.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _validatePhoneInput() {
    setState(() {
      if (_phoneController.text.isEmpty) {
        _errorPhoneMessage = 'Это поле обязательно для заполнения';
      } else {
        _errorPhoneMessage = null;
      }
    });
  }

  void _validatePasswordInput() {
    setState(() {
      if (_passwordController.text.isEmpty) {
        _errorPasswordMessage = 'Это поле обязательно для заполнения';
      } else {
        _errorPasswordMessage = null;
      }
    });
  }

  String? _errorPhoneMessage;
  String? _errorPasswordMessage;
  String? _errorMessage;


  void _login() async {
    try {
      print(_phoneController.text);
      print(_passwordController.text);
      print(maskFormatter.getUnmaskedText());

      final response = await _authService.login(
        maskFormatter.getUnmaskedText(),
        _passwordController.text,
      );
      if (response['success']) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Login successful!')));
        final token = await _authService.getToken();
        print('Token: $token');
        Navigator.pushNamedAndRemoveUntil(context, '/', (Route route) => false);
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token saved!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response['message']}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _obscureText = true;

  var maskFormatter = new MaskTextInputFormatter(
      mask: '+# (###) ###-##-##',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.lock, size: 100, color: AppColors.primary_color),
            const SizedBox(height: 30),
            const Text(
              'С возвращением!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Войдите в свою учетную запись',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            // CustomTextfield(
            //   controller: _phoneController,
            //   label: 'Номер телефона',
            //   ktype: TextInputType.phone,
            //   icon: const Icon(
            //     Icons.phone,
            //   ),
            // ),

            // TextFormField

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [maskFormatter],
              decoration: InputDecoration(
                errorText: _errorPhoneMessage,

                // errorText: _errorPhoneMessage,
                hintText: '+7 (700) 000-00-00',
                labelText: 'Введите номер телефона',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Пароль',
                errorText: _errorPasswordMessage,

                // errorText: _errorPasswordMessage,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 20),
            // CustomTextfield(
            //   controller: _passwordController,
            //   ktype: TextInputType.visiblePassword,
            //   label: 'Пароль',
            //   icon: const Icon(Icons.lock),
            //   obs: true,
            // ),
            const SizedBox(height: 30),
            // ElevatedButton(
            //   onPressed: _login,
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

            ElevatedButton(
              child: Text('data'),
              onPressed: () {
                _validatePasswordInput();
                _validatePhoneInput();
              }
            ),
            CustomButton(onTap: _login, text: 'Войти'),
            const SizedBox(height: 20),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/register');
            //   },
            //   child: const Text(
            //     'У вас нет учетной записи? подписывать',
            //     style: TextStyle(fontSize: 16, color: Colors.red),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
