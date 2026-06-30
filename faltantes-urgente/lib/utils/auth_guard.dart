import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Verifica que haya sesión activa antes de continuar con una acción que la
/// requiere (reservar, alquilar, registrar un servicio, etc.).
///
/// Si NO hay sesión: muestra un aviso, lleva al usuario a la pantalla de
/// login y devuelve `false` para que la pantalla que llama aborte la acción.
/// Si SÍ hay sesión: devuelve `true` y la acción continúa con normalidad.
bool requireLogin(BuildContext context, {String accion = 'continuar'}) {
  if (AuthService().isAuthenticated) return true;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Debes iniciar sesión para $accion.')),
  );
  Navigator.pushNamed(context, '/login');
  return false;
}
