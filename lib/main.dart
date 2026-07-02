import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'landing_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'main_shell.dart';
import 'splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/dark_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootApp());
}

/// Mejora 1 — Splash Screen: se muestra mientras Firebase se inicializa.
/// Una vez listo, reemplaza con EcoSpotApp usando un FadeTransition.
class _BootApp extends StatefulWidget {
  const _BootApp({Key? key}) : super(key: key);
  @override
  State<_BootApp> createState() => _BootAppState();
}

class _BootAppState extends State<_BootApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // Esperamos al menos 1.8 s para que la animación del splash se vea completa.
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSpot',
      debugShowCheckedModeBanner: false,
      // Mejora 2 — Modo oscuro: respeta la preferencia del sistema.
      theme: buildEcoSpotTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeIn,
        child: _ready ? const EcoSpotApp() : const SplashScreen(),
      ),
    );
  }
}

class EcoSpotApp extends StatelessWidget {
  const EcoSpotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSpot',
      debugShowCheckedModeBanner: false,
      // Mejora 2 — Modo oscuro.
      theme: buildEcoSpotTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      // Mejora 3 — Transiciones animadas: fade suave entre todas las rutas.
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/landing':
            page = const LandingPage();
            break;
          case '/login':
            page = const LoginPage();
            break;
          case '/register':
            page = const RegisterPage();
            break;
          case '/home':
          default:
            page = const MainShell();
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 280),
        );
      },
      home: const AuthGate(),
    );
  }
}
