import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../database.dart';
import '../utils/functions.dart';

CrdtDatabase createTempDatabase({
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
}) {
  return CrdtDatabase(createTempExecutor(
    logStatements: logStatements,
    initializeDatabase: initializeDatabase,
  ));
}

QueryExecutor createTempExecutor({
  bool logStatements = false,
  Future<Uint8List?> Function()? initializeDatabase,
}) {
  final dir = Directory.systemTemp.createTempSync('pocketbase');
  final file = File('${dir.path}/temp.db');
  final e = NativeDatabase(
    file,
    setup: applyDbFunctions,
    logStatements: logStatements,
    // initializeDatabase: initializeDatabase,
  );
  return e;
}
