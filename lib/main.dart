import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
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

import 'package:ken_dala/view/profile_screen.dart';
// import 'package:ken_dala/example.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
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
