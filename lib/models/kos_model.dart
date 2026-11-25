import 'package:intl/intl.dart';

class Kos {
  final String id;
  final String ownerId;
  final String name;
  final String genderType;
  final int price;
  final int roomAvailable;
  final String address;
  final String contactNumber;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Kos({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.genderType,
    required this.price,
    required this.roomAvailable,
    required this.address,
    required this.contactNumber,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Normalizes contact number to Indonesian country code format (628xxx).
  /// Handles prefixes like '08', '+62', '62', and removes non-digit characters.
  static String normalizeContactNumber(String contact) {
    // Remove non-digit characters except leading plus if any, or strip everything non-numeric
    String cleaned = contact.replaceAll(RegExp(r'\D'), '');

    if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('8')) {
      cleaned = '62$cleaned';
    } else if (cleaned.startsWith('62')) {
      // already starts with 62
    }

    return cleaned;
  }

  /// Formats the integer price in Rupiah format, e.g. "Rp 850.000 / bulan".
  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return '${formatter.format(price)} / bulan';
  }

  /// Formatted WhatsApp link URL (https://wa.me/628xxx).
  String get whatsappUrl {
    final normalized = normalizeContactNumber(contactNumber);
    return 'https://wa.me/$normalized';
  }

  /// Whether the room is full.
  bool get isFull => roomAvailable <= 0;

  /// Creates a Kos instance from Supabase JSON map.
  factory Kos.fromJson(Map<String, dynamic> json) {
    return Kos(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      genderType: (json['gender_type'] as String? ?? 'campur').toLowerCase(),
      price: (json['price'] as num?)?.toInt() ?? 0,
      roomAvailable: (json['room_available'] as num?)?.toInt() ?? 0,
      address: json['address'] as String? ?? '',
      contactNumber: normalizeContactNumber(
        json['contact_number'] as String? ?? '',
      ),
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts this instance to Supabase JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'gender_type': genderType,
      'price': price,
      'room_available': roomAvailable,
      'address': address,
      'contact_number': normalizeContactNumber(contactNumber),
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copies this instance with optional field modifications.
  Kos copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? genderType,
    int? price,
    int? roomAvailable,
    String? address,
    String? contactNumber,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Kos(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      genderType: genderType ?? this.genderType,
      price: price ?? this.price,
      roomAvailable: roomAvailable ?? this.roomAvailable,
      address: address ?? this.address,
      contactNumber: contactNumber != null
          ? normalizeContactNumber(contactNumber)
          : this.contactNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
