import 'package:flutter_sync_engine/flutter_sync_engine.dart';

class DummyTransport implements SyncTransport {
  final List<SyncOperation> _remote = [];

  @override
  Future<void> push(List<SyncOperation> operations) async {
    _remote.addAll(operations);
  }

  @override
  Future<List<SyncOperation>> pull(DateTime? since) async {
    if (since == null) return List.from(_remote);
    return _remote.where((op) => op.timestamp.isAfter(since)).toList();
  }
}
