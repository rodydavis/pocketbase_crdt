import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_crdt/server.dart';
import 'package:pocketbase_crdt/src/connection/connect.dart';

void main(List<String> args) async {
  final instance = PocketbaseCrdtServer(
    createDatabaseExecutor(args.first),
    client: PocketBase('http://127.0.0.1:8090'),
    userTables: [
      'todos',
    ],
    createFilters: (userId) {
      final userExp = CustomExpression<bool>(
        "json_extract(data, '\$.user') = '$userId'",
      );
      return {
        'todos': userExp,
      };
    },
  );
  await instance.init();
}
