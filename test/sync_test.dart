import 'package:crdt/crdt.dart';
import 'package:test/test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pocketbase_crdt/pocketbase_crdt.dart';
import 'package:pocketbase_crdt/src/connection/connect.memory.dart';

void main() {
  const userId = 'qqp8kzg8hq5qwnq';
  const collectionId = '2gufa3r1rbqvc36';
  const collectionName = 'todos';

  test('open and close', () async {
    final ctx = DbContext(['todos']);
    await ctx.init();
    await ctx.close();
  });

  group('remote only', () {
    test('create', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final client = ctx.remoteCrdt.client;

      var current = await client //
          .collection(collectionName)
          .getFullList();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      Hlc hlc = ctx.remoteCrdt.canonicalTime;
      hlc = hlc.increment();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': ctx.localCrdt.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await client.collection(collectionName).create(body: data);
      current = await client //
          .collection(collectionName)
          .getFullList();

      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      await ctx.close();
    });

    test('create and update', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final client = ctx.remoteCrdt.client;

      var current = await client //
          .collection(collectionName)
          .getFullList();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      Hlc hlc = ctx.remoteCrdt.canonicalTime;
      hlc = hlc.increment();
      var data = <String, Object?>{
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': ctx.localCrdt.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await client.collection(collectionName).create(body: data);
      current = await client //
          .collection(collectionName)
          .getFullList();

      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      // Update record
      now = DateTime.now();
      hlc = hlc.increment();
      data = current.first.toJson();
      data['name'] = 'Task 2';

      await client //
          .collection(collectionName)
          .update(data['id'] as String, body: data);
      current = await client //
          .collection(collectionName)
          .getFullList();

      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 2');

      await ctx.close();
    });

    test('create, update and delete', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final client = ctx.remoteCrdt.client;

      var current = await client //
          .collection(collectionName)
          .getFullList();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      Hlc hlc = ctx.remoteCrdt.canonicalTime;
      hlc = hlc.increment();
      var data = <String, Object?>{
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': ctx.localCrdt.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await client.collection(collectionName).create(body: data);
      current = await client //
          .collection(collectionName)
          .getFullList();

      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      // Update record
      now = DateTime.now();
      hlc = hlc.increment();
      data = current.first.toJson();
      data['name'] = 'Task 2';

      await client //
          .collection(collectionName)
          .update(data['id'] as String, body: data);
      current = await client //
          .collection(collectionName)
          .getFullList();

      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 2');

      // Delete record
      await client //
          .collection(collectionName)
          .delete(data['id'] as String);
      current = await client //
          .collection(collectionName)
          .getFullList();

      expect(current, isEmpty);

      await ctx.close();
    });
  });

  group('local only', () {
    test('create', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final tbl = ctx.tables.first;

      var current = await db //
          .getAll(tbl)
          .get();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      Hlc hlc = db.canonicalTime;
      hlc = hlc.increment();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await db.set(RecordModel.fromJson(data));

      current = await db //
          .getAll(tbl)
          .get();
      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      await ctx.close();
    });

    test('create and update', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final tbl = ctx.tables.first;

      var current = await db //
          .getAll(tbl)
          .get();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      Hlc hlc = db.canonicalTime;
      hlc = hlc.increment();
      var data = <String, Object?>{
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await db.set(RecordModel.fromJson(data));

      current = await db //
          .getAll(tbl)
          .get();
      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      // Update record
      now = DateTime.now();
      hlc = hlc.increment();
      data = current.first.toJson();
      data['name'] = 'Task 2';

      await db.set(RecordModel.fromJson(data));
      current = await db //
          .getAll(tbl)
          .get();
      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 2');

      await ctx.close();
    });

    test('create, update and delete', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final tbl = ctx.tables.first;

      var current = await db //
          .getAll(tbl)
          .get();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      Hlc hlc = db.canonicalTime;
      hlc = hlc.increment();
      var data = <String, Object?>{
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await db.set(RecordModel.fromJson(data));

      current = await db //
          .getAll(tbl)
          .get();
      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      // Update record
      now = DateTime.now();
      hlc = hlc.increment();
      data = current.first.toJson();
      data['name'] = 'Task 2';

      await db.set(RecordModel.fromJson(data));
      current = await db //
          .getAll(tbl)
          .get();
      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 2');

      // Delete record
      await db.set(RecordModel.fromJson(data), isDeleted: true);
      current = await db //
          .getAll(tbl)
          .get();
      expect(current, isEmpty);

      await ctx.close();
    });
  });

  group('crdt', () {
    test('new item should return on getChanges', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;

      var current = await db //
          .getAll('todos')
          .get();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
      };
      await db.set(RecordModel.fromJson(data));

      current = await db //
          .getAll('todos')
          .get();
      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      // Changes
      final changes = await db.getChangeset();
      expect(changes.length, 1);
      expect(changes['todos']!.length, 1);
      expect(changes['todos']!.first['id'], data['id']);

      await ctx.close();
    });

    test('new item should return on getChanges after date', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;

      var current = await db //
          .getAll('todos')
          .get();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
      };
      await db.set(RecordModel.fromJson(data));

      current = await db //
          .getAll('todos')
          .get();
      expect(current.length, 1);
      expect(current.first.id, data['id']);
      expect(current.first.data['name'], 'Task 1');

      // Changes
      var changes = await db.getChangeset();
      expect(changes.length, 1);
      expect(changes['todos']!.length, 1);
      expect(changes['todos']!.first['id'], data['id']);

      final hlc = Hlc.parse(db.canonicalTime.toString());
      await db.set(RecordModel.fromJson({
        ...data,
        'name': 'Task 2',
        'id': db.createPocketbaseId(),
      }));
      changes = await db.getChangeset(
        modifiedAfter: hlc,
      );
      expect(changes.length, 1);
      expect(changes['todos']!.length, 1);
      expect(changes['todos']!.first['name'], 'Task 2');

      await ctx.close();
    });

    test('auto add id', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;

      var current = await db //
          .getAll('todos')
          .get();
      expect(current, isEmpty);

      // Add record
      var now = DateTime.now();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'name': 'Task 1',
      };
      await db.set(RecordModel.fromJson(data));

      current = await db //
          .getAll('todos')
          .get();
      expect(current.length, 1);
      expect(current.first.data['name'], 'Task 1');
      expect(current.first.id.isNotEmpty, true);

      await ctx.close();
    });

    test('sync 1 record', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final pb = ctx.remoteCrdt;

      var currentLocal = await db //
          .getAll('todos')
          .get();
      var currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal, isEmpty);
      expect(currentRemote, isEmpty);

      // Add record
      var now = DateTime.now();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
      };
      await db.set(RecordModel.fromJson(data));

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 0);

      // Sync
      var changes = await db.getChangeset();
      await pb.merge(changes);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 1);

      await ctx.close();
    });

    test('sync 2 records (only 1 that is not on remote)', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final pb = ctx.remoteCrdt;

      var currentLocal = await db //
          .getAll('todos')
          .get();
      var currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal, isEmpty);
      expect(currentRemote, isEmpty);

      // Add record
      var now = DateTime.now();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
      };
      await db.set(RecordModel.fromJson(data));

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 0);

      // Sync
      var changes = await db.getChangeset();
      await pb.merge(changes);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 1);

      final hlc = Hlc.parse(db.canonicalTime.toString());

      await db.set(RecordModel.fromJson({
        ...data,
        'id': db.createPocketbaseId(),
        'name': 'Task 2',
      }));

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 2);
      expect(currentRemote.length, 1);

      changes = await db.getChangeset(
        modifiedAfter: hlc,
      );
      expect(changes.length, 1);

      await pb.merge(changes);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 2);
      expect(currentRemote.length, 2);

      await ctx.close();
    });

    test('check for changes on remote and not local', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final pb = ctx.remoteCrdt;

      var currentLocal = await db //
          .getAll('todos')
          .get();
      var currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal, isEmpty);
      expect(currentRemote, isEmpty);

      // Add record
      var now = DateTime.now();
      var hlc = db.canonicalTime;
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await pb //
          .client
          .collection(collectionName)
          .create(body: data);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 0);
      expect(currentRemote.length, 1);

      // Sync
      var changes = await pb.getChangeset();
      expect(changes.length, 1);

      await db.merge(changes);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 1);

      await ctx.close();
    });
  });

  group('sync', () {
    test('add local item and sync to remote', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final pb = ctx.remoteCrdt;

      var currentLocal = await db //
          .getAll('todos')
          .get();
      var currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal, isEmpty);
      expect(currentRemote, isEmpty);

      // Add record
      var now = DateTime.now();
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
      };
      await db.set(RecordModel.fromJson(data));

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 0);

      // Sync
      await ctx.sync(userId);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 1);

      await ctx.close();
    });

    test('add remote item and sync to local', () async {
      final ctx = DbContext(['todos']);
      await ctx.init();

      final db = ctx.localCrdt;
      final pb = ctx.remoteCrdt;

      var currentLocal = await db //
          .getAll('todos')
          .get();
      var currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal, isEmpty);
      expect(currentRemote, isEmpty);

      // Add record
      var now = DateTime.now();
      var hlc = db.canonicalTime;
      var data = {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': now.toIso8601String(),
        'user': userId,
        'updated': now.toIso8601String(),
        'id': db.createPocketbaseId(),
        'name': 'Task 1',
        'hlc': hlc.toString(),
        'node_id': hlc.nodeId,
        'modified': hlc.toString(),
      };
      await pb //
          .client
          .collection(collectionName)
          .create(body: data);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 0);
      expect(currentRemote.length, 1);

      // Sync
      await ctx.sync(userId);

      currentLocal = await db //
          .getAll('todos')
          .get();
      currentRemote = await pb //
          .client
          .collection('todos')
          .getFullList();
      expect(currentLocal.length, 1);
      expect(currentRemote.length, 1);

      await ctx.close();
    });
  });

  group('CrdtPocketBase', () {
    test('open and close', () async {
      final instance = createInstance();
      await instance.init();
      //
      await instance.close();
    });

    test('create 1 local', () async {
      await instanceScope((instance) async {
        final col = instance.crdtCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );

        var current = await col //
            .getAll()
            .get();
        expect(current, isEmpty);

        // Add record
        var data = {
          'name': 'Task 1',
          'user': userId,
        };
        await col.set(data);

        current = await col //
            .getAll()
            .get();
        expect(current.length, 1);
        expect(current.first.data['name'], 'Task 1');
      });
    });

    test('create 1 local and sync to remote', () async {
      await instanceScope((instance) async {
        final col = instance.crdtCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );

        var current = await col //
            .getAll()
            .get();
        expect(current, isEmpty);

        // Add record
        var data = {
          'name': 'Task 1',
          'user': userId,
        };
        await col.set(data);

        current = await col //
            .getAll()
            .get();
        expect(current.length, 1);
        expect(current.first.data['name'], 'Task 1');

        // Sync
        await col.sync(filters: "user = '$userId'");

        final remote = await col //
            .getFullList();
        expect(remote.length, 1);
        expect(remote.first.data['name'], 'Task 1');
      });
    });

    test('create 1 remote and sync to local', () async {
      await instanceScope((instance) async {
        final col = instance.crdtCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );

        var current = await col //
            .getAll()
            .get();
        expect(current, isEmpty);

        // Add record
        final remoteNode = instance.db.createPocketbaseId();
        final hlc = Hlc.zero(remoteNode);
        var data = {
          'name': 'Task 1',
          'user': userId,
          'hlc': hlc.toString(),
          'node_id': hlc.nodeId,
          'modified': hlc.toString(),
        };
        await col.create(body: data);

        current = await col //
            .getFullList();
        expect(current.length, 1);

        current = await col //
            .getAll()
            .get();
        expect(current.length, 0);

        // Sync
        await col.sync(filters: "user = '$userId'");

        current = await col //
            .getAll()
            .get();
        expect(current.length, 1);
        expect(current.first.data['name'], 'Task 1');
      });
    });

    test('invalid record does not stop sync', () async {
      await instanceScope((instance) async {
        final col = instance.crdtCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );

        var current = await col //
            .getAll()
            .get();
        expect(current, isEmpty);

        // Add record
        var data = {
          'user': userId,
        };
        await col.set(data);

        current = await col //
            .getAll()
            .get();
        expect(current.length, 1);

        // Sync
        await col.sync(filters: "user = '$userId'");

        final remote = await col //
            .getFullList();
        expect(remote.length, 0);

        var failed = await instance //
            .db
            .getFailedRecords()
            .get();
        expect(failed.length, 1);
      });
    });
  });
}

