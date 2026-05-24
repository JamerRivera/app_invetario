import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_invetario/main.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Smoke test for Control de Inventario', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the Dashboard is displayed by searching for its title
    expect(find.text('Dashboard'), findsNWidgets(2));

    // Verify navigation destinations:
    // - Dashboard, Compras and Ventas appear both in the nav bar and on the dashboard cards (onstage)
    // - Productos and Clientes only appear in the nav bar (their screens are offstage)
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Compras'), findsNWidgets(2));
    expect(find.text('Ventas'), findsNWidgets(2));
  });
}
