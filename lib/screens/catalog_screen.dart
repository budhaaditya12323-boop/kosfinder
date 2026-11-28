import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/filter_bar.dart';
import '../widgets/kos_card.dart';
import 'about_screen.dart';
import 'kos_detail_screen.dart';
import 'login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<KosProvider>();
      if (provider.status == KosStateStatus.initial) {
        provider.fetchActiveKos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KosFinder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('owner_login_button'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Masuk Pemilik Kos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          IconButton(
            key: const Key('about_button'),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<KosProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search Bar & Filter Chips (T09)
              FilterBar(
                searchQuery: provider.searchQuery,
                selectedGender: provider.selectedGender,
                onSearchChanged: (query) => provider.setSearchQuery(query),
                onGenderSelected: (gender) => provider.setSelectedGender(gender),
                onClearSearch: () => provider.setSearchQuery(''),
                onPriceChanged: (val) => provider.setMaxPrice(val),
              ),

              // Content Area
              Expanded(
                child: _buildContent(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, KosProvider provider) {
    // Loading State
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          key: Key('loading_indicator'),
          color: Colors.green,
        ),
      );
    }

    // Error State with Retry Button (US01-AC3)
    if (provider.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 72,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage ??
                    'Gagal memuat data. Periksa koneksi internet Anda',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                key: const Key('retry_button'),
                onPressed: () => provider.retry(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty State (US01-AC2 vs US02-AC2)
    if (provider.isEmpty || provider.kosList.isEmpty) {
      final isFiltered = provider.isFilterActive;
      final emptyMessage = isFiltered
          ? 'Tidak ada kos yang cocok dengan pencarian Anda.'
          : 'Belum ada kos yang tersedia saat ini.';

      return RefreshIndicator(
        color: Colors.green,
        onRefresh: () => provider.fetchActiveKos(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFiltered
                          ? Icons.search_off_rounded
                          : Icons.home_outlined,
                      size: 72,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        emptyMessage,
                        key: const Key('empty_state_text'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    if (isFiltered) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        key: const Key('reset_filter_button'),
                        onPressed: () => provider.resetFilters(),
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset Filter'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Success / List Data (US01-AC1)
    return RefreshIndicator(
      color: Colors.green,
      onRefresh: () => provider.fetchActiveKos(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.kosList.length,
        itemBuilder: (context, index) {
          final kos = provider.kosList[index];
          return KosCard(
            kos: kos,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KosDetailScreen(kos: kos),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
