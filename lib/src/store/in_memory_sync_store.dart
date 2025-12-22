import 'sync_store.dart';
import '../model/sync_operation.dart';

class InMemorySyncStore implements SyncStore {
  final Map<String, Map<String, Map<String, dynamic>>> _entities = {};
  final List<SyncOperation> _operations = [];

  // Public getter to access entities (read-only)
  Map<String, Map<String, dynamic>> getEntities(String collection) {
    return _entities[collection] ?? {};
  }

  @override
  Future<void> saveEntity(
    String collection,
    Map<String, dynamic> entity,
  ) async {
    _entities.putIfAbsent(collection, () => {});
    _entities[collection]![entity['id']] = entity;
  }

  @override
  Future<void> logOperation(SyncOperation operation) async {
    _operations.add(operation);
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async {
    return List.from(_operations);
  }

  @override
  Future<void> clearOperations(List<SyncOperation> operations) async {
    _operations.removeWhere((op) => operations.contains(op));
  }
}
