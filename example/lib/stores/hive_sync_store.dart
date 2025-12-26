import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_sync_engine/flutter_sync_engine.dart';

class HiveSyncStore implements SyncStore {
  late Box box;

  HiveSyncStore();

  Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('sync_store');
  }

  @override
  Future<void> saveEntity(String collection, dynamic entity) async {
    final col = box.get(collection, defaultValue: <String, dynamic>{}) as Map;
    col[entity['id']] = entity;
    await box.put(collection, col);
  }

  @override
  Future<Map<String, dynamic>> getEntities(String collection) async {
    final col = box.get(collection, defaultValue: <String, dynamic>{}) as Map;
    return Map<String, dynamic>.from(col);
  }

  @override
  Future<void> logOperation(SyncOperation operation) async {
    final ops = box.get('operations', defaultValue: <Map>[]) as List;
    ops.add({
      'collection': operation.collection,
      'entityId': operation.entityId,
      'type': operation.type.toString(),
      'timestamp': operation.timestamp.toIso8601String(),
      'data': operation.data,
    });
    await box.put('operations', ops);
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async {
    final ops = box.get('operations', defaultValue: <Map>[]) as List;
    return ops.map((json) {
      return SyncOperation(
        collection: json['collection'],
        entityId: json['entityId'],
        type: OperationType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
        timestamp: DateTime.parse(json['timestamp']),
        data: Map<String, dynamic>.from(json['data']),
      );
    }).toList();
  }

  @override
  Future<void> clearOperations(List<SyncOperation> operations) async {
    final ops = await pendingOperations();
    final remaining = ops.where((op) => !operations.contains(op)).toList();
    final listToStore = remaining
        .map(
          (op) => {
            'collection': op.collection,
            'entityId': op.entityId,
            'type': op.type.toString(),
            'timestamp': op.timestamp.toIso8601String(),
            'data': op.data,
          },
        )
        .toList();
    await box.put('operations', listToStore);
  }

  @override
  Future<dynamic> getEntity(String collection, String id) async {
    final col = await getEntities(collection);
    return col[id];
  }
}
