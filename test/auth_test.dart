// test/auth_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ecospot/services/auth_service.dart'; // AJUSTA el nombre del paquete según pubspec.yaml

void main() {
  group('AuthService - Patrón Singleton', () {
    test('debe retornar siempre la misma instancia', () {
      final instanciaA = AuthService();
      final instanciaB = AuthService();
      expect(identical(instanciaA, instanciaB), isTrue);
    });

    test('login con cuenta demo válida debe autenticar', () async {
      final auth = AuthService();
      final resultado = await auth.login('demo@unimet.edu.ve', '123456');
      expect(resultado, isTrue);
      expect(auth.isAuthenticated, isTrue);
    });

    test('login con credenciales incorrectas debe fallar', () async {
      final auth = AuthService();
      final resultado = await auth.login('demo@unimet.edu.ve', 'clave_incorrecta');
      expect(resultado, isFalse);
    });

    test('registro rechaza correos fuera del dominio institucional', () async {
      final auth = AuthService();
      final resultado = await auth.register('usuario@gmail.com', 'Clave123');
      expect(resultado, isFalse);
    });

    test('registro acepta dominio @unimet.edu.ve y @correo.unimet.edu.ve', () async {
      final auth = AuthService();
      expect(await auth.register('nuevo@unimet.edu.ve', 'Clave123'), isTrue);
      expect(await auth.register('nuevo2@correo.unimet.edu.ve', 'Clave123'), isTrue);
    });
  });
}
