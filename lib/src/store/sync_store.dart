import '../model/sync_operation.dart';

abstract class SyncStore {
  Future<void> saveEntity(String collection, Map<String, dynamic> entity);
  Future<void> logOperation(SyncOperation operation);
  Future<List<SyncOperation>> pendingOperations();
  Future<void> clearOperations(List<SyncOperation> operations);
}
