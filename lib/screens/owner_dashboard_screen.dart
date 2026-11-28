import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/owner_kos_provider.dart';
import '../widgets/owner_kos_card.dart';
import 'kos_form_screen.dart';

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
        content: const Text('Kos ini akan dipindahkan ke arsip (soft-delete)...'),
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
      final messenger = ScaffoldMessenger.of(context);
      final rootNavigator = Navigator.of(context, rootNavigator: true);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final provider = context.read<OwnerKosProvider>();
      final success = await provider.softDeleteKos(id, ownerId);

      // Tutup dialog loading
      if (rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      if (success) {
        messenger.showSnackBar(const SnackBar(content: Text('Kos berhasil dipindahkan ke arsip.'), backgroundColor: Colors.green));
      } else {
        messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Gagal menghapus kos.'), backgroundColor: Colors.red));
      }
    }
  }

  void _handleRestoreKos(BuildContext context, String id, String ownerId) async {
    final messenger = ScaffoldMessenger.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final provider = context.read<OwnerKosProvider>();
    final success = await provider.restoreKos(id, ownerId);

    // Tutup dialog loading
    if (rootNavigator.canPop()) {
      rootNavigator.pop();
    }

    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('Kos berhasil dipulihkan ke daftar aktif.'), backgroundColor: Colors.green));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Gagal memulihkan kos.'), backgroundColor: Colors.red));
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
          title: const Text(
            'Dashboard Kos',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          // 1. Gunakan Gradient yang senada dengan tema hijau
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          // 2. Tombol logout dibuat lebih rapi dengan tooltip
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new_rounded),
              tooltip: 'Logout',
              onPressed: () => _handleLogout(context),
            ),
            const SizedBox(width: 8),
          ],
          // 3. TabBar disesuaikan agar menyatu dengan gradient
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70),
            tabs: [
              Tab(text: 'Kos Aktif'),
              Tab(text: 'Arsip'),
            ],
          ),
        ),
        body: (ownerKosProvider.isLoading && ownerKosProvider.activeKosList.isEmpty && ownerKosProvider.archivedKosList.isEmpty)
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
            // Navigasi ke form Tambah Kos
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KosFormScreen()),
            ).then((_) {
               // Refresh list setelah kembali dari form
               final ownerId = context.read<AuthProvider>().currentUser?.id;
               if (ownerId != null) {
                 context.read<OwnerKosProvider>().loadOwnerKos(ownerId);
               }
            });
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
            // Navigasi ke KosFormScreen dengan membawa data kos yang akan diedit
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KosFormScreen(existingKos: kos),
              ),
            ).then((_) {
              // Setelah form ditutup, refresh data agar perubahan langsung terlihat
              final ownerId = context.read<AuthProvider>().currentUser?.id;
              if (ownerId != null) {
                context.read<OwnerKosProvider>().loadOwnerKos(ownerId);
              }
            });
          },
          onDelete: () => _handleDeleteKos(context, kos.id, ownerId),
          onRestore: () => _handleRestoreKos(context, kos.id, ownerId),
        );
      },
    );
  }
}