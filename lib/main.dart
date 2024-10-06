import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:ken_dala/model/product.dart';
import 'package:ken_dala/primer.dart';
import 'package:ken_dala/view/card_screen.dart';
import 'package:ken_dala/view/detail_screen.dart';
import 'package:ken_dala/view/login_screen.dart';
import 'package:ken_dala/view/map_screen.dart';
import 'package:ken_dala/view/profile_check_screen.dart';
import 'package:ken_dala/view/profile_screen.dart';
import 'package:ken_dala/view/register_screen.dart';
// import 'package:ken_dala/example.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [ProductSchema],
    directory: dir.path,
  );

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
        textTheme: TextTheme(
          displayLarge: Theme.of(context).textTheme.displayLarge?.copyWith(
                letterSpacing: -0.1,
              ),
          displayMedium: Theme.of(context).textTheme.displayMedium?.copyWith(
                letterSpacing: -0.1,
              ),
          displaySmall: Theme.of(context).textTheme.displaySmall?.copyWith(
                letterSpacing: -0.1,
              ),
          headlineLarge: Theme.of(context).textTheme.headlineLarge?.copyWith(
                letterSpacing: -0.1,
              ),
          headlineMedium: Theme.of(context).textTheme.headlineMedium?.copyWith(
                letterSpacing: -0.1,
              ),
          headlineSmall: Theme.of(context).textTheme.headlineSmall?.copyWith(
                letterSpacing: -0.1,
              ),
          titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: -0.1,
              ),
          titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(
                letterSpacing: -0.1,
              ),
          titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(
                letterSpacing: -0.1,
              ),
          bodyLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(
                letterSpacing: -0.1,
              ),
          bodyMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: -0.1,
              ),
          bodySmall: Theme.of(context).textTheme.bodySmall?.copyWith(
                letterSpacing: -0.1,
              ),
          labelLarge: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: -0.1,
              ),
          labelMedium: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: -0.1,
              ),
          labelSmall: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: -0.1,
              ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => Example(isar:isar),
        //   '/': (context) => HomePage(),
        // '/': (context) => MapScreen(),
        '/map': (context) => MapScreen(),
        // '/': (context) => OpenContainerTransformDemo(),
        '/cart': (context) => ProductListScreen(isar: isar),
        '/detail': (context) => DetailScreen(isar: isar),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileCheckScreen(),
        // '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
