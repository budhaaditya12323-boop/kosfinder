import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<AuthState>? _authSubscription;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _initAuthState();
  }

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  Session? _currentSession;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  Session? get currentSession => _currentSession;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;

  void _initAuthState() {
    try {
      _currentUser = _repository.currentUser;
      _currentSession = _repository.currentSession;
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }

    try {
      _authSubscription = _repository.onAuthStateChange.listen((data) {
        final session = data.session;
        _currentSession = session;
        _currentUser = session?.user;
        _status = _currentUser != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        notifyListeners();
      });
    } catch (_) {
      // Ignored for environments without active streams (e.g. testing)
    }
  }

  /// Registrasi akun pemilik kos baru (US04-AC1, US04-AC2).
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.signUp(
        email: email,
        password: password,
      );

      _currentUser = res.user;
      _currentSession = res.session;
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Masuk dengan email dan password terdaftar.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.signInWithPassword(
        email: email,
        password: password,
      );

      _currentUser = res.user;
      _currentSession = res.session;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Keluar dari sesi pemilik kos.
  Future<void> logout() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signOut();
      _currentUser = null;
      _currentSession = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'Gagal keluar. Silakan coba lagi.';
      _status = AuthStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
