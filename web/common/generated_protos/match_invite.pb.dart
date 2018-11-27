///
//  Generated code. Do not modify.
//  source: match_invite.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart' as $pb;

class MatchInvite extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('MatchInvite', package: const $pb.PackageName('palace'))
    ..aOS(1, 'msg')
    ..aOS(2, 'matchID')
    ..hasRequiredFields = false
  ;

  MatchInvite() : super();
  MatchInvite.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  MatchInvite.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  MatchInvite clone() => new MatchInvite()..mergeFromMessage(this);
  MatchInvite copyWith(void Function(MatchInvite) updates) => super.copyWith((message) => updates(message as MatchInvite));
  $pb.BuilderInfo get info_ => _i;
  static MatchInvite create() => new MatchInvite();
  static $pb.PbList<MatchInvite> createRepeated() => new $pb.PbList<MatchInvite>();
  static MatchInvite getDefault() => _defaultInstance ??= create()..freeze();
  static MatchInvite _defaultInstance;
  static void $checkItem(MatchInvite v) {
    if (v is! MatchInvite) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  String get msg => $_getS(0, '');
  set msg(String v) { $_setString(0, v); }
  bool hasMsg() => $_has(0);
  void clearMsg() => clearField(1);

  String get matchID => $_getS(1, '');
  set matchID(String v) { $_setString(1, v); }
  bool hasMatchID() => $_has(1);
  void clearMatchID() => clearField(2);
}

