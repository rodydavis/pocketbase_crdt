import 'dart:async';

import 'package:crdt/crdt.dart';
import 'package:pocketbase/pocketbase.dart';

import 'utils/crdt.dart';
import 'utils/id.dart';

class PocketBaseCrdt with Crdt, CrdtMixin {
  PocketBaseCrdt(this.client, this.collections);

  final PocketBase client;
  final List<String> collections;

  /// Create a new ID
  String newId() => createId();

  bool initialized = false;

  /// Initialize this CRDT
  ///
  /// Use [nodeId] to set an explicit id, or leave it empty to autogenerate a
  /// random one.
  /// If you set a custom id, make sure it's unique across your system, as
  /// collisions will break the CRDT in subtle ways.
  ///
  /// Setting the node id on init only works for empty CRDTs.
  /// See [resetNodeId] and [generateNodeId].
  Future<void> init([String? nodeId]) async {
    if (initialized) return;
    // Read the canonical time from database, or start from scratch
    nodeId ??= generateNodeId();
    canonicalTime = await getLastModified(nodeId: nodeId);
    initialized = true;
  }

  @override
  FutureOr<Hlc> getLastModified({
    String? onlyNodeId,
    String? exceptNodeId,
    String? nodeId,
  }) async {
    final collections = this.collections;
    final results = <String, Hlc>{};
    for (final collection in collections) {
      final filters = <String>[];
      if (onlyNodeId != null) {
        filters.add("node_id = '$onlyNodeId'");
      } else if (exceptNodeId != null) {
        filters.add("node_id != '$exceptNodeId'");
      }
      final col = client.collection(collection);
      final records = await col.getFullList(
        filter: filters.isEmpty ? null : filters.join(' && '),
        fields: "node_id,hlc",
      );
      if (records.isNotEmpty) {
        // Sort by hlc
        records.sort((a, b) {
          final hlcA = _parseHlc(a.data);
          final hlcB = _parseHlc(b.data);
          if (hlcA == null) {
            return 1;
          }
          if (hlcB == null) {
            return -1;
          }
          return hlcA.compareTo(hlcB);
        });
        final last = records.last;
        final hlc = _parseHlc(last.data);
        if (hlc != null) {
          results[collection] = hlc;
        }
      }
    }
    if (results.isNotEmpty) {
      final sorted = results.entries.toList();
      sorted.sort((a, b) => a.value.compareTo(b.value));
      return sorted.last.value;
    }
    return Hlc.zero(nodeId ?? this.nodeId);
  }

  @override
  FutureOr<CrdtChangeset> getChangeset({
    Iterable<String>? onlyTables,
    String? onlyNodeId,
    String? exceptNodeId,
    Hlc? modifiedOn,
    Hlc? modifiedAfter,
    Iterable<String>? extraFilters,
  }) async {
    assert(onlyNodeId == null || exceptNodeId == null);
    assert(modifiedOn == null || modifiedAfter == null);

    // Modified times use the local node id
    modifiedOn = modifiedOn?.apply(nodeId: nodeId);
    modifiedAfter = modifiedAfter?.apply(nodeId: nodeId);

    final collections = onlyTables ?? this.collections;
    final changeset = <String, List<RecordModel>>{};
    for (final collection in collections) {
      final filters = <String>{};
      if (onlyNodeId != null) {
        filters.add("node_id = '$onlyNodeId'");
      } else if (exceptNodeId != null) {
        filters.add("node_id != '$exceptNodeId'");
      }
      if (modifiedOn != null) {
        filters.add("modified = '${modifiedOn.dateTime.toIso8601String()}'");
      } else if (modifiedAfter != null) {
        filters.add("modified > '${modifiedAfter.dateTime.toIso8601String()}'");
      }
      if (extraFilters != null) {
        filters.addAll(extraFilters);
      }
      final col = client.collection(collection);
      final records = await col.getFullList(
        filter: filters.isEmpty ? null : filters.join(' && '),
      );
      if (records.isNotEmpty) {
        changeset[collection] = records;
      }
    }

    // Apply remaining filters
    for (final records in changeset.values) {
      records.removeWhere((value) {
        return (onlyNodeId != null && value.hlc.nodeId != onlyNodeId) ||
            (exceptNodeId != null && value.hlc.nodeId == exceptNodeId) ||
            (modifiedOn != null && value.modified != modifiedOn) ||
            (modifiedAfter != null && value.modified <= modifiedAfter);
      });
    }

    // Remove empty table changesets
    changeset.removeWhere((_, records) => records.isEmpty);

    return {
      for (final entry in changeset.entries)
        entry.key: entry.value.map((e) {
          return repairHlc(e.toJson(), now: false);
        }).toList(),
    };
  }

