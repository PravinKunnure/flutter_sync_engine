# Flutter SyncEngine

[![Pub Version](https://img.shields.io/pub/v/flutter_sync_engine)](https://pub.dev/packages/flutter_sync_engine) | [![License: MIT](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)


**Version:** 1.0.0

`SyncEngine` is a lightweight Flutter/Dart package that helps developers **sync data between local storage and remote backends**.  
It is **flexible** and **backend-agnostic**, allowing you to use any storage (File, Hive, SQLite, etc.) and any transport (REST API, dummy transport, or custom).

---

## Features

- Push and pull data to/from a backend.
- Local storage support (File, Hive, SQLite, or custom).
- Conflict resolution support (`LastWriteWins` by default, custom resolvers allowed).
- Backend-agnostic: transport can be REST, GraphQL, WebSocket, or custom.
- Minimal dependencies – you can choose your storage/transport freely.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_sync_engine: ^1.0.0

```

---

## Usage

### 1️⃣ Import the package

```dart
import 'package:flutter_sync_engine/flutter_sync_engine.dart';
```

---

### 2️⃣ Initialize a store and transport

```dart
final store = await FileSyncStore.create('notes.json'); // File store
final transport = DummyTransport(); // Dummy transport

final engine = SyncEngine(store: store, transport: transport);
engine.registerCollection(name: 'notes', conflictResolver: const LastWriteWins());
```

> You can replace `FileSyncStore` with `HiveSyncStore` or `SQLiteSyncStore`.  
> You can replace `DummyTransport` with `RestTransport` or a custom backend.

---

### 3️⃣ Add and sync data

```dart
// Add note locally
final note = {
  'id': '1',
  'title': 'Note 1',
  'content': 'This is a note',
  'updatedAt': DateTime.now().toIso8601String(),
};
await store.saveEntity('notes', note);
await store.logOperation(SyncOperation(
  collection: 'notes',
  entityId: note['id']!,
  type: OperationType.create,
  timestamp: DateTime.now(),
  data: note,
));

// Sync with backend
await engine.sync();
```

---

### 4️⃣ RestTransport example (sync with dummy REST API)

```dart
final transport = RestTransport('https://jsonplaceholder.typicode.com');

await engine.sync(); // Push local notes and pull remote notes
```

---

### 5️⃣ Conflict Resolution

By default, `LastWriteWins` is used:

```dart
class LastWriteWins implements ConflictResolver {
  @override
  Map<String, dynamic> resolve({
    required Map<String, dynamic> local,
    required Map<String, dynamic> remote,
  }) {
    final localUpdated = DateTime.parse(local['updatedAt'] ?? '1970-01-01');
    final remoteUpdated = DateTime.parse(remote['updatedAt'] ?? '1970-01-01');
    return localUpdated.isAfter(remoteUpdated) ? local : remote;
  }
}
```

You can also implement a **custom resolver** per collection:

```dart
engine.registerCollection(
  name: 'notes',
  conflictResolver: MyCustomResolver(),
);
```

---

## Example App

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final store = await FileSyncStore.create('notes.json');
  final transport = DummyTransport();

  final engine = SyncEngine(store: store, transport: transport);
  engine.registerCollection(name: 'notes', conflictResolver: const LastWriteWins());

  runApp(MyApp(engine));
}
```

- Supports **File**, **Hive**, **SQLite** storage.
- Supports **DummyTransport** or any custom backend.
- Easy to extend and integrate into any Flutter app.

---

## Store Options

| Store Type | Description |
|------------|-------------|
| FileSyncStore | Simple JSON file storage (default for example apps) |
| HiveSyncStore | Persistent NoSQL storage using Hive |
| SQLiteSyncStore | Relational storage using SQLite |
| Custom | You can implement `SyncStore` interface for your own storage |

---

## Transport Options

| Transport Type | Description |
|----------------|-------------|
| DummyTransport | In-memory backend for testing |
| RestTransport | Connects to a REST API |
| Custom | Implement `SyncTransport` for your own backend |

---

## Installation Notes

- No dependencies on Hive or SQLite in the package itself.
- Example app includes optional implementations for testing and demonstration.
- You can use your preferred database without modifying the package.

---

## License

MIT License
