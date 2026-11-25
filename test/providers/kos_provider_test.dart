import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';

void main() {
  group('KosProvider Test', () {
    late List<Kos> mockResult;
    late bool shouldThrow;
    late String? customErrorMessage;
    late KosProvider provider;

    final dummyKos1 = Kos(
      id: 'kos-1',
      ownerId: 'owner-1',
      name: 'Kos Sejahtera',
      genderType: 'campur',
      price: 1000000,
      roomAvailable: 2,
      address: 'Jl. Merdeka No. 1',
      contactNumber: '081234567890',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final dummyKos2 = Kos(
      id: 'kos-2',
      ownerId: 'owner-2',
      name: 'Kos Bahagia',
      genderType: 'putri',
      price: 850000,
      roomAvailable: 0,
      address: 'Jl. Kenanga No. 5',
      contactNumber: '081987654321',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Future<List<Kos>> mockFetch() async {
      if (shouldThrow) {
        throw Exception(customErrorMessage ?? 'Network error');
      }
      return mockResult;
    }

    setUp(() {
      mockResult = [];
      shouldThrow = false;
      customErrorMessage = null;
      provider = KosProvider(fetchActiveKosCallback: mockFetch);
    });

    test('initial state should be initial and empty list', () {
      expect(provider.status, KosStateStatus.initial);
      expect(provider.kosList, isEmpty);
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.isEmpty, isFalse);
      expect(provider.isError, isFalse);
      expect(provider.isSuccess, isFalse);
    });

    test('fetchActiveKos sets loading state then success when data is not empty', () async {
      mockResult = [dummyKos1, dummyKos2];

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
      expect(provider.kosList.length, 2);
      expect(provider.kosList.first.name, 'Kos Sejahtera');
      expect(provider.errorMessage, isNull);
      expect(stateTransitions, contains(KosStateStatus.loading));
      expect(stateTransitions.last, KosStateStatus.success);
    });

    test('fetchActiveKos sets empty state when data is empty list (US01-AC2)', () async {
      mockResult = [];

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
      mockResult = [dummyKos1];

      provider.retry();
      expect(provider.isLoading, isTrue);

      await Future.delayed(Duration.zero);

      expect(provider.status, KosStateStatus.success);
      expect(provider.kosList.length, 1);
      expect(provider.errorMessage, isNull);
    });
  });
}
