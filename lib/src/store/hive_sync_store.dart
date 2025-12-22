import 'package:hive/hive.dart';
import 'sync_store.dart';
import '../model/sync_operation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveSyncStore implements SyncStore {
  late Box<Map> _entityBox;
  late Box<SyncOperation> _opBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _entityBox = await Hive.openBox<Map>('entities');
    _opBox = await Hive.openBox<SyncOperation>('operations');
  }

  @override
  Future<void> saveEntity(
    String collection,
    Map<String, dynamic> entity,
  ) async {
    final key = '$collection-${entity['id']}';
    await _entityBox.put(key, {...entity});
  }

  @override
  Future<void> logOperation(SyncOperation operation) async {
    await _opBox.add(operation);
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async {
    return _opBox.values.toList();
  }

  @override
  Future<void> clearOperations(List<SyncOperation> operations) async {
    for (final op in operations) {
      final key = _opBox.keys.firstWhere(
        (k) => _opBox.get(k) == op,
        orElse: () => null,
      );
      if (key != null) await _opBox.delete(key);
    }
  }

  Map<String, Map<String, dynamic>> getEntities(String collection) {
    final result = <String, Map<String, dynamic>>{};
    for (final key in _entityBox.keys) {
      if (key.startsWith('$collection-')) {
        final entity = _entityBox.get(key)!;
        final id = entity['id'] as String;
        result[id] = Map<String, dynamic>.from(entity);
      }
    }
    return result;
  }
}
