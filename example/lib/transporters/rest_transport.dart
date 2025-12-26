import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_sync_engine/flutter_sync_engine.dart';

class RestTransport implements SyncTransport {
  final String baseUrl;

  RestTransport(this.baseUrl);

  @override
  Future<void> push(List<SyncOperation> operations) async {
    for (var op in operations) {
      final url = Uri.parse('$baseUrl/${op.collection}');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(op.data),
      );
    }
  }

  @override
  Future<List<SyncOperation>> pull(DateTime? since) async {
    final url = Uri.parse('$baseUrl/notes');
    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) {
      final id = item['id'].toString();
      return SyncOperation(
        collection: 'notes',
        entityId: id,
        type: OperationType.update,
        timestamp: DateTime.now().toUtc(),
        data: Map<String, dynamic>.from(item),
      );
    }).toList();
  }
}
