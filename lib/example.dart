import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationSender extends StatefulWidget {
  @override
  _NotificationSenderState createState() => _NotificationSenderState();
}

class _NotificationSenderState extends State<NotificationSender> {
  String? _deviceToken;

  @override
  void initState() {
    super.initState();
    _getDeviceToken();
    initialization();
  }

  void initialization() async {
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  Future<void> _getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      _deviceToken = token;
    });
    print("FCM Device Token: $_deviceToken");
  }

  Future<void> _sendNotification() async {
    if (_deviceToken == null) return;

    const String serverKey = 'YOUR_SERVER_KEY';

    final Map<String, dynamic> notificationData = {
      'to': _deviceToken,
      'notification': {
        'title': 'Тестовое уведомление',
        'body': 'Это сообщение отправлено из Flutter!',
        'sound': 'default'
      },
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done'
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/azure-3b732/messages:send'),
      headers: headers,
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Уведомление успешно отправлено!');
    } else {
      print('Ошибка отправки уведомления: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отправка уведомления'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _sendNotification,
          child: Text('Отправить уведомление'),
        ),
      ),
    );
  }
}