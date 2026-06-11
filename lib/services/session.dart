import 'package:flutter/foundation.dart';

/// Estado de sesión en memoria.
/// Guarda el "modo" de la cuenta (administrador o viajero) que decide qué
/// pestañas se muestran en la barra superior. Se usa un [ValueNotifier] para
/// que el shell se actualice al instante cuando el usuario cambia de modo,
/// sin esperar a Firestore. El valor también se persiste en el perfil.
class Session {
  Session._();

  /// true = Administrador (ve todas las pestañas).
  /// false = Viajero (no ve Operadores, Dashboard ni Administración).
  static final ValueNotifier<bool> isAdmin = ValueNotifier<bool>(false);

  /// Contraseña requerida para activar el modo administrador.
  static const String adminPassword = 'admin';

  static void setAdmin(bool value) => isAdmin.value = value;

  /// Reinicia a viajero (p. ej. al cerrar sesión).
  static void reset() => isAdmin.value = false;
}
