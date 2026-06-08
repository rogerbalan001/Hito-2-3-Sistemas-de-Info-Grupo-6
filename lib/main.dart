import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'search_page.dart';

void main() async {
  // Necesario antes de inicializar Firebase cuando main() es async.
  WidgetsFlutterBinding.ensureInitialized();
  // Conecta la app con el proyecto Firebase (configuración generada por
  // `flutterfire configure` en firebase_options.dart).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EcoSpotApp());
}

class EcoSpotApp extends StatelessWidget {
  const EcoSpotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSpot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[800],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
      },
    );
  }
}
