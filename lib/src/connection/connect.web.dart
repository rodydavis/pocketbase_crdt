import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'package:sqlite3/wasm.dart';

// Future<CommonDatabase> getDatabase(String name) async {
//   final sqlite3 = await WasmSqlite3.loadFromUrl(sqliteUrl());
//   final fileSystem = await IndexedDbFileSystem.open(dbName: name);
//   sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
//   if (name == dbName) {
//     final data = await rootBundle.load('db/assets/$dbName');
//     final bytes = data.buffer.asUint8List();

//   }
//   return sqlite3.open(name);
// }

QueryExecutor createExecutor(
  String name,
  void Function(CommonDatabase) setup, {
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
}) {
  return DatabaseConnection.delayed(Future(() async {
    final db = await WasmDatabase.open(
      databaseName: name,
      // enableMigrations: false,
      // sqlite3Uri: sqliteUrl(),
      // driftWorkerUri: Uri.parse('worker.dart.js'),
      // driftWorkerUri: Uri.parse('drift_worker.js'),
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('worker.dart.js'),
      localSetup: setup,
      initializeDatabase: initializeDatabase,
    );

    if (db.missingFeatures.isNotEmpty) {
      print(
        'Using ${db.chosenImplementation} due to unsupported '
        'browser features: ${db.missingFeatures}',
      );
    }

    return db.resolvedExecutor;
  }));
}

Uri sqliteUrl() {
  // TODO: Server url
  // if (kDebugMode) {
  //   return Uri.parse('sqlite3.debug.wasm');
  // }
  return Uri.parse('sqlite3.wasm');
}

Future<CommonDatabase> loadSqlite({String? name}) async {
  final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  final fileSystem = await IndexedDbFileSystem.open(dbName: 'db');
  sqlite.registerVirtualFileSystem(fileSystem, makeDefault: true);
  return name == null ? sqlite.openInMemory() : sqlite.open(name);
}
