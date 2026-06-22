import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'landing_page.dart';
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
      // AuthGate decide al abrir la app: si ya hay sesión activa entra
      // directo a Inicio (MainShell); si no, muestra el login. Las rutas
      // con nombre siguen disponibles para las navegaciones explícitas que
      // ya usa el resto de la app (después de iniciar/cerrar sesión).
      home: const AuthGate(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const MainShell(),
      },
    );
  }
}
