enum OperationType { create, update, delete }

class SyncOperation {
  final String collection;
  final String entityId;
  final OperationType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  SyncOperation({
    required this.collection,
    required this.entityId,
    required this.type,
    required this.timestamp,
    required this.data,
  });
}
