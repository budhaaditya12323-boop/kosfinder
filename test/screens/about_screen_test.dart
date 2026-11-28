import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/catalog_screen.dart';

void main() {
  group('AboutScreen Test', () {
    testWidgets('renders developer identity strictly adhering to AGENTS.md format',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      // Verify developer identity text: 2415051006 - I Putu Budha Aditya
      expect(find.text('2415051006 - I Putu Budha Aditya'), findsOneWidget);
      expect(find.byKey(const Key('developer_info_text')), findsOneWidget);
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.text('KosFinder'), findsOneWidget);
    });

    testWidgets('navigates to AboutScreen from CatalogScreen info button',
        (tester) async {
      final provider = KosProvider(
        fetchActiveKosCallback: () async => <Kos>[],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<KosProvider>.value(
            value: provider,
            child: const CatalogScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Find the about/info button on the AppBar
      final aboutButton = find.byKey(const Key('about_button'));
      expect(aboutButton, findsOneWidget);

      // Tap the about button and verify navigation
      await tester.tap(aboutButton);
      await tester.pumpAndSettle();

      // Verify AboutScreen is now displayed with the required developer text
      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('2415051006 - I Putu Budha Aditya'), findsOneWidget);
    });
  });
}
