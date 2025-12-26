import '../model/sync_operation.dart';

/// Defines the interface for transporting synchronization data
/// between the local store and a remote backend.
///
/// A [SyncTransport] implementation is responsible for:
/// - Sending local operations to a server
/// - Fetching remote changes since a given point in time
///
/// This abstraction allows the sync engine to work with different
/// communication layers such as REST APIs, GraphQL, or WebSockets.
abstract class SyncTransport {
  /// Pushes a list of local synchronization operations to the remote backend.
  ///
  /// Implementations should ensure operations are transmitted
  /// reliably and in the correct order.
  Future<void> push(List<SyncOperation> operations);

  /// Pulls remote synchronization operations from the backend.
  ///
  /// If [since] is provided, only operations that occurred after
  /// the given timestamp should be returned. If `null`, all
  /// available remote operations may be fetched.
  Future<List<SyncOperation>> pull(DateTime? since);
}

///Without Docs
// import '../model/sync_operation.dart';
//
// abstract class SyncTransport {
//   Future<void> push(List<SyncOperation> operations);
//   Future<List<SyncOperation>> pull(DateTime? since);
// }
