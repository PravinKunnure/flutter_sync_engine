# Changelog

All notable changes to this project will be documented in this file.

## [0.0.1-dev.2+nonfunctional] - 2025-12-22
### Added
- Refactored `HiveSyncStore` with proper `Hive.initFlutter()` initialization.
- Added `SQLiteSyncStore` for persistent offline storage.
- `_synced` flag added to entities for visual sync status.
- Example app now visually distinguishes **synced** and **pending** notes:
  - Green cloud: synced
  - Orange cloud: pending
- Logs panel in example app shows operation events.
- Example app supports offline note creation with sync simulation.
- Pre-release versioning now compatible with `pub` (`0.0.1-dev.2+nonfunctional`).

### Fixed
- `LastWriteWins` conflict resolver handles null `updatedAt` values.
- `_entities` access is now via public getter (`getEntities`) to prevent private field errors.
- Hive initialization updated to match latest `hive_flutter` API.

### Known Issues
- DummyTransport only; no real backend integration.
- Offline sync logic is non-functional with real backend.
- Conflict resolver uses default local/remote comparison for demo purposes.

### Notes
- Development-only version, API may change in future.
