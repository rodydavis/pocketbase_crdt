import 'dart:math';

import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_crdt/client.dart';
import 'package:pocketbase_crdt/src/connection/connect.dart';

void main(List<String> args) async {
  final userId = 'qqp8kzg8hq5qwnq';
  final pb = PocketBase('http://127.0.0.1:8090');
  final pbUrl = pb.baseUrl.replaceAll('https://', '').replaceAll('http://', '');
  final instance = PocketbaseCrdtClient(
    createDatabaseExecutor(args.firstOrNull ?? 'local.db'),
    client: pb,
    createUri: (userId) {
      final url = 'ws://${pbUrl}/ws/$userId';
      // final url = 'ws://localhost:6000/ws/$userId';
      print('Connecting to: $url');
      return Uri.parse(url);
    },
    userId: userId,
  );
  await instance.init();

  // Add records
  final (collectionId, collectionName) = ('2gufa3r1rbqvc36', 'todos');
  var now = DateTime.now();
  var base = {
    'collectionId': collectionId,
    'collectionName': collectionName,
    'created': now.toIso8601String(),
    'user': userId,
    'updated': now.toIso8601String(),
  };
  final rdm = Random();
  final count = rdm.nextInt(10).clamp(1, 10);
  final records = {
    for (final i in List.generate(count, (index) => index))
      RecordModel.fromJson({
        ...base,
        'id': instance.createPocketbaseId(),
        'name': 'Task: $i',
      }),
  };
  await instance.setAll(records);

  await Future.delayed(const Duration(seconds: 30));

  await instance.disconnect();
}
