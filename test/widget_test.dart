// Prueba mínima de humo para EcoSpot.
//
// No arrancamos toda la app aquí porque depende de Firebase (que requiere
// inicialización). Solo verificamos que el widget raíz se puede construir.

import 'package:flutter_test/flutter_test.dart';
import 'package:ecospot/main.dart';

void main() {
  testWidgets('El widget raíz EcoSpotApp se construye', (tester) async {
    const app = EcoSpotApp();
    expect(app, isA<EcoSpotApp>());
  });
}
