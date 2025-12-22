import '../store/sync_store.dart';
import '../transport/sync_transport.dart';
import '../conflict/conflict_resolver.dart';
import '../model/sync_operation.dart';

class SyncEngine {
  final SyncStore store;
  final SyncTransport transport;

  final Map<String, ConflictResolver> _resolvers = {};

  SyncEngine({required this.store, required this.transport});

  /// Register conflict resolver for a collection
  void registerCollection({
    required String name,
    required ConflictResolver conflictResolver,
  }) {
    _resolvers[name] = conflictResolver;
  }

  /// The main sync function
  Future<void> sync() async {
    // 1️⃣ Pull pending operations
    final pendingOps = await store.pendingOperations();

    // 2️⃣ Push local changes
    if (pendingOps.isNotEmpty) {
      await transport.push(pendingOps);
    }

    // 3️⃣ Pull remote changes
    final remoteChanges = await transport.pull(
      pendingOps.isEmpty ? null : pendingOps.last.timestamp,
    );

    // 4️⃣ Apply remote changes with conflict resolution
    for (final op in remoteChanges) {
      final resolver = _resolvers[op.collection] ?? LastWriteWins();

      // For simplicity, assume op.data contains full entity
      // In real usage, you could merge at field-level
      await store.saveEntity(
        op.collection,
        resolver.resolve(
          local: {}, // Here we could fetch local entity if needed
          remote: op.data,
        ),
      );
    }

    // 5️⃣ Clear applied operations
    await store.clearOperations(pendingOps);
  }
}
