///
//  Generated code. Do not modify.
//  source: match_invite.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart' as $pb;

class LobbyInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('LobbyInfo', package: const $pb.PackageName('palace'))
    ..aOS(1, 'host')
    ..pp<PlayerEntry>(2, 'players', $pb.PbFieldType.PM, PlayerEntry.$checkItem, PlayerEntry.create)
    ..aOB(3, 'canStart')
    ..aOB(4, 'canJoin')
    ..hasRequiredFields = false
  ;

  LobbyInfo() : super();
  LobbyInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  LobbyInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  LobbyInfo clone() => new LobbyInfo()..mergeFromMessage(this);
  LobbyInfo copyWith(void Function(LobbyInfo) updates) => super.copyWith((message) => updates(message as LobbyInfo));
  $pb.BuilderInfo get info_ => _i;
  static LobbyInfo create() => new LobbyInfo();
  static $pb.PbList<LobbyInfo> createRepeated() => new $pb.PbList<LobbyInfo>();
  static LobbyInfo getDefault() => _defaultInstance ??= create()..freeze();
  static LobbyInfo _defaultInstance;
  static void $checkItem(LobbyInfo v) {
    if (v is! LobbyInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  String get host => $_getS(0, '');
  set host(String v) { $_setString(0, v); }
  bool hasHost() => $_has(0);
  void clearHost() => clearField(1);

  List<PlayerEntry> get players => $_getList(1);

  bool get canStart => $_get(2, false);
  set canStart(bool v) { $_setBool(2, v); }
  bool hasCanStart() => $_has(2);
  void clearCanStart() => clearField(3);

  bool get canJoin => $_get(3, false);
  set canJoin(bool v) { $_setBool(3, v); }
  bool hasCanJoin() => $_has(3);
  void clearCanJoin() => clearField(4);
}

class PlayerEntry extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('PlayerEntry', package: const $pb.PackageName('palace'))
    ..aOS(1, 'userID')
    ..aOB(2, 'ready')
    ..hasRequiredFields = false
  ;

  PlayerEntry() : super();
  PlayerEntry.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  PlayerEntry.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  PlayerEntry clone() => new PlayerEntry()..mergeFromMessage(this);
  PlayerEntry copyWith(void Function(PlayerEntry) updates) => super.copyWith((message) => updates(message as PlayerEntry));
  $pb.BuilderInfo get info_ => _i;
  static PlayerEntry create() => new PlayerEntry();
  static $pb.PbList<PlayerEntry> createRepeated() => new $pb.PbList<PlayerEntry>();
  static PlayerEntry getDefault() => _defaultInstance ??= create()..freeze();
  static PlayerEntry _defaultInstance;
  static void $checkItem(PlayerEntry v) {
    if (v is! PlayerEntry) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  String get userID => $_getS(0, '');
  set userID(String v) { $_setString(0, v); }
  bool hasUserID() => $_has(0);
  void clearUserID() => clearField(1);

  bool get ready => $_get(1, false);
  set ready(bool v) { $_setBool(1, v); }
  bool hasReady() => $_has(1);
  void clearReady() => clearField(2);
}

class UserIDs extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('UserIDs', package: const $pb.PackageName('palace'))
    ..pPS(1, 'ids')
    ..hasRequiredFields = false
  ;

  UserIDs() : super();
  UserIDs.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  UserIDs.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  UserIDs clone() => new UserIDs()..mergeFromMessage(this);
  UserIDs copyWith(void Function(UserIDs) updates) => super.copyWith((message) => updates(message as UserIDs));
  $pb.BuilderInfo get info_ => _i;
  static UserIDs create() => new UserIDs();
  static $pb.PbList<UserIDs> createRepeated() => new $pb.PbList<UserIDs>();
  static UserIDs getDefault() => _defaultInstance ??= create()..freeze();
  static UserIDs _defaultInstance;
  static void $checkItem(UserIDs v) {
    if (v is! UserIDs) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<String> get ids => $_getList(0);
}

