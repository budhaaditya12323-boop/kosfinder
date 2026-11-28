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
}
