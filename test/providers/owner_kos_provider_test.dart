import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class FakeOwnerRepository extends KosRepository {
  List<Kos> mockDb = [];

  @override
  Future<List<Kos>> fetchOwnerKos(String ownerId, {bool? isActive}) async {
    return mockDb.where((k) {
      final matchOwner = k.ownerId == ownerId;
      final matchActive = isActive == null || k.isActive == isActive;
      return matchOwner && matchActive;
    }).toList();
  }

  @override
  Future<Kos> createKos(Kos kos) async {
    final newKos = kos.copyWith(id: 'new-id');
    mockDb.add(newKos);
    return newKos;
  }

  @override
  Future<Kos> updateKos(String id, Map<String, dynamic> updates) async {
    final index = mockDb.indexWhere((k) => k.id == id);
    final oldKos = mockDb[index];
    final updatedKos = oldKos.copyWith(
      name: updates['name'] ?? oldKos.name,
      updatedAt: DateTime.now(),
    );
    mockDb[index] = updatedKos;
    return updatedKos;
  }

  @override
  Future<void> softDeleteKos(String id, {bool isActive = false}) async {
    final index = mockDb.indexWhere((k) => k.id == id);
    mockDb[index] = mockDb[index].copyWith(isActive: isActive);
  }
}

void main() {
  group('OwnerKosProvider Test (T15)', () {
    late FakeOwnerRepository fakeRepo;
    late OwnerKosProvider provider;
    final ownerId = 'owner-1';

    final dummyKos = Kos(
      id: 'kos-1',
      ownerId: ownerId,
      name: 'Kos Aktif',
      genderType: 'putra',
      price: 1000000,
      roomAvailable: 2,
      address: 'Jl. Test',
      contactNumber: '628123',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      fakeRepo = FakeOwnerRepository();
      fakeRepo.mockDb = [dummyKos];
      provider = OwnerKosProvider(repository: fakeRepo);
    });

    test('loadOwnerKos memisahkan data aktif dan arsip', () async {
      final archivedKos = dummyKos.copyWith(id: 'kos-2', name: 'Kos Arsip', isActive: false);
      fakeRepo.mockDb.add(archivedKos);

      await provider.loadOwnerKos(ownerId);

      expect(provider.status, OwnerKosStatus.success);
      expect(provider.activeKosList.length, 1);
      expect(provider.archivedKosList.length, 1);
      expect(provider.activeKosList.first.name, 'Kos Aktif');
    });

    test('createKos menambah data dan merefresh list', () async {
      final newKos = dummyKos.copyWith(id: '', name: 'Kos Baru');
      
      final result = await provider.createKos(newKos);

      expect(result, isTrue);
      expect(provider.activeKosList.length, 2);
      expect(provider.activeKosList.last.name, 'Kos Baru');
    });

    test('softDeleteKos memindahkan data ke arsip', () async {
      await provider.loadOwnerKos(ownerId);
      expect(provider.activeKosList.length, 1);

      final result = await provider.softDeleteKos('kos-1', ownerId);

      expect(result, isTrue);
      expect(provider.activeKosList.length, 0);
      expect(provider.archivedKosList.length, 1); // Pindah ke arsip
    });

    test('restoreKos mengembalikan data ke aktif', () async {
      fakeRepo.mockDb[0] = dummyKos.copyWith(isActive: false);
      await provider.loadOwnerKos(ownerId);
      
      final result = await provider.restoreKos('kos-1', ownerId);

      expect(result, isTrue);
      expect(provider.activeKosList.length, 1);
      expect(provider.archivedKosList.length, 0);
    });
  });
}