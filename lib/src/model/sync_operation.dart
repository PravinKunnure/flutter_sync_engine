/// The type of operation performed on an entity during synchronization.
enum OperationType {
  /// Indicates that a new entity was created.
  create,

  /// Indicates that an existing entity was updated.
  update,

  /// Indicates that an existing entity was deleted.
  delete,
}

/// Represents a single synchronization operation.
///
/// A [SyncOperation] captures a change made locally that must be
/// synchronized with a remote data source. These operations are
/// processed by the sync engine to push local changes and
/// resolve conflicts when pulling remote updates.
class SyncOperation {
  /// The name of the collection this operation applies to.
  final String collection;

  /// The unique identifier of the affected entity.
  final String entityId;

  /// The type of operation being performed.
  final OperationType type;

  /// The time at which the operation occurred.
  ///
  /// This timestamp is used to determine synchronization order
  /// and resolve conflicts.
  final DateTime timestamp;

  /// The entity data associated with this operation.
  ///
  /// For delete operations, this map may be empty.
  final Map<String, dynamic> data;

  /// Creates a new [SyncOperation].
  ///
  /// All fields are required and describe the context and
  /// payload of the synchronization change.
  SyncOperation({
    required this.collection,
    required this.entityId,
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

///Without Docs
// enum OperationType { create, update, delete }
//
// class SyncOperation {
//   final String collection;
//   final String entityId;
//   final OperationType type;
//   final DateTime timestamp;
//   final Map<String, dynamic> data;
//
//   SyncOperation({
//     required this.collection,
//     required this.entityId,
//     required this.type,
//     required this.timestamp,
//     required this.data,
//   });
// }
