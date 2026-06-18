import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'main_shell.dart';
import 'theme/app_theme.dart';

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
      theme: buildEcoSpotTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        // Tras iniciar sesión se entra al shell con la barra superior del Figma.
        '/home': (context) => const MainShell(),
      },
    );
  }
}
