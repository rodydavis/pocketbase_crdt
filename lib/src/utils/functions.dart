import 'package:crdt/crdt.dart';
import 'package:sqlite3/common.dart';

void applyDbFunctions(CommonDatabase db) {
  db.createFunction(
    functionName: 'compareHlc',
    function: (args) {
      final [hlc1, hlc2] = args;
      final hlcA = Hlc.parse(hlc1 as String);
      final hlcB = Hlc.parse(hlc2 as String);
      return hlcA.compareTo(hlcB);
    },
    directOnly: false,
    deterministic: true,
  );
  // db.createFunction(
  //   functionName: 'now',
  //   function: (_) {
  //     final now = DateTime.now();
  //     final d = now.toUtc();
  //     return d.toString().replaceFirst('T', ' ');
  //   },
  //   directOnly: false,
  // );
  // db.execute('PRAGMA busy_timeout=100;');
  // db.execute('PRAGMA foreign_keys=on');
}
