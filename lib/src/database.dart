import 'dart:async';
import 'dart:convert';

import 'package:crdt/crdt.dart';
import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart' show RecordModel;

import 'utils/hlc.dart';
import 'utils/id.dart';

part 'database.g.dart';

@DriftDatabase(include: {"sql/crdt.drift"})
class CrdtDatabase extends _$CrdtDatabase with Crdt {
  CrdtDatabase(super.e);

  @override
  int get schemaVersion => 1;

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
    nodeId ??= generateNodeId();
    // Read the canonical time from database, or start from scratch
    // final lastModified = await _getLastModified() //
    //     .map((e) => e.modified)
    //     .getSingleOrNull();
    var records = await getAllRecords().get();
    // Sort by modified
    records.sort((a, b) => a.modified.compareTo(b.modified));
    final last = records.lastOrNull;
    final lastModified = last?.modified;

    canonicalTime = lastModified ?? Hlc.zero(nodeId);
  }

  String createPocketbaseId() => createId();

  @override
  Future<Hlc> getLastModified({
    String? onlyNodeId,
    String? exceptNodeId,
  }) async {
    var records = await getAllRecords().get();
    if (records.isNotEmpty) {
      if (onlyNodeId != null) {
        records = records.where((e) => e.hlc.nodeId == onlyNodeId).toList();
      }
      if (exceptNodeId != null) {
        records = records.where((e) => e.hlc.nodeId != exceptNodeId).toList();
      }
      // Sort by modified
      records.sort((a, b) => a.modified.compareTo(b.modified));
    }
    final last = records.lastOrNull;
    return last?.hlc ?? Hlc.zero(nodeId);
  }

  // Future<RecordModel?> getLastModifiedRecordModel({
  //   String? onlyNodeId,
  //   String? exceptNodeId,
  // }) async {
  //   final record = await getLastModifiedRecord(
  //     onlyNodeId: onlyNodeId,
  //     exceptNodeId: exceptNodeId,
  //   );
  //   if (record == null) return null;
  //   return _recordFromJson(record);
  // }

  // Future<PocketbaseRecord?> getLastModifiedRecord({
  //   String? onlyNodeId,
  //   String? exceptNodeId,
  // }) async {
  //   assert(onlyNodeId == null || exceptNodeId == null);
  //   PocketbaseRecord? target;
  //   if (onlyNodeId == null && exceptNodeId != null) {
  //     target = await _getLastModifiedOnlyNodeId(exceptNodeId) //
  //         .getSingleOrNull()
  //         .then((val) => val?.pocketbaseRecords);
  //   } else if (exceptNodeId == null && onlyNodeId != null) {
  //     target = await _getLastModifiedExceptNodeId(onlyNodeId) //
  //         .getSingleOrNull()
  //         .then((val) => val?.pocketbaseRecords);
  //   } else {
  //     target = await _getLastModified() //
  //         .getSingleOrNull()
  //         .then((val) => val?.pocketbaseRecords);
  //   }
  //   return target;
  // }

  @override
  Future<void> merge(
    CrdtChangeset changeset, {
    DateTime? syncedAt,
  }) async {
    if (changeset.recordCount == 0) return;

    await transaction(() async {
      // Ignore empty records
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
        final records = entry.value;
        for (final record in records) {
          // Extract node id from the record's hlc
          record['node_id'] = (record['hlc'] is String
                  ? (record['hlc'] as String).toHlc
                  : (record['hlc'] as Hlc))
              .nodeId;
          // Ensure hlc and modified are strings
          record['hlc'] = record['hlc'].toString();
          record['modified'] = hlc.toString();
          await _insertRecord(jsonEncode(record), syncedAt);
        }
      }
    });
  }

  @override
  FutureOr<CrdtChangeset> getChangeset({
    Iterable<String>? onlyTables,
    Map<String, CustomExpression<bool>>? filters,
    String? onlyNodeId,
    String? exceptNodeId,
    Hlc? modifiedOn,
    Hlc? modifiedAfter,
    bool includeFailed = true,
    bool includeNotSynced = true,
    DateTime? syncedAfter,
  }) async {
    assert(onlyNodeId == null || exceptNodeId == null);
    assert(modifiedOn == null || modifiedAfter == null);

    // Modified times use the local node id
    modifiedOn = modifiedOn?.apply(nodeId: nodeId);
    modifiedAfter = modifiedAfter?.apply(nodeId: nodeId);

    onlyTables ??= await _getCollectionNames().get();
    if (filters != null) {
      onlyTables = onlyTables.where((table) => filters.containsKey(table));
    }

    // Get records for the specified tables
    final Map<String, List<PocketbaseRecord>> changeset = {};
    for (final table in onlyTables) {
      var q = select(pocketbaseRecords);
      // q = q
      //   ..where((tbl) =>
      //       tbl.collectionName.equals(table) | tbl.collectionId.equals(table));
      final tblExp = pocketbaseRecords.collectionName.equals(table) |
          pocketbaseRecords.collectionId.equals(table);
      Expression<bool> exp = tblExp;

      if (filters != null && filters.containsKey(table)) {
        final filter = filters[table]!;
        exp = exp & filter;
      }
      if (syncedAfter != null) {
        exp = exp & pocketbaseRecords.syncedAt.isBiggerThanValue(syncedAfter);
      }
      if (includeFailed) {
        exp =
            exp | (tblExp & pocketbaseRecords.failedCount.isBiggerThanValue(0));
      }
      if (includeNotSynced) {
        exp = exp | (tblExp & pocketbaseRecords.syncedAt.isNull());
      }
      q = q..where((tbl) => exp);
      // print(q.constructQuery().buffer.toString());
      changeset[table] = await q.get();
    }

    // Apply remaining filters
    for (final records in changeset.values) {
      records.removeWhere((value) =>
          (onlyNodeId != null && value.hlc.nodeId != onlyNodeId) ||
          (exceptNodeId != null && value.hlc.nodeId == exceptNodeId) ||
          (modifiedOn != null && value.modified != modifiedOn) ||
          (modifiedAfter != null && value.modified <= modifiedAfter));
    }

    // Remove empty table changesets
    changeset.removeWhere((_, records) => records.isEmpty);

    final changeSetData = changeset.map(
      (table, records) => MapEntry(
        table,
        records
            .map((e) => e.data)
            .map((e) => jsonDecode(e) as Map<String, Object?>)
            .toList(),
      ),
    );

    return changeSetData;
  }

  /// Changes the node id.
  /// This can be useful e.g. when the user logs out and logs in with a new
  /// account without resetting the database - id avoids synchronization issues
  /// where the existing entries do not get correctly propagated to the new
  /// user id.
  ///
  /// Use [newNodeId] to set an explicit id, or leave it empty to autogenerate a
  /// random one.
  /// If you set a custom id, make sure it's unique accross your system, as
  /// collisions will break the CRDT in subtle ways.
  ///
  /// See [init] and [generateNodeId].
  Future<void> resetNodeId([String? newNodeId]) async {
    final oldNodeId = canonicalTime.nodeId;
    newNodeId ??= generateNodeId();
    await transaction(() async {
      final tables = await _getCollectionNames().get();
      for (final table in tables) {
        await _resetNodeIdByCollection(
          oldNodeId,
          newNodeId!,
          table,
        );
      }
    });
    canonicalTime = canonicalTime.apply(nodeId: newNodeId);
  }

  RecordModel _recordFromJson(PocketbaseRecord record) {
    return RecordModel.fromJson(jsonDecode(record.data));
  }

  Selectable<RecordModel?> get(String collection, String id) {
    return _getRecordByIdAndCollectionNonDeleted(
      id,
      collection,
    ).map(_recordFromJson);
  }

  Selectable<RecordModel> getAll(String collection) {
    return _getRecordsByCollectionNonDeleted(
      collection,
    ).map(_recordFromJson);
  }

  Future<void> setAll(
    Iterable<RecordModel> records, {
    bool isDeleted = false,
    bool notify = true,
    bool addId = true,
    DateTime? syncedAt,
  }) async {
    await transaction(() async {
      DateTime? deletedAt = isDeleted ? DateTime.now() : null;
      Hlc hlc = canonicalTime;
      if (notify) hlc = hlc.increment();
      for (final record in records) {
        final data = record.toJson();
        if (addId && record.id.isEmpty) {
          data['id'] = createPocketbaseId();
        }
        data['hlc'] = hlc.toString();
        data['node_id'] = hlc.nodeId;
        data['modified'] = hlc.toString();
        data['deleted_at'] = deletedAt?.toIso8601String();
        await _insertRecord(jsonEncode(data), syncedAt);
      }
      final tables = records.map((e) => e.collectionId).toSet();
      if (notify) onDatasetChanged(tables, hlc);
    });
  }

  Future<void> set(
    RecordModel record, {
    bool isDeleted = false,
    bool notify = true,
    bool addId = true,
    DateTime? syncedAt,
  }) async {
    await setAll(
      [record],
      isDeleted: isDeleted,
      notify: notify,
      addId: addId,
      syncedAt: syncedAt,
    );
  }

  // Future<void> remove(RecordModel record) async {
  //   await set(
  //     record,
  //     isDeleted: true,
  //   );
  // }

  CrdtChangeset parseChangeset(String str) {
    final items = jsonDecode(str) as Map<String, dynamic>;
    // final changes = parseCrdtChangeset(items);
    Map<String, List<Map<String, Object?>>> changes = {};
    for (final key in items.keys) {
      final value = items[key] as List;
      changes[key] = value //
          .map((e) => RecordModel.fromJson(e))
          .map((e) => e.toJson())
          .toList();
    }
    return changes.map(
      (table, records) => MapEntry(
        table,
        records
            // .map((e) => RecordModel.fromJson(e))
            // .map((e) => e.toJson())
            .toList(),
      ),
    );
  }

  // final _sync = <String, bool>{};
  // Future<void> sync(String collection) async {
  //   if (_sync[collection] == true) return;
  //   try {
  //     _sync[collection] = true;
  //     // Get newest record locally
  //     final col = client.collection(collection);
  //     final newest = await _getLastSyncedRecord(
  //       collection: collection,
  //     ).getSingleOrNull();
  //     // Get changeset from server
  //     final records = await col.getFullList(
  //       filter: newest == null ? null : "updated > '${newest.modified}'",
  //     );
  //     // Merge changeset
  //     final changeset = <String, List<Map<String, dynamic>>>{
  //       collection: records.map((e) => e.toJson()).toList(),
  //     };
  //     await merge(changeset);
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print('error syncing: $e');
  //   } finally {
  //     _sync[collection] = false;
  //   }
  // }
}

// extension CrdtRecordModelUtils on Iterable<RecordModel> {
//   CrdtChangeset toChangeset() {
//     final tables = map((e) => e.collectionName).toSet();
//     return {
//       for (final table in tables)
//         table: where((e) => e.collectionName == table)
//             .map((e) => e.toJson())
//             .toList(),
//     };
//   }
// }
