import 'package:example/stores/file_sync_store.dart';
import 'package:example/stores/hive_sync_store.dart';
import 'package:example/stores/sqflite_sync_store.dart';
import 'package:example/transporters/dummy_transport.dart';
import 'package:example/transporters/rest_transport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sync_engine/flutter_sync_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncEngine Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

enum StoreType { file, hive, sqlite }

class _NotesPageState extends State<NotesPage> {
  late final SyncEngine engine;
  late SyncStore store;
  // late final DummyTransport transport;
  late final RestTransport transport;

  List<Map<String, dynamic>> notes = [];
  bool syncing = false;
  StoreType selectedStore = StoreType.file;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    // 1️⃣ Initialize store based on selection
    switch (selectedStore) {
      case StoreType.file:
        store = await FileSyncStore.create('notes.json');
        break;
      case StoreType.hive:
        store = HiveSyncStore();
        await (store as HiveSyncStore).init();
        break;
      case StoreType.sqlite:
        store = SQLiteSyncStore();
        await (store as SQLiteSyncStore).init();
        break;
    }

    // 2️⃣ Initialize transport
    // transport = DummyTransport();///For Demo Purpose Only
    transport = RestTransport('https://jsonplaceholder.typicode.com');

    // 3️⃣ Initialize engine
    engine = SyncEngine(store: store, transport: transport);

    engine.registerCollection(
      name: 'notes',
      conflictResolver: const LastWriteWins(),
    );

    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    final entities = await store.getEntities('notes');
    setState(() {
      notes = entities.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    });
  }

  Future<void> _addNote() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final note = {
      'id': id,
      'title': 'Note $id',
      'content': 'This is a new note',
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    await store.saveEntity('notes', note);
    await store.logOperation(
      SyncOperation(
        collection: 'notes',
        entityId: id,
        type: OperationType.create,
        timestamp: DateTime.now().toUtc(),
        data: note,
      ),
    );
    await _loadNotes();
  }

  Future<void> _sync() async {
    setState(() => syncing = true);
    try {
      await engine.sync();
      await _loadNotes();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sync completed!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
    } finally {
      setState(() => syncing = false);
    }
  }

  void _changeStore(StoreType type) async {
    setState(() {
      selectedStore = type;
    });
    await _initEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SyncEngine Demo')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: StoreType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () => _changeStore(type),
                  child: Text(type.name.toUpperCase()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedStore == type
                        ? Colors.blue
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No notes yet'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (_, i) {
                      final note = notes[i];
                      return ListTile(
                        title: Text(note['title']),
                        subtitle: Text(note['content']),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: syncing ? null : _addNote,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'sync',
            onPressed: syncing ? null : _sync,
            child: syncing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.sync),
          ),
        ],
      ),
    );
  }
}

///Version 1 Demo
// import 'package:example/transporters/dummy_transport.dart';
// import 'package:example/stores/file_sync_store.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sync_engine/flutter_sync_engine.dart';
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: const NotesPage());
//   }
// }
//
// class NotesPage extends StatefulWidget {
//   const NotesPage({super.key});
//   @override
//   State<NotesPage> createState() => _NotesPageState();
// }
//
// class _NotesPageState extends State<NotesPage> {
//   late final SyncEngine engine;
//   late final FileSyncStore store;
//   late final DummyTransport transport;
//
//   List<Map<String, dynamic>> notes = [];
//   bool syncing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initEngine();
//   }
//
//   Future<void> _initEngine() async {
//     store = await FileSyncStore.create('notes.json');
//     transport = DummyTransport();
//     engine = SyncEngine(store: store, transport: transport);
//     engine.registerCollection(name: 'notes', conflictResolver: const LastWriteWins());
//     await _loadNotes();
//   }
//
//   Future<void> _loadNotes() async {
//     final entities = await store.getEntities('notes');
//
//     setState(() {
//       notes = entities.values
//           .map((e) => Map<String, dynamic>.from(e as Map))
//           .toList();
//     });
//   }
//
//
//   Future<void> _addNote() async {
//     final id = DateTime.now().millisecondsSinceEpoch.toString();
//     final note = {
//       'id': id,
//       'title': 'Note $id',
//       'content': 'This is a new note',
//       'updatedAt': DateTime.now().toUtc().toIso8601String(),
//     };
//     await store.saveEntity('notes', note);
//     await store.logOperation(SyncOperation(
//       collection: 'notes',
//       entityId: id,
//       type: OperationType.create,
//       timestamp: DateTime.now().toUtc(),
//       data: note,
//     ));
//     await _loadNotes();
//   }
//
//   Future<void> _sync() async {
//     setState(() => syncing = true);
//     try {
//       await engine.sync();
//       await _loadNotes();
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync completed!')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
//     } finally {
//       setState(() => syncing = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('SyncEngine Example')),
//       body: notes.isEmpty
//           ? const Center(child: Text('No notes yet'))
//           : ListView.builder(
//         itemCount: notes.length,
//         itemBuilder: (_, i) {
//           final note = notes[i];
//           return ListTile(title: Text(note['title']), subtitle: Text(note['content']));
//         },
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: 'add',
//             onPressed: syncing ? null : _addNote,
//             child: const Icon(Icons.add),
//           ),
//           const SizedBox(height: 16),
//           FloatingActionButton(
//             heroTag: 'sync',
//             onPressed: syncing ? null : _sync,
//             child: syncing ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.sync),
//           ),
//         ],
//       ),
//     );
//   }
// }
