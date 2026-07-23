// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BuildingsTable extends Buildings
    with TableInfo<$BuildingsTable, Building> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($BuildingsTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _estateSlugMeta = const VerificationMeta(
    'estateSlug',
  );
  @override
  late final GeneratedColumn<String> estateSlug = GeneratedColumn<String>(
    'estate_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gpsAccuracyMeta = const VerificationMeta(
    'gpsAccuracy',
  );
  @override
  late final GeneratedColumn<double> gpsAccuracy = GeneratedColumn<double>(
    'gps_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _floorsMeta = const VerificationMeta('floors');
  @override
  late final GeneratedColumn<int> floors = GeneratedColumn<int>(
    'floors',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterNotesMeta = const VerificationMeta(
    'waterNotes',
  );
  @override
  late final GeneratedColumn<String> waterNotes = GeneratedColumn<String>(
    'water_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _powerNotesMeta = const VerificationMeta(
    'powerNotes',
  );
  @override
  late final GeneratedColumn<String> powerNotes = GeneratedColumn<String>(
    'power_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _securityNotesMeta = const VerificationMeta(
    'securityNotes',
  );
  @override
  late final GeneratedColumn<String> securityNotes = GeneratedColumn<String>(
    'security_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _parkingMeta = const VerificationMeta(
    'parking',
  );
  @override
  late final GeneratedColumn<bool> parking = GeneratedColumn<bool>(
    'parking',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("parking" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _caretakerNameMeta = const VerificationMeta(
    'caretakerName',
  );
  @override
  late final GeneratedColumn<String> caretakerName = GeneratedColumn<String>(
    'caretaker_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _caretakerPhoneMeta = const VerificationMeta(
    'caretakerPhone',
  );
  @override
  late final GeneratedColumn<String> caretakerPhone = GeneratedColumn<String>(
    'caretaker_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    syncError,
    createdAt,
    estateSlug,
    name,
    lat,
    lng,
    gpsAccuracy,
    floors,
    waterNotes,
    powerNotes,
    securityNotes,
    parking,
    caretakerName,
    caretakerPhone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buildings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Building> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('estate_slug')) {
      context.handle(
        _estateSlugMeta,
        estateSlug.isAcceptableOrUnknown(data['estate_slug']!, _estateSlugMeta),
      );
    } else if (isInserting) {
      context.missing(_estateSlugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('gps_accuracy')) {
      context.handle(
        _gpsAccuracyMeta,
        gpsAccuracy.isAcceptableOrUnknown(
          data['gps_accuracy']!,
          _gpsAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('floors')) {
      context.handle(
        _floorsMeta,
        floors.isAcceptableOrUnknown(data['floors']!, _floorsMeta),
      );
    }
    if (data.containsKey('water_notes')) {
      context.handle(
        _waterNotesMeta,
        waterNotes.isAcceptableOrUnknown(data['water_notes']!, _waterNotesMeta),
      );
    }
    if (data.containsKey('power_notes')) {
      context.handle(
        _powerNotesMeta,
        powerNotes.isAcceptableOrUnknown(data['power_notes']!, _powerNotesMeta),
      );
    }
    if (data.containsKey('security_notes')) {
      context.handle(
        _securityNotesMeta,
        securityNotes.isAcceptableOrUnknown(
          data['security_notes']!,
          _securityNotesMeta,
        ),
      );
    }
    if (data.containsKey('parking')) {
      context.handle(
        _parkingMeta,
        parking.isAcceptableOrUnknown(data['parking']!, _parkingMeta),
      );
    }
    if (data.containsKey('caretaker_name')) {
      context.handle(
        _caretakerNameMeta,
        caretakerName.isAcceptableOrUnknown(
          data['caretaker_name']!,
          _caretakerNameMeta,
        ),
      );
    }
    if (data.containsKey('caretaker_phone')) {
      context.handle(
        _caretakerPhoneMeta,
        caretakerPhone.isAcceptableOrUnknown(
          data['caretaker_phone']!,
          _caretakerPhoneMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Building map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Building(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: $BuildingsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      estateSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estate_slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      gpsAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_accuracy'],
      ),
      floors: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floors'],
      ),
      waterNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}water_notes'],
      )!,
      powerNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}power_notes'],
      )!,
      securityNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}security_notes'],
      )!,
      parking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}parking'],
      )!,
      caretakerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caretaker_name'],
      )!,
      caretakerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caretaker_phone'],
      )!,
    );
  }

  @override
  $BuildingsTable createAlias(String alias) {
    return $BuildingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Building extends DataClass implements Insertable<Building> {
  final String id;
  final SyncStatus syncStatus;
  final String? syncError;
  final DateTime createdAt;
  final String estateSlug;
  final String name;
  final double lat;
  final double lng;
  final double? gpsAccuracy;
  final int? floors;
  final String waterNotes;
  final String powerNotes;
  final String securityNotes;
  final bool parking;
  final String caretakerName;
  final String caretakerPhone;
  const Building({
    required this.id,
    required this.syncStatus,
    this.syncError,
    required this.createdAt,
    required this.estateSlug,
    required this.name,
    required this.lat,
    required this.lng,
    this.gpsAccuracy,
    this.floors,
    required this.waterNotes,
    required this.powerNotes,
    required this.securityNotes,
    required this.parking,
    required this.caretakerName,
    required this.caretakerPhone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['sync_status'] = Variable<int>(
        $BuildingsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['estate_slug'] = Variable<String>(estateSlug);
    map['name'] = Variable<String>(name);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || gpsAccuracy != null) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy);
    }
    if (!nullToAbsent || floors != null) {
      map['floors'] = Variable<int>(floors);
    }
    map['water_notes'] = Variable<String>(waterNotes);
    map['power_notes'] = Variable<String>(powerNotes);
    map['security_notes'] = Variable<String>(securityNotes);
    map['parking'] = Variable<bool>(parking);
    map['caretaker_name'] = Variable<String>(caretakerName);
    map['caretaker_phone'] = Variable<String>(caretakerPhone);
    return map;
  }

  BuildingsCompanion toCompanion(bool nullToAbsent) {
    return BuildingsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      createdAt: Value(createdAt),
      estateSlug: Value(estateSlug),
      name: Value(name),
      lat: Value(lat),
      lng: Value(lng),
      gpsAccuracy: gpsAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracy),
      floors: floors == null && nullToAbsent
          ? const Value.absent()
          : Value(floors),
      waterNotes: Value(waterNotes),
      powerNotes: Value(powerNotes),
      securityNotes: Value(securityNotes),
      parking: Value(parking),
      caretakerName: Value(caretakerName),
      caretakerPhone: Value(caretakerPhone),
    );
  }

  factory Building.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Building(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: $BuildingsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      estateSlug: serializer.fromJson<String>(json['estateSlug']),
      name: serializer.fromJson<String>(json['name']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      gpsAccuracy: serializer.fromJson<double?>(json['gpsAccuracy']),
      floors: serializer.fromJson<int?>(json['floors']),
      waterNotes: serializer.fromJson<String>(json['waterNotes']),
      powerNotes: serializer.fromJson<String>(json['powerNotes']),
      securityNotes: serializer.fromJson<String>(json['securityNotes']),
      parking: serializer.fromJson<bool>(json['parking']),
      caretakerName: serializer.fromJson<String>(json['caretakerName']),
      caretakerPhone: serializer.fromJson<String>(json['caretakerPhone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<int>(
        $BuildingsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'estateSlug': serializer.toJson<String>(estateSlug),
      'name': serializer.toJson<String>(name),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'gpsAccuracy': serializer.toJson<double?>(gpsAccuracy),
      'floors': serializer.toJson<int?>(floors),
      'waterNotes': serializer.toJson<String>(waterNotes),
      'powerNotes': serializer.toJson<String>(powerNotes),
      'securityNotes': serializer.toJson<String>(securityNotes),
      'parking': serializer.toJson<bool>(parking),
      'caretakerName': serializer.toJson<String>(caretakerName),
      'caretakerPhone': serializer.toJson<String>(caretakerPhone),
    };
  }

  Building copyWith({
    String? id,
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    DateTime? createdAt,
    String? estateSlug,
    String? name,
    double? lat,
    double? lng,
    Value<double?> gpsAccuracy = const Value.absent(),
    Value<int?> floors = const Value.absent(),
    String? waterNotes,
    String? powerNotes,
    String? securityNotes,
    bool? parking,
    String? caretakerName,
    String? caretakerPhone,
  }) => Building(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    createdAt: createdAt ?? this.createdAt,
    estateSlug: estateSlug ?? this.estateSlug,
    name: name ?? this.name,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    gpsAccuracy: gpsAccuracy.present ? gpsAccuracy.value : this.gpsAccuracy,
    floors: floors.present ? floors.value : this.floors,
    waterNotes: waterNotes ?? this.waterNotes,
    powerNotes: powerNotes ?? this.powerNotes,
    securityNotes: securityNotes ?? this.securityNotes,
    parking: parking ?? this.parking,
    caretakerName: caretakerName ?? this.caretakerName,
    caretakerPhone: caretakerPhone ?? this.caretakerPhone,
  );
  Building copyWithCompanion(BuildingsCompanion data) {
    return Building(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      estateSlug: data.estateSlug.present
          ? data.estateSlug.value
          : this.estateSlug,
      name: data.name.present ? data.name.value : this.name,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      gpsAccuracy: data.gpsAccuracy.present
          ? data.gpsAccuracy.value
          : this.gpsAccuracy,
      floors: data.floors.present ? data.floors.value : this.floors,
      waterNotes: data.waterNotes.present
          ? data.waterNotes.value
          : this.waterNotes,
      powerNotes: data.powerNotes.present
          ? data.powerNotes.value
          : this.powerNotes,
      securityNotes: data.securityNotes.present
          ? data.securityNotes.value
          : this.securityNotes,
      parking: data.parking.present ? data.parking.value : this.parking,
      caretakerName: data.caretakerName.present
          ? data.caretakerName.value
          : this.caretakerName,
      caretakerPhone: data.caretakerPhone.present
          ? data.caretakerPhone.value
          : this.caretakerPhone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Building(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('estateSlug: $estateSlug, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('floors: $floors, ')
          ..write('waterNotes: $waterNotes, ')
          ..write('powerNotes: $powerNotes, ')
          ..write('securityNotes: $securityNotes, ')
          ..write('parking: $parking, ')
          ..write('caretakerName: $caretakerName, ')
          ..write('caretakerPhone: $caretakerPhone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    syncError,
    createdAt,
    estateSlug,
    name,
    lat,
    lng,
    gpsAccuracy,
    floors,
    waterNotes,
    powerNotes,
    securityNotes,
    parking,
    caretakerName,
    caretakerPhone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Building &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.createdAt == this.createdAt &&
          other.estateSlug == this.estateSlug &&
          other.name == this.name &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.gpsAccuracy == this.gpsAccuracy &&
          other.floors == this.floors &&
          other.waterNotes == this.waterNotes &&
          other.powerNotes == this.powerNotes &&
          other.securityNotes == this.securityNotes &&
          other.parking == this.parking &&
          other.caretakerName == this.caretakerName &&
          other.caretakerPhone == this.caretakerPhone);
}

class BuildingsCompanion extends UpdateCompanion<Building> {
  final Value<String> id;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime> createdAt;
  final Value<String> estateSlug;
  final Value<String> name;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double?> gpsAccuracy;
  final Value<int?> floors;
  final Value<String> waterNotes;
  final Value<String> powerNotes;
  final Value<String> securityNotes;
  final Value<bool> parking;
  final Value<String> caretakerName;
  final Value<String> caretakerPhone;
  final Value<int> rowid;
  const BuildingsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.estateSlug = const Value.absent(),
    this.name = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.floors = const Value.absent(),
    this.waterNotes = const Value.absent(),
    this.powerNotes = const Value.absent(),
    this.securityNotes = const Value.absent(),
    this.parking = const Value.absent(),
    this.caretakerName = const Value.absent(),
    this.caretakerPhone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuildingsCompanion.insert({
    required String id,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String estateSlug,
    this.name = const Value.absent(),
    required double lat,
    required double lng,
    this.gpsAccuracy = const Value.absent(),
    this.floors = const Value.absent(),
    this.waterNotes = const Value.absent(),
    this.powerNotes = const Value.absent(),
    this.securityNotes = const Value.absent(),
    this.parking = const Value.absent(),
    this.caretakerName = const Value.absent(),
    this.caretakerPhone = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       estateSlug = Value(estateSlug),
       lat = Value(lat),
       lng = Value(lng);
  static Insertable<Building> custom({
    Expression<String>? id,
    Expression<int>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? createdAt,
    Expression<String>? estateSlug,
    Expression<String>? name,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? gpsAccuracy,
    Expression<int>? floors,
    Expression<String>? waterNotes,
    Expression<String>? powerNotes,
    Expression<String>? securityNotes,
    Expression<bool>? parking,
    Expression<String>? caretakerName,
    Expression<String>? caretakerPhone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (createdAt != null) 'created_at': createdAt,
      if (estateSlug != null) 'estate_slug': estateSlug,
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
      if (floors != null) 'floors': floors,
      if (waterNotes != null) 'water_notes': waterNotes,
      if (powerNotes != null) 'power_notes': powerNotes,
      if (securityNotes != null) 'security_notes': securityNotes,
      if (parking != null) 'parking': parking,
      if (caretakerName != null) 'caretaker_name': caretakerName,
      if (caretakerPhone != null) 'caretaker_phone': caretakerPhone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuildingsCompanion copyWith({
    Value<String>? id,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<DateTime>? createdAt,
    Value<String>? estateSlug,
    Value<String>? name,
    Value<double>? lat,
    Value<double>? lng,
    Value<double?>? gpsAccuracy,
    Value<int?>? floors,
    Value<String>? waterNotes,
    Value<String>? powerNotes,
    Value<String>? securityNotes,
    Value<bool>? parking,
    Value<String>? caretakerName,
    Value<String>? caretakerPhone,
    Value<int>? rowid,
  }) {
    return BuildingsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      createdAt: createdAt ?? this.createdAt,
      estateSlug: estateSlug ?? this.estateSlug,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      floors: floors ?? this.floors,
      waterNotes: waterNotes ?? this.waterNotes,
      powerNotes: powerNotes ?? this.powerNotes,
      securityNotes: securityNotes ?? this.securityNotes,
      parking: parking ?? this.parking,
      caretakerName: caretakerName ?? this.caretakerName,
      caretakerPhone: caretakerPhone ?? this.caretakerPhone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $BuildingsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (estateSlug.present) {
      map['estate_slug'] = Variable<String>(estateSlug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (gpsAccuracy.present) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy.value);
    }
    if (floors.present) {
      map['floors'] = Variable<int>(floors.value);
    }
    if (waterNotes.present) {
      map['water_notes'] = Variable<String>(waterNotes.value);
    }
    if (powerNotes.present) {
      map['power_notes'] = Variable<String>(powerNotes.value);
    }
    if (securityNotes.present) {
      map['security_notes'] = Variable<String>(securityNotes.value);
    }
    if (parking.present) {
      map['parking'] = Variable<bool>(parking.value);
    }
    if (caretakerName.present) {
      map['caretaker_name'] = Variable<String>(caretakerName.value);
    }
    if (caretakerPhone.present) {
      map['caretaker_phone'] = Variable<String>(caretakerPhone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('estateSlug: $estateSlug, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('floors: $floors, ')
          ..write('waterNotes: $waterNotes, ')
          ..write('powerNotes: $powerNotes, ')
          ..write('securityNotes: $securityNotes, ')
          ..write('parking: $parking, ')
          ..write('caretakerName: $caretakerName, ')
          ..write('caretakerPhone: $caretakerPhone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitTypesTable extends UnitTypes
    with TableInfo<$UnitTypesTable, UnitType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($UnitTypesTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _buildingIdMeta = const VerificationMeta(
    'buildingId',
  );
  @override
  late final GeneratedColumn<String> buildingId = GeneratedColumn<String>(
    'building_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentKesMeta = const VerificationMeta(
    'rentKes',
  );
  @override
  late final GeneratedColumn<int> rentKes = GeneratedColumn<int>(
    'rent_kes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depositKesMeta = const VerificationMeta(
    'depositKes',
  );
  @override
  late final GeneratedColumn<int> depositKes = GeneratedColumn<int>(
    'deposit_kes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amenitiesMeta = const VerificationMeta(
    'amenities',
  );
  @override
  late final GeneratedColumn<String> amenities = GeneratedColumn<String>(
    'amenities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    syncError,
    createdAt,
    buildingId,
    kind,
    rentKes,
    depositKes,
    amenities,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('building_id')) {
      context.handle(
        _buildingIdMeta,
        buildingId.isAcceptableOrUnknown(data['building_id']!, _buildingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('rent_kes')) {
      context.handle(
        _rentKesMeta,
        rentKes.isAcceptableOrUnknown(data['rent_kes']!, _rentKesMeta),
      );
    } else if (isInserting) {
      context.missing(_rentKesMeta);
    }
    if (data.containsKey('deposit_kes')) {
      context.handle(
        _depositKesMeta,
        depositKes.isAcceptableOrUnknown(data['deposit_kes']!, _depositKesMeta),
      );
    }
    if (data.containsKey('amenities')) {
      context.handle(
        _amenitiesMeta,
        amenities.isAcceptableOrUnknown(data['amenities']!, _amenitiesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: $UnitTypesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      buildingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      rentKes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rent_kes'],
      )!,
      depositKes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposit_kes'],
      ),
      amenities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amenities'],
      )!,
    );
  }

  @override
  $UnitTypesTable createAlias(String alias) {
    return $UnitTypesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class UnitType extends DataClass implements Insertable<UnitType> {
  final String id;
  final SyncStatus syncStatus;
  final String? syncError;
  final DateTime createdAt;
  final String buildingId;
  final String kind;
  final int rentKes;
  final int? depositKes;
  final String amenities;
  const UnitType({
    required this.id,
    required this.syncStatus,
    this.syncError,
    required this.createdAt,
    required this.buildingId,
    required this.kind,
    required this.rentKes,
    this.depositKes,
    required this.amenities,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['sync_status'] = Variable<int>(
        $UnitTypesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['building_id'] = Variable<String>(buildingId);
    map['kind'] = Variable<String>(kind);
    map['rent_kes'] = Variable<int>(rentKes);
    if (!nullToAbsent || depositKes != null) {
      map['deposit_kes'] = Variable<int>(depositKes);
    }
    map['amenities'] = Variable<String>(amenities);
    return map;
  }

  UnitTypesCompanion toCompanion(bool nullToAbsent) {
    return UnitTypesCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      createdAt: Value(createdAt),
      buildingId: Value(buildingId),
      kind: Value(kind),
      rentKes: Value(rentKes),
      depositKes: depositKes == null && nullToAbsent
          ? const Value.absent()
          : Value(depositKes),
      amenities: Value(amenities),
    );
  }

  factory UnitType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitType(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: $UnitTypesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      buildingId: serializer.fromJson<String>(json['buildingId']),
      kind: serializer.fromJson<String>(json['kind']),
      rentKes: serializer.fromJson<int>(json['rentKes']),
      depositKes: serializer.fromJson<int?>(json['depositKes']),
      amenities: serializer.fromJson<String>(json['amenities']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<int>(
        $UnitTypesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'buildingId': serializer.toJson<String>(buildingId),
      'kind': serializer.toJson<String>(kind),
      'rentKes': serializer.toJson<int>(rentKes),
      'depositKes': serializer.toJson<int?>(depositKes),
      'amenities': serializer.toJson<String>(amenities),
    };
  }

  UnitType copyWith({
    String? id,
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    DateTime? createdAt,
    String? buildingId,
    String? kind,
    int? rentKes,
    Value<int?> depositKes = const Value.absent(),
    String? amenities,
  }) => UnitType(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    createdAt: createdAt ?? this.createdAt,
    buildingId: buildingId ?? this.buildingId,
    kind: kind ?? this.kind,
    rentKes: rentKes ?? this.rentKes,
    depositKes: depositKes.present ? depositKes.value : this.depositKes,
    amenities: amenities ?? this.amenities,
  );
  UnitType copyWithCompanion(UnitTypesCompanion data) {
    return UnitType(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      buildingId: data.buildingId.present
          ? data.buildingId.value
          : this.buildingId,
      kind: data.kind.present ? data.kind.value : this.kind,
      rentKes: data.rentKes.present ? data.rentKes.value : this.rentKes,
      depositKes: data.depositKes.present
          ? data.depositKes.value
          : this.depositKes,
      amenities: data.amenities.present ? data.amenities.value : this.amenities,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitType(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('buildingId: $buildingId, ')
          ..write('kind: $kind, ')
          ..write('rentKes: $rentKes, ')
          ..write('depositKes: $depositKes, ')
          ..write('amenities: $amenities')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    syncError,
    createdAt,
    buildingId,
    kind,
    rentKes,
    depositKes,
    amenities,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitType &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.createdAt == this.createdAt &&
          other.buildingId == this.buildingId &&
          other.kind == this.kind &&
          other.rentKes == this.rentKes &&
          other.depositKes == this.depositKes &&
          other.amenities == this.amenities);
}

class UnitTypesCompanion extends UpdateCompanion<UnitType> {
  final Value<String> id;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime> createdAt;
  final Value<String> buildingId;
  final Value<String> kind;
  final Value<int> rentKes;
  final Value<int?> depositKes;
  final Value<String> amenities;
  final Value<int> rowid;
  const UnitTypesCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.kind = const Value.absent(),
    this.rentKes = const Value.absent(),
    this.depositKes = const Value.absent(),
    this.amenities = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitTypesCompanion.insert({
    required String id,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String buildingId,
    required String kind,
    required int rentKes,
    this.depositKes = const Value.absent(),
    this.amenities = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       buildingId = Value(buildingId),
       kind = Value(kind),
       rentKes = Value(rentKes);
  static Insertable<UnitType> custom({
    Expression<String>? id,
    Expression<int>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? createdAt,
    Expression<String>? buildingId,
    Expression<String>? kind,
    Expression<int>? rentKes,
    Expression<int>? depositKes,
    Expression<String>? amenities,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (createdAt != null) 'created_at': createdAt,
      if (buildingId != null) 'building_id': buildingId,
      if (kind != null) 'kind': kind,
      if (rentKes != null) 'rent_kes': rentKes,
      if (depositKes != null) 'deposit_kes': depositKes,
      if (amenities != null) 'amenities': amenities,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitTypesCompanion copyWith({
    Value<String>? id,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<DateTime>? createdAt,
    Value<String>? buildingId,
    Value<String>? kind,
    Value<int>? rentKes,
    Value<int?>? depositKes,
    Value<String>? amenities,
    Value<int>? rowid,
  }) {
    return UnitTypesCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      createdAt: createdAt ?? this.createdAt,
      buildingId: buildingId ?? this.buildingId,
      kind: kind ?? this.kind,
      rentKes: rentKes ?? this.rentKes,
      depositKes: depositKes ?? this.depositKes,
      amenities: amenities ?? this.amenities,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $UnitTypesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<String>(buildingId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (rentKes.present) {
      map['rent_kes'] = Variable<int>(rentKes.value);
    }
    if (depositKes.present) {
      map['deposit_kes'] = Variable<int>(depositKes.value);
    }
    if (amenities.present) {
      map['amenities'] = Variable<String>(amenities.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitTypesCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('buildingId: $buildingId, ')
          ..write('kind: $kind, ')
          ..write('rentKes: $rentKes, ')
          ..write('depositKes: $depositKes, ')
          ..write('amenities: $amenities, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VacancySnapshotsTable extends VacancySnapshots
    with TableInfo<$VacancySnapshotsTable, VacancySnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VacancySnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($VacancySnapshotsTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _unitTypeIdMeta = const VerificationMeta(
    'unitTypeId',
  );
  @override
  late final GeneratedColumn<String> unitTypeId = GeneratedColumn<String>(
    'unit_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vacantCountMeta = const VerificationMeta(
    'vacantCount',
  );
  @override
  late final GeneratedColumn<int> vacantCount = GeneratedColumn<int>(
    'vacant_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AGENT_VISIT'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    syncError,
    createdAt,
    unitTypeId,
    vacantCount,
    verifiedAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vacancy_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<VacancySnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('unit_type_id')) {
      context.handle(
        _unitTypeIdMeta,
        unitTypeId.isAcceptableOrUnknown(
          data['unit_type_id']!,
          _unitTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitTypeIdMeta);
    }
    if (data.containsKey('vacant_count')) {
      context.handle(
        _vacantCountMeta,
        vacantCount.isAcceptableOrUnknown(
          data['vacant_count']!,
          _vacantCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vacantCountMeta);
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_verifiedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VacancySnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VacancySnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: $VacancySnapshotsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      unitTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type_id'],
      )!,
      vacantCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vacant_count'],
      )!,
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $VacancySnapshotsTable createAlias(String alias) {
    return $VacancySnapshotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class VacancySnapshot extends DataClass implements Insertable<VacancySnapshot> {
  final String id;
  final SyncStatus syncStatus;
  final String? syncError;
  final DateTime createdAt;
  final String unitTypeId;
  final int vacantCount;
  final DateTime verifiedAt;
  final String source;
  const VacancySnapshot({
    required this.id,
    required this.syncStatus,
    this.syncError,
    required this.createdAt,
    required this.unitTypeId,
    required this.vacantCount,
    required this.verifiedAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['sync_status'] = Variable<int>(
        $VacancySnapshotsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['unit_type_id'] = Variable<String>(unitTypeId);
    map['vacant_count'] = Variable<int>(vacantCount);
    map['verified_at'] = Variable<DateTime>(verifiedAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  VacancySnapshotsCompanion toCompanion(bool nullToAbsent) {
    return VacancySnapshotsCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      createdAt: Value(createdAt),
      unitTypeId: Value(unitTypeId),
      vacantCount: Value(vacantCount),
      verifiedAt: Value(verifiedAt),
      source: Value(source),
    );
  }

  factory VacancySnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VacancySnapshot(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: $VacancySnapshotsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      unitTypeId: serializer.fromJson<String>(json['unitTypeId']),
      vacantCount: serializer.fromJson<int>(json['vacantCount']),
      verifiedAt: serializer.fromJson<DateTime>(json['verifiedAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<int>(
        $VacancySnapshotsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'unitTypeId': serializer.toJson<String>(unitTypeId),
      'vacantCount': serializer.toJson<int>(vacantCount),
      'verifiedAt': serializer.toJson<DateTime>(verifiedAt),
      'source': serializer.toJson<String>(source),
    };
  }

  VacancySnapshot copyWith({
    String? id,
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    DateTime? createdAt,
    String? unitTypeId,
    int? vacantCount,
    DateTime? verifiedAt,
    String? source,
  }) => VacancySnapshot(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    createdAt: createdAt ?? this.createdAt,
    unitTypeId: unitTypeId ?? this.unitTypeId,
    vacantCount: vacantCount ?? this.vacantCount,
    verifiedAt: verifiedAt ?? this.verifiedAt,
    source: source ?? this.source,
  );
  VacancySnapshot copyWithCompanion(VacancySnapshotsCompanion data) {
    return VacancySnapshot(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      unitTypeId: data.unitTypeId.present
          ? data.unitTypeId.value
          : this.unitTypeId,
      vacantCount: data.vacantCount.present
          ? data.vacantCount.value
          : this.vacantCount,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VacancySnapshot(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('unitTypeId: $unitTypeId, ')
          ..write('vacantCount: $vacantCount, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    syncError,
    createdAt,
    unitTypeId,
    vacantCount,
    verifiedAt,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VacancySnapshot &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.createdAt == this.createdAt &&
          other.unitTypeId == this.unitTypeId &&
          other.vacantCount == this.vacantCount &&
          other.verifiedAt == this.verifiedAt &&
          other.source == this.source);
}

class VacancySnapshotsCompanion extends UpdateCompanion<VacancySnapshot> {
  final Value<String> id;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime> createdAt;
  final Value<String> unitTypeId;
  final Value<int> vacantCount;
  final Value<DateTime> verifiedAt;
  final Value<String> source;
  final Value<int> rowid;
  const VacancySnapshotsCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.unitTypeId = const Value.absent(),
    this.vacantCount = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VacancySnapshotsCompanion.insert({
    required String id,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String unitTypeId,
    required int vacantCount,
    required DateTime verifiedAt,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unitTypeId = Value(unitTypeId),
       vacantCount = Value(vacantCount),
       verifiedAt = Value(verifiedAt);
  static Insertable<VacancySnapshot> custom({
    Expression<String>? id,
    Expression<int>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? createdAt,
    Expression<String>? unitTypeId,
    Expression<int>? vacantCount,
    Expression<DateTime>? verifiedAt,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (createdAt != null) 'created_at': createdAt,
      if (unitTypeId != null) 'unit_type_id': unitTypeId,
      if (vacantCount != null) 'vacant_count': vacantCount,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VacancySnapshotsCompanion copyWith({
    Value<String>? id,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<DateTime>? createdAt,
    Value<String>? unitTypeId,
    Value<int>? vacantCount,
    Value<DateTime>? verifiedAt,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return VacancySnapshotsCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      createdAt: createdAt ?? this.createdAt,
      unitTypeId: unitTypeId ?? this.unitTypeId,
      vacantCount: vacantCount ?? this.vacantCount,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $VacancySnapshotsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (unitTypeId.present) {
      map['unit_type_id'] = Variable<String>(unitTypeId.value);
    }
    if (vacantCount.present) {
      map['vacant_count'] = Variable<int>(vacantCount.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VacancySnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('unitTypeId: $unitTypeId, ')
          ..write('vacantCount: $vacantCount, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($PhotosTable.$convertersyncStatus);
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _buildingIdMeta = const VerificationMeta(
    'buildingId',
  );
  @override
  late final GeneratedColumn<String> buildingId = GeneratedColumn<String>(
    'building_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitTypeIdMeta = const VerificationMeta(
    'unitTypeId',
  );
  @override
  late final GeneratedColumn<String> unitTypeId = GeneratedColumn<String>(
    'unit_type_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storageKeyMeta = const VerificationMeta(
    'storageKey',
  );
  @override
  late final GeneratedColumn<String> storageKey = GeneratedColumn<String>(
    'storage_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncStatus,
    syncError,
    createdAt,
    buildingId,
    unitTypeId,
    localPath,
    storageKey,
    uploaded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('building_id')) {
      context.handle(
        _buildingIdMeta,
        buildingId.isAcceptableOrUnknown(data['building_id']!, _buildingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('unit_type_id')) {
      context.handle(
        _unitTypeIdMeta,
        unitTypeId.isAcceptableOrUnknown(
          data['unit_type_id']!,
          _unitTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('storage_key')) {
      context.handle(
        _storageKeyMeta,
        storageKey.isAcceptableOrUnknown(data['storage_key']!, _storageKeyMeta),
      );
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      syncStatus: $PhotosTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      buildingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_id'],
      )!,
      unitTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type_id'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      storageKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_key'],
      ),
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final SyncStatus syncStatus;
  final String? syncError;
  final DateTime createdAt;
  final String buildingId;
  final String? unitTypeId;
  final String localPath;
  final String? storageKey;
  final bool uploaded;
  const Photo({
    required this.id,
    required this.syncStatus,
    this.syncError,
    required this.createdAt,
    required this.buildingId,
    this.unitTypeId,
    required this.localPath,
    this.storageKey,
    required this.uploaded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['sync_status'] = Variable<int>(
        $PhotosTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['building_id'] = Variable<String>(buildingId);
    if (!nullToAbsent || unitTypeId != null) {
      map['unit_type_id'] = Variable<String>(unitTypeId);
    }
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || storageKey != null) {
      map['storage_key'] = Variable<String>(storageKey);
    }
    map['uploaded'] = Variable<bool>(uploaded);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      createdAt: Value(createdAt),
      buildingId: Value(buildingId),
      unitTypeId: unitTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitTypeId),
      localPath: Value(localPath),
      storageKey: storageKey == null && nullToAbsent
          ? const Value.absent()
          : Value(storageKey),
      uploaded: Value(uploaded),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      syncStatus: $PhotosTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      syncError: serializer.fromJson<String?>(json['syncError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      buildingId: serializer.fromJson<String>(json['buildingId']),
      unitTypeId: serializer.fromJson<String?>(json['unitTypeId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      storageKey: serializer.fromJson<String?>(json['storageKey']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'syncStatus': serializer.toJson<int>(
        $PhotosTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'syncError': serializer.toJson<String?>(syncError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'buildingId': serializer.toJson<String>(buildingId),
      'unitTypeId': serializer.toJson<String?>(unitTypeId),
      'localPath': serializer.toJson<String>(localPath),
      'storageKey': serializer.toJson<String?>(storageKey),
      'uploaded': serializer.toJson<bool>(uploaded),
    };
  }

  Photo copyWith({
    String? id,
    SyncStatus? syncStatus,
    Value<String?> syncError = const Value.absent(),
    DateTime? createdAt,
    String? buildingId,
    Value<String?> unitTypeId = const Value.absent(),
    String? localPath,
    Value<String?> storageKey = const Value.absent(),
    bool? uploaded,
  }) => Photo(
    id: id ?? this.id,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    createdAt: createdAt ?? this.createdAt,
    buildingId: buildingId ?? this.buildingId,
    unitTypeId: unitTypeId.present ? unitTypeId.value : this.unitTypeId,
    localPath: localPath ?? this.localPath,
    storageKey: storageKey.present ? storageKey.value : this.storageKey,
    uploaded: uploaded ?? this.uploaded,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      buildingId: data.buildingId.present
          ? data.buildingId.value
          : this.buildingId,
      unitTypeId: data.unitTypeId.present
          ? data.unitTypeId.value
          : this.unitTypeId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      storageKey: data.storageKey.present
          ? data.storageKey.value
          : this.storageKey,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('buildingId: $buildingId, ')
          ..write('unitTypeId: $unitTypeId, ')
          ..write('localPath: $localPath, ')
          ..write('storageKey: $storageKey, ')
          ..write('uploaded: $uploaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncStatus,
    syncError,
    createdAt,
    buildingId,
    unitTypeId,
    localPath,
    storageKey,
    uploaded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.createdAt == this.createdAt &&
          other.buildingId == this.buildingId &&
          other.unitTypeId == this.unitTypeId &&
          other.localPath == this.localPath &&
          other.storageKey == this.storageKey &&
          other.uploaded == this.uploaded);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<SyncStatus> syncStatus;
  final Value<String?> syncError;
  final Value<DateTime> createdAt;
  final Value<String> buildingId;
  final Value<String?> unitTypeId;
  final Value<String> localPath;
  final Value<String?> storageKey;
  final Value<bool> uploaded;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.unitTypeId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.storageKey = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String buildingId,
    this.unitTypeId = const Value.absent(),
    required String localPath,
    this.storageKey = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       buildingId = Value(buildingId),
       localPath = Value(localPath);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<int>? syncStatus,
    Expression<String>? syncError,
    Expression<DateTime>? createdAt,
    Expression<String>? buildingId,
    Expression<String>? unitTypeId,
    Expression<String>? localPath,
    Expression<String>? storageKey,
    Expression<bool>? uploaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (createdAt != null) 'created_at': createdAt,
      if (buildingId != null) 'building_id': buildingId,
      if (unitTypeId != null) 'unit_type_id': unitTypeId,
      if (localPath != null) 'local_path': localPath,
      if (storageKey != null) 'storage_key': storageKey,
      if (uploaded != null) 'uploaded': uploaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<SyncStatus>? syncStatus,
    Value<String?>? syncError,
    Value<DateTime>? createdAt,
    Value<String>? buildingId,
    Value<String?>? unitTypeId,
    Value<String>? localPath,
    Value<String?>? storageKey,
    Value<bool>? uploaded,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      createdAt: createdAt ?? this.createdAt,
      buildingId: buildingId ?? this.buildingId,
      unitTypeId: unitTypeId ?? this.unitTypeId,
      localPath: localPath ?? this.localPath,
      storageKey: storageKey ?? this.storageKey,
      uploaded: uploaded ?? this.uploaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $PhotosTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<String>(buildingId.value);
    }
    if (unitTypeId.present) {
      map['unit_type_id'] = Variable<String>(unitTypeId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (storageKey.present) {
      map['storage_key'] = Variable<String>(storageKey.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('createdAt: $createdAt, ')
          ..write('buildingId: $buildingId, ')
          ..write('unitTypeId: $unitTypeId, ')
          ..write('localPath: $localPath, ')
          ..write('storageKey: $storageKey, ')
          ..write('uploaded: $uploaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BuildingsTable buildings = $BuildingsTable(this);
  late final $UnitTypesTable unitTypes = $UnitTypesTable(this);
  late final $VacancySnapshotsTable vacancySnapshots = $VacancySnapshotsTable(
    this,
  );
  late final $PhotosTable photos = $PhotosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    buildings,
    unitTypes,
    vacancySnapshots,
    photos,
  ];
}

typedef $$BuildingsTableCreateCompanionBuilder =
    BuildingsCompanion Function({
      required String id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      required String estateSlug,
      Value<String> name,
      required double lat,
      required double lng,
      Value<double?> gpsAccuracy,
      Value<int?> floors,
      Value<String> waterNotes,
      Value<String> powerNotes,
      Value<String> securityNotes,
      Value<bool> parking,
      Value<String> caretakerName,
      Value<String> caretakerPhone,
      Value<int> rowid,
    });
typedef $$BuildingsTableUpdateCompanionBuilder =
    BuildingsCompanion Function({
      Value<String> id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      Value<String> estateSlug,
      Value<String> name,
      Value<double> lat,
      Value<double> lng,
      Value<double?> gpsAccuracy,
      Value<int?> floors,
      Value<String> waterNotes,
      Value<String> powerNotes,
      Value<String> securityNotes,
      Value<bool> parking,
      Value<String> caretakerName,
      Value<String> caretakerPhone,
      Value<int> rowid,
    });

class $$BuildingsTableFilterComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estateSlug => $composableBuilder(
    column: $table.estateSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floors => $composableBuilder(
    column: $table.floors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get waterNotes => $composableBuilder(
    column: $table.waterNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get powerNotes => $composableBuilder(
    column: $table.powerNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get securityNotes => $composableBuilder(
    column: $table.securityNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get parking => $composableBuilder(
    column: $table.parking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caretakerName => $composableBuilder(
    column: $table.caretakerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caretakerPhone => $composableBuilder(
    column: $table.caretakerPhone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BuildingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estateSlug => $composableBuilder(
    column: $table.estateSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floors => $composableBuilder(
    column: $table.floors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get waterNotes => $composableBuilder(
    column: $table.waterNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get powerNotes => $composableBuilder(
    column: $table.powerNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get securityNotes => $composableBuilder(
    column: $table.securityNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get parking => $composableBuilder(
    column: $table.parking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caretakerName => $composableBuilder(
    column: $table.caretakerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caretakerPhone => $composableBuilder(
    column: $table.caretakerPhone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuildingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get estateSlug => $composableBuilder(
    column: $table.estateSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get gpsAccuracy => $composableBuilder(
    column: $table.gpsAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get floors =>
      $composableBuilder(column: $table.floors, builder: (column) => column);

  GeneratedColumn<String> get waterNotes => $composableBuilder(
    column: $table.waterNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get powerNotes => $composableBuilder(
    column: $table.powerNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get securityNotes => $composableBuilder(
    column: $table.securityNotes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get parking =>
      $composableBuilder(column: $table.parking, builder: (column) => column);

  GeneratedColumn<String> get caretakerName => $composableBuilder(
    column: $table.caretakerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caretakerPhone => $composableBuilder(
    column: $table.caretakerPhone,
    builder: (column) => column,
  );
}

class $$BuildingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuildingsTable,
          Building,
          $$BuildingsTableFilterComposer,
          $$BuildingsTableOrderingComposer,
          $$BuildingsTableAnnotationComposer,
          $$BuildingsTableCreateCompanionBuilder,
          $$BuildingsTableUpdateCompanionBuilder,
          (Building, BaseReferences<_$AppDatabase, $BuildingsTable, Building>),
          Building,
          PrefetchHooks Function()
        > {
  $$BuildingsTableTableManager(_$AppDatabase db, $BuildingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> estateSlug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<double?> gpsAccuracy = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                Value<String> waterNotes = const Value.absent(),
                Value<String> powerNotes = const Value.absent(),
                Value<String> securityNotes = const Value.absent(),
                Value<bool> parking = const Value.absent(),
                Value<String> caretakerName = const Value.absent(),
                Value<String> caretakerPhone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                estateSlug: estateSlug,
                name: name,
                lat: lat,
                lng: lng,
                gpsAccuracy: gpsAccuracy,
                floors: floors,
                waterNotes: waterNotes,
                powerNotes: powerNotes,
                securityNotes: securityNotes,
                parking: parking,
                caretakerName: caretakerName,
                caretakerPhone: caretakerPhone,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String estateSlug,
                Value<String> name = const Value.absent(),
                required double lat,
                required double lng,
                Value<double?> gpsAccuracy = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                Value<String> waterNotes = const Value.absent(),
                Value<String> powerNotes = const Value.absent(),
                Value<String> securityNotes = const Value.absent(),
                Value<bool> parking = const Value.absent(),
                Value<String> caretakerName = const Value.absent(),
                Value<String> caretakerPhone = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                estateSlug: estateSlug,
                name: name,
                lat: lat,
                lng: lng,
                gpsAccuracy: gpsAccuracy,
                floors: floors,
                waterNotes: waterNotes,
                powerNotes: powerNotes,
                securityNotes: securityNotes,
                parking: parking,
                caretakerName: caretakerName,
                caretakerPhone: caretakerPhone,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BuildingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuildingsTable,
      Building,
      $$BuildingsTableFilterComposer,
      $$BuildingsTableOrderingComposer,
      $$BuildingsTableAnnotationComposer,
      $$BuildingsTableCreateCompanionBuilder,
      $$BuildingsTableUpdateCompanionBuilder,
      (Building, BaseReferences<_$AppDatabase, $BuildingsTable, Building>),
      Building,
      PrefetchHooks Function()
    >;
typedef $$UnitTypesTableCreateCompanionBuilder =
    UnitTypesCompanion Function({
      required String id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      required String buildingId,
      required String kind,
      required int rentKes,
      Value<int?> depositKes,
      Value<String> amenities,
      Value<int> rowid,
    });
typedef $$UnitTypesTableUpdateCompanionBuilder =
    UnitTypesCompanion Function({
      Value<String> id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      Value<String> buildingId,
      Value<String> kind,
      Value<int> rentKes,
      Value<int?> depositKes,
      Value<String> amenities,
      Value<int> rowid,
    });

class $$UnitTypesTableFilterComposer
    extends Composer<_$AppDatabase, $UnitTypesTable> {
  $$UnitTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildingId => $composableBuilder(
    column: $table.buildingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rentKes => $composableBuilder(
    column: $table.rentKes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depositKes => $composableBuilder(
    column: $table.depositKes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amenities => $composableBuilder(
    column: $table.amenities,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnitTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitTypesTable> {
  $$UnitTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildingId => $composableBuilder(
    column: $table.buildingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rentKes => $composableBuilder(
    column: $table.rentKes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depositKes => $composableBuilder(
    column: $table.depositKes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amenities => $composableBuilder(
    column: $table.amenities,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitTypesTable> {
  $$UnitTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get buildingId => $composableBuilder(
    column: $table.buildingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get rentKes =>
      $composableBuilder(column: $table.rentKes, builder: (column) => column);

  GeneratedColumn<int> get depositKes => $composableBuilder(
    column: $table.depositKes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amenities =>
      $composableBuilder(column: $table.amenities, builder: (column) => column);
}

class $$UnitTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitTypesTable,
          UnitType,
          $$UnitTypesTableFilterComposer,
          $$UnitTypesTableOrderingComposer,
          $$UnitTypesTableAnnotationComposer,
          $$UnitTypesTableCreateCompanionBuilder,
          $$UnitTypesTableUpdateCompanionBuilder,
          (UnitType, BaseReferences<_$AppDatabase, $UnitTypesTable, UnitType>),
          UnitType,
          PrefetchHooks Function()
        > {
  $$UnitTypesTableTableManager(_$AppDatabase db, $UnitTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> buildingId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> rentKes = const Value.absent(),
                Value<int?> depositKes = const Value.absent(),
                Value<String> amenities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitTypesCompanion(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                buildingId: buildingId,
                kind: kind,
                rentKes: rentKes,
                depositKes: depositKes,
                amenities: amenities,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String buildingId,
                required String kind,
                required int rentKes,
                Value<int?> depositKes = const Value.absent(),
                Value<String> amenities = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitTypesCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                buildingId: buildingId,
                kind: kind,
                rentKes: rentKes,
                depositKes: depositKes,
                amenities: amenities,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnitTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitTypesTable,
      UnitType,
      $$UnitTypesTableFilterComposer,
      $$UnitTypesTableOrderingComposer,
      $$UnitTypesTableAnnotationComposer,
      $$UnitTypesTableCreateCompanionBuilder,
      $$UnitTypesTableUpdateCompanionBuilder,
      (UnitType, BaseReferences<_$AppDatabase, $UnitTypesTable, UnitType>),
      UnitType,
      PrefetchHooks Function()
    >;
typedef $$VacancySnapshotsTableCreateCompanionBuilder =
    VacancySnapshotsCompanion Function({
      required String id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      required String unitTypeId,
      required int vacantCount,
      required DateTime verifiedAt,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$VacancySnapshotsTableUpdateCompanionBuilder =
    VacancySnapshotsCompanion Function({
      Value<String> id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      Value<String> unitTypeId,
      Value<int> vacantCount,
      Value<DateTime> verifiedAt,
      Value<String> source,
      Value<int> rowid,
    });

class $$VacancySnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $VacancySnapshotsTable> {
  $$VacancySnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitTypeId => $composableBuilder(
    column: $table.unitTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vacantCount => $composableBuilder(
    column: $table.vacantCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VacancySnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $VacancySnapshotsTable> {
  $$VacancySnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitTypeId => $composableBuilder(
    column: $table.unitTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vacantCount => $composableBuilder(
    column: $table.vacantCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VacancySnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VacancySnapshotsTable> {
  $$VacancySnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get unitTypeId => $composableBuilder(
    column: $table.unitTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vacantCount => $composableBuilder(
    column: $table.vacantCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$VacancySnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VacancySnapshotsTable,
          VacancySnapshot,
          $$VacancySnapshotsTableFilterComposer,
          $$VacancySnapshotsTableOrderingComposer,
          $$VacancySnapshotsTableAnnotationComposer,
          $$VacancySnapshotsTableCreateCompanionBuilder,
          $$VacancySnapshotsTableUpdateCompanionBuilder,
          (
            VacancySnapshot,
            BaseReferences<
              _$AppDatabase,
              $VacancySnapshotsTable,
              VacancySnapshot
            >,
          ),
          VacancySnapshot,
          PrefetchHooks Function()
        > {
  $$VacancySnapshotsTableTableManager(
    _$AppDatabase db,
    $VacancySnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VacancySnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VacancySnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VacancySnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> unitTypeId = const Value.absent(),
                Value<int> vacantCount = const Value.absent(),
                Value<DateTime> verifiedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VacancySnapshotsCompanion(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                unitTypeId: unitTypeId,
                vacantCount: vacantCount,
                verifiedAt: verifiedAt,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String unitTypeId,
                required int vacantCount,
                required DateTime verifiedAt,
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VacancySnapshotsCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                unitTypeId: unitTypeId,
                vacantCount: vacantCount,
                verifiedAt: verifiedAt,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VacancySnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VacancySnapshotsTable,
      VacancySnapshot,
      $$VacancySnapshotsTableFilterComposer,
      $$VacancySnapshotsTableOrderingComposer,
      $$VacancySnapshotsTableAnnotationComposer,
      $$VacancySnapshotsTableCreateCompanionBuilder,
      $$VacancySnapshotsTableUpdateCompanionBuilder,
      (
        VacancySnapshot,
        BaseReferences<_$AppDatabase, $VacancySnapshotsTable, VacancySnapshot>,
      ),
      VacancySnapshot,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      required String id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      required String buildingId,
      Value<String?> unitTypeId,
      required String localPath,
      Value<String?> storageKey,
      Value<bool> uploaded,
      Value<int> rowid,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<String> id,
      Value<SyncStatus> syncStatus,
      Value<String?> syncError,
      Value<DateTime> createdAt,
      Value<String> buildingId,
      Value<String?> unitTypeId,
      Value<String> localPath,
      Value<String?> storageKey,
      Value<bool> uploaded,
      Value<int> rowid,
    });

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildingId => $composableBuilder(
    column: $table.buildingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitTypeId => $composableBuilder(
    column: $table.unitTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildingId => $composableBuilder(
    column: $table.buildingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitTypeId => $composableBuilder(
    column: $table.unitTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get buildingId => $composableBuilder(
    column: $table.buildingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitTypeId => $composableBuilder(
    column: $table.unitTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get storageKey => $composableBuilder(
    column: $table.storageKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
          Photo,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> buildingId = const Value.absent(),
                Value<String?> unitTypeId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> storageKey = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                buildingId: buildingId,
                unitTypeId: unitTypeId,
                localPath: localPath,
                storageKey: storageKey,
                uploaded: uploaded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String buildingId,
                Value<String?> unitTypeId = const Value.absent(),
                required String localPath,
                Value<String?> storageKey = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                syncStatus: syncStatus,
                syncError: syncError,
                createdAt: createdAt,
                buildingId: buildingId,
                unitTypeId: unitTypeId,
                localPath: localPath,
                storageKey: storageKey,
                uploaded: uploaded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, BaseReferences<_$AppDatabase, $PhotosTable, Photo>),
      Photo,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BuildingsTableTableManager get buildings =>
      $$BuildingsTableTableManager(_db, _db.buildings);
  $$UnitTypesTableTableManager get unitTypes =>
      $$UnitTypesTableTableManager(_db, _db.unitTypes);
  $$VacancySnapshotsTableTableManager get vacancySnapshots =>
      $$VacancySnapshotsTableTableManager(_db, _db.vacancySnapshots);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
}