  @override
  FutureOr<void> merge(
    CrdtChangeset changeset, {
    Future<void> Function(
      RecordModel record,
      Object? error,
      StackTrace? stackTrace,
    )? onError,
    Future<void> Function(
      RecordModel record,
    )? onSuccess,
  }) async {
    if (changeset.recordCount == 0) return;
    changeset.removeWhere((_, records) => records.isEmpty);

    // fix: validateChangeset needs Hlc objects, not strings
    for (final entry in changeset.entries) {
      final records = entry.value;
      for (final record in records) {
        record['hlc'] = Hlc.parse(record['hlc'] as String);
        record['modified'] = Hlc.parse(record['modified'] as String);
      }
    }

    // Validate changeset and highest hlc therein
    final hlc = validateChangeset(changeset);
    for (final entry in changeset.entries) {
      // final table = entry.key;
      for (final item in entry.value) {
        item['hlc'] = item['hlc'].toString();
        item['modified'] = item['modified'].toString();
        final record = RecordModel.fromJson(item);
        // Extract node id from the record's hlc
        record.data['node_id'] = (record.data['hlc'] is String
                ? (record.data['hlc'] as String).toHlc
                : (record.data['hlc'] as Hlc))
            .nodeId;
        // Ensure hlc and modified are strings
        record.data['hlc'] = record.data['hlc'].toString();
        record.data['modified'] = hlc.toString();

        await save(
          record,
          onError: onError,
          onSuccess: onSuccess,
        );
      }
    }
  }

  Future<void> save(
    RecordModel record, {
    Future<void> Function(
      RecordModel record,
      Object? error,
      StackTrace? stackTrace,
    )? onError,
    Future<void> Function(
      RecordModel record,
    )? onSuccess,
  }) async {
    final col = client.collection(record.collectionId);
    try {
      final existing = await col.getList(filter: "id = '${record.id}'");
      final data = repairHlc(record.toJson());
      data.remove('created');
      data.remove('updated');
      data.remove('collectionId');
      data.remove('collectionName');
      data.remove('expand');
      if (existing.items.isEmpty) {
        await col.create(body: data);
      } else {
        data.remove('id');
        final current = existing.items.first;
        // Check hlc for conflict
        final newHlc = _parseHlc(data);
        final existingHlc = _parseHlc(current.data);
        if (newHlc != null && existingHlc != null) {
          if (newHlc.compareTo(existingHlc) < 0) {
            print('skipping record: $record');
            return;
          }
        }
        await col.update(record.id, body: data);
      }
      await onSuccess?.call(record);
    } catch (e, t) {
      print('error merging: $e');
      await onError?.call(record, e, t);
    }
  }
}

Hlc? _parseHlc(Map<String, dynamic> data) {
  if (!data.containsKey('hlc')) {
    return null;
  }
  final hlc = data['hlc'];
  if (hlc is String) {
    if (hlc.isEmpty) {
      return null;
    }
    return Hlc.parse(hlc);
  }
  return null;
}

extension on RecordModel {
  Hlc get hlc => _parseHlc(data)!;
  Hlc get modified => _parseHlc(data)!;
}
