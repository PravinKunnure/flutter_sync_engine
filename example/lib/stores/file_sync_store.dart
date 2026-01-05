import 'dart:convert';
import 'dart:io';
import 'package:flutter_sync_engine/flutter_sync_engine.dart';

class FileSyncStore implements SyncStore {
  final String filePath;

  /// collection -> entityId -> entity
  final Map<String, Map<String, dynamic>> _entities = {};
  final List<SyncOperation> _operations = [];

  FileSyncStore._(this.filePath);

  /// Factory to initialize store and load from file
  static Future<FileSyncStore> create(String fileName) async {
    final dir = Directory.systemTemp; // for example
    final file = File('${dir.path}/$fileName');
    final store = FileSyncStore._(file.path);

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
          jsonDecode(content),
        );

        // Cast nested entities safely
        jsonData.forEach((collection, items) {
          final Map<String, dynamic> entityMap = Map<String, dynamic>.from(
            items,
          );
          store._entities[collection] = entityMap.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          );
        });
      }
    }
    return store;
  }

  Future<void> _saveToFile() async {
    final file = File(filePath);
    await file.writeAsString(jsonEncode(_entities));
  }

  @override
  Future<void> saveEntity(String collection, dynamic entity) async {
    _entities.putIfAbsent(collection, () => {});
    _entities[collection]![entity['id']] = Map<String, dynamic>.from(entity);
    await _saveToFile();
  }

  @override
  Future<dynamic> getEntity(String collection, String id) async {
    return _entities[collection]?[id];
  }

  @override
  Future<Map<String, dynamic>> getEntities(String collection) async {
    return Map<String, dynamic>.from(_entities[collection] ?? {});
  }

  @override
  Future<void> logOperation(SyncOperation operation) async {
    _operations.add(operation);
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async {
    return List<SyncOperation>.from(_operations);
  }

  @override
  Future<void> clearOperations(List<SyncOperation> operations) async {
    _operations.removeWhere((op) => operations.contains(op));
  }

  /// ✅ Implemented deleteEntity
  @override
  Future<void> deleteEntity(String collection, String id) async {
    if (_entities.containsKey(collection)) {
      _entities[collection]!.remove(id);
      await _saveToFile();
    }
  }
}
