import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/owner_kos_provider.dart';
import '../widgets/owner_kos_card.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data kos milik pemilik setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = context.read<AuthProvider>().currentUser?.id;
      if (ownerId != null) {
        context.read<OwnerKosProvider>().loadOwnerKos(ownerId);
      }
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _handleDeleteKos(BuildContext context, String id, String ownerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kos?'),
        content: const Text('Kos ini akan dipindahkan ke arsip (soft-delete). Anda dapat memulihkannya kembali nanti.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<OwnerKosProvider>().softDeleteKos(id, ownerId);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kos berhasil dihapus.')));
      }
    }
  }

  void _handleRestoreKos(BuildContext context, String id, String ownerId) async {
    final success = await context.read<OwnerKosProvider>().restoreKos(id, ownerId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kos berhasil dipulihkan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ownerKosProvider = context.watch<OwnerKosProvider>();
    final email = authProvider.currentUser?.email ?? 'Owner';
    final ownerId = authProvider.currentUser?.id ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Kos'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () => _handleLogout(context),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Kos Aktif'),
              Tab(text: 'Arsip'),
            ],
          ),
        ),
        body: ownerKosProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Login sebagai: $email', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // TAB 1: AKTIF
                        _buildKosList(ownerKosProvider.activeKosList, ownerId, context, true),
                        // TAB 2: ARSIP
                        _buildKosList(ownerKosProvider.archivedKosList, ownerId, context, false),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigasi ke form Tambah Kos (T17)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form Tambah Kos akan dibuat di T17')));
          },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Kos'),
        ),
      ),
    );
  }

  Widget _buildKosList(List<dynamic> list, String ownerId, BuildContext context, bool isTabActive) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isTabActive ? 'Belum ada kos aktif.' : 'Tidak ada kos di arsip.',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Jarak untuk FAB
      itemCount: list.length,
      itemBuilder: (context, index) {
        final kos = list[index];
        return OwnerKosCard(
          kos: kos,
          onEdit: () {
             // TODO: Navigasi ke form Edit Kos (T18)
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form Edit Kos akan dibuat di T18')));
          },
          onDelete: () => _handleDeleteKos(context, kos.id, ownerId),
          onRestore: () => _handleRestoreKos(context, kos.id, ownerId),
        );
      },
    );
  }
}