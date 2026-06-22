
import 'package:flutter_test/flutter_test.dart';
import 'package:ecospot/services/auth_service.dart';

void main() {
  group('AuthService - Patrón Singleton y Login', () {
    test('Retorna siempre la misma instancia (Singleton)', () {
      final instance1 = AuthService();
      final instance2 = AuthService();
      expect(identical(instance1, instance2), true);
    });

    test('Login exitoso con credenciales válidas', () async {
      final auth = AuthService();
      final result = await auth.login('demo@ecospot.com', 'password123');
      expect(result, true);
      expect(auth.isAuthenticated, true);
    });

    test('Login fallido con credenciales inválidas', () async {
      final auth = AuthService();
      final result = await auth.login('demo@ecospot.com', 'wrongpass');
      expect(result, false);
    });

    test('Logout limpia el estado de sesión', () async {
      final auth = AuthService();
      await auth.login('demo@ecospot.com', 'password123');
      auth.logout();
      expect(auth.isAuthenticated, false);
    });
  });
}

/*
  Supuesto de API: factory AuthService(), Future<bool> login(email, pass),
  bool isAuthenticated, void logout(). Ajusta nombres a tu implementación real.
  Resultado real (PASS/FAIL) se obtiene corriendo: flutter test test/auth_test.dart
*/
