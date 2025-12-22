import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'sync_store.dart';
import '../model/sync_operation.dart';
import 'dart:convert';

class SQLiteSyncStore implements SyncStore {
  late Database _db;

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'sync_engine.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entities (
            collection TEXT,
            id TEXT,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE operations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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
  Future<void> saveEntity(
    String collection,
    Map<String, dynamic> entity,
  ) async {
    await _db.insert('entities', {
      'collection': collection,
      'id': entity['id'],
      'data': jsonEncode(entity),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> logOperation(SyncOperation operation) async {
    await _db.insert('operations', {
      'collection': operation.collection,
      'entityId': operation.entityId,
      'type': operation.type.toString(),
      'timestamp': operation.timestamp.toIso8601String(),
      'data': jsonEncode(operation.data),
    });
  }

  @override
  Future<List<SyncOperation>> pendingOperations() async {
    final rows = await _db.query('operations');
    return rows.map((row) {
      return SyncOperation(
        collection: row['collection'] as String,
        entityId: row['entityId'] as String,
        type: OperationType.values.firstWhere(
          (e) => e.toString() == row['type'],
        ),
        timestamp: DateTime.parse(row['timestamp'] as String),
        data: Map<String, dynamic>.from(jsonDecode(row['data'] as String)),
      );
    }).toList();
  }

  @override
  Future<void> clearOperations(List<SyncOperation> operations) async {
    for (final op in operations) {
      await _db.delete(
        'operations',
        where: 'collection = ? AND entityId = ?',
        whereArgs: [op.collection, op.entityId],
      );
    }
  }

  Future<Map<String, Map<String, dynamic>>> getEntities(
    String collection,
  ) async {
    final rows = await _db.query(
      'entities',
      where: 'collection = ?',
      whereArgs: [collection],
    );
    final result = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final entity = Map<String, dynamic>.from(
        jsonDecode(row['data'] as String),
      );
      result[entity['id']] = entity;
    }
    return result;
  }
}
