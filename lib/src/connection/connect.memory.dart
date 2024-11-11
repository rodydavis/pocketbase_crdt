import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart' hide Database;

import '../database.dart';
import '../utils/functions.dart';

CrdtDatabase createMemoryDatabase({
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
}) {
  return CrdtDatabase(createMemoryExecutor(
    logStatements: logStatements,
    initializeDatabase: initializeDatabase,
  ));
}

QueryExecutor createMemoryExecutor({
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
}) {
  final e = NativeDatabase.memory(
    setup: applyDbFunctions,
    logStatements: logStatements,
    // initializeDatabase: initializeDatabase,
  );
  return e;
}

Future<CommonDatabase> loadSqlite({String? name}) async {
  return name == null ? sqlite3.openInMemory() : sqlite3.open(name);
}
