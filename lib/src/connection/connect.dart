import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart';

import '../utils/functions.dart';
import 'connect.web.dart' if (dart.library.ffi) 'connect.io.dart';

import '../database.dart';

QueryExecutor createDatabaseExecutor(
  String name, {
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
  bool isWeb = false,
}) {
  return createExecutor(
    name,
    (db) {
      applyDbFunctions(db);
      if (!isWeb) {
        db.execute(pragma);
      } else {
        db.execute('PRAGMA journal_mode=JOURNAL;');
      }
    },
    logStatements: logStatements,
    initializeDatabase: initializeDatabase,
  );
}

CrdtDatabase createCrdtDatabase(
  String name, {
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
  bool isWeb = false,
}) {
  return CrdtDatabase(createDatabaseExecutor(
    name,
    logStatements: logStatements,
    initializeDatabase: initializeDatabase,
    isWeb: isWeb,
  ));
}

Future<CommonDatabase> loadSqlite$({String? name}) async {
  return loadSqlite(name: name);
}

const pragma = r'''
PRAGMA busy_timeout       = 10000;
PRAGMA journal_mode       = WAL;
PRAGMA journal_size_limit = 200000000;
PRAGMA synchronous        = NORMAL;
PRAGMA foreign_keys       = ON;
PRAGMA temp_store         = MEMORY;
PRAGMA cache_size         = -16000;
''';
