import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/screens/catalog_screen.dart';
import 'package:kosfinder/widgets/kos_card.dart';

void main() {
  group('CatalogScreen Widget Test', () {
    late List<Kos> mockKosData;
    late bool shouldThrow;

    final dummyKosAvailable = Kos(
      id: 'kos-avail',
      ownerId: 'owner-1',
      name: 'Kos Pogung Jaya',
      genderType: 'campur',
      price: 850000,
      roomAvailable: 2,
      address: 'Jl. Pogung Baru No. 15',
      contactNumber: '081234567890',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final dummyKosFull = Kos(
      id: 'kos-full',
      ownerId: 'owner-2',
      name: 'Kos Melati Cantik',
      genderType: 'putri',
      price: 1200000,
      roomAvailable: 0,
      address: 'Jl. Kaliurang KM 4.5',
      contactNumber: '089876543210',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Widget createCatalogScreen(KosProvider provider) {
      return MaterialApp(
        home: ChangeNotifierProvider<KosProvider>.value(
          value: provider,
          child: const CatalogScreen(),
        ),
      );
    }

    testWidgets('US01-AC1: displays list of active kos with room availability and full badges',
        (tester) async {
      mockKosData = [dummyKosAvailable, dummyKosFull];
      shouldThrow = false;

      final provider = KosProvider(
        fetchActiveKosCallback: () async {
          if (shouldThrow) throw Exception('Network error');
          return mockKosData;
        },
      );

      await tester.pumpWidget(createCatalogScreen(provider));
      // Triggers initial fetch postFrameCallback
      await tester.pump();
      // Wait for future completion
      await tester.pumpAndSettle();

      // Verify Kos items are rendered
      expect(find.byType(KosCard), findsNWidgets(2));
      expect(find.text('Kos Pogung Jaya'), findsOneWidget);
      expect(find.text('Kos Melati Cantik'), findsOneWidget);

      // Verify availability status
      expect(find.text('Sisa 2 Kamar'), findsOneWidget);
      expect(find.text('Penuh'), findsOneWidget);
    });

    testWidgets('US01-AC2: displays empty state illustration when list is empty',
        (tester) async {
      mockKosData = [];
      shouldThrow = false;

      final provider = KosProvider(
        fetchActiveKosCallback: () async {
          if (shouldThrow) throw Exception('Network error');
          return mockKosData;
        },
      );

      await tester.pumpWidget(createCatalogScreen(provider));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Belum ada kos yang tersedia saat ini.'),
        findsOneWidget,
      );
      expect(find.byType(KosCard), findsNothing);
    });

    testWidgets('US01-AC3: displays error state with retry button on network failure',
        (tester) async {
      mockKosData = [];
      shouldThrow = true;

      final provider = KosProvider(
        fetchActiveKosCallback: () async {
          if (shouldThrow) throw Exception('Network failure');
          return mockKosData;
        },
      );

      await tester.pumpWidget(createCatalogScreen(provider));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Gagal memuat data. Periksa koneksi internet Anda'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('retry_button')), findsOneWidget);

      // Skenario retry berhasil
      shouldThrow = false;
      mockKosData = [dummyKosAvailable];

      await tester.tap(find.byKey(const Key('retry_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Kos Pogung Jaya'), findsOneWidget);
      expect(find.text('Sisa 2 Kamar'), findsOneWidget);
    });
  });
}
