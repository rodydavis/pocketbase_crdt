import 'dart:convert';

import 'package:crdt_sync/crdt_sync.dart';
import 'package:pocketbase/pocketbase.dart';

import 'database.dart';

class PocketbaseCrdtClient extends CrdtDatabase {
  PocketbaseCrdtClient(
    super.e, {
    required this.client,
    required this.createUri,
    required this.userId,
  });

  String userId;
  final Uri Function(String userId) createUri;
  final PocketBase client;

  late final CrdtSyncClient service = CrdtSyncClient(
    this,
    createUri(userId),
    handshakeDataBuilder: () => {'user_id': userId},
    mapIncomingChangeset: (table, record) {
      return jsonDecode(jsonEncode(record));
    },
    onChangesetReceived: (nodeId, recordCounts) {
      print('client: changeset received: $nodeId, $recordCounts');
    },
    onChangesetSent: (nodeId, recordCounts) {
      print('client: changeset sent: $nodeId, $recordCounts');
    },
  );

  Future<void> init([String? nodeId]) async {
    await super.init(nodeId);
    service.connect();
  }

  Future<void> disconnect([int? code, String? reason]) async {
    await service.disconnect(code, reason);
  }

  Future<void> close() async {
    await super.close();
    await disconnect();
  }

  // Future<void> sync({
  //   String url = 'http://localhost:6000',
  //   required http.Client Function() createClient,
  // }) async {
  //   final uri = Uri.parse(url);
  //   final client = createClient();
  //   var changes = await getChangeset();
  //   final response = await client.post(
  //     uri,
  //     body: jsonEncode(changes),
  //   );
  //   if (response.statusCode == 200) {
  //     final body = response.body;
  //     changes = parseChangeset(body);
  //     await merge(changes);
  //   }
  // }
}
