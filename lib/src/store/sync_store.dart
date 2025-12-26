import '../model/sync_operation.dart';

abstract class SyncStore {
  Future<void> saveEntity(String collection, dynamic entity);
  Future<dynamic> getEntity(String collection, String id);
  Future<Map<String, dynamic>> getEntities(String collection);
  Future<void> logOperation(SyncOperation operation);
  Future<List<SyncOperation>> pendingOperations();
  Future<void> clearOperations(List<SyncOperation> operations);
}
