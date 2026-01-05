import '../model/sync_operation.dart';

/// Defines the interface for local persistence used by the sync engine.
///
/// A [SyncStore] implementation is responsible for:
/// - Persisting entities locally
/// - Tracking pending synchronization operations
/// - Providing access to stored data for conflict resolution
///
/// This abstraction allows the sync engine to work with different
/// storage backends such as in-memory stores, SQLite, or NoSQL databases.
abstract class SyncStore {
  /// Persists an entity in the local store.
  ///
  /// The [collection] identifies the logical grouping of entities.
  /// The [entity] contains the resolved data that should be saved.
  Future<void> saveEntity(String collection, dynamic entity);

  /// Retrieves a single entity by its identifier.
  ///
  /// Returns the stored entity if found, or `null` if no entity exists
  /// with the given [id] in the specified [collection].
  Future<dynamic> getEntity(String collection, String id);

  /// Retrieves all entities for a given collection.
  ///
  /// The returned map is keyed by entity identifier and contains
  /// the corresponding stored entity data.
  Future<Map<String, dynamic>> getEntities(String collection);

  /// Delete entity for a given collection id/unique field.
  ///
  Future<void> deleteEntity(String collection, String id);

  /// Records a synchronization operation for later processing.
  ///
  /// Logged operations are pushed to the remote backend during
  /// the next synchronization cycle.
  Future<void> logOperation(SyncOperation operation);

  /// Returns all pending local operations that have not yet
  /// been synchronized with the remote backend.
  Future<List<SyncOperation>> pendingOperations();

  /// Clears the specified operations from the local operation log.
  ///
  /// This is typically called after the operations have been
  /// successfully synchronized.
  Future<void> clearOperations(List<SyncOperation> operations);
}

///Without Docs
// import '../model/sync_operation.dart';
//
// abstract class SyncStore {
//   Future<void> saveEntity(String collection, dynamic entity);
//   Future<dynamic> getEntity(String collection, String id);
//   Future<Map<String, dynamic>> getEntities(String collection);
//   Future<void> logOperation(SyncOperation operation);
//   Future<List<SyncOperation>> pendingOperations();
//   Future<void> clearOperations(List<SyncOperation> operations);
// }
