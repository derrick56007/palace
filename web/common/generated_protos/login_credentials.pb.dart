///
//  Generated code. Do not modify.
//  source: login_credentials.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart' as $pb;

class LoginCredentials extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('LoginCredentials', package: const $pb.PackageName('palace'))
    ..aOS(1, 'userID')
    ..aOS(2, 'passCode')
    ..hasRequiredFields = false
  ;

  LoginCredentials() : super();
  LoginCredentials.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  LoginCredentials.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  LoginCredentials clone() => new LoginCredentials()..mergeFromMessage(this);
  LoginCredentials copyWith(void Function(LoginCredentials) updates) => super.copyWith((message) => updates(message as LoginCredentials));
  $pb.BuilderInfo get info_ => _i;
  static LoginCredentials create() => new LoginCredentials();
  static $pb.PbList<LoginCredentials> createRepeated() => new $pb.PbList<LoginCredentials>();
  static LoginCredentials getDefault() => _defaultInstance ??= create()..freeze();
  static LoginCredentials _defaultInstance;
  static void $checkItem(LoginCredentials v) {
    if (v is! LoginCredentials) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  String get userID => $_getS(0, '');
  set userID(String v) { $_setString(0, v); }
  bool hasUserID() => $_has(0);
  void clearUserID() => clearField(1);

  String get passCode => $_getS(1, '');
  set passCode(String v) { $_setString(1, v); }
  bool hasPassCode() => $_has(1);
  void clearPassCode() => clearField(2);
}

