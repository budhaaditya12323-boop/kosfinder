import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/catalog_screen.dart';
import 'package:kosfinder/screens/login_screen.dart';
import 'package:kosfinder/screens/register_screen.dart';

class FakeAuthRepoForUI implements AuthRepository {
  User? mockUser;
  Session? mockSession;
  bool shouldThrowSignUp = false;
  AuthException? signUpException;
  bool shouldThrowSignIn = false;
  AuthException? signInException;

  final StreamController<AuthState> _controller =
      StreamController<AuthState>.broadcast();

  @override
  SupabaseClient? get client => null;

  @override
  User? get currentUser => mockUser;

  @override
  Session? get currentSession => mockSession;

  @override
  bool get isAuthenticated => mockUser != null;

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    if (shouldThrowSignUp) {
      throw signUpException ??
          const AuthException('Email sudah terdaftar. Silakan login.');
    }
    return AuthResponse(user: mockUser, session: mockSession);
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
    return AuthResponse(user: mockUser, session: mockSession);
  }

  @override
  Future<void> signOut() async {
    mockUser = null;
    mockSession = null;
  }
}

void main() {
  group('Auth Screens (LoginScreen & RegisterScreen) Test', () {
    late FakeAuthRepoForUI fakeRepo;
    late AuthProvider authProvider;

    final dummyUser = User(
      id: 'owner-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    );

    final dummySession = Session(
      accessToken: 'token-123',
      tokenType: 'bearer',
      user: dummyUser,
    );

    setUp(() {
      fakeRepo = FakeAuthRepoForUI();
      authProvider = AuthProvider(repository: fakeRepo);
    });

    Widget wrapWithAuthProvider(Widget child) {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: child,
        ),
        routes: {
          '/owner-dashboard': (_) => const Scaffold(
                body: Center(child: Text('Owner Dashboard Placeholder')),
              ),
        },
      );
    }

    testWidgets('LoginScreen validates empty/invalid email and short password',
        (tester) async {
      await tester.pumpWidget(wrapWithAuthProvider(const LoginScreen()));

      // Tap submit with empty fields
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);

      // Enter invalid email and short password
      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'invalidemail',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        '123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid'), findsOneWidget);
      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('LoginScreen succeeds and navigates to /owner-dashboard',
        (tester) async {
      fakeRepo.mockUser = dummyUser;
      fakeRepo.mockSession = dummySession;

      await tester.pumpWidget(wrapWithAuthProvider(const LoginScreen()));

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'owner@kos.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Owner Dashboard Placeholder'), findsOneWidget);
    });

    testWidgets('LoginScreen displays error banner on invalid credentials',
        (tester) async {
      fakeRepo.shouldThrowSignIn = true;

      await tester.pumpWidget(wrapWithAuthProvider(const LoginScreen()));

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'wrong@kos.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'password123',
      );
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth_error_banner')), findsOneWidget);
      expect(find.text('Email atau password salah.'), findsOneWidget);
    });

    testWidgets('US04-AC1: RegisterScreen succeeds and navigates to dashboard',
        (tester) async {
      fakeRepo.mockUser = dummyUser;
      fakeRepo.mockSession = dummySession;

      await tester.pumpWidget(wrapWithAuthProvider(const RegisterScreen()));

      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'newowner@kos.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'securepass123',
      );
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Owner Dashboard Placeholder'), findsOneWidget);
    });

    testWidgets('US04-AC2: RegisterScreen shows duplicate email error banner',
        (tester) async {
      fakeRepo.shouldThrowSignUp = true;

      await tester.pumpWidget(wrapWithAuthProvider(const RegisterScreen()));

      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'existing@kos.com',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'securepass123',
      );
      await tester.tap(find.byKey(const Key('register_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('auth_error_banner')), findsOneWidget);
      expect(
        find.text('Email sudah terdaftar. Silakan login.'),
        findsOneWidget,
      );
    });

    testWidgets('navigates from CatalogScreen person icon to LoginScreen',
        (tester) async {
      final kosProvider = KosProvider(
        fetchActiveKosCallback: () async => <Kos>[],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<KosProvider>.value(value: kosProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: CatalogScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      final loginBtn = find.byKey(const Key('owner_login_button'));
      expect(loginBtn, findsOneWidget);

      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Masuk Pemilik Kos'), findsOneWidget);
    });
  });
}
