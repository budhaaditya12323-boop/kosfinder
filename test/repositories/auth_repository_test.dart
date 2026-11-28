import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeGoTrueClient extends Fake implements GoTrueClient {
  User? mockUser;
  Session? mockSession;
  bool shouldThrowSignUp = false;
  AuthException? signUpException;
  bool shouldThrowSignIn = false;
  AuthException? signInException;
  bool signOutCalled = false;

  @override
  User? get currentUser => mockUser;

  @override
  Session? get currentSession => mockSession;

  @override
  Future<AuthResponse> signUp({
    String? email,
    required String password,
    String? phone,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    OtpChannel channel = OtpChannel.sms,
    String? captchaToken,
  }) async {
    if (shouldThrowSignUp) {
      throw signUpException ??
          const AuthException('User already registered', statusCode: '400');
    }
    return AuthResponse(
      session: mockSession,
      user: mockUser,
    );
  }

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
  }) async {
    if (shouldThrowSignIn) {
      throw signInException ??
          const AuthException('Invalid login credentials', statusCode: '400');
    }
    return AuthResponse(
      session: mockSession,
      user: mockUser,
    );
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.global}) async {
    signOutCalled = true;
    mockUser = null;
    mockSession = null;
  }
}

class FakeAuthSupabaseClient extends Fake implements SupabaseClient {
  final FakeGoTrueClient fakeAuth;

  FakeAuthSupabaseClient(this.fakeAuth);

  @override
  GoTrueClient get auth => fakeAuth;
}

void main() {
  group('AuthRepository Test', () {
    late FakeGoTrueClient fakeAuth;
    late FakeAuthSupabaseClient fakeClient;
    late AuthRepository repository;

    final dummyUser = User(
      id: 'owner-uuid-1234',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    );

    final dummySession = Session(
      accessToken: 'dummy-access-token',
      tokenType: 'bearer',
      user: dummyUser,
    );

    setUp(() {
      fakeAuth = FakeGoTrueClient();
      fakeClient = FakeAuthSupabaseClient(fakeAuth);
      repository = AuthRepository(client: fakeClient);
    });

    test('check session and isAuthenticated returns correct values', () {
      expect(repository.currentUser, isNull);
      expect(repository.currentSession, isNull);
      expect(repository.isAuthenticated, isFalse);

      fakeAuth.mockUser = dummyUser;
      fakeAuth.mockSession = dummySession;

      expect(repository.currentUser, dummyUser);
      expect(repository.currentSession, dummySession);
      expect(repository.isAuthenticated, isTrue);
    });

    test('US04-AC1: signUp succeeds with valid email and password', () async {
      fakeAuth.mockUser = dummyUser;
      fakeAuth.mockSession = dummySession;

      final res = await repository.signUp(
        email: 'owner@example.com',
        password: 'password123',
      );

      expect(res.user?.id, dummyUser.id);
      expect(res.session?.accessToken, dummySession.accessToken);
    });

    test('US04-AC2: signUp throws friendly message when email is already registered', () async {
      fakeAuth.shouldThrowSignUp = true;
      fakeAuth.signUpException = const AuthException('User already registered');

      expect(
        () => repository.signUp(
          email: 'duplicate@example.com',
          password: 'password123',
        ),
        throwsA(
          predicate<AuthException>(
            (e) => e.message == 'Email sudah terdaftar. Silakan login.',
          ),
        ),
      );
    });

    test('signInWithPassword succeeds with correct credentials', () async {
      fakeAuth.mockUser = dummyUser;
      fakeAuth.mockSession = dummySession;

      final res = await repository.signInWithPassword(
        email: 'owner@example.com',
        password: 'password123',
      );

      expect(res.user?.id, dummyUser.id);
    });

    test('signInWithPassword throws friendly message on invalid credentials', () async {
      fakeAuth.shouldThrowSignIn = true;
      fakeAuth.signInException = const AuthException('Invalid login credentials');

      expect(
        () => repository.signInWithPassword(
          email: 'wrong@example.com',
          password: 'wrongpassword',
        ),
        throwsA(
          predicate<AuthException>(
            (e) => e.message == 'Email atau password salah.',
          ),
        ),
      );
    });

    test('signOut terminates session', () async {
      fakeAuth.mockUser = dummyUser;
      fakeAuth.mockSession = dummySession;

      await repository.signOut();

      expect(fakeAuth.signOutCalled, isTrue);
      expect(repository.currentUser, isNull);
      expect(repository.isAuthenticated, isFalse);
    });
  });
}
