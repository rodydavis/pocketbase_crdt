// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crdt_sync/crdt_sync_server.dart';
import 'package:drift/drift.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:version/version.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'database.dart';

const maxIdleDuration = Duration(minutes: 5);
final minimumVersion = Version(1, 0, 0);
final version = Version(1, 0, 0);

class PocketbaseCrdtServer extends CrdtDatabase {
  final PocketBase client;
  final int port;

  PocketbaseCrdtServer(
    super.e, {
    required this.client,
    this.port = 6000,
    this.userTables = const [],
    required this.createFilters,
  });

  final List<String> userTables;
  final Map<String, CustomExpression<bool>> Function(String userId)
      createFilters;
  var syncDuration = const Duration(minutes: 5);
  StreamSubscription? _subscription;
  Timer? _timer;
  Timer? _debounce;
  var debounceDuration = const Duration(seconds: 1);
  final _connectedClients = <CrdtSync, DateTime>{};

  Future<void> sync() async {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () async {
      final ls = await getLastSyncedRecord().getSingleOrNull();
      print('server: sync start ${ls?.syncedAt}');
      if (ls == null) {
        // Special case for first sync
        final records = await getAllRecords().get();
        for (final record in records) {
          await sendRecord(record);
        }
      } else {
        // Regular sync
        var records = await getNewRecords().get();
        for (final record in records) {
          await sendRecord(record);
        }
        records = await getUpdatedRecords(ls.syncedAt).get();
        for (final record in records) {
          await sendRecord(record);
        }
      }
      final time = DateTime.now().toIso8601String();
      // await setCurrentSyncTime(time);
      print('server: sync done $time');
    });
  }

  Future<void> init([String? nodeId]) async {
    await super.init(nodeId);
    _timer = Timer.periodic(syncDuration, (timer) async {
      await sync();
    });
    _subscription = select(pocketbaseRecords).watch().listen((event) async {
      print('server: records change: ${event.length}');
      await sync();
    });
    sync().ignore();
    await startServer();
  }

  Future<void> sendRecord(PocketbaseRecord record) async {
    try {
      final model = RecordModel.fromJson(jsonDecode(record.data));
      final colId = model.collectionId;
      final colName = model.collectionName;
      final col = client.collection(colId);
      var data = model.toJson();
      while (data.containsKey('data')) {
        if (data['data'] is String) {
          data = jsonDecode(data['data']);
        } else if (data['data'] is Map) {
          data = data['data'];
        } else {
          break;
        }
      }
      data.remove('created');
      data.remove('updated');
      data.remove('collectionId');
      data.remove('collectionName');
      data.remove('expand');
      print('server: sendRecord: ${record.id} $data');
      final synced = await getPocketbaseRecordsSync(record.id, colId) //
          .getSingleOrNull();
      if (synced == null) {
        try {
          await col.create(
            body: data,
          );
        } catch (e) {
          if (e is ClientException) {
            if (e.statusCode == 400) {
              data.remove('id');
              await col.update(
                model.id,
                body: data,
              );
            }
          }
        }
      } else {
        data.remove('id');
        await col.update(
          model.id,
          body: data,
        );
      }
      await setRecordSynced(
        record.id,
        colId,
        colName,
        DateTime.now(),
      );
    } catch (e, t) {
      print('server: syncRecord error: $e $t');
    }
  }

  // Future<void> syncRecord(String table, Map<String, dynamic> data) async {
  //  throw UnimplementedError();
  // }

  @override
  Future<void> close() async {
    await super.close();
    _timer?.cancel();
    await _subscription?.cancel();
  }

  Future<void> startServer() async {
    // print('Serving at ws://localhost:$port');

    final router = Router() //
      ..head('/check_version', _checkVersion)
      ..get('/changeset/<userId>/<peerId>', _getChangeset)
      ..delete('/user/<userId>', _deleteData)
      ..get('/ws/<userId>', _wsHandler);

    final handler = Pipeline() //
        .addMiddleware(logRequests())
        .addMiddleware(corsHeaders())
        .addMiddleware(_validateVersion)
        .addHandler(router.call);

    final server = await io.serve(handler, '0.0.0.0', port);
    print('Serving at http://${server.address.host}:${server.port}');

    const fullSyncKey = 'full_sync';
    final needsFullSync = await getItem(fullSyncKey).getSingleOrNull();
    if (needsFullSync == null || needsFullSync != 'true') {
      await _fullSync();
      await setItem(fullSyncKey, 'true');
    }
  }

  Future<Response> _wsHandler(Request request, String userId) async {
    try {
      await _validateAuth(request, userId);
    } catch (e) {
      return Response.forbidden('$e');
    }

    final handler = webSocketHandler(
      (WebSocketChannel webSocket) {
        late CrdtSync syncClient;
        syncClient = CrdtSync.server(
          this,
          webSocket,
          changesetBuilder: ({
            exceptNodeId,
            modifiedAfter,
            modifiedOn,
            onlyNodeId,
            onlyTables,
          }) {
            return this.getChangeset(
              exceptNodeId: exceptNodeId,
              modifiedAfter: modifiedAfter,
              modifiedOn: modifiedOn,
              onlyNodeId: onlyNodeId,
              onlyTables: onlyTables,
              filters: createFilters(userId),
            );
          },
          validateRecord: _validateRecord,
          mapIncomingChangeset: (table, record) {
            return jsonDecode(jsonEncode(record));
          },
          onChangesetReceived: (nodeId, recordCounts) {
            print('server: changeset received: $nodeId, $recordCounts');
            _refreshClient(syncClient);
          },
          onChangesetSent: (nodeId, recordCounts) {
            print('server: changeset sent: $nodeId, $recordCounts');
          },
          onConnect: (nodeId, __) {
            print('server: client connected: $nodeId');
            _refreshClient(syncClient);
          },
          onDisconnect: (nodeId, code, reason) {
            _connectedClients.remove(syncClient);
          },
          // verbose: true,
        );
      },
    );

    return await handler(request);
  }

  void _refreshClient(CrdtSync syncClient) {
    final now = DateTime.now();
    // Reset client's idle time
    _connectedClients[syncClient] = now;
    // Close stale connections
    _connectedClients.forEach((client, lastAccess) {
      final idleTime = now.difference(lastAccess);
      if (idleTime > maxIdleDuration) {
        print('Closing idle client: (${syncClient.peerId})');
        client.close();
      }
    });
  }

  Future<void> _fullSync() async {
    for (final table in userTables) {
      final col = client.collection(table);
      final records = await col.getFullList();
      for (final record in records) {
        await set(
          record,
          notify: false,
        );
        await setRecordSynced(
          record.id,
          record.collectionId,
          record.collectionName,
          DateTime.now(),
        );
      }
      print('server: full sync: $table ${records.length}');
    }
  }

  Future<Response> _getChangeset(
    Request request,
    String userId,
    String peerId,
  ) async {
    try {
      await _validateAuth(request, userId);
    } catch (e) {
      return Response.forbidden('$e');
    }

    final changeset = await getChangeset(
      filters: createFilters(userId),
      exceptNodeId: peerId,
    );
    return Response.ok(jsonEncode(changeset));
  }

  bool _validateRecord(String table, Map<String, dynamic> record) {
    // Disallow external changes to the auth table
    return userTables.contains(table);
  }

  /// By the time we arrive here, the version has already been checked
  Response _checkVersion(Request request) => Response(HttpStatus.noContent);

  Future<void> _validateAuth(Request request, String userId) async {
    // AsyncAuthStore
  }

  Future<Response> _deleteData(Request request, String userId) async {
    return Response(HttpStatus.noContent);
  }

  Handler _validateVersion(Handler innerHandler) {
    return (request) {
      final userAgent = request.headers[HttpHeaders.userAgentHeader]!;
      final version = Version.parse(userAgent.substring(
          userAgent.indexOf('/') + 1, userAgent.indexOf(' ')));
      return version >= minimumVersion
          ? innerHandler(request)
          : Response(HttpStatus.upgradeRequired);
    };
  }
}
