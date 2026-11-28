import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/owner_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Fake AuthRepository — isolasi dari Supabase runtime
// ---------------------------------------------------------------------------
class FakeAuthRepoForDashboard implements AuthRepository {
  User? mockUser;
  Session? mockSession;
  bool shouldThrowSignOut = false;

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
  }) async =>
      AuthResponse();

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async =>
      AuthResponse();

  @override
  Future<void> signOut() async {
    if (shouldThrowSignOut) {
      throw Exception('sign out failed');
    }
    mockUser = null;
    mockSession = null;
  }

  void dispose() => _controller.close();
}

// ---------------------------------------------------------------------------
// Helper: buat User palsu dengan email
// ---------------------------------------------------------------------------
User _fakeUser(String email) => User(
      id: 'owner-uuid',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );

// ---------------------------------------------------------------------------
// Helper: pump OwnerDashboardScreen dengan provider
// ---------------------------------------------------------------------------
Widget _buildDashboard(AuthProvider authProvider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: authProvider,
    child: const MaterialApp(
      home: OwnerDashboardScreen(),
    ),
  );
}

void main() {
  group('OwnerDashboardScreen', () {
    // -----------------------------------------------------------------------
    // 1. Menampilkan email owner yang sedang login
    // -----------------------------------------------------------------------
    testWidgets('Menampilkan email user saat authenticated',
        (WidgetTester tester) async {
      final repo = FakeAuthRepoForDashboard()
        ..mockUser = _fakeUser('pemilik@kos.com');
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(_buildDashboard(authProvider));
      await tester.pump();

      expect(find.text('pemilik@kos.com'), findsOneWidget);
      expect(find.byKey(const Key('owner_email_text')), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 2. Menampilkan 'Guest' saat currentUser null
    // -----------------------------------------------------------------------
    testWidgets('Menampilkan "Guest" saat tidak ada user',
        (WidgetTester tester) async {
      final repo = FakeAuthRepoForDashboard(); // mockUser = null
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(_buildDashboard(authProvider));
      await tester.pump();

      expect(find.text('Guest'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 3. Tombol Logout ada dan bisa ditekan
    // -----------------------------------------------------------------------
    testWidgets('Tombol Logout ada di screen', (WidgetTester tester) async {
      final repo = FakeAuthRepoForDashboard()
        ..mockUser = _fakeUser('pemilik@kos.com');
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(_buildDashboard(authProvider));
      await tester.pump();

      expect(find.byKey(const Key('logout_button')), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 4. Ketuk Logout → logout() dipanggil dan user menjadi null
    // -----------------------------------------------------------------------
    testWidgets('Ketuk Logout memanggil authProvider.logout()',
        (WidgetTester tester) async {
      final repo = FakeAuthRepoForDashboard()
        ..mockUser = _fakeUser('pemilik@kos.com');
      final authProvider = AuthProvider(repository: repo);

      // Bungkus dengan Navigator agar pop tidak crash
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            routes: {
              '/': (_) => const Scaffold(body: Text('Catalog')),
              '/dashboard': (_) => const OwnerDashboardScreen(),
            },
            initialRoute: '/dashboard',
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Setelah logout, user di repo harus null
      expect(repo.mockUser, isNull);
      // Status provider harus unauthenticated
      expect(authProvider.isAuthenticated, isFalse);
    });

    // -----------------------------------------------------------------------
    // 5. Tombol "Kembali ke Katalog" ada di screen
    // -----------------------------------------------------------------------
    testWidgets('Tombol Kembali ke Katalog ada di screen',
        (WidgetTester tester) async {
      final repo = FakeAuthRepoForDashboard()
        ..mockUser = _fakeUser('pemilik@kos.com');
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(_buildDashboard(authProvider));
      await tester.pump();

      expect(find.byKey(const Key('back_to_catalog_button')), findsOneWidget);
      expect(find.text('Kembali ke Katalog'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 6. Ketuk "Kembali ke Katalog" → Navigator.pop() dipanggil
    // -----------------------------------------------------------------------
    testWidgets('Ketuk Kembali ke Katalog melakukan pop navigasi',
        (WidgetTester tester) async {
      final repo = FakeAuthRepoForDashboard()
        ..mockUser = _fakeUser('pemilik@kos.com');
      final authProvider = AuthProvider(repository: repo);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: Builder(builder: (ctx) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).push(
                    MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider<
                                AuthProvider>.value(
                              value: authProvider,
                              child: const OwnerDashboardScreen(),
                            )),
                  );
                },
                child: const Text('Go to Dashboard'),
              );
            }),
          ),
        ),
      );

      // Navigasi ke OwnerDashboardScreen
      await tester.tap(find.text('Go to Dashboard'));
      await tester.pumpAndSettle();

      expect(find.byType(OwnerDashboardScreen), findsOneWidget);

      // Ketuk tombol kembali
      await tester.tap(find.byKey(const Key('back_to_catalog_button')));
      await tester.pumpAndSettle();

      // OwnerDashboardScreen sudah dipop
      expect(find.byType(OwnerDashboardScreen), findsNothing);
    });
  });
}
