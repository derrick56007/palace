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

