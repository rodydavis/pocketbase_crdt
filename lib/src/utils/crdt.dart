import 'package:crdt/crdt.dart';

mixin CrdtMixin on Crdt {
  Map<String, Object?> repairHlc(
    Map<String, Object?> data, {
    bool now = true,
  }) {
    // Check for hlc, node_id, and modified
    if (!data.containsKey('hlc') ||
        !data.containsKey('node_id') ||
        !data.containsKey('modified')) {
      Hlc hlc = canonicalTime;
      if (now) {
        hlc = hlc.increment();
      } else {
        hlc = Hlc.zero(nodeId);
      }
      data['hlc'] = hlc.toString();
      data['node_id'] = hlc.nodeId;
      data['modified'] = hlc.toString();
    }
    return data;
  }

  // @override
  // Hlc validateChangeset(CrdtChangeset changeset) {
  //   // fix: validateChangeset needs Hlc objects, not strings
  //   for (final entry in changeset.entries) {
  //     final records = entry.value;
  //     for (final record in records) {
  //       fixHlc(record);
  //       record['hlc'] = hlcFromJson(record['hlc']!);
  //       record['modified'] = hlcFromJson(record['modified']!);
  //     }
  //   }
  //   return super.validateChangeset(changeset);
  // }
}
