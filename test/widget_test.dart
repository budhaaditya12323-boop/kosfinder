import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/screens/catalog_screen.dart';

void main() {
  testWidgets('App root smoke test renders CatalogScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(find.text('KosFinder'), findsOneWidget);
  });
}
