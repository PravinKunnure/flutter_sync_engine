# flutter_sync_engine

**Version:** 0.0.1-dev.2+nonfunctional  
**Status:** Development / Non-functional for real backend

`flutter_sync_engine` is a **Flutter offline-first sync engine plugin** that provides:

- Local operation logging
- Push/pull transport system
- Conflict resolution
- Example app demonstrating offline note sync using in-memory, Hive, or SQLite stores

---

## Features (Dev Preview)

- **Offline-first data model** with `SyncOperation` and `SyncEntity`.
- **Stores**:
  - `InMemorySyncStore` (volatile, for demo)
  - `HiveSyncStore` (persistent, uses Hive)
  - `SQLiteSyncStore` (persistent, uses SQLite)
- **DummyTransport**: Simulate push/pull without a real backend.
- **SyncEngine**: Handles push, pull, conflict resolution.
- **Conflict resolution**: Built-in `LastWriteWins`.
- **Example app** shows:
  - Add notes offline
  - Sync notes to dummy backend
  - Pending vs synced visual indicators (cloud icons)
  - Log panel showing operations

---

## Getting Started

Add dependency in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_sync_engine:
    path: ../
