import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

typedef FetchActiveKosFunction = Future<List<Kos>> Function({
  String? query,
  String? genderType,
  int? maxPrice,
});

enum KosStateStatus { initial, loading, success, empty, error }

class KosProvider extends ChangeNotifier {
  final Function? fetchActiveKosCallback;
  final KosRepository? repository;

  KosProvider({
    this.fetchActiveKosCallback,
    this.repository,
  });

  KosStateStatus _status = KosStateStatus.initial;
  List<Kos> _kosList = [];
  String? _errorMessage;

  // Filter state
  String _searchQuery = '';
  String _selectedGender = 'Semua';
  int? _maxPrice;

  KosStateStatus get status => _status;
  List<Kos> get kosList => _kosList;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedGender => _selectedGender;
  int? get maxPrice => _maxPrice;

  bool get isLoading => _status == KosStateStatus.loading;
  bool get isEmpty => _status == KosStateStatus.empty;
  bool get isError => _status == KosStateStatus.error;
  bool get isSuccess => _status == KosStateStatus.success;

  bool get isFilterActive =>
      _searchQuery.trim().isNotEmpty ||
      (_selectedGender.toLowerCase() != 'semua') ||
      (_maxPrice != null && _maxPrice! > 0);

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    fetchActiveKos();
  }

  void setSelectedGender(String gender) {
    if (_selectedGender == gender) return;
    _selectedGender = gender;
    fetchActiveKos();
  }

  void setMaxPrice(int? price) {
    if (_maxPrice == price) return;
    _maxPrice = price;
    fetchActiveKos();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedGender = 'Semua';
    _maxPrice = null;
    fetchActiveKos();
  }

  Future<void> fetchActiveKos() async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Kos> items;
      final callback = fetchActiveKosCallback;
      if (callback != null) {
        if (callback is FetchActiveKosFunction) {
          items = await callback(
            query: _searchQuery,
            genderType: _selectedGender,
            maxPrice: _maxPrice,
          );
        } else if (callback is Future<List<Kos>> Function()) {
          items = await callback();
        } else {
          items = await (callback as dynamic)();
        }
      } else {
        final repo = repository ?? KosRepository();
        items = await repo.fetchActiveKos(
          query: _searchQuery,
          genderType: _selectedGender,
          maxPrice: _maxPrice,
        );
      }

      if (items.isEmpty) {
        _kosList = [];
        _status = KosStateStatus.empty;
      } else {
        _kosList = items;
        _status = KosStateStatus.success;
      }
    } catch (e) {
      debugPrint('ERROR ASLI: $e');
      _kosList = [];
      _status = KosStateStatus.error;
      _errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda';
    } finally {
      notifyListeners();
    }
  }

  void retry() {
    fetchActiveKos();
  }
}
