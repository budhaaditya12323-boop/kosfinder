import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient? client;

  AuthRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  GoTrueClient get _auth => _supabase.auth;

  /// User saat ini yang sedang aktif login, atau null jika guest.
  User? get currentUser => _auth.currentUser;

  /// Session saat ini, atau null jika belum login.
  Session? get currentSession => _auth.currentSession;

  /// Cek apakah pengguna saat ini terautentikasi.
  bool get isAuthenticated => currentUser != null;

  /// Stream perubahan state autentikasi pengguna.
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Mendaftarkan pengguna baru dengan email dan password.
  /// Menangani error umum seperti email duplikat.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('user already exists')) {
        throw const AuthException('Email sudah terdaftar. Silakan login.');
      }
      rethrow;
    }
  }

  /// Masuk dengan email dan password yang terdaftar.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw const AuthException('Email atau password salah.');
      }
      rethrow;
    }
  }

  /// Keluar dari sesi akun saat ini.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
