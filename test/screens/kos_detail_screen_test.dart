import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/screens/catalog_screen.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/widgets/kos_card.dart';

void main() {
  group('KosDetailScreen Test', () {
    final sampleKos = Kos(
      id: 'kos-detail-1',
      ownerId: 'owner-1',
      name: 'Kos Pogung Asri',
      genderType: 'campur',
      price: 950000,
      roomAvailable: 3,
      address: 'Jl. Pogung Kidul No. 25, Sleman',
      contactNumber: '08123456789',
      imageUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('US03-AC2: displays green placeholder fallback when imageUrl is null or empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KosDetailScreen(kos: sampleKos),
        ),
      );

      // Verify fallback placeholder is displayed
      expect(find.byKey(const Key('kos_placeholder_image')), findsOneWidget);
      expect(find.text('Foto belum tersedia'), findsOneWidget);

      // Verify kos details are displayed (both in AppBar title and body content)
      expect(find.text('Kos Pogung Asri'), findsNWidgets(2));
      expect(find.text(sampleKos.formattedPrice), findsOneWidget);
      expect(find.text('Jl. Pogung Kidul No. 25, Sleman'), findsOneWidget);
      expect(find.text('Sisa 3 Kamar'), findsOneWidget);
      expect(find.text('+628123456789'), findsOneWidget);
    });

    testWidgets('US03-AC1: clicking WhatsApp button triggers launchUrl with wa.me/62...',
        (tester) async {
      Uri? launchedUri;

      await tester.pumpWidget(
        MaterialApp(
          home: KosDetailScreen(
            kos: sampleKos,
            launchUrlFn: (uri) async {
              launchedUri = uri;
              return true;
            },
          ),
        ),
      );

      final waButton = find.byKey(const Key('whatsapp_button'));
      expect(waButton, findsOneWidget);

      await tester.tap(waButton);
      await tester.pumpAndSettle();

      // Verify the URL launched is https://wa.me/628123456789
      expect(launchedUri, isNotNull);
      expect(launchedUri.toString(), 'https://wa.me/628123456789');
    });

    testWidgets('navigates from CatalogScreen to KosDetailScreen on card tap',
        (tester) async {
      final provider = KosProvider(
        fetchActiveKosCallback: () async => [sampleKos],
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

      // Tap on the KosCard
      expect(find.byType(KosCard), findsOneWidget);
      await tester.tap(find.byType(KosCard));
      await tester.pumpAndSettle();

      // Verify KosDetailScreen is pushed
      expect(find.byType(KosDetailScreen), findsOneWidget);
      expect(find.text('Hubungi via WhatsApp'), findsOneWidget);
    });
  });
}
