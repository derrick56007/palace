///
//  Generated code. Do not modify.
//  source: simple_info.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart' as $pb;

class SimpleInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('SimpleInfo', package: const $pb.PackageName('palace'))
    ..aOS(1, 'info')
    ..hasRequiredFields = false
  ;

  SimpleInfo() : super();
  SimpleInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  SimpleInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  SimpleInfo clone() => new SimpleInfo()..mergeFromMessage(this);
  SimpleInfo copyWith(void Function(SimpleInfo) updates) => super.copyWith((message) => updates(message as SimpleInfo));
  $pb.BuilderInfo get info_ => _i;
  static SimpleInfo create() => new SimpleInfo();
  static $pb.PbList<SimpleInfo> createRepeated() => new $pb.PbList<SimpleInfo>();
  static SimpleInfo getDefault() => _defaultInstance ??= create()..freeze();
  static SimpleInfo _defaultInstance;
  static void $checkItem(SimpleInfo v) {
    if (v is! SimpleInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  String get info => $_getS(0, '');
  set info(String v) { $_setString(0, v); }
  bool hasInfo() => $_has(0);
  void clearInfo() => clearField(1);
}

