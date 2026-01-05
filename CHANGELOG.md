# Changelog

All notable changes to this project will be documented in this file.

## [1.0.3] - 2026-01-05
### Added
- `deleteEntity` implementation added to all example `SyncStore` classes (`FileSyncStore`, `HiveSyncStore`, `SQLiteSyncStore`).
- Example `MockSyncStore` included for easier testing and unit tests without real storage.
- Added `SyncEngine.registerCollection` usage examples in documentation.
- Optional `SyncStore` and `SyncTransport` implementations can now be fully customized by the developer (enhanced DX).

### Improved
- Improved developer experience (DX) by clarifying how to use custom stores and transports in README and example app.
- Minor refactoring in example app for clearer store switching logic.
- Better null safety and type checking across the package.
- Minor bug fixes in entity retrieval and operation logging.

### Fixed
- Compilation errors due to missing `SyncStore.deleteEntity` implementations in example stores.
- Type errors in example app (`SyncStore`, `SyncTransport`, `ConflictResolver`) when importing package incorrectly.


## [1.0.2] - 2025-12-26
### Added
- Comprehensive DartDoc documentation across all public API elements.
- Improved pub.dev score by meeting the public API documentation requirement.
- Added library-level documentation for the main package entry point.
- Minor internal refactoring with no breaking API changes.

### Improved
- Code readability and maintainability through consistent documentation.
- Developer experience when browsing API docs on pub.dev.

---

## [1.0.1] - 2025-12-26
### Added
- README.md documentation added.
- Minor changes and improvements across the package.

---

## [1.0.0] - 2025-12-26
### Added
- Initial release of `Flutter SyncEngine`.
- Core `SyncEngine` class to handle local ↔ remote synchronization.
- `SyncStore` interface for local storage.
- Example implementations:
  - `FileSyncStore`
  - `HiveSyncStore`
  - `SQLiteSyncStore`
- `SyncTransport` interface for backend communication.
- Example transport implementations:
  - `DummyTransport` (in-memory)
  - `RestTransport` (dummy REST API integration).
- Conflict resolution mechanism (`ConflictResolver` interface).
- Built-in `LastWriteWins` conflict resolver.
- `SyncOperation` model for tracking CRUD operations.
- Example Flutter app demonstrating:
  - Adding notes.
  - Syncing with local and remote storage.
  - Switching storage and transport.

---

## [0.0.1-dev.2+nonfunctional] - 2025-12-22
### Added
- Refactored `HiveSyncStore` with proper `Hive.initFlutter()` initialization.
- Added `SQLiteSyncStore` for persistent offline storage.
- `_synced` flag added to entities for visual sync status.
- Example app visually distinguishes **synced** and **pending** notes:
  - Green cloud: synced
  - Orange cloud: pending.
- Logs panel in example app showing operation events.
- Offline note creation with sync simulation support.
- Pre-release versioning compatible with `pub`
  (`0.0.1-dev.2+nonfunctional`).

