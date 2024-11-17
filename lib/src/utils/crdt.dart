import 'package:crdt/crdt.dart';

mixin CrdtMixin on Crdt {
  Map<String, Object?> fixHlc(Map<String, Object?> data) {
    // Check for hlc, node_id, and modified
    if (!data.containsKey('hlc') ||
        !data.containsKey('node_id') ||
        !data.containsKey('modified')) {
      Hlc hlc = canonicalTime;
      hlc = hlc.increment();
      data['hlc'] = hlc.toString();
      data['node_id'] = hlc.nodeId;
      data['modified'] = hlc.toString();
    }
    return data;
  }
}
