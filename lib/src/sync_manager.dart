import 'package:flutter_sync_engine/flutter_sync_engine.dart';

class SyncManager {
  final SyncEngine _engine;

  SyncManager({required SyncStore store, required SyncTransport transport})
    : _engine = SyncEngine(store: store, transport: transport);

  CollectionManager collection(String name, {ConflictResolver? resolver}) {
    if (resolver != null) {
      _engine.registerCollection(name: name, conflictResolver: resolver);
    }
    return CollectionManager(_engine, name);
  }

  Future<void> sync() => _engine.sync();
}

class CollectionManager {
  final SyncEngine _engine;
  final String _name;

  CollectionManager(this._engine, this._name);

  Future<void> create(Map<String, dynamic> entity) async {
    final id = entity['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    entity['id'] = id;
    entity['updatedAt'] = DateTime.now().toUtc().toIso8601String();

    await _engine.store.saveEntity(_name, entity);
    await _engine.store.logOperation(
      SyncOperation(
        collection: _name,
        entityId: id,
        type: OperationType.create,
        timestamp: DateTime.now().toUtc(),
        data: entity,
      ),
    );
  }

  Future<void> update(Map<String, dynamic> entity) async {
    final id = entity['id'];
    if (id == null) throw Exception('Entity must have an id');
    entity['updatedAt'] = DateTime.now().toUtc().toIso8601String();

    await _engine.store.saveEntity(_name, entity);
    await _engine.store.logOperation(
      SyncOperation(
        collection: _name,
        entityId: id,
        type: OperationType.update,
        timestamp: DateTime.now().toUtc(),
        data: entity,
      ),
    );
  }

  Future<void> delete(String id) async {
    await _engine.store.deleteEntity(_name, id);
    await _engine.store.logOperation(
      SyncOperation(
        collection: _name,
        entityId: id,
        type: OperationType.delete,
        timestamp: DateTime.now().toUtc(),
        data: {},
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final entities = await _engine.store.getEntities(_name);
    return entities.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
