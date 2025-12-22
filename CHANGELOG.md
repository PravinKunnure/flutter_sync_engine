# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1-dev.1+nonfunctional] - 2025-12-22
### Added
- Initial plugin scaffolding for `flutter_sync_engine`.
- Core models:
    - `SyncOperation`
    - `SyncEntity`
- Interfaces:
    - `SyncStore`
    - `SyncTransport`
    - `ConflictResolver`
- Default implementation:
    - `InMemorySyncStore` for in-memory storage.
    - `DummyTransport` for local push/pull simulation.
    - `LastWriteWins` conflict resolver.
- `SyncEngine` core class:
    - Push and pull operations.
    - Conflict resolution per collection.
    - Clear applied operations.
- Example app demonstrating:
    - Adding notes offline.
    - Sync button triggering sync cycle.
    - Log panel showing operations.
    - Visual feedback of synced/pending notes.

### Fixed
- N/A (first development release).

### Known Issues
- Example app uses dummy in-memory transport (no real backend).
- Conflict resolution uses empty local entity by default.
- Offline sync logic is **non-functional with real backend**.
- `_synced` flag logic is basic; may need refinement for production.

### Notes
- This version is **development-only**.
- API may change in future releases.
