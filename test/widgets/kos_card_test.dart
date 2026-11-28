import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/widgets/kos_card.dart';

void main() {
  group('KosCard Badge Verification (T22)', () {
    
    // Helper untuk membungkus widget dengan MaterialApp (wajib untuk widget test)
    Widget createWidgetUnderTest(Kos kos) {
      return MaterialApp(
        home: Scaffold(
          body: KosCard(kos: kos),
        ),
      );
    }

    final dummyKosAvailable = Kos(
      id: '1',
      ownerId: 'owner-1',
      name: 'Kos Tersedia',
      genderType: 'putra',
      price: 1000000,
      roomAvailable: 2, // Masih ada kamar
      address: 'Jl. Test',
      contactNumber: '628123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final dummyKosFull = Kos(
      id: '2',
      ownerId: 'owner-1',
      name: 'Kos Penuh',
      genderType: 'putri',
      price: 1500000,
      roomAvailable: 0, // Kamar habis
      address: 'Jl. Test 2',
      contactNumber: '628123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('Menampilkan badge "Sisa X Kamar" jika kamar > 0', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(dummyKosAvailable));

      // Cari teks yang sesuai
      expect(find.text('Sisa 2 Kamar'), findsOneWidget);
      expect(find.text('Penuh'), findsNothing);
    });

    testWidgets('Menampilkan badge "Penuh" jika kamar == 0', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(dummyKosFull));

      // Cari teks yang sesuai
      expect(find.text('Penuh'), findsOneWidget);
      expect(find.text('Sisa 0 Kamar'), findsNothing);
    });
  });
}