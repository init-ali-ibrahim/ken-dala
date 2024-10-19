import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:isar/isar.dart';
import 'package:ken_dala/firebase_options.dart';
import 'package:ken_dala/model/product.dart';
import 'package:ken_dala/primer.dart';
import 'package:ken_dala/view/card_screen.dart';
import 'package:ken_dala/view/detail_screen.dart';
import 'package:ken_dala/view/login_screen.dart';
import 'package:ken_dala/view/map_screen.dart';
import 'package:ken_dala/view/profile_check_screen.dart';
import 'package:ken_dala/view/profile_edit_screen.dart';
import 'package:ken_dala/view/register_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [ProductSchema],
    directory: dir.path,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarContrastEnforced: true,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  //----------

  final messaging = FirebaseMessaging.instance;

  messaging.getToken().then((token) {
    log('FCM Token: $token');
  });

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  final androiodPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if(androiodPlugin != null) {
    await androiodPlugin.createNotificationChannel(channel);
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'ic_launcher_foreground',
              // other properties...
            ),
          ));
    }
  });

  //----------

  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;

  const MyApp({super.key, required this.isar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
            TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
          },
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver],
      routes: {
        '/': (context) => Example(isar: isar),
        // '/': (context) => MapScreen(),
        '/map': (context) => const MapScreen(),
        '/cart': (context) => ProductListScreen(isar: isar),
        '/detail': (context) => DetailScreen(isar: isar),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileCheckScreen(),
        '/profile_edit': (context) => const ProfileEditScreen(),
        // '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
