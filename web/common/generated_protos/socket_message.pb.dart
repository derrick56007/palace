///
//  Generated code. Do not modify.
//  source: socket_message.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart' as $pb;

import 'socket_message.pbenum.dart';

export 'socket_message.pbenum.dart';

class SocketMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('SocketMessage', package: const $pb.PackageName('palace'))
    ..e<SocketMessage_Type>(1, 'type', $pb.PbFieldType.OE, SocketMessage_Type.ERROR, SocketMessage_Type.valueOf, SocketMessage_Type.values)
    ..aOS(2, 'json')
    ..hasRequiredFields = false
  ;

  SocketMessage() : super();
  SocketMessage.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  SocketMessage.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  SocketMessage clone() => new SocketMessage()..mergeFromMessage(this);
  SocketMessage copyWith(void Function(SocketMessage) updates) => super.copyWith((message) => updates(message as SocketMessage));
  $pb.BuilderInfo get info_ => _i;
  static SocketMessage create() => new SocketMessage();
  static $pb.PbList<SocketMessage> createRepeated() => new $pb.PbList<SocketMessage>();
  static SocketMessage getDefault() => _defaultInstance ??= create()..freeze();
  static SocketMessage _defaultInstance;
  static void $checkItem(SocketMessage v) {
    if (v is! SocketMessage) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  SocketMessage_Type get type => $_getN(0);
  set type(SocketMessage_Type v) { setField(1, v); }
  bool hasType() => $_has(0);
  void clearType() => clearField(1);

  String get json => $_getS(1, '');
  set json(String v) { $_setString(1, v); }
  bool hasJson() => $_has(1);
  void clearJson() => clearField(2);
}

class ActivePlayerIndex extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('ActivePlayerIndex', package: const $pb.PackageName('palace'))
    ..a<int>(1, 'index', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  ActivePlayerIndex() : super();
  ActivePlayerIndex.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  ActivePlayerIndex.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  ActivePlayerIndex clone() => new ActivePlayerIndex()..mergeFromMessage(this);
  ActivePlayerIndex copyWith(void Function(ActivePlayerIndex) updates) => super.copyWith((message) => updates(message as ActivePlayerIndex));
  $pb.BuilderInfo get info_ => _i;
  static ActivePlayerIndex create() => new ActivePlayerIndex();
  static $pb.PbList<ActivePlayerIndex> createRepeated() => new $pb.PbList<ActivePlayerIndex>();
  static ActivePlayerIndex getDefault() => _defaultInstance ??= create()..freeze();
  static ActivePlayerIndex _defaultInstance;
  static void $checkItem(ActivePlayerIndex v) {
    if (v is! ActivePlayerIndex) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  int get index => $_get(0, 0);
  set index(int v) { $_setSignedInt32(0, v); }
  bool hasIndex() => $_has(0);
  void clearIndex() => clearField(1);
}

class FriendItemInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('FriendItemInfo', package: const $pb.PackageName('palace'))
    ..aOS(1, 'userID')
    ..aOB(2, 'online')
    ..aOB(3, 'invitable')
    ..aOS(4, 'statusText')
    ..aOS(5, 'color')
    ..hasRequiredFields = false
  ;

  FriendItemInfo() : super();
  FriendItemInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  FriendItemInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  FriendItemInfo clone() => new FriendItemInfo()..mergeFromMessage(this);
  FriendItemInfo copyWith(void Function(FriendItemInfo) updates) => super.copyWith((message) => updates(message as FriendItemInfo));
  $pb.BuilderInfo get info_ => _i;
  static FriendItemInfo create() => new FriendItemInfo();
  static $pb.PbList<FriendItemInfo> createRepeated() => new $pb.PbList<FriendItemInfo>();
  static FriendItemInfo getDefault() => _defaultInstance ??= create()..freeze();
  static FriendItemInfo _defaultInstance;
  static void $checkItem(FriendItemInfo v) {
    if (v is! FriendItemInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  String get userID => $_getS(0, '');
  set userID(String v) { $_setString(0, v); }
  bool hasUserID() => $_has(0);
  void clearUserID() => clearField(1);

  bool get online => $_get(1, false);
  set online(bool v) { $_setBool(1, v); }
  bool hasOnline() => $_has(1);
  void clearOnline() => clearField(2);

  bool get invitable => $_get(2, false);
  set invitable(bool v) { $_setBool(2, v); }
  bool hasInvitable() => $_has(2);
  void clearInvitable() => clearField(3);

  String get statusText => $_getS(3, '');
  set statusText(String v) { $_setString(3, v); }
  bool hasStatusText() => $_has(3);
  void clearStatusText() => clearField(4);

  String get color => $_getS(4, '');
  set color(String v) { $_setString(4, v); }
  bool hasColor() => $_has(4);
  void clearColor() => clearField(5);
}

class RequestHigherLowerChoiceInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('RequestHigherLowerChoiceInfo', package: const $pb.PackageName('palace'))
    ..a<int>(1, 'value', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  RequestHigherLowerChoiceInfo() : super();
  RequestHigherLowerChoiceInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  RequestHigherLowerChoiceInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  RequestHigherLowerChoiceInfo clone() => new RequestHigherLowerChoiceInfo()..mergeFromMessage(this);
  RequestHigherLowerChoiceInfo copyWith(void Function(RequestHigherLowerChoiceInfo) updates) => super.copyWith((message) => updates(message as RequestHigherLowerChoiceInfo));
  $pb.BuilderInfo get info_ => _i;
  static RequestHigherLowerChoiceInfo create() => new RequestHigherLowerChoiceInfo();
  static $pb.PbList<RequestHigherLowerChoiceInfo> createRepeated() => new $pb.PbList<RequestHigherLowerChoiceInfo>();
  static RequestHigherLowerChoiceInfo getDefault() => _defaultInstance ??= create()..freeze();
  static RequestHigherLowerChoiceInfo _defaultInstance;
  static void $checkItem(RequestHigherLowerChoiceInfo v) {
    if (v is! RequestHigherLowerChoiceInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  int get value => $_get(0, 0);
  set value(int v) { $_setSignedInt32(0, v); }
  bool hasValue() => $_has(0);
  void clearValue() => clearField(1);
}

