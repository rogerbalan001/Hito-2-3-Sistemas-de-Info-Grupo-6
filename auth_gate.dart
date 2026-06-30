import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_shell.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

/// Puerta de entrada de la app.
///
/// La pestaña "Inicio" (dentro de [MainShell]) es pública: se muestra al
/// abrir el link SIN necesidad de iniciar sesión. Lo que cambia según haya o
/// no sesión activa es el contenido del propio shell (qué botones se ven en
/// el encabezado, qué pestañas, y si se puede reservar/alquilar o no). Por
/// eso este gate ya no decide entre dos pantallas distintas: solo espera a
/// que Firebase termine de restaurar la sesión (si la hay) y entrega el
/// mismo MainShell en ambos casos. Mientras Firebase resuelve eso se ve una
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
        return const MainShell();
      },
    );
  }
}
