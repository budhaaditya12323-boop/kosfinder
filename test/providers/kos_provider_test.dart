import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';

void main() {
  group('KosProvider Test', () {
    late List<Kos> allMockData;
    late bool shouldThrow;
    late String? customErrorMessage;
    late KosProvider provider;

    final dummyKosPutra = Kos(
      id: 'kos-1',
      ownerId: 'owner-1',
      name: 'Kos Putra Pogung 1',
      genderType: 'putra',
      price: 1000000,
      roomAvailable: 2,
      address: 'Jl. Pogung Kidul No. 1',
      contactNumber: '081234567890',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final dummyKosPutri = Kos(
      id: 'kos-2',
      ownerId: 'owner-2',
      name: 'Kos Putri Melati Pogung',
      genderType: 'putri',
      price: 850000,
      roomAvailable: 0,
      address: 'Jl. Pogung Lor No. 5',
      contactNumber: '081987654321',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final dummyKosCampur = Kos(
      id: 'kos-3',
      ownerId: 'owner-3',
      name: 'Kos Campur Gejayan Indah',
      genderType: 'campur',
      price: 1500000,
      roomAvailable: 5,
      address: 'Jl. Gejayan No. 10',
      contactNumber: '081122334455',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Future<List<Kos>> mockFetch({
      String? query,
      String? genderType,
      int? maxPrice,
    }) async {
      if (shouldThrow) {
        throw Exception(customErrorMessage ?? 'Network error');
      }

      var filtered = List<Kos>.from(allMockData);

      if (genderType != null &&
          genderType.trim().isNotEmpty &&
          genderType.toLowerCase() != 'semua') {
        filtered = filtered
            .where((k) => k.genderType.toLowerCase() == genderType.toLowerCase())
            .toList();
      }

      if (maxPrice != null && maxPrice > 0) {
        filtered = filtered.where((k) => k.price <= maxPrice).toList();
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        filtered = filtered
            .where((k) =>
                k.name.toLowerCase().contains(q) ||
                k.address.toLowerCase().contains(q))
            .toList();
      }

      return filtered;
    }

    setUp(() {
      allMockData = [dummyKosPutra, dummyKosPutri, dummyKosCampur];
      shouldThrow = false;
      customErrorMessage = null;
      provider = KosProvider(fetchActiveKosCallback: mockFetch);
    });

    test('initial state should be initial, empty list, and default filter values', () {
      expect(provider.status, KosStateStatus.initial);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.isEmpty, isFalse);
      expect(provider.isError, isFalse);
      expect(provider.isSuccess, isFalse);
      expect(provider.searchQuery, '');
      expect(provider.selectedGender, 'Semua');
      expect(provider.maxPrice, isNull);
      expect(provider.isFilterActive, isFalse);
    });

    test('fetchActiveKos sets loading state then success when data is not empty', () async {
      final stateTransitions = <KosStateStatus>[];
      provider.addListener(() {
        stateTransitions.add(provider.status);
      });

      final future = provider.fetchActiveKos();
      expect(provider.status, KosStateStatus.loading);
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.status, KosStateStatus.success);
      expect(provider.isSuccess, isTrue);
      expect(provider.kosList.length, 3);
      expect(provider.errorMessage, isNull);
      expect(stateTransitions, contains(KosStateStatus.loading));
      expect(stateTransitions.last, KosStateStatus.success);
    });

    test('US02-AC1: filtering by gender Putri and typing "Pogung" returns matching kos', () async {
      provider.setSelectedGender('Putri');
      await Future.delayed(Duration.zero);
      expect(provider.selectedGender, 'Putri');
      expect(provider.isFilterActive, isTrue);

      provider.setSearchQuery('Pogung');
      await Future.delayed(Duration.zero);

      expect(provider.status, KosStateStatus.success);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Putri Melati Pogung');
      expect(provider.kosList.first.genderType, 'putri');
    });

    test('US02-AC2: searching with unmatched keyword yields empty state', () async {
      provider.setSearchQuery('NonExistentAreaXYZ');
      await Future.delayed(Duration.zero);

      expect(provider.status, KosStateStatus.empty);
      expect(provider.isEmpty, isTrue);
      expect(provider.kosList, isEmpty);
    });

    test('filtering by maxPrice excludes items above the price', () async {
      provider.setMaxPrice(900000);
      await Future.delayed(Duration.zero);

      expect(provider.status, KosStateStatus.success);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Putri Melati Pogung');
      expect(provider.kosList.first.price, 850000);
    });

    test('resetFilters clears query, gender, and price then refetches all', () async {
      provider.setSelectedGender('Putri');
      provider.setSearchQuery('Pogung');
      provider.setMaxPrice(900000);
      await Future.delayed(Duration.zero);
      expect(provider.kosList.length, 1);

      provider.resetFilters();
      await Future.delayed(Duration.zero);

      expect(provider.searchQuery, '');
      expect(provider.selectedGender, 'Semua');
      expect(provider.maxPrice, isNull);
      expect(provider.isFilterActive, isFalse);
      expect(provider.kosList.length, 3);
    });

    test('fetchActiveKos sets empty state when mock data is empty list (US01-AC2)', () async {
      allMockData = [];

      await provider.fetchActiveKos();

      expect(provider.status, KosStateStatus.empty);
      expect(provider.isEmpty, isTrue);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage, isNull);
    });

    test('fetchActiveKos sets error state with friendly message when exception thrown (US01-AC3)', () async {
      shouldThrow = true;

      await provider.fetchActiveKos();

      expect(provider.status, KosStateStatus.error);
      expect(provider.isError, isTrue);
      expect(provider.kosList, isEmpty);
      expect(
        provider.errorMessage,
        'Gagal memuat data. Periksa koneksi internet Anda',
      );
    });

    test('retry calls fetchActiveKos and succeeds after previous error', () async {
      shouldThrow = true;
      await provider.fetchActiveKos();
      expect(provider.isError, isTrue);

      // Fix repo and retry
      shouldThrow = false;
      allMockData = [dummyKosPutra];

      provider.retry();
      expect(provider.isLoading, isTrue);

      await Future.delayed(Duration.zero);

      expect(provider.status, KosStateStatus.success);
      expect(provider.kosList.length, 1);
      expect(provider.errorMessage, isNull);
    });
  });
}
