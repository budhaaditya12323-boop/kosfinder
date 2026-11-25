import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakePostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  final FutureOr<T> Function() _onExecute;

  FakePostgrestTransformBuilder(this._onExecute);

  @override
  Future<U> then<U>(
    FutureOr<U> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future.sync(_onExecute).then(onValue, onError: onError);
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final Map<String, dynamic> filters;
  final FutureOr<T> Function() onExecute;

  FakePostgrestFilterBuilder(this.onExecute, [Map<String, dynamic>? initialFilters])
      : filters = initialFilters ?? {};

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    filters[column] = value;
    return this;
  }

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    return FakePostgrestTransformBuilder<T>(onExecute);
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future.sync(onExecute).then(onValue, onError: onError);
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final FutureOr<dynamic> Function() _onQuery;
  final Map<String, dynamic> recordedFilters;

  FakeSupabaseQueryBuilder(this._onQuery, this.recordedFilters);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String columns = '*']) {
    return FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(() async {
      final res = await _onQuery();
      return (res as List).cast<Map<String, dynamic>>();
    }, recordedFilters);
  }
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, FutureOr<dynamic> Function()> tableHandlers = {};
  final Map<String, dynamic> recordedFilters = {};

  void mockTable(String tableName, FutureOr<dynamic> Function() onQuery) {
    tableHandlers[tableName] = onQuery;
  }

  @override
  SupabaseQueryBuilder from(String table) {
    if (tableHandlers.containsKey(table)) {
      return FakeSupabaseQueryBuilder(tableHandlers[table]!, recordedFilters);
    }
    throw UnimplementedError('Table $table is not mocked');
  }
}

void main() {
  group('KosRepository Test', () {
    late FakeSupabaseClient fakeClient;
    late KosRepository repository;

    final sampleData = [
      {
        'id': '11111111-1111-1111-1111-111111111111',
        'owner_id': '22222222-2222-2222-2222-222222222222',
        'name': 'Kos Flamboyan',
        'gender_type': 'putra',
        'price': 750000,
        'room_available': 4,
        'address': 'Jl. Kaliurang KM 5',
        'contact_number': '081234567890',
        'image_url': 'https://example.com/flamboyan.jpg',
        'is_active': true,
        'created_at': '2026-02-01T08:00:00.000Z',
        'updated_at': '2026-02-01T08:00:00.000Z',
      },
      {
        'id': '33333333-3333-3333-3333-333333333333',
        'owner_id': '44444444-4444-4444-4444-444444444444',
        'name': 'Kos Cempaka',
        'gender_type': 'putri',
        'price': 900000,
        'room_available': 0,
        'address': 'Jl. Gejayan No. 10',
        'contact_number': '089876543210',
        'image_url': null,
        'is_active': true,
        'created_at': '2026-02-02T10:00:00.000Z',
        'updated_at': '2026-02-02T10:00:00.000Z',
      },
    ];

    setUp(() {
      fakeClient = FakeSupabaseClient();
      repository = KosRepository(client: fakeClient);
    });

    test('fetchActiveKos successfully returns list of active Kos (US01-AC1)', () async {
      fakeClient.mockTable('kos', () => sampleData);

      final result = await repository.fetchActiveKos();

      expect(result.length, 2);
      expect(result.first.name, 'Kos Flamboyan');
      expect(result.first.genderType, 'putra');
      expect(result.first.price, 750000);
      expect(result.first.roomAvailable, 4);
      expect(result.first.contactNumber, '6281234567890');
      expect(result.first.isFull, false);

      expect(result.last.name, 'Kos Cempaka');
      expect(result.last.genderType, 'putri');
      expect(result.last.roomAvailable, 0);
      expect(result.last.isFull, true);

      // Verify query filter is_active == true
      expect(fakeClient.recordedFilters['is_active'], true);
    });

    test('fetchActiveKos returns empty list when no active kos in database (US01-AC2)', () async {
      fakeClient.mockTable('kos', () => <Map<String, dynamic>>[]);

      final result = await repository.fetchActiveKos();

      expect(result, isEmpty);
    });

    test('fetchActiveKos propagates exception when query fails (US01-AC3)', () async {
      fakeClient.mockTable('kos', () {
        throw const PostgrestException(message: 'Connection failed');
      });

      expect(
        repository.fetchActiveKos(),
        throwsA(isA<PostgrestException>()),
      );
    });
  });
}
