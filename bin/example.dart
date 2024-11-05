import 'dart:convert';
import 'dart:io';

import 'package:pocketbase/pocketbase.dart';

import '../lib/src/connection/connect.dart';
import '../lib/src/database.dart';
import '../lib/src/utils/id.dart';

void main(List<String> args) async {
  final db = createCrdtDatabase(args.first);
  await db.init();
  // final todos = client.collection('todos');
  var changes = await db.getChangeset();
  print('a changeset: $changes');
  final cs = File('./changeset.json')..createSync();
  if (args.length == 1) {
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
    await db.setAll(records);
    changes = await db.getChangeset();
    print('b changeset: $changes');
    const encoder = JsonEncoder.withIndent('  ');
    await cs.writeAsString(encoder.convert(changes));
  } else {
    final str = await cs.readAsString();
    final items = jsonDecode(str) as Map<String, dynamic>;
    Map<String, List<Map<String, Object?>>> newChanges = {};
    for (final key in items.keys) {
      final value = items[key] as List;
      newChanges[key] =
          value.map((e) => PocketbaseRecord.fromJson(e).toJson()).toList();
    }
    await db.merge(newChanges);
    changes = await db.getChangeset();
    print('b changeset: $changes');
  }

  await Future.delayed(const Duration(seconds: 1));
  await db.close();
  //final client = PocketBase('http://127.0.0.1:8090');
}
