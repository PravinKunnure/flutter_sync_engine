# Flutter SyncEngine

[![Pub Version](https://img.shields.io/pub/v/flutter_sync_engine)](https://pub.dev/packages/flutter_sync_engine) | [![License: MIT](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)

`SyncEngine` is a lightweight Flutter/Dart package that helps developers **sync data between local storage and remote backends**.  
It is **flexible** and **backend-agnostic**, allowing you to use any storage (File, Hive, SQLite, etc.) and any transport (REST API, dummy transport, or custom).

---

## Features

- Push and pull data to/from a backend.
- Local storage support (File, Hive, SQLite, or custom).
- Full CRUD support including deletion (`deleteEntity` now supported in all example stores).
- Conflict resolution support (`LastWriteWins` by default, custom resolvers allowed).
- Backend-agnostic: transport can be REST, GraphQL, WebSocket, or custom.
- Minimal dependencies – you can choose your storage/transport freely.
- MockSyncStore for testing and unit tests.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_sync_engine: <latest_version>
```
## Usage 
### Import package
`import 'package:flutter_sync_engine/flutter_sync_engine.dart';`

### Initialise store and transport
      final store = await FileSyncStore.create('notes.json'); // File store
      final transport = DummyTransport(); // Dummy transport
    
      final engine = SyncEngine(store: store, transport: transport);
      engine.registerCollection(name: 'notes', conflictResolver: const LastWriteWins());

### Add, Delete & Sync Data

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
    
    // Delete note
    await store.deleteEntity('notes', note['id']!);
    await store.logOperation(SyncOperation(
    collection: 'notes',
    entityId: note['id']!,
    type: OperationType.delete,
    timestamp: DateTime.now(),
    data: {},
    ));
    
    // Sync with backend
    await engine.sync();

### RestTransport Example [sync with REST API]
    final transport = RestTransport('YOU_API_HERE');//Dummy API
    await engine.sync(); // Push local notes and pull remote notes


### Conflict Resolution

- By Default LastWriteWins is used:


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

- You can also implement a custom resolver per collection:

        engine.registerCollection(
        name: 'notes',
        conflictResolver: MyCustomResolver(),
        );


### Store Options

| Store Type      | Description                                                              |
| --------------- | ------------------------------------------------------------------------ |
| FileSyncStore   | Simple JSON file storage (supports create, update, delete)               |
| HiveSyncStore   | Persistent NoSQL storage using Hive (supports create, update, delete)    |
| SQLiteSyncStore | Relational storage using SQLite (supports create, update, delete)        |
| MockSyncStore   | In-memory store for testing and unit tests                               |
| Custom          | You can implement `SyncStore` interface for your own storage (full CRUD) |


### Transport Options

| Transport Type | Description                                    |
| -------------- | ---------------------------------------------- |
| DummyTransport | In-memory backend for testing                  |
| RestTransport  | Connects to a REST API                         |
| Custom         | Implement `SyncTransport` for your own backend |






