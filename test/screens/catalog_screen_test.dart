import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/screens/catalog_screen.dart';
import 'package:kosfinder/widgets/filter_bar.dart';
import 'package:kosfinder/widgets/kos_card.dart';

void main() {
  group('CatalogScreen Widget Test', () {
    late List<Kos> allKosData;
    late bool shouldThrow;

    final dummyKosPutra = Kos(
      id: 'kos-putra',
      ownerId: 'owner-1',
      name: 'Kos Putra Pogung Jaya',
      genderType: 'putra',
      price: 850000,
      roomAvailable: 2,
      address: 'Jl. Pogung Baru No. 15',
      contactNumber: '081234567890',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final dummyKosPutri = Kos(
      id: 'kos-putri',
      ownerId: 'owner-2',
      name: 'Kos Putri Melati Cantik Pogung',
      genderType: 'putri',
      price: 1200000,
      roomAvailable: 0,
      address: 'Jl. Pogung Lor No. 10',
      contactNumber: '089876543210',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Future<List<Kos>> mockFetch({
      String? query,
      String? genderType,
      int? maxPrice,
    }) async {
      if (shouldThrow) throw Exception('Network error');

      var list = List<Kos>.from(allKosData);

      if (genderType != null &&
          genderType.trim().isNotEmpty &&
          genderType.toLowerCase() != 'semua') {
        list = list
            .where((k) => k.genderType.toLowerCase() == genderType.toLowerCase())
            .toList();
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list
            .where((k) =>
                k.name.toLowerCase().contains(q) ||
                k.address.toLowerCase().contains(q))
            .toList();
      }

      return list;
    }

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
      allKosData = [dummyKosPutra, dummyKosPutri];
      shouldThrow = false;

      final provider = KosProvider(fetchActiveKosCallback: mockFetch);

      await tester.pumpWidget(createCatalogScreen(provider));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(FilterBar), findsOneWidget);
      expect(find.byType(KosCard), findsNWidgets(2));
      expect(find.text('Kos Putra Pogung Jaya'), findsOneWidget);
      expect(find.text('Kos Putri Melati Cantik Pogung'), findsOneWidget);

      expect(find.text('Sisa 2 Kamar'), findsOneWidget);
      expect(find.text('Penuh'), findsOneWidget);
    });

    testWidgets('US01-AC2: displays default empty state when database has no kos',
        (tester) async {
      allKosData = [];
      shouldThrow = false;

      final provider = KosProvider(fetchActiveKosCallback: mockFetch);

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
      allKosData = [];
      shouldThrow = true;

      final provider = KosProvider(fetchActiveKosCallback: mockFetch);

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
      allKosData = [dummyKosPutra];

      await tester.tap(find.byKey(const Key('retry_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Kos Putra Pogung Jaya'), findsOneWidget);
      expect(find.text('Sisa 2 Kamar'), findsOneWidget);
    });

    testWidgets('US02-AC1: typing query and selecting filter chip narrows results in UI',
        (tester) async {
      allKosData = [dummyKosPutra, dummyKosPutri];
      shouldThrow = false;

      final provider = KosProvider(fetchActiveKosCallback: mockFetch);

      await tester.pumpWidget(createCatalogScreen(provider));
      await tester.pump();
      await tester.pumpAndSettle();

      // Pilih filter chip Putri
      final putriChip = find.byKey(const Key('filter_chip_putri'));
      expect(putriChip, findsOneWidget);
      await tester.tap(putriChip);
      await tester.pump();
      await tester.pumpAndSettle();

      // Ketikkan teks "Pogung" di search bar
      final searchField = find.byKey(const Key('search_bar_field'));
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Pogung');
      await tester.pump();
      await tester.pumpAndSettle();

      // Verifikasi hanya Kos Putri Melati Cantik Pogung yang tampil
      expect(find.byType(KosCard), findsOneWidget);
      expect(find.text('Kos Putri Melati Cantik Pogung'), findsOneWidget);
      expect(find.text('Kos Putra Pogung Jaya'), findsNothing);
    });

    testWidgets('US02-AC2: searching with unmatched keyword displays "Tidak ada kos yang cocok..."',
        (tester) async {
      allKosData = [dummyKosPutra, dummyKosPutri];
      shouldThrow = false;

      final provider = KosProvider(fetchActiveKosCallback: mockFetch);

      await tester.pumpWidget(createCatalogScreen(provider));
      await tester.pump();
      await tester.pumpAndSettle();

      // Ketik kata kunci yang tidak ada
      final searchField = find.byKey(const Key('search_bar_field'));
      await tester.enterText(searchField, 'LokasiTakDikenalXYZ');
      await tester.pump();
      await tester.pumpAndSettle();

      // Verifikasi pesan empty state khusus pencarian
      expect(
        find.text('Tidak ada kos yang cocok dengan pencarian Anda.'),
        findsOneWidget,
      );
      expect(find.byType(KosCard), findsNothing);

      // Verifikasi tombol reset filter dapat mengembalikan data
      final resetButton = find.byKey(const Key('reset_filter_button'));
      expect(resetButton, findsOneWidget);
      await tester.tap(resetButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(KosCard), findsNWidgets(2));
    });
  });
}
