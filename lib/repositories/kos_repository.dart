import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

class KosRepository {
  final SupabaseClient? client;

  KosRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  /// Mengambil semua kos aktif (`is_active = true`) diurutkan berdasarkan waktu pembuatan terbaru.
  Future<List<Kos>> fetchActiveKos() async {
    final response = await _supabase
        .from('kos')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final list = response as List<dynamic>;
    return list
        .map((item) => Kos.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
