import 'package:flutter/material.dart';
import 'package:flutter_sync_engine/flutter_sync_engine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncEngine Example',
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

class _NotesPageState extends State<NotesPage> {
  late final SyncEngine engine;
  late final InMemorySyncStore store;
  late final DummyTransport transport;

  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();

    // 1️⃣ Initialize engine
    store = InMemorySyncStore();
    transport = DummyTransport();
    engine = SyncEngine(store: store, transport: transport);

    engine.registerCollection(name: 'notes', conflictResolver: LastWriteWins());

    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final entities = store.getEntities('notes');
    setState(() {
      notes = entities.values.toList();
    });
  }

  Future<void> _addNote() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final note = {
      'id': id,
      'title': 'Note $id',
      'content': 'This is a new note',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await store.saveEntity('notes', note);

    await store.logOperation(
      SyncOperation(
        collection: 'notes',
        entityId: id,
        type: OperationType.create,
        timestamp: DateTime.now(),
        data: note,
      ),
    );

    await _loadNotes();
  }

  Future<void> _sync() async {
    await engine.sync();
    await _loadNotes();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sync completed!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SyncEngine Notes')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note['title']),
            subtitle: Text(note['content']),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _addNote,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'sync',
            onPressed: _sync,
            child: const Icon(Icons.sync),
          ),
        ],
      ),
    );
  }
}
