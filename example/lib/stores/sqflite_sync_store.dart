import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_sync_engine/flutter_sync_engine.dart';
import 'dart:convert';

class SQLiteSyncStore implements SyncStore {
  late Database db;

  /// Initialize database and tables
  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'sync_engine.db');
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS entities(
            collection TEXT,
            entityId TEXT,
            data TEXT,
            PRIMARY KEY(collection, entityId)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS operations(
            collection TEXT,
            entityId TEXT,
            type TEXT,
            timestamp TEXT,
            data TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<void> saveEntity(String collection, dynamic entity) async {
    await db.insert('entities', {
      'collection': collection,
      'entityId': entity['id'],
      'data': jsonEncode(entity),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<dynamic> getEntity(String collection, String id) async {
    final list = await db.query(
      'entities',
      where: 'collection = ? AND entityId = ?',
      whereArgs: [collection, id],
    );
    if (list.isEmpty) return null;
    return jsonDecode(list.first['data'] as String);
  }

  @override
  Future<Map<String, dynamic>> getEntities(String collection) async {
    final list = await db.query(
      'entities',
      where: 'collection = ?',
      whereArgs: [collection],
    );
    final Map<String, dynamic> result = {};
    for (final row in list) {
      result[row['entityId'] as String] = jsonDecode(row['data'] as String);
    }
    return result;
  }

  @override
  Future<void> deleteEntity(String collection, String id) async {
    await db.delete(
      'entities',
      where: 'collection = ? AND entityId = ?',
      whereArgs: [collection, id],
    );
  }

  @override
  Future<void> logOperation(SyncOperation operation) async {
    await db.insert('operations', {
      'collection': operation.collection,
      'entityId': operation.entityId,
      'type': operation.type.toString(),
      'timestamp': operation.timestamp.toIso8601String(),
      'data': jsonEncode(operation.data),
    });
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async {
    final list = await db.query('operations');
    return list.map((row) {
      return SyncOperation(
        collection: row['collection'] as String,
        entityId: row['entityId'] as String,
        type: OperationType.values.firstWhere(
          (e) => e.toString() == row['type'] as String,
        ),
        timestamp: DateTime.parse(row['timestamp'] as String),
        data: Map<String, dynamic>.from(jsonDecode(row['data'] as String)),
      );
    }).toList();
  }

  @override
  Future<void> clearOperations(List<SyncOperation> operations) async {
    for (final op in operations) {
      await db.delete(
        'operations',
        where: 'collection = ? AND entityId = ?',
        whereArgs: [op.collection, op.entityId],
      );
    }
  }
}
