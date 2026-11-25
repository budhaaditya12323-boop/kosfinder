import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';

typedef FetchActiveKosFunction = Future<List<Kos>> Function();

enum KosStateStatus { initial, loading, success, empty, error }

class KosProvider extends ChangeNotifier {
  final FetchActiveKosFunction? fetchActiveKosCallback;

  KosProvider({this.fetchActiveKosCallback});

  KosStateStatus _status = KosStateStatus.initial;
  List<Kos> _kosList = [];
  String? _errorMessage;

  KosStateStatus get status => _status;
  List<Kos> get kosList => _kosList;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == KosStateStatus.loading;
  bool get isEmpty => _status == KosStateStatus.empty;
  bool get isError => _status == KosStateStatus.error;
  bool get isSuccess => _status == KosStateStatus.success;

  Future<void> fetchActiveKos() async {
    _status = KosStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetcher = fetchActiveKosCallback;
      final List<Kos> items;
      if (fetcher != null) {
        items = await fetcher();
      } else {
        items = [];
      }

      if (items.isEmpty) {
        _kosList = [];
        _status = KosStateStatus.empty;
      } else {
        _kosList = items;
        _status = KosStateStatus.success;
      }
    } catch (e) {
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
