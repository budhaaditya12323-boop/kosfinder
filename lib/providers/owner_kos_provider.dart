import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

enum OwnerKosStatus { initial, loading, success, empty, error }

class OwnerKosProvider extends ChangeNotifier {
  final KosRepository _repository;

  OwnerKosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  OwnerKosStatus _status = OwnerKosStatus.initial;
  List<Kos> _activeKosList = [];
  List<Kos> _archivedKosList = [];
  String? _errorMessage;

  OwnerKosStatus get status => _status;
  List<Kos> get activeKosList => _activeKosList;
  List<Kos> get archivedKosList => _archivedKosList;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == OwnerKosStatus.loading;
  bool get isEmpty => _status == OwnerKosStatus.empty;
  bool get isError => _status == OwnerKosStatus.error;

  /// Memuat daftar kos aktif dan arsip milik pemilik (US05, US06, US07)
  Future<void> loadOwnerKos(String ownerId) async {
    _status = OwnerKosStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final active = await _repository.fetchOwnerKos(ownerId, isActive: true);
      final archived = await _repository.fetchOwnerKos(ownerId, isActive: false);

      _activeKosList = active;
      _archivedKosList = archived;

      if (active.isEmpty && archived.isEmpty) {
        _status = OwnerKosStatus.empty;
      } else {
        _status = OwnerKosStatus.success;
      }
    } catch (e) {
      _status = OwnerKosStatus.error;
      _errorMessage = 'Gagal memuat data kos Anda. Periksa koneksi internet.';
      debugPrint('ERROR OWNER FETCH: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Menambahkan kos baru (US05-AC1)
  Future<bool> createKos(Kos kos) async {
    _status = OwnerKosStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createKos(kos);
      await loadOwnerKos(kos.ownerId); // Refresh list
      return true;
    } catch (e) {
      _status = OwnerKosStatus.error;
      _errorMessage = 'Gagal menambahkan kos. Coba lagi.';
      debugPrint('ERROR CREATE KOS: $e');
      notifyListeners();
      return false;
    }
  }

  /// Mengubah data kos (US06-AC1)
  Future<bool> updateKos(String id, Map<String, dynamic> updates, String ownerId) async {
    _status = OwnerKosStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateKos(id, updates);
      await loadOwnerKos(ownerId); // Refresh list
      return true;
    } catch (e) {
      _status = OwnerKosStatus.error;
      _errorMessage = 'Gagal mengubah kos. Coba lagi.';
      debugPrint('ERROR UPDATE KOS: $e');
      notifyListeners();
      return false;
    }
  }

  /// Menghapus kos (Soft Delete) (US07-AC1)
  Future<bool> softDeleteKos(String id, String ownerId) async {
    _status = OwnerKosStatus.loading;
    notifyListeners();

    try {
      await _repository.softDeleteKos(id, isActive: false);
      await loadOwnerKos(ownerId); // Refresh list
      return true;
    } catch (e) {
      _status = OwnerKosStatus.error;
      _errorMessage = 'Gagal menghapus kos. Periksa koneksi internet.';
      debugPrint('ERROR DELETE KOS: $e');
      notifyListeners();
      return false;
    }
  }

  /// Mengembalikan kos dari arsip ke aktif (Restore)
  Future<bool> restoreKos(String id, String ownerId) async {
    _status = OwnerKosStatus.loading;
    notifyListeners();

    try {
      await _repository.softDeleteKos(id, isActive: true); // True to restore
      await loadOwnerKos(ownerId);
      return true;
    } catch (e) {
      _status = OwnerKosStatus.error;
      _errorMessage = 'Gagal memulihkan kos.';
      debugPrint('ERROR RESTORE KOS: $e');
      notifyListeners();
      return false;
    }
  }
}