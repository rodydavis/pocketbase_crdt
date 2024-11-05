import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_crdt/server.dart';
import 'package:pocketbase_crdt/src/connection/connect.dart';

void main(List<String> args) async {
  String pbHost = Platform.environment['PB_HOST'] ?? 'http://127.0.0.1:8090';
  String dbName = Platform.environment['CRDT_DB_NAME'] ?? 'crdt.db';
  Map<String, String> tableMapping = {};
  final tablesIdx = args.indexWhere((e) => e.startsWith('--tables='));
  if (tablesIdx != -1) {
    final tables = args[tablesIdx];
    final json = tables.substring('--tables='.length);
    final tableMap = jsonDecode(json);
    if (tableMap is Map<String, dynamic>) {
      tableMapping = tableMap.cast<String, String>();
    }
  } else if (File('tables.json').existsSync()) {
    final json = File('tables.json').readAsStringSync();
    final tableMap = jsonDecode(json);
    if (tableMap is Map<String, dynamic>) {
      tableMapping = tableMap.cast<String, String>();
    }
  }
  print('Table Mapping: $tableMapping');
  final instance = PocketbaseCrdtServer(
    createDatabaseExecutor(dbName),
    client: PocketBase(pbHost),
    userTables: tableMapping.keys.toList(),
    createFilters: (userId) {
      // final userExp = CustomExpression<bool>(
      //   "json_extract(data, '\$.user') = '$userId'",
      // );
      final filters = {
        for (final item in tableMapping.entries)
          item.key: CustomExpression<bool>(
            item.value.replaceAll('{{user_id}}', userId),
          ),
      };
      print('Filters: $filters');
      return filters;
    },
  );
  await instance.init();
}
