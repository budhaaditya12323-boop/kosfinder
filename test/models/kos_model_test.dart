import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';

void main() {
  group('Kos Model Test', () {
    final sampleJson = {
      'id': 'c7b5a1b2-1111-2222-3333-444455556666',
      'owner_id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
      'name': 'Kos Melati Indah',
      'gender_type': 'putri',
      'price': 850000,
      'room_available': 3,
      'address': 'Jl. Pogung Kidul No. 12, Sleman',
      'contact_number': '081234567890',
      'image_url': 'https://example.com/kos.jpg',
      'is_active': true,
      'created_at': '2026-01-01T10:00:00.000Z',
      'updated_at': '2026-01-01T12:00:00.000Z',
    };

    test('should parse valid Supabase JSON into Kos entity correctly', () {
      final kos = Kos.fromJson(sampleJson);

      expect(kos.id, 'c7b5a1b2-1111-2222-3333-444455556666');
      expect(kos.ownerId, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(kos.name, 'Kos Melati Indah');
      expect(kos.genderType, 'putri');
      expect(kos.price, 850000);
      expect(kos.roomAvailable, 3);
      expect(kos.address, 'Jl. Pogung Kidul No. 12, Sleman');
      expect(kos.contactNumber, '6281234567890');
      expect(kos.imageUrl, 'https://example.com/kos.jpg');
      expect(kos.isActive, true);
      expect(kos.createdAt, DateTime.parse('2026-01-01T10:00:00.000Z'));
      expect(kos.updatedAt, DateTime.parse('2026-01-01T12:00:00.000Z'));
    });

    test('should convert Kos entity to JSON correctly', () {
      final kos = Kos.fromJson(sampleJson);
      final json = kos.toJson();

      expect(json['id'], sampleJson['id']);
      expect(json['name'], sampleJson['name']);
      expect(json['contact_number'], '6281234567890');
      expect(json['price'], 850000);
      expect(json['is_active'], true);
    });

    test('should correctly format price into Rupiah', () {
      final kos = Kos.fromJson(sampleJson);
      // Indonesian currency format: Rp 850.000 / bulan
      expect(kos.formattedPrice, contains('850.000'));
      expect(kos.formattedPrice, contains('Rp'));
      expect(kos.formattedPrice, endsWith('/ bulan'));
    });

    test('should format whatsappUrl with international code 62', () {
      final kos = Kos.fromJson(sampleJson);
      expect(kos.whatsappUrl, 'https://wa.me/6281234567890');
    });

    test('should normalize contact numbers from various common inputs', () {
      expect(Kos.normalizeContactNumber('081234567890'), '6281234567890');
      expect(Kos.normalizeContactNumber('+6281234567890'), '6281234567890');
      expect(Kos.normalizeContactNumber('6281234567890'), '6281234567890');
      expect(Kos.normalizeContactNumber('81234567890'), '6281234567890');
      expect(Kos.normalizeContactNumber('0812-3456-7890'), '6281234567890');
      expect(Kos.normalizeContactNumber('+62 812 3456 7890'), '6281234567890');
    });

    test('should correctly determine isFull status', () {
      final availableKos = Kos.fromJson(sampleJson);
      expect(availableKos.isFull, false);

      final fullKos = availableKos.copyWith(roomAvailable: 0);
      expect(fullKos.isFull, true);

      final negativeRoomKos = availableKos.copyWith(roomAvailable: -1);
      expect(negativeRoomKos.isFull, true);
    });

    test('should support copyWith modifications', () {
      final original = Kos.fromJson(sampleJson);
      final modified = original.copyWith(
        name: 'Kos Melati Baru',
        price: 900000,
        roomAvailable: 1,
      );

      expect(modified.name, 'Kos Melati Baru');
      expect(modified.price, 900000);
      expect(modified.roomAvailable, 1);
      expect(modified.id, original.id);
    });
  });
}
