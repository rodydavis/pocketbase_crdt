// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class PocketbaseRecords extends Table
    with TableInfo<PocketbaseRecords, PocketbaseRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PocketbaseRecords(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(data, \'\$.id\')'), false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(data, \'\$.id\')) VIRTUAL NOT NULL');
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT \'{}\'',
      defaultValue: const CustomExpression('\'{}\''));
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
      'collectionId', aliasedName, false,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(data, \'\$.collectionId\')'),
          false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(data, \'\$.collectionId\')) VIRTUAL NOT NULL');
  static const VerificationMeta _collectionNameMeta =
      const VerificationMeta('collectionName');
  late final GeneratedColumn<String> collectionName = GeneratedColumn<String>(
      'collectionName', aliasedName, false,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(data, \'\$.collectionName\')'),
          false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(data, \'\$.collectionName\')) VIRTUAL NOT NULL');
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  late final GeneratedColumn<String> created = GeneratedColumn<String>(
      'created', aliasedName, false,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(data, \'\$.created\')'), false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(data, \'\$.created\')) VIRTUAL NOT NULL');
  static const VerificationMeta _updatedMeta =
      const VerificationMeta('updated');
  late final GeneratedColumn<String> updated = GeneratedColumn<String>(
      'updated', aliasedName, false,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(data, \'\$.updated\')'), false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(data, \'\$.updated\')) VIRTUAL NOT NULL');
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
      'node_id', aliasedName, false,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(data, \'\$.node_id\')'), false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(data, \'\$.node_id\')) VIRTUAL NOT NULL');
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  late final GeneratedColumnWithTypeConverter<Hlc,
      String> hlc = GeneratedColumn<String>('hlc', aliasedName, false,
          generatedAs: GeneratedAs(
              const CustomExpression('json_extract(data, \'\$.hlc\')'), false),
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints:
              'GENERATED ALWAYS AS (json_extract(data, \'\$.hlc\')) VIRTUAL NOT NULL')
      .withConverter<Hlc>(PocketbaseRecords.$converterhlc);
  static const VerificationMeta _modifiedMeta =
      const VerificationMeta('modified');
  late final GeneratedColumnWithTypeConverter<Hlc,
      String> modified = GeneratedColumn<String>('modified', aliasedName, false,
          generatedAs: GeneratedAs(
              const CustomExpression('json_extract(data, \'\$.modified\')'),
              false),
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints:
              'GENERATED ALWAYS AS (json_extract(data, \'\$.modified\')) VIRTUAL NOT NULL')
      .withConverter<Hlc>(PocketbaseRecords.$convertermodified);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
      'deleted_at', aliasedName, true,
      generatedAs: GeneratedAs(
          const CustomExpression('json_extract(data, \'\$.deleted_at\')'),
          false),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'GENERATED ALWAYS AS (json_extract(data, \'\$.deleted_at\')) VIRTUAL');
  static const VerificationMeta _failedCountMeta =
      const VerificationMeta('failedCount');
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
      'failed_count', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        data,
        collectionId,
        collectionName,
        created,
        updated,
        nodeId,
        hlc,
        modified,
        deletedAt,
        failedCount,
        syncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pocketbase_records';
  @override
  VerificationContext validateIntegrity(Insertable<PocketbaseRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('collectionId')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collectionId']!, _collectionIdMeta));
    }
    if (data.containsKey('collectionName')) {
      context.handle(
          _collectionNameMeta,
          collectionName.isAcceptableOrUnknown(
              data['collectionName']!, _collectionNameMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('updated')) {
      context.handle(_updatedMeta,
          updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta));
    }
    if (data.containsKey('node_id')) {
      context.handle(_nodeIdMeta,
          nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta));
    }
    context.handle(_hlcMeta, const VerificationResult.success());
    context.handle(_modifiedMeta, const VerificationResult.success());
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('failed_count')) {
      context.handle(
          _failedCountMeta,
          failedCount.isAcceptableOrUnknown(
              data['failed_count']!, _failedCountMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {id, collectionId, collectionName},
      ];
  @override
  PocketbaseRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PocketbaseRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collectionId'])!,
      collectionName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collectionName'])!,
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created'])!,
      updated: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated'])!,
      nodeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}node_id'])!,
      hlc: PocketbaseRecords.$converterhlc.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hlc'])!),
      modified: PocketbaseRecords.$convertermodified.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modified'])!),
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deleted_at']),
      failedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failed_count']),
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
    );
  }

  @override
  PocketbaseRecords createAlias(String alias) {
    return PocketbaseRecords(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Hlc, String, String> $converterhlc =
      const HlcConverter();
  static JsonTypeConverter2<Hlc, String, String> $convertermodified =
      const HlcConverter();
  @override
  List<String> get customConstraints =>
      const ['UNIQUE(id, collectionId, collectionName)'];
  @override
  bool get dontWriteConstraints => true;
}

class PocketbaseRecord extends DataClass
    implements Insertable<PocketbaseRecord> {
  final String id;
  final String data;
  final String collectionId;
  final String collectionName;
  final String created;
  final String updated;
  final String nodeId;
  final Hlc hlc;
  final Hlc modified;
  final String? deletedAt;
  final int? failedCount;
  final DateTime? syncedAt;
  const PocketbaseRecord(
      {required this.id,
      required this.data,
      required this.collectionId,
      required this.collectionName,
      required this.created,
      required this.updated,
      required this.nodeId,
      required this.hlc,
      required this.modified,
      this.deletedAt,
      this.failedCount,
      this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    if (!nullToAbsent || failedCount != null) {
      map['failed_count'] = Variable<int>(failedCount);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  PocketbaseRecordsCompanion toCompanion(bool nullToAbsent) {
    return PocketbaseRecordsCompanion(
      data: Value(data),
      failedCount: failedCount == null && nullToAbsent
          ? const Value.absent()
          : Value(failedCount),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory PocketbaseRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PocketbaseRecord(
      id: serializer.fromJson<String>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      collectionName: serializer.fromJson<String>(json['collectionName']),
      created: serializer.fromJson<String>(json['created']),
      updated: serializer.fromJson<String>(json['updated']),
      nodeId: serializer.fromJson<String>(json['node_id']),
      hlc: PocketbaseRecords.$converterhlc
          .fromJson(serializer.fromJson<String>(json['hlc'])),
      modified: PocketbaseRecords.$convertermodified
          .fromJson(serializer.fromJson<String>(json['modified'])),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      failedCount: serializer.fromJson<int?>(json['failed_count']),
      syncedAt: serializer.fromJson<DateTime?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'data': serializer.toJson<String>(data),
      'collectionId': serializer.toJson<String>(collectionId),
      'collectionName': serializer.toJson<String>(collectionName),
      'created': serializer.toJson<String>(created),
      'updated': serializer.toJson<String>(updated),
      'node_id': serializer.toJson<String>(nodeId),
      'hlc': serializer
          .toJson<String>(PocketbaseRecords.$converterhlc.toJson(hlc)),
      'modified': serializer.toJson<String>(
          PocketbaseRecords.$convertermodified.toJson(modified)),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'failed_count': serializer.toJson<int?>(failedCount),
      'synced_at': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  PocketbaseRecord copyWith(
          {String? id,
          String? data,
          String? collectionId,
          String? collectionName,
          String? created,
          String? updated,
          String? nodeId,
          Hlc? hlc,
          Hlc? modified,
          Value<String?> deletedAt = const Value.absent(),
          Value<int?> failedCount = const Value.absent(),
          Value<DateTime?> syncedAt = const Value.absent()}) =>
      PocketbaseRecord(
        id: id ?? this.id,
        data: data ?? this.data,
        collectionId: collectionId ?? this.collectionId,
        collectionName: collectionName ?? this.collectionName,
        created: created ?? this.created,
        updated: updated ?? this.updated,
        nodeId: nodeId ?? this.nodeId,
        hlc: hlc ?? this.hlc,
        modified: modified ?? this.modified,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        failedCount: failedCount.present ? failedCount.value : this.failedCount,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
      );
  @override
  String toString() {
    return (StringBuffer('PocketbaseRecord(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('collectionId: $collectionId, ')
          ..write('collectionName: $collectionName, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('nodeId: $nodeId, ')
          ..write('hlc: $hlc, ')
          ..write('modified: $modified, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('failedCount: $failedCount, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      data,
      collectionId,
      collectionName,
      created,
      updated,
      nodeId,
      hlc,
      modified,
      deletedAt,
      failedCount,
      syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PocketbaseRecord &&
          other.id == this.id &&
          other.data == this.data &&
          other.collectionId == this.collectionId &&
          other.collectionName == this.collectionName &&
          other.created == this.created &&
          other.updated == this.updated &&
          other.nodeId == this.nodeId &&
          other.hlc == this.hlc &&
          other.modified == this.modified &&
          other.deletedAt == this.deletedAt &&
          other.failedCount == this.failedCount &&
          other.syncedAt == this.syncedAt);
}

class PocketbaseRecordsCompanion extends UpdateCompanion<PocketbaseRecord> {
  final Value<String> data;
  final Value<int?> failedCount;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const PocketbaseRecordsCompanion({
    this.data = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PocketbaseRecordsCompanion.insert({
    this.data = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<PocketbaseRecord> custom({
    Expression<String>? data,
    Expression<int>? failedCount,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (failedCount != null) 'failed_count': failedCount,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PocketbaseRecordsCompanion copyWith(
      {Value<String>? data,
      Value<int?>? failedCount,
      Value<DateTime?>? syncedAt,
      Value<int>? rowid}) {
    return PocketbaseRecordsCompanion(
      data: data ?? this.data,
      failedCount: failedCount ?? this.failedCount,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PocketbaseRecordsCompanion(')
          ..write('data: $data, ')
          ..write('failedCount: $failedCount, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class KvStore extends Table with TableInfo<KvStore, KvStoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  KvStore(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY');
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_store';
  @override
  VerificationContext validateIntegrity(Insertable<KvStoreData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvStoreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvStoreData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key']),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
    );
  }

  @override
  KvStore createAlias(String alias) {
    return KvStore(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class KvStoreData extends DataClass implements Insertable<KvStoreData> {
  final String? key;
  final String? value;
  const KvStoreData({this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<String>(key);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  KvStoreCompanion toCompanion(bool nullToAbsent) {
    return KvStoreCompanion(
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory KvStoreData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvStoreData(
      key: serializer.fromJson<String?>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String?>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  KvStoreData copyWith(
          {Value<String?> key = const Value.absent(),
          Value<String?> value = const Value.absent()}) =>
      KvStoreData(
        key: key.present ? key.value : this.key,
        value: value.present ? value.value : this.value,
      );
  KvStoreData copyWithCompanion(KvStoreCompanion data) {
    return KvStoreData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvStoreData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvStoreData &&
          other.key == this.key &&
          other.value == this.value);
}

class KvStoreCompanion extends UpdateCompanion<KvStoreData> {
  final Value<String?> key;
  final Value<String?> value;
  final Value<int> rowid;
  const KvStoreCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvStoreCompanion.insert({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<KvStoreData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvStoreCompanion copyWith(
      {Value<String?>? key, Value<String?>? value, Value<int>? rowid}) {
    return KvStoreCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvStoreCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CrdtDatabase extends GeneratedDatabase {
  _$CrdtDatabase(QueryExecutor e) : super(e);
  $CrdtDatabaseManager get managers => $CrdtDatabaseManager(this);
  late final PocketbaseRecords pocketbaseRecords = PocketbaseRecords(this);
  late final KvStore kvStore = KvStore(this);
  Future<int> setItem(String? key, String? value) {
    return customInsert(
      'INSERT INTO kv_store ("key", value) VALUES (?1, ?2) ON CONFLICT ("key") DO UPDATE SET value = ?2',
      variables: [Variable<String>(key), Variable<String>(value)],
      updates: {kvStore},
    );
  }

  Selectable<String?> getItem(String? key) {
    return customSelect('SELECT value FROM kv_store WHERE "key" = ?1',
        variables: [
          Variable<String>(key)
        ],
        readsFrom: {
          kvStore,
        }).map((QueryRow row) => row.readNullable<String>('value'));
  }

  Future<int> deleteItem(String? key) {
    return customUpdate(
      'DELETE FROM kv_store WHERE "key" = ?1',
      variables: [Variable<String>(key)],
      updates: {kvStore},
      updateKind: UpdateKind.delete,
    );
  }

  Selectable<PocketbaseRecord> getAllRecords() {
    return customSelect('SELECT * FROM pocketbase_records',
        variables: [],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<GetLastModifiedResult> _getLastModified() {
    return customSelect(
        'SELECT"pocketbase_records"."id" AS "nested_0.id", "pocketbase_records"."data" AS "nested_0.data", "pocketbase_records"."collectionId" AS "nested_0.collectionId", "pocketbase_records"."collectionName" AS "nested_0.collectionName", "pocketbase_records"."created" AS "nested_0.created", "pocketbase_records"."updated" AS "nested_0.updated", "pocketbase_records"."node_id" AS "nested_0.node_id", "pocketbase_records"."hlc" AS "nested_0.hlc", "pocketbase_records"."modified" AS "nested_0.modified", "pocketbase_records"."deleted_at" AS "nested_0.deleted_at", "pocketbase_records"."failed_count" AS "nested_0.failed_count", "pocketbase_records"."synced_at" AS "nested_0.synced_at", MAX(modified) AS modified FROM pocketbase_records',
        variables: [],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap((QueryRow row) async => GetLastModifiedResult(
          pocketbaseRecords:
              await pocketbaseRecords.mapFromRow(row, tablePrefix: 'nested_0'),
          modified: NullAwareTypeConverter.wrapFromSql(
              PocketbaseRecords.$convertermodified,
              row.readNullable<String>('modified')),
        ));
  }

  Selectable<GetLastModifiedOnlyNodeIdResult> _getLastModifiedOnlyNodeId(
      String nodeId) {
    return customSelect(
        'SELECT"pocketbase_records"."id" AS "nested_0.id", "pocketbase_records"."data" AS "nested_0.data", "pocketbase_records"."collectionId" AS "nested_0.collectionId", "pocketbase_records"."collectionName" AS "nested_0.collectionName", "pocketbase_records"."created" AS "nested_0.created", "pocketbase_records"."updated" AS "nested_0.updated", "pocketbase_records"."node_id" AS "nested_0.node_id", "pocketbase_records"."hlc" AS "nested_0.hlc", "pocketbase_records"."modified" AS "nested_0.modified", "pocketbase_records"."deleted_at" AS "nested_0.deleted_at", "pocketbase_records"."failed_count" AS "nested_0.failed_count", "pocketbase_records"."synced_at" AS "nested_0.synced_at", MAX(modified) AS modified FROM pocketbase_records WHERE node_id = ?1',
        variables: [
          Variable<String>(nodeId)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap((QueryRow row) async => GetLastModifiedOnlyNodeIdResult(
          pocketbaseRecords:
              await pocketbaseRecords.mapFromRow(row, tablePrefix: 'nested_0'),
          modified: NullAwareTypeConverter.wrapFromSql(
              PocketbaseRecords.$convertermodified,
              row.readNullable<String>('modified')),
        ));
  }

  Selectable<GetLastModifiedExceptNodeIdResult> _getLastModifiedExceptNodeId(
      String nodeId) {
    return customSelect(
        'SELECT"pocketbase_records"."id" AS "nested_0.id", "pocketbase_records"."data" AS "nested_0.data", "pocketbase_records"."collectionId" AS "nested_0.collectionId", "pocketbase_records"."collectionName" AS "nested_0.collectionName", "pocketbase_records"."created" AS "nested_0.created", "pocketbase_records"."updated" AS "nested_0.updated", "pocketbase_records"."node_id" AS "nested_0.node_id", "pocketbase_records"."hlc" AS "nested_0.hlc", "pocketbase_records"."modified" AS "nested_0.modified", "pocketbase_records"."deleted_at" AS "nested_0.deleted_at", "pocketbase_records"."failed_count" AS "nested_0.failed_count", "pocketbase_records"."synced_at" AS "nested_0.synced_at", MAX(modified) AS modified FROM pocketbase_records WHERE node_id != ?1',
        variables: [
          Variable<String>(nodeId)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap((QueryRow row) async => GetLastModifiedExceptNodeIdResult(
          pocketbaseRecords:
              await pocketbaseRecords.mapFromRow(row, tablePrefix: 'nested_0'),
          modified: NullAwareTypeConverter.wrapFromSql(
              PocketbaseRecords.$convertermodified,
              row.readNullable<String>('modified')),
        ));
  }

  Future<int> _insertRecord(String data, DateTime? syncedAt) {
    return customInsert(
      'INSERT INTO pocketbase_records (data) VALUES (?1) ON CONFLICT (id, collectionId, collectionName) DO UPDATE SET data = ?1, synced_at = ?2 WHERE compareHlc(excluded.hlc, pocketbase_records.hlc) > 0',
      variables: [Variable<String>(data), Variable<DateTime>(syncedAt)],
      updates: {pocketbaseRecords},
    );
  }

  Selectable<PocketbaseRecord> getRecord(String id, String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE id = ?1 AND(collectionName = ?2 OR collectionId = ?2)',
        variables: [
          Variable<String>(id),
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<PocketbaseRecord> getFailedRecords(String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE failed_count > 0 AND(collectionName = ?1 OR collectionId = ?1)',
        variables: [
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<PocketbaseRecord> getUnsyncedRecords(String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE(synced_at IS NULL OR synced_at = \'\')AND(collectionName = ?1 OR collectionId = ?1)',
        variables: [
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<PocketbaseRecord> getSyncedAfter(
      DateTime? syncedAt, String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE synced_at > ?1 AND(collectionName = ?2 OR collectionId = ?2)',
        variables: [
          Variable<DateTime>(syncedAt),
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Future<int> setRecordSynced(
      DateTime? syncedAt, String id, String collection) {
    return customUpdate(
      'UPDATE pocketbase_records SET synced_at = ?1, failed_count = 0 WHERE id = ?2 AND(collectionName = ?3 OR collectionId = ?3)',
      variables: [
        Variable<DateTime>(syncedAt),
        Variable<String>(id),
        Variable<String>(collection)
      ],
      updates: {pocketbaseRecords},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> resetRecordError(String id, String collection) {
    return customUpdate(
      'UPDATE pocketbase_records SET failed_count = 0 WHERE id = ?1 AND(collectionName = ?2 OR collectionId = ?2)',
      variables: [Variable<String>(id), Variable<String>(collection)],
      updates: {pocketbaseRecords},
      updateKind: UpdateKind.update,
    );
  }

  Future<int> incrementRecordError(String id, String collection) {
    return customUpdate(
      'UPDATE pocketbase_records SET failed_count = failed_count + 1 WHERE id = ?1 AND(collectionName = ?2 OR collectionId = ?2)',
      variables: [Variable<String>(id), Variable<String>(collection)],
      updates: {pocketbaseRecords},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<PocketbaseRecord> _getRecords() {
    return customSelect('SELECT * FROM pocketbase_records',
        variables: [],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<PocketbaseRecord> _getRecordByIdAndCollection(
      String id, String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE id = ?1 AND(collectionName = ?2 OR collectionId = ?2)',
        variables: [
          Variable<String>(id),
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<PocketbaseRecord> _getRecordsByCollection(String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE(collectionName = ?1 OR collectionId = ?1)',
        variables: [
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<String> _getCollectionNames() {
    return customSelect(
        'SELECT collectionName FROM pocketbase_records GROUP BY collectionName',
        variables: [],
        readsFrom: {
          pocketbaseRecords,
        }).map((QueryRow row) => row.read<String>('collectionName'));
  }

  Future<int> _resetNodeIdByCollection(
      String oldNodeId, String newNodeId, String collection) {
    return customUpdate(
      'UPDATE pocketbase_records SET data = json_set(data, \'\$.modified\', "REPLACE"(modified, ?1, ?2)) WHERE(collectionName = ?3 OR collectionId = ?3)',
      variables: [
        Variable<String>(oldNodeId),
        Variable<String>(newNodeId),
        Variable<String>(collection)
      ],
      updates: {pocketbaseRecords},
      updateKind: UpdateKind.update,
    );
  }

  Selectable<PocketbaseRecord> _getRecordByIdAndCollectionNonDeleted(
      String id, String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE id = ?1 AND(collectionName = ?2 OR collectionId = ?2)AND(deleted_at IS NULL OR deleted_at = \'\')',
        variables: [
          Variable<String>(id),
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Selectable<PocketbaseRecord> _getRecordsByCollectionNonDeleted(
      String collection) {
    return customSelect(
        'SELECT * FROM pocketbase_records WHERE(collectionName = ?1 OR collectionId = ?1)AND(deleted_at IS NULL OR deleted_at = \'\')',
        variables: [
          Variable<String>(collection)
        ],
        readsFrom: {
          pocketbaseRecords,
        }).asyncMap(pocketbaseRecords.mapFromRow);
  }

  Future<int> _deleteRecordByIdAndCollection(
      String deletedAt, String id, String collection) {
    return customUpdate(
      'UPDATE pocketbase_records SET data = json_set(data, \'\$.deleted_at\', ?1) WHERE id = ?2 AND(collectionName = ?3 OR collectionId = ?3)',
      variables: [
        Variable<String>(deletedAt),
        Variable<String>(id),
        Variable<String>(collection)
      ],
      updates: {pocketbaseRecords},
      updateKind: UpdateKind.update,
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [pocketbaseRecords, kvStore];
}

typedef $PocketbaseRecordsCreateCompanionBuilder = PocketbaseRecordsCompanion
    Function({
  Value<String> data,
  Value<int?> failedCount,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $PocketbaseRecordsUpdateCompanionBuilder = PocketbaseRecordsCompanion
    Function({
  Value<String> data,
  Value<int?> failedCount,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $PocketbaseRecordsFilterComposer
    extends Composer<_$CrdtDatabase, PocketbaseRecords> {
  $PocketbaseRecordsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionName => $composableBuilder(
      column: $table.collectionName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get created => $composableBuilder(
      column: $table.created, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updated => $composableBuilder(
      column: $table.updated, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nodeId => $composableBuilder(
      column: $table.nodeId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
          column: $table.hlc,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get modified =>
      $composableBuilder(
          column: $table.modified,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $PocketbaseRecordsOrderingComposer
    extends Composer<_$CrdtDatabase, PocketbaseRecords> {
  $PocketbaseRecordsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionId => $composableBuilder(
      column: $table.collectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionName => $composableBuilder(
      column: $table.collectionName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get created => $composableBuilder(
      column: $table.created, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updated => $composableBuilder(
      column: $table.updated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nodeId => $composableBuilder(
      column: $table.nodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hlc => $composableBuilder(
      column: $table.hlc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modified => $composableBuilder(
      column: $table.modified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $PocketbaseRecordsAnnotationComposer
    extends Composer<_$CrdtDatabase, PocketbaseRecords> {
  $PocketbaseRecordsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
      column: $table.collectionId, builder: (column) => column);

  GeneratedColumn<String> get collectionName => $composableBuilder(
      column: $table.collectionName, builder: (column) => column);

  GeneratedColumn<String> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<String> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Hlc, String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get failedCount => $composableBuilder(
      column: $table.failedCount, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $PocketbaseRecordsTableManager extends RootTableManager<
    _$CrdtDatabase,
    PocketbaseRecords,
    PocketbaseRecord,
    $PocketbaseRecordsFilterComposer,
    $PocketbaseRecordsOrderingComposer,
    $PocketbaseRecordsAnnotationComposer,
    $PocketbaseRecordsCreateCompanionBuilder,
    $PocketbaseRecordsUpdateCompanionBuilder,
    (
      PocketbaseRecord,
      BaseReferences<_$CrdtDatabase, PocketbaseRecords, PocketbaseRecord>
    ),
    PocketbaseRecord,
    PrefetchHooks Function()> {
  $PocketbaseRecordsTableManager(_$CrdtDatabase db, PocketbaseRecords table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PocketbaseRecordsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PocketbaseRecordsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PocketbaseRecordsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> data = const Value.absent(),
            Value<int?> failedCount = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PocketbaseRecordsCompanion(
            data: data,
            failedCount: failedCount,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> data = const Value.absent(),
            Value<int?> failedCount = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PocketbaseRecordsCompanion.insert(
            data: data,
            failedCount: failedCount,
            syncedAt: syncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $PocketbaseRecordsProcessedTableManager = ProcessedTableManager<
    _$CrdtDatabase,
    PocketbaseRecords,
    PocketbaseRecord,
    $PocketbaseRecordsFilterComposer,
    $PocketbaseRecordsOrderingComposer,
    $PocketbaseRecordsAnnotationComposer,
    $PocketbaseRecordsCreateCompanionBuilder,
    $PocketbaseRecordsUpdateCompanionBuilder,
    (
      PocketbaseRecord,
      BaseReferences<_$CrdtDatabase, PocketbaseRecords, PocketbaseRecord>
    ),
    PocketbaseRecord,
    PrefetchHooks Function()>;
typedef $KvStoreCreateCompanionBuilder = KvStoreCompanion Function({
  Value<String?> key,
  Value<String?> value,
  Value<int> rowid,
});
typedef $KvStoreUpdateCompanionBuilder = KvStoreCompanion Function({
  Value<String?> key,
  Value<String?> value,
  Value<int> rowid,
});

class $KvStoreFilterComposer extends Composer<_$CrdtDatabase, KvStore> {
  $KvStoreFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $KvStoreOrderingComposer extends Composer<_$CrdtDatabase, KvStore> {
  $KvStoreOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $KvStoreAnnotationComposer extends Composer<_$CrdtDatabase, KvStore> {
  $KvStoreAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $KvStoreTableManager extends RootTableManager<
    _$CrdtDatabase,
    KvStore,
    KvStoreData,
    $KvStoreFilterComposer,
    $KvStoreOrderingComposer,
    $KvStoreAnnotationComposer,
    $KvStoreCreateCompanionBuilder,
    $KvStoreUpdateCompanionBuilder,
    (KvStoreData, BaseReferences<_$CrdtDatabase, KvStore, KvStoreData>),
    KvStoreData,
    PrefetchHooks Function()> {
  $KvStoreTableManager(_$CrdtDatabase db, KvStore table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $KvStoreFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $KvStoreOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $KvStoreAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KvStoreCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KvStoreCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $KvStoreProcessedTableManager = ProcessedTableManager<
    _$CrdtDatabase,
    KvStore,
    KvStoreData,
    $KvStoreFilterComposer,
    $KvStoreOrderingComposer,
    $KvStoreAnnotationComposer,
    $KvStoreCreateCompanionBuilder,
    $KvStoreUpdateCompanionBuilder,
    (KvStoreData, BaseReferences<_$CrdtDatabase, KvStore, KvStoreData>),
    KvStoreData,
    PrefetchHooks Function()>;

class $CrdtDatabaseManager {
  final _$CrdtDatabase _db;
  $CrdtDatabaseManager(this._db);
  $PocketbaseRecordsTableManager get pocketbaseRecords =>
      $PocketbaseRecordsTableManager(_db, _db.pocketbaseRecords);
  $KvStoreTableManager get kvStore => $KvStoreTableManager(_db, _db.kvStore);
}

class GetLastModifiedResult {
  final PocketbaseRecord pocketbaseRecords;
  final Hlc? modified;
  GetLastModifiedResult({
    required this.pocketbaseRecords,
    this.modified,
  });
}

class GetLastModifiedOnlyNodeIdResult {
  final PocketbaseRecord pocketbaseRecords;
  final Hlc? modified;
  GetLastModifiedOnlyNodeIdResult({
    required this.pocketbaseRecords,
    this.modified,
  });
}

class GetLastModifiedExceptNodeIdResult {
  final PocketbaseRecord pocketbaseRecords;
  final Hlc? modified;
  GetLastModifiedExceptNodeIdResult({
    required this.pocketbaseRecords,
    this.modified,
  });
}
