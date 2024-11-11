import 'package:crdt/crdt.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';

import 'database.dart';
import 'pb.dart';

class CrdtPocketBase extends PocketBase {
  CrdtPocketBase(
    super.baseUrl,
    QueryExecutor e, {
    super.lang,
    super.authStore,
    super.httpClientFactory,
  }) : db = CrdtDatabase(e);

  final CrdtDatabase db;

  Future<void> init() async {
    await db.init();
  }

  Future<void> close() async {
    await db.close();
  }

  String newId() {
    return db.createPocketbaseId();
  }

  CrdtRecordService crdtCollection({
    required String collectionId,
    required String collectionName,
  }) {
    return CrdtRecordService(
      collectionId: collectionId,
      collectionName: collectionName,
      client: this,
      db: db,
    );
  }
}

class CrdtRecordService extends RecordService {
  CrdtRecordService({
    required this.collectionId,
    required this.collectionName,
    required PocketBase client,
    required this.db,
  }) : super(client, collectionId.isEmpty ? collectionName : collectionId);
  final String collectionId;
  final String collectionName;

  String get collectionIdOrName {
    assert(collectionId.isNotEmpty || collectionName.isNotEmpty);
    return collectionId.isNotEmpty ? collectionId : collectionName;
  }

  final CrdtDatabase db;
  late final PocketBaseCrdt crdt = PocketBaseCrdt(
    client,
    [collectionIdOrName],
  );

  Future<void> init() async {
    await db.init();
    await crdt.init();
  }

  bool _syncing = false;

  Selectable<RecordModel> getAll() {
    return db.getAll(collectionIdOrName);
  }

  Selectable<RecordModel?> get(String id) {
    return db.get(collectionIdOrName, id);
  }

  Future<void> set(
    Map<String, Object?> data, {
    bool isDeleted = false,
    bool notify = true,
    bool addId = true,
  }) async {
    await setAll(
      [data],
      isDeleted: isDeleted,
      notify: notify,
      addId: addId,
    );
  }

  Future<void> setAll(
    Iterable<Map<String, Object?>> target, {
    bool isDeleted = false,
    bool notify = true,
    bool addId = true,
  }) async {
    final models = <RecordModel>[];
    for (final data in target) {
      if (addId && (data['id'] == null || data['id'] == '')) {
        data['id'] = db.createPocketbaseId();
      }
      final model = RecordModel.fromJson({
        ...data,
        'collectionId': collectionId,
        'collectionName': collectionName,
      });
      models.add(model);
    }
    await db.setAll(
      models,
      isDeleted: isDeleted,
      notify: notify,
      addId: addId,
    );
  }

  Future<void> sync({
    String? localFilters,
    String? remoteFilters,
  }) async {
    if (_syncing == true) {
      print('already syncing $collectionIdOrName');
      return;
    }
    try {
      _syncing = true;
      await crdt.init();
      final localCrdt = db;
      final remoteCrdt = crdt;
      final lastHlcKey = '$collectionIdOrName:local-last-hlc';
      final lastHlc = await localCrdt //
          .getItem(lastHlcKey)
          .getSingleOrNull()
          .then((value) {
        if (value != null && value.isNotEmpty) {
          return Hlc.parse(value);
        }
        return null;
      });
      final changes = await localCrdt.getChangeset(
        modifiedAfter: lastHlc,
        // onlyNodeId: localCrdt.nodeId,
        onlyTables: [collectionIdOrName],
        filters: {
          if (localFilters != null) ...{
            collectionIdOrName: CustomExpression<bool>(localFilters),
          },
        },
      );
      await remoteCrdt.merge(
        changes,
        onError: (record, err, trace) async {
          print('sync - record error: ${record.id}, $err, $trace');
          await localCrdt.incrementRecordError(
            record.id,
            collectionIdOrName,
          );
        },
        onSuccess: (record) async {
          // print('sync - record success: ${record.id}');
          await localCrdt.resetRecordError(
            record.id,
            collectionIdOrName,
          );
        },
      );
      await localCrdt.setItem(lastHlcKey, lastHlc?.toString());

      final lastUpdatedKey = '$collectionIdOrName:remote-last-updated';
      final lastUpdated = await localCrdt //
          .getItem(lastUpdatedKey)
          .getSingleOrNull();
      var remoteChanges = await remoteCrdt.getChangeset(
        onlyTables: [collectionIdOrName],
        extraFilters: {
          if (remoteFilters != null) remoteFilters,
          if (lastUpdated != null)
            "updated >= '${DateTime.parse(lastUpdated).dateOnly}'",
        },
        exceptNodeId: localCrdt.nodeId,
      );
      print('remoteChanges: $remoteChanges');
      await localCrdt.merge(remoteChanges);
      if (remoteChanges.isNotEmpty) {
        final newest = remoteChanges //
            .values
            .expand((e) => e)
            .map((e) => e['updated'] as String)
            .toSet()
            .map((e) => DateTime.parse(e))
            .reduce(
                (value, element) => value.isAfter(element) ? value : element);
        await localCrdt.setItem(lastUpdatedKey, newest.toIso8601String());
      }
    } catch (e, t) {
      print('error syncing $collectionIdOrName: $e, $t');
    } finally {
      _syncing = false;
    }
  }
}

extension on DateTime {
  String get dateOnly {
    final dateFormat = DateFormat("yyyy-MM-dd");
    return dateFormat.format(this);
  }
}
