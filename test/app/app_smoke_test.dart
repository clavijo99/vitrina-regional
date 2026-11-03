import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/app/app.dart';
import 'package:vitrina_regional/app/di/app_providers.dart';

/// Prueba de humo de la app completa en modo mock: verifica que la
/// composición de dependencias (app_providers.dart) y el router funcionan
/// juntos: splash -> login -> (login demo) -> home.
void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('arranca en login y entra a home con el usuario demo', (
    tester,
  ) async {
    expect(useMockData, isTrue, reason: 'La plantilla debe venir en modo mock');

    await tester.pumpWidget(const AppProviders(child: VitrinaRegionalApp()));
    await tester.pumpAndSettle();

    expect(find.text('Ingresar'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'cliente@demo.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Ingresar'));
    // Latencia simulada del mock (400 ms) + transición de go_router.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Hola, Carlos Cliente'), findsOneWidget);
  });
}
