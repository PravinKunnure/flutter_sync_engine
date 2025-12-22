# flutter_sync_engine

**Version:** 0.0.1-dev_non_functional.1  
**Status:** Development / Currently Non-functional 

`flutter_sync_engine` is a **Flutter offline-first sync engine plugin** that provides:

- Local operation logging
- Push/pull transport system
- Conflict resolution
- Example app demonstrating offline note sync

---

## Features (Dev Preview)

- **Offline-first data model** with `SyncOperation` and `SyncEntity`.
- **InMemorySyncStore**: Store entities and track pending operations in memory.
- **DummyTransport**: Simulate push/pull without a backend.
- **SyncEngine**: Core engine handling push, pull, conflict resolution.
- **Conflict resolution**: Built-in `LastWriteWins`.
- Example app showing:
    - Add notes offline
    - Sync notes to dummy backend
    - Pending vs synced visual indicators
    - Log panel showing operations

---

## Getting Started

Add dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_sync_engine: <latest version>


## Usage/Example

final store = InMemorySyncStore();
final transport = DummyTransport();
final engine = SyncEngine(store: store, transport: transport);

engine.registerCollection(
  name: 'notes',
  conflictResolver: LastWriteWins(),
);

// Add note locally
await store.saveEntity('notes', {
  'id': '1',
  'title': 'Offline Note',
  'content': 'This is offline',
  'updatedAt': DateTime.now().toIso8601String(),
  '_synced': false,
});

await store.logOperation(SyncOperation(
  collection: 'notes',
  entityId: '1',
  type: OperationType.create,
  timestamp: DateTime.now(),
  data: {
    'id': '1',
    'title': 'Offline Note',
    'content': 'This is offline',
    'updatedAt': DateTime.now().toIso8601String(),
  },
));

// Perform sync
await engine.sync();
