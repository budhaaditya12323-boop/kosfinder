import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Halaman dashboard pemilik kos.
///
/// Menampilkan info user yang sedang login, tombol logout,
/// dan tombol kembali ke katalog publik.
/// Memenuhi AC: US04-AC1
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (context.mounted) {
      // Kembali ke halaman awal (CatalogScreen) dengan menghapus semua route
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _handleBackToCatalog(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.currentUser?.email ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // Info user yang sedang login
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      key: const Key('owner_email_text'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Tombol Kembali ke Katalog
            OutlinedButton.icon(
              key: const Key('back_to_catalog_button'),
              onPressed: () => _handleBackToCatalog(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Katalog'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            // Tombol Logout
            ElevatedButton.icon(
              key: const Key('logout_button'),
              onPressed: authProvider.isLoading
                  ? null
                  : () => _handleLogout(context),
              icon: authProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
