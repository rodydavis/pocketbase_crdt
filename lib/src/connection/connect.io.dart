import 'dart:io';

// import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

Future<File> getDatabaseFile(String name) async {
  return File(name);
  // final appDir = await getApplicationSupportDirectory();
  // return File(p.join(appDir.path, name));
}

// Future<CommonDatabase> getDatabase(String name) async {
//   final dbFile = await getDatabaseFile(name);
//   if (name == dbName && !dbFile.existsSync()) {
//     final data = await rootBundle.load('db/assets/$dbName');
//     await dbFile.writeAsBytes(data.buffer.asUint8List());
//   }
//   return sqlite3.open(dbFile.path);
// }

LazyDatabase createExecutor(
  String name,
  void Function(CommonDatabase) setup, {
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
}) {
  return LazyDatabase(() async {
    final dbFile = await getDatabaseFile(name);
    final size = dbFile.existsSync() ? dbFile.lengthSync() : 0;
    // ignore: avoid_print
    print('$name: $size');
    // if (name == dbName && size == 0) {
    //   final data = await rootBundle.load('db/assets/$dbName');
    //   await dbFile.writeAsBytes(data.buffer.asUint8List());
    // }
    if (initializeDatabase != null && size == 0) {
      final data = await initializeDatabase();
      if (data != null) {
        await dbFile.writeAsBytes(data);
      }
    }
    return NativeDatabase.createInBackground(
      dbFile,
      setup: setup,
      logStatements: logStatements,
    );
  });
}

Future<CommonDatabase> loadSqlite({String? name}) async {
  if (name == null) return sqlite3.openInMemory();
  // final appDir = await getApplicationSupportDirectory();
  // final dbPath = p.join(appDir.path, name);
  print('$name: $name');
  return sqlite3.open(name);
}
