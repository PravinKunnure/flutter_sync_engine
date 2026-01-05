import 'package:flutter_sync_engine/flutter_sync_engine.dart';

class SyncEngine {
  final SyncStore store;
  final SyncTransport transport;
  final Map<String, ConflictResolver> _resolvers = {};

  /// Hooks for debugging or custom reactions
  void Function()? onSyncStart;
  void Function()? onSyncComplete;
  void Function(Map<String, dynamic> local, Map<String, dynamic> remote)?
  onConflict;
  bool debug = false;

  SyncEngine({required this.store, required this.transport});

  void registerCollection({
    required String name,
    required ConflictResolver conflictResolver,
  }) {
    _resolvers[name] = conflictResolver;
  }

  Future<void> sync() async {
    if (debug) print('Sync started');
    onSyncStart?.call();

    final pendingOps = await store.pendingOperations();
    if (pendingOps.isNotEmpty) await transport.push(pendingOps);

    final remoteChanges = await transport.pull(
      pendingOps.isEmpty ? null : pendingOps.last.timestamp,
    );

    for (final op in remoteChanges) {
      final resolver = _resolvers[op.collection] ?? LastWriteWins();
      final local = await store.getEntity(op.collection, op.entityId);
      final resolved = resolver.resolve(local: local ?? {}, remote: op.data);

      if (local != null && local != resolved) {
        if (debug) print('Conflict resolved for ${op.entityId}');
        onConflict?.call(local, op.data);
      }

      await store.saveEntity(op.collection, resolved);
    }

    await store.clearOperations(pendingOps);

    if (debug) print('Sync completed');
    onSyncComplete?.call();
  }
}

///Version 1.0.2
// import '../store/sync_store.dart';
// import '../transport/sync_transport.dart';
// import '../conflict/conflict_resolver.dart';
//
// /// The core synchronization engine.
// ///
// /// `SyncEngine` coordinates synchronization between a local [SyncStore]
// /// and a remote [SyncTransport]. It is responsible for:
// /// - Pushing pending local operations to the server
// /// - Pulling remote changes
// /// - Resolving conflicts using registered [ConflictResolver]s
// /// - Persisting the resolved data locally
// class SyncEngine {
//   /// The local persistence layer used for storing entities
//   /// and tracking pending operations.
//   final SyncStore store;
//
//   /// The transport layer responsible for communicating
//   /// with the remote backend.
//   final SyncTransport transport;
//
//   /// Conflict resolvers registered per collection name.
//   ///
//   /// If no resolver is registered for a collection,
//   /// a [LastWriteWins] resolver is used by default.
//   final Map<String, ConflictResolver> _resolvers = {};
//
//   /// Creates a new [SyncEngine].
//   ///
//   /// Both [store] and [transport] must be provided and
//   /// define how local data is stored and synchronized remotely.
//   SyncEngine({required this.store, required this.transport});
//
//   /// Registers a conflict resolver for a specific collection.
//   ///
//   /// The [name] corresponds to the collection identifier used
//   /// in sync operations. The provided [conflictResolver] will
//   /// be used to merge local and remote changes for that collection.
//   void registerCollection({
//     required String name,
//     required ConflictResolver conflictResolver,
//   }) {
//     _resolvers[name] = conflictResolver;
//   }
//
//   /// Executes a full synchronization cycle.
//   ///
//   /// This method performs the following steps:
//   /// 1. Pushes any pending local operations to the remote backend
//   /// 2. Pulls remote changes since the last known operation
//   /// 3. Resolves conflicts using the registered [ConflictResolver]
//   /// 4. Saves the resolved entities locally
//   /// 5. Clears successfully synced local operations
//   ///
//   /// If no specific resolver is registered for a collection,
//   /// [LastWriteWins] is used as the default strategy.
//   Future<void> sync() async {
//     final pendingOps = await store.pendingOperations();
//
//     if (pendingOps.isNotEmpty) {
//       await transport.push(pendingOps);
//     }
//
//     final remoteChanges = await transport.pull(
//       pendingOps.isEmpty ? null : pendingOps.last.timestamp,
//     );
//
//     for (final op in remoteChanges) {
//       final resolver = _resolvers[op.collection] ?? LastWriteWins();
//       final local = await store.getEntity(op.collection, op.entityId);
//
//       await store.saveEntity(
//         op.collection,
//         resolver.resolve(local: local ?? {}, remote: op.data),
//       );
//     }
//
//     await store.clearOperations(pendingOps);
//   }
// }

///Without docs
// import '../store/sync_store.dart';
// import '../transport/sync_transport.dart';
// import '../conflict/conflict_resolver.dart';
//
// class SyncEngine {
//   final SyncStore store;
//   final SyncTransport transport;
//   final Map<String, ConflictResolver> _resolvers = {};
//
//   SyncEngine({required this.store, required this.transport});
//
//   void registerCollection({
//     required String name,
//     required ConflictResolver conflictResolver,
//   }) {
//     _resolvers[name] = conflictResolver;
//   }
//
//   Future<void> sync() async {
//     final pendingOps = await store.pendingOperations();
//     if (pendingOps.isNotEmpty) await transport.push(pendingOps);
//
//     final remoteChanges = await transport.pull(
//       pendingOps.isEmpty ? null : pendingOps.last.timestamp,
//     );
//
//     for (final op in remoteChanges) {
//       final resolver = _resolvers[op.collection] ?? LastWriteWins();
//       final local = await store.getEntity(op.collection, op.entityId);
//       await store.saveEntity(
//         op.collection,
//         resolver.resolve(local: local ?? {}, remote: op.data),
//       );
//     }
//
//     await store.clearOperations(pendingOps);
//   }
// }
