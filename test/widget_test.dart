// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecospot/pages/search_page.dart'; // AJUSTA según tu ruta real

void main() {
  group('Búsqueda - Widget Test', () {
    testWidgets('filtra resultados por destino y muestra contador', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('destino_field')), 'Margarita');
      await tester.tap(find.byKey(const Key('buscar_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('resultados_counter')), findsOneWidget);
      expect(find.textContaining('resultado'), findsWidgets);
    });

    testWidgets('muestra estado vacío cuando no hay coincidencias', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('destino_field')), 'Destino_Inexistente_XYZ');
      await tester.tap(find.byKey(const Key('buscar_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('empty_state')), findsOneWidget);
    });

    testWidgets('filtra por presupuesto máximo con el slider', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));
      await tester.pumpAndSettle();

      final slider = find.byKey(const Key('presupuesto_slider'));
      await tester.drag(slider, const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('resultados_counter')), findsOneWidget);
    });
  });
}
