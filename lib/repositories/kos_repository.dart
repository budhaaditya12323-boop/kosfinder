import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

class KosRepository {
  final SupabaseClient? client;

  KosRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  /// Mengambil semua kos aktif (`is_active = true`) diurutkan berdasarkan waktu pembuatan terbaru.
  /// Mendukung filter opsional:
  /// - [query]: pencarian teks pada nama atau alamat (case-insensitive)
  /// - [genderType]: 'putra', 'putri', atau 'campur' (jika 'semua' atau null tidak difilter)
  /// - [maxPrice]: batas harga sewa bulanan maksimum
  Future<List<Kos>> fetchActiveKos({
    String? query,
    String? genderType,
    int? maxPrice,
  }) async {
    var request = _supabase.from('kos').select().eq('is_active', true);

    if (genderType != null &&
        genderType.trim().isNotEmpty &&
        genderType.toLowerCase() != 'semua') {
      request = request.eq('gender_type', genderType.toLowerCase());
    }

    if (maxPrice != null && maxPrice > 0) {
      request = request.lte('price', maxPrice);
    }

    if (query != null && query.trim().isNotEmpty) {
      final sanitized = query.trim();
      request = request.or('name.ilike.%$sanitized%,address.ilike.%$sanitized%');
    }

    final response = await request.order('created_at', ascending: false);

    final list = response as List<dynamic>;
    return list
        .map((item) => Kos.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  // Tambahkan kode ini di dalam class KosRepository

  // ─── T14: CRUD FUNCTIONS FOR OWNER ───

  /// Mengambil semua kos milik pemilik yang sedang login (aktif & arsip).
  Future<List<Kos>> fetchOwnerKos(String ownerId, {bool? isActive}) async {
    var request = _supabase.from('kos').select().eq('owner_id', ownerId);
    
    if (isActive != null) {
      request = request.eq('is_active', isActive);
    }

    final response = await request.order('created_at', ascending: false);
    final list = response as List<dynamic>;
    return list.map((item) => Kos.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Menambahkan data kos baru.
  Future<Kos> createKos(Kos kos) async {
    final data = kos.toJson();
    // Hapus ID dan timestamp agar database yang meng-generate (default gen_random_uuid() & now())
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');

    final response = await _supabase.from('kos').insert(data).select().single();
    return Kos.fromJson(response);
  }

  /// Mengubah data kos yang sudah ada.
  Future<Kos> updateKos(String id, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    final response = await _supabase
        .from('kos')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
        
    return Kos.fromJson(response);
  }

  /// Menghapus kos (Soft Delete: mengubah is_active menjadi false).
  Future<void> softDeleteKos(String id, {bool isActive = false}) async {
    await _supabase
        .from('kos')
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
    /// Memperbarui jumlah kamar tersedia secara cepat (Quick Update - T20)
  Future<void> updateRoomAvailable(String id, int newCount) async {
    await _supabase
        .from('kos')
        .update({
          'room_available': newCount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}
