import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';

/// Fake Repository (In-Memory) untuk menguji logika T14 tanpa Supabase
class FakeKosRepository {
  final List<Kos> _db = [];

  Future<List<Kos>> fetchOwnerKos(String ownerId, {bool? isActive}) async {
    return _db.where((k) {
      final matchOwner = k.ownerId == ownerId;
      final matchActive = isActive == null || k.isActive == isActive;
      return matchOwner && matchActive;
    }).toList();
  }

  Future<Kos> createKos(Kos kos) async {
    final newKos = kos.copyWith(id: 'generated-uuid-${_db.length + 1}');
    _db.add(newKos);
    return newKos;
  }

  Future<Kos> updateKos(String id, Map<String, dynamic> updates) async {
    final index = _db.indexWhere((k) => k.id == id);
    if (index == -1) throw Exception('Kos not found');

    final oldKos = _db[index];
    final updatedKos = Kos(
      id: oldKos.id,
      ownerId: oldKos.ownerId,
      name: updates['name'] as String? ?? oldKos.name,
      genderType: updates['gender_type'] as String? ?? oldKos.genderType,
      price: updates['price'] as int? ?? oldKos.price,
      roomAvailable: updates['room_available'] as int? ?? oldKos.roomAvailable,
      address: updates['address'] as String? ?? oldKos.address,
      contactNumber: updates['contact_number'] as String? ?? oldKos.contactNumber,
      imageUrl: updates['image_url'] as String? ?? oldKos.imageUrl,
      isActive: updates['is_active'] as bool? ?? oldKos.isActive,
      createdAt: oldKos.createdAt,
      updatedAt: DateTime.now(),
    );
    _db[index] = updatedKos;
    return updatedKos;
  }

  Future<void> softDeleteKos(String id, {bool isActive = false}) async {
    final index = _db.indexWhere((k) => k.id == id);
    if (index != -1) {
      _db[index] = _db[index].copyWith(isActive: isActive);
    }
  }
}

void main() {
  group('KosRepository T14 Logic Tests', () {
    late FakeKosRepository repository;
    final dummyKos = Kos(
      id: '',
      ownerId: 'owner-1',
      name: 'Kos Test',
      genderType: 'putra',
      price: 1000000,
      roomAvailable: 2,
      address: 'Jl. Test',
      contactNumber: '6281234567890',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      repository = FakeKosRepository();
    });

    test('createKos berhasil menambahkan data', () async {
      final created = await repository.createKos(dummyKos);
      
      expect(created.id, isNotEmpty);
      expect(created.name, 'Kos Test');
      
      final list = await repository.fetchOwnerKos('owner-1');
      expect(list.length, 1);
    });

    test('updateKos berhasil mengubah data', () async {
      final created = await repository.createKos(dummyKos);
      
      final updated = await repository.updateKos(created.id, {
        'name': 'Kos Test Updated',
        'room_available': 0,
      });

      expect(updated.name, 'Kos Test Updated');
      expect(updated.roomAvailable, 0);
      expect(updated.isFull, isTrue); // Memastikan logika UI (Penuh) berjalan
    });

    test('softDeleteKos berhasil mengubah status is_active menjadi false', () async {
      final created = await repository.createKos(dummyKos);
      
      await repository.softDeleteKos(created.id, isActive: false);

      final activeList = await repository.fetchOwnerKos('owner-1', isActive: true);
      final archiveList = await repository.fetchOwnerKos('owner-1', isActive: false);

      expect(activeList.length, 0);
      expect(archiveList.length, 1);
      expect(archiveList.first.isActive, isFalse);
    });
  });
}