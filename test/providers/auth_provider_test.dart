import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository implements AuthRepository {
  User? mockUser;
  Session? mockSession;
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  bool shouldThrowSignUp = false;
  AuthException? signUpException;
  bool shouldThrowSignIn = false;
  AuthException? signInException;
  bool shouldThrowSignOut = false;
  bool signOutCalled = false;

  @override
  SupabaseClient? get client => null;

  @override
  User? get currentUser => mockUser;

  @override
  Session? get currentSession => mockSession;

  @override
  bool get isAuthenticated => mockUser != null;

  @override
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  void emitAuthState(AuthChangeEvent event, Session? session) {
    _authStateController.add(AuthState(event, session));
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (shouldThrowSignUp) {
      throw signUpException ??
          const AuthException('Email sudah terdaftar. Silakan login.');
    }
    return AuthResponse(
      user: mockUser,
      session: mockSession,
    );
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrowSignIn) {
      throw signInException ??
          const AuthException('Email atau password salah.');
    }
    return AuthResponse(
      user: mockUser,
      session: mockSession,
    );
  }

  @override
  Future<void> signOut() async {
    if (shouldThrowSignOut) {
      throw const AuthException('Sign out failed');
    }
    signOutCalled = true;
    mockUser = null;
    mockSession = null;
  }
}

void main() {
  group('AuthProvider Test', () {
    late MockAuthRepository mockRepository;
    late AuthProvider authProvider;

    final dummyUser = User(
      id: 'user-id-999',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    );

    final dummySession = Session(
      accessToken: 'dummy-token',
      tokenType: 'bearer',
      user: dummyUser,
    );

    setUp(() {
      mockRepository = MockAuthRepository();
      authProvider = AuthProvider(repository: mockRepository);
    });

    test('initial state when not logged in should be unauthenticated', () {
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.currentSession, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.errorMessage, isNull);
    });

    test('initial state when user is already logged in should be authenticated', () {
      final loggedInRepo = MockAuthRepository()
        ..mockUser = dummyUser
        ..mockSession = dummySession;

      final provider = AuthProvider(repository: loggedInRepo);

      expect(provider.status, AuthStatus.authenticated);
      expect(provider.currentUser, dummyUser);
      expect(provider.currentSession, dummySession);
      expect(provider.isAuthenticated, isTrue);
    });

    test('register (US04-AC1): succeeds and updates status to authenticated', () async {
      mockRepository.mockUser = dummyUser;
      mockRepository.mockSession = dummySession;

      final success = await authProvider.register(
        email: 'owner@kos.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.currentUser, dummyUser);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.errorMessage, isNull);
    });

    test('register (US04-AC2): fails when email is duplicate, sets error state', () async {
      mockRepository.shouldThrowSignUp = true;
      mockRepository.signUpException =
          const AuthException('Email sudah terdaftar. Silakan login.');

      final success = await authProvider.register(
        email: 'duplicate@kos.com',
        password: 'password123',
      );

      expect(success, isFalse);
      expect(authProvider.status, AuthStatus.error);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(
        authProvider.errorMessage,
        'Email sudah terdaftar. Silakan login.',
      );
    });

    test('login: succeeds with valid credentials', () async {
      mockRepository.mockUser = dummyUser;
      mockRepository.mockSession = dummySession;

      final success = await authProvider.login(
        email: 'owner@kos.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.currentUser, dummyUser);
      expect(authProvider.isAuthenticated, isTrue);
    });

    test('login: fails on invalid credentials and sets friendly errorMessage', () async {
      mockRepository.shouldThrowSignIn = true;
      mockRepository.signInException =
          const AuthException('Email atau password salah.');

      final success = await authProvider.login(
        email: 'owner@kos.com',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      expect(authProvider.status, AuthStatus.error);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, 'Email atau password salah.');
    });

    test('logout: clears session and transitions state to unauthenticated', () async {
      // Login first
      mockRepository.mockUser = dummyUser;
      mockRepository.mockSession = dummySession;
      await authProvider.login(email: 'owner@kos.com', password: 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      // Perform logout
      await authProvider.logout();

      expect(mockRepository.signOutCalled, isTrue);
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.currentSession, isNull);
      expect(authProvider.isAuthenticated, isFalse);
    });

    test('clearError resets error message and notifies listeners', () async {
      mockRepository.shouldThrowSignIn = true;
      await authProvider.login(email: 'a@b.com', password: '123');
      expect(authProvider.errorMessage, isNotNull);

      authProvider.clearError();
      expect(authProvider.errorMessage, isNull);
    });

    test('stream subscription updates auth status when onAuthStateChange emits', () async {
      expect(authProvider.isAuthenticated, isFalse);

      mockRepository.emitAuthState(AuthChangeEvent.signedIn, dummySession);
      await Future.delayed(Duration.zero);

      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.currentUser, dummyUser);

      mockRepository.emitAuthState(AuthChangeEvent.signedOut, null);
      await Future.delayed(Duration.zero);

      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.currentUser, isNull);
    });
  });
}