CrdtPocketBase createInstance() {
  return CrdtPocketBase(
    'http://127.0.0.1:8090',
    createMemoryExecutor(logStatements: false),
  );
}

Future<void> instanceScope(
  Future<void> Function(CrdtPocketBase instance) callback,
) async {
  final instance = createInstance();
  await instance.init();
  try {
    await callback(instance);
  } catch (e) {
    rethrow;
  } finally {
    final tables = ['todos'];
    for (final tbl in tables) {
      final col = instance.collection(tbl);
      final records = await col.getFullList();
      for (final record in records) {
        await col.delete(record.id);
      }
    }
    await instance.close();
  }
}

class DbContext {
  DbContext(this.tables);
  final List<String> tables;
  final pb = PocketBase('http://127.0.0.1:8090');
  late final remoteCrdt = PocketBaseCrdt(pb, tables);
  final localCrdt = createMemoryDatabase(logStatements: false);

  Future<void> init() async {
    await localCrdt.init();
    await remoteCrdt.init();
  }

  Future<void> close({bool reset = true}) async {
    await localCrdt.close();
    if (reset) await deleteAll();
  }

  Future<void> deleteAll() async {
    for (final table in tables) {
      final col = remoteCrdt.client.collection(table);
      final records = await col.getFullList();
      for (final record in records) {
        await col.delete(record.id);
      }
    }
  }

  Future<void> sync(String userId) async {
    final lastHlcKey = 'local-last-hlc';
    final lastHlc = await localCrdt //
        .getItem(lastHlcKey)
        .getSingleOrNull()
        .then((value) => value != null ? Hlc.parse(value) : null);
    final changes = await localCrdt.getChangeset(
      modifiedAfter: lastHlc,
    );
    await remoteCrdt.merge(changes);
    await localCrdt.setItem(lastHlcKey, lastHlc.toString());

    final lastUpdatedKey = 'remote-last-updated';
    final lastUpdated = await localCrdt //
        .getItem(lastUpdatedKey)
        .getSingleOrNull();
    final remoteChanges = await remoteCrdt.getChangeset(
      extraFilters: {
        "user = '$userId'",
        if (lastUpdated != null) "updated > '${lastUpdated}'",
      },
    );
    await localCrdt.merge(remoteChanges);
    final newest = remoteChanges //
        .values
        .expand((e) => e)
        .map((e) => e['updated'] as String)
        .toSet()
        .map((e) => DateTime.parse(e))
        .reduce((value, element) => value.isAfter(element) ? value : element);
    await localCrdt.setItem(lastUpdatedKey, newest.toIso8601String());
  }
}