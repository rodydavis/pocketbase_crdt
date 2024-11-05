import 'dart:convert';
import 'dart:io';

import 'package:pocketbase/pocketbase.dart';

import '../lib/src/connection/connect.dart';
import '../lib/src/database.dart';
import '../lib/src/utils/id.dart';

void main(List<String> args) async {
  final localDb = createCrdtDatabase('local.db');
  final remoteDb = createCrdtDatabase('remote.db');
  await localDb.init();
  await remoteDb.init();
  // final todos = client.collection('todos');
  var changes = await localDb.getChangeset();
  print('a changeset: ${changes.short}');
  final cs = File('./changeset.json')..createSync();

  final (collectionId, collectionName) = ('2gufa3r1rbqvc36', 'todos');
  var now = DateTime.now();
  var base = {
    'collectionId': collectionId,
    'collectionName': collectionName,
    'created': now.toIso8601String(),
    'updated': now.toIso8601String(),
  };
  final records = {
    RecordModel.fromJson({
      ...base,
      'id': createId(),
      'name': 'Buy milk',
    }),
    RecordModel.fromJson({
      ...base,
      'id': createId(),
      'name': 'Buy eggs',
    }),
  };
  await localDb.setAll(records);
  changes = await localDb.getChangeset();
  print('a changeset: ${changes.short}');
  const encoder = JsonEncoder.withIndent('  ');
  await cs.writeAsString(encoder.convert(changes));

  final str = await cs.readAsString();
  final items = jsonDecode(str) as Map<String, dynamic>;
  Map<String, List<Map<String, Object?>>> newChanges = {};
  for (final key in items.keys) {
    final value = items[key] as List;
    newChanges[key] =
        value.map((e) => PocketbaseRecord.fromJson(e).toJson()).toList();
  }
  await remoteDb.merge(newChanges);
  changes = await remoteDb.getChangeset();
  print('b changeset: ${changes.short}');

  await Future.delayed(const Duration(seconds: 1));
  await localDb.close();
  await remoteDb.close();
  //final client = PocketBase('http://127.0.0.1:8090');
}

extension on Map<String, List<Map<String, Object?>>> {
  String get short {
    final data = {
      for (final entry in this.entries) entry.key: entry.value.length,
    };
    return jsonEncode(data);
  }
}
