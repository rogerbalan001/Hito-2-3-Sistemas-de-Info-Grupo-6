import 'package:flutter/foundation.dart';

/// Estado de sesión en memoria.
/// Refleja si la cuenta con sesión activa es administrador, lo que decide qué
/// pestañas se muestran en la barra superior. Se usa un [ValueNotifier] para
/// que el shell se actualice al instante.
///
/// IMPORTANTE: este valor NO se puede activar desde la interfaz. Lo determina
/// el backend (ver [AuthService.isCurrentUserAdmin]) a partir de una lista
/// cableada de correos de administrador.
class Session {
  Session._();

  /// true = Administrador (ve todas las pestañas).
  /// false = Viajero (no ve Operadores, Dashboard ni Administración).
  static final ValueNotifier<bool> isAdmin = ValueNotifier<bool>(false);

  static void setAdmin(bool value) => isAdmin.value = value;

  /// Reinicia a viajero (p. ej. al cerrar sesión).
  static void reset() => isAdmin.value = false;
}
