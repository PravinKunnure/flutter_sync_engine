import '../store/sync_store.dart';
import '../transport/sync_transport.dart';
import '../conflict/conflict_resolver.dart';

class SyncEngine {
  final SyncStore store;
  final SyncTransport transport;
  final Map<String, ConflictResolver> _resolvers = {};

  SyncEngine({required this.store, required this.transport});

  void registerCollection({
    required String name,
    required ConflictResolver conflictResolver,
  }) {
    _resolvers[name] = conflictResolver;
  }

  Future<void> sync() async {
    final pendingOps = await store.pendingOperations();
    if (pendingOps.isNotEmpty) await transport.push(pendingOps);

    final remoteChanges = await transport.pull(
      pendingOps.isEmpty ? null : pendingOps.last.timestamp,
    );

    for (final op in remoteChanges) {
      final resolver = _resolvers[op.collection] ?? LastWriteWins();
      final local = await store.getEntity(op.collection, op.entityId);
      await store.saveEntity(
        op.collection,
        resolver.resolve(local: local ?? {}, remote: op.data),
      );
    }

    await store.clearOperations(pendingOps);
  }
}
