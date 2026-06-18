import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';
import 'main_shell.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

/// Puerta de entrada de la app.
///
/// Antes, la app siempre arrancaba en /login sin importar si ya había una
/// sesión activa (Firebase la mantiene entre recargas/reinicios). Esta
/// pantalla escucha el estado de sesión en tiempo real y decide: si hay un
/// usuario con sesión, abre directo en el shell de Inicio; si no, muestra
/// el login. Mientras Firebase termina de restaurar la sesión, se ve una
/// breve pantalla de carga (suele tardar muy poco).
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final haySesion = snapshot.data != null;
        return haySesion ? const MainShell() : const LoginPage();
      },
    );
  }
}
