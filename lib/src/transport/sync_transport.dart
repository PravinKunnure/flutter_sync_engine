import '../model/sync_operation.dart';

abstract class SyncTransport {
  Future<void> push(List<SyncOperation> operations);
  Future<List<SyncOperation>> pull(DateTime? since);
}
