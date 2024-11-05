import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart' hide Database;

import '../database.dart';
import '../utils/functions.dart';

CrdtDatabase createMemoryDatabase({
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
}) {
  final e = NativeDatabase.memory(
    setup: applyDbFunctions,
    logStatements: logStatements,
    // initializeDatabase: initializeDatabase,
  );
  return CrdtDatabase(e);
}

Future<CommonDatabase> loadSqlite({String? name}) async {
  return name == null ? sqlite3.openInMemory() : sqlite3.open(name);
}
