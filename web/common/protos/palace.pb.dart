///
//  Generated code. Do not modify.
//  source: protos/palace.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'palace.pbenum.dart';

export 'palace.pbenum.dart';

class Card extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Card', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..e<Card_Type>(1, 'type', $pb.PbFieldType.OE, defaultOrMaker: Card_Type.BASIC, valueOf: Card_Type.valueOf, enumValues: Card_Type.values)
    ..aOS(2, 'id')
    ..a<$core.int>(3, 'value', $pb.PbFieldType.O3)
    ..aOB(4, 'hidden')
    ..a<$core.int>(5, 'playerIndex', $pb.PbFieldType.O3, protoName: 'playerIndex')
    ..aOB(6, 'activated')
    ..hasRequiredFields = false
  ;

  Card._() : super();
  factory Card() => create();
  factory Card.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Card.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Card clone() => Card()..mergeFromMessage(this);
  Card copyWith(void Function(Card) updates) => super.copyWith((message) => updates(message as Card));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Card create() => Card._();
  Card createEmptyInstance() => create();
  static $pb.PbList<Card> createRepeated() => $pb.PbList<Card>();
  @$core.pragma('dart2js:noInline')
  static Card getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Card>(create);
  static Card _defaultInstance;

  @$pb.TagNumber(1)
  Card_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(Card_Type v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get value => $_getIZ(2);
  @$pb.TagNumber(3)
  set value($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hidden => $_getBF(3);
  @$pb.TagNumber(4)
  set hidden($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHidden() => $_has(3);
  @$pb.TagNumber(4)
  void clearHidden() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get playerIndex => $_getIZ(4);
  @$pb.TagNumber(5)
  set playerIndex($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPlayerIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearPlayerIndex() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get activated => $_getBF(5);
  @$pb.TagNumber(6)
  set activated($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasActivated() => $_has(5);
  @$pb.TagNumber(6)
  void clearActivated() => clearField(6);
}

class Tower extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Tower', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pc<Card>(1, 'cards', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  Tower._() : super();
  factory Tower() => create();
  factory Tower.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Tower.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Tower clone() => Tower()..mergeFromMessage(this);
  Tower copyWith(void Function(Tower) updates) => super.copyWith((message) => updates(message as Tower));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Tower create() => Tower._();
  Tower createEmptyInstance() => create();
  static $pb.PbList<Tower> createRepeated() => $pb.PbList<Tower>();
  @$core.pragma('dart2js:noInline')
  static Tower getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tower>(create);
  static Tower _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Card> get cards => $_getList(0);
}

class CardIDs extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CardIDs', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pPS(1, 'ids')
    ..hasRequiredFields = false
  ;

  CardIDs._() : super();
  factory CardIDs() => create();
  factory CardIDs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CardIDs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  CardIDs clone() => CardIDs()..mergeFromMessage(this);
  CardIDs copyWith(void Function(CardIDs) updates) => super.copyWith((message) => updates(message as CardIDs));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CardIDs create() => CardIDs._();
  CardIDs createEmptyInstance() => create();
  static $pb.PbList<CardIDs> createRepeated() => $pb.PbList<CardIDs>();
  @$core.pragma('dart2js:noInline')
  static CardIDs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CardIDs>(create);
  static CardIDs _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get ids => $_getList(0);
}

class HigherLowerChoice extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('HigherLowerChoice', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..e<HigherLowerChoice_Type>(1, 'choice', $pb.PbFieldType.OE, defaultOrMaker: HigherLowerChoice_Type.HIGHER, valueOf: HigherLowerChoice_Type.valueOf, enumValues: HigherLowerChoice_Type.values)
    ..a<$core.int>(2, 'value', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  HigherLowerChoice._() : super();
  factory HigherLowerChoice() => create();
  factory HigherLowerChoice.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HigherLowerChoice.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  HigherLowerChoice clone() => HigherLowerChoice()..mergeFromMessage(this);
  HigherLowerChoice copyWith(void Function(HigherLowerChoice) updates) => super.copyWith((message) => updates(message as HigherLowerChoice));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static HigherLowerChoice create() => HigherLowerChoice._();
  HigherLowerChoice createEmptyInstance() => create();
  static $pb.PbList<HigherLowerChoice> createRepeated() => $pb.PbList<HigherLowerChoice>();
  @$core.pragma('dart2js:noInline')
  static HigherLowerChoice getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HigherLowerChoice>(create);
  static HigherLowerChoice _defaultInstance;

  @$pb.TagNumber(1)
  HigherLowerChoice_Type get choice => $_getN(0);
  @$pb.TagNumber(1)
  set choice(HigherLowerChoice_Type v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasChoice() => $_has(0);
  @$pb.TagNumber(1)
  void clearChoice() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get value => $_getIZ(1);
  @$pb.TagNumber(2)
  set value($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class DealTowerInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('DealTowerInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pc<Tower>(1, 'topTowers', $pb.PbFieldType.PM, protoName: 'topTowers', subBuilder: Tower.create)
    ..pc<Tower>(2, 'bottomTowers', $pb.PbFieldType.PM, protoName: 'bottomTowers', subBuilder: Tower.create)
    ..hasRequiredFields = false
  ;

  DealTowerInfo._() : super();
  factory DealTowerInfo() => create();
  factory DealTowerInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DealTowerInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  DealTowerInfo clone() => DealTowerInfo()..mergeFromMessage(this);
  DealTowerInfo copyWith(void Function(DealTowerInfo) updates) => super.copyWith((message) => updates(message as DealTowerInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DealTowerInfo create() => DealTowerInfo._();
  DealTowerInfo createEmptyInstance() => create();
  static $pb.PbList<DealTowerInfo> createRepeated() => $pb.PbList<DealTowerInfo>();
  @$core.pragma('dart2js:noInline')
  static DealTowerInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DealTowerInfo>(create);
  static DealTowerInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Tower> get topTowers => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<Tower> get bottomTowers => $_getList(1);
}

class SecondDealTowerInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SecondDealTowerInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pc<Tower>(1, 'topTowers', $pb.PbFieldType.PM, protoName: 'topTowers', subBuilder: Tower.create)
    ..hasRequiredFields = false
  ;

  SecondDealTowerInfo._() : super();
  factory SecondDealTowerInfo() => create();
  factory SecondDealTowerInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SecondDealTowerInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  SecondDealTowerInfo clone() => SecondDealTowerInfo()..mergeFromMessage(this);
  SecondDealTowerInfo copyWith(void Function(SecondDealTowerInfo) updates) => super.copyWith((message) => updates(message as SecondDealTowerInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SecondDealTowerInfo create() => SecondDealTowerInfo._();
  SecondDealTowerInfo createEmptyInstance() => create();
  static $pb.PbList<SecondDealTowerInfo> createRepeated() => $pb.PbList<SecondDealTowerInfo>();
  @$core.pragma('dart2js:noInline')
  static SecondDealTowerInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SecondDealTowerInfo>(create);
  static SecondDealTowerInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Tower> get topTowers => $_getList(0);
}

class PlayFromHandInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PlayFromHandInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..a<$core.int>(1, 'userIndex', $pb.PbFieldType.O3, protoName: 'userIndex')
    ..pc<Card>(2, 'cards', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  PlayFromHandInfo._() : super();
  factory PlayFromHandInfo() => create();
  factory PlayFromHandInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlayFromHandInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PlayFromHandInfo clone() => PlayFromHandInfo()..mergeFromMessage(this);
  PlayFromHandInfo copyWith(void Function(PlayFromHandInfo) updates) => super.copyWith((message) => updates(message as PlayFromHandInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PlayFromHandInfo create() => PlayFromHandInfo._();
  PlayFromHandInfo createEmptyInstance() => create();
  static $pb.PbList<PlayFromHandInfo> createRepeated() => $pb.PbList<PlayFromHandInfo>();
  @$core.pragma('dart2js:noInline')
  static PlayFromHandInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlayFromHandInfo>(create);
  static PlayFromHandInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get userIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set userIndex($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserIndex() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Card> get cards => $_getList(1);
}

class DiscardInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('DiscardInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pc<Card>(1, 'cards', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  DiscardInfo._() : super();
  factory DiscardInfo() => create();
  factory DiscardInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DiscardInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  DiscardInfo clone() => DiscardInfo()..mergeFromMessage(this);
  DiscardInfo copyWith(void Function(DiscardInfo) updates) => super.copyWith((message) => updates(message as DiscardInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DiscardInfo create() => DiscardInfo._();
  DiscardInfo createEmptyInstance() => create();
  static $pb.PbList<DiscardInfo> createRepeated() => $pb.PbList<DiscardInfo>();
  @$core.pragma('dart2js:noInline')
  static DiscardInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DiscardInfo>(create);
  static DiscardInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Card> get cards => $_getList(0);
}

class DrawInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('DrawInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..a<$core.int>(1, 'userIndex', $pb.PbFieldType.O3, protoName: 'userIndex')
    ..pc<Card>(2, 'cards', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  DrawInfo._() : super();
  factory DrawInfo() => create();
  factory DrawInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DrawInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  DrawInfo clone() => DrawInfo()..mergeFromMessage(this);
  DrawInfo copyWith(void Function(DrawInfo) updates) => super.copyWith((message) => updates(message as DrawInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DrawInfo create() => DrawInfo._();
  DrawInfo createEmptyInstance() => create();
  static $pb.PbList<DrawInfo> createRepeated() => $pb.PbList<DrawInfo>();
  @$core.pragma('dart2js:noInline')
  static DrawInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DrawInfo>(create);
  static DrawInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get userIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set userIndex($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserIndex() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Card> get cards => $_getList(1);
}

class PickUpPileInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PickUpPileInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..a<$core.int>(1, 'userIndex', $pb.PbFieldType.O3, protoName: 'userIndex')
    ..pc<Card>(2, 'cards', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  PickUpPileInfo._() : super();
  factory PickUpPileInfo() => create();
  factory PickUpPileInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PickUpPileInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PickUpPileInfo clone() => PickUpPileInfo()..mergeFromMessage(this);
  PickUpPileInfo copyWith(void Function(PickUpPileInfo) updates) => super.copyWith((message) => updates(message as PickUpPileInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PickUpPileInfo create() => PickUpPileInfo._();
  PickUpPileInfo createEmptyInstance() => create();
  static $pb.PbList<PickUpPileInfo> createRepeated() => $pb.PbList<PickUpPileInfo>();
  @$core.pragma('dart2js:noInline')
  static PickUpPileInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PickUpPileInfo>(create);
  static PickUpPileInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get userIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set userIndex($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserIndex() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Card> get cards => $_getList(1);
}

class Hand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Hand', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pc<Card>(1, 'cards', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  Hand._() : super();
  factory Hand() => create();
  factory Hand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Hand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Hand clone() => Hand()..mergeFromMessage(this);
  Hand copyWith(void Function(Hand) updates) => super.copyWith((message) => updates(message as Hand));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Hand create() => Hand._();
  Hand createEmptyInstance() => create();
  static $pb.PbList<Hand> createRepeated() => $pb.PbList<Hand>();
  @$core.pragma('dart2js:noInline')
  static Hand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Hand>(create);
  static Hand _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Card> get cards => $_getList(0);
}

class TowerCardsToHandInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TowerCardsToHandInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..a<$core.int>(1, 'userIndex', $pb.PbFieldType.O3, protoName: 'userIndex')
    ..pPS(2, 'cardIDs', protoName: 'cardIDs')
    ..hasRequiredFields = false
  ;

  TowerCardsToHandInfo._() : super();
  factory TowerCardsToHandInfo() => create();
  factory TowerCardsToHandInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TowerCardsToHandInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TowerCardsToHandInfo clone() => TowerCardsToHandInfo()..mergeFromMessage(this);
  TowerCardsToHandInfo copyWith(void Function(TowerCardsToHandInfo) updates) => super.copyWith((message) => updates(message as TowerCardsToHandInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TowerCardsToHandInfo create() => TowerCardsToHandInfo._();
  TowerCardsToHandInfo createEmptyInstance() => create();
  static $pb.PbList<TowerCardsToHandInfo> createRepeated() => $pb.PbList<TowerCardsToHandInfo>();
  @$core.pragma('dart2js:noInline')
  static TowerCardsToHandInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TowerCardsToHandInfo>(create);
  static TowerCardsToHandInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get userIndex => $_getIZ(0);
  @$pb.TagNumber(1)
  set userIndex($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserIndex() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get cardIDs => $_getList(1);
}

class FinalDealInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FinalDealInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pc<Hand>(1, 'hands', $pb.PbFieldType.PM, subBuilder: Hand.create)
    ..hasRequiredFields = false
  ;

  FinalDealInfo._() : super();
  factory FinalDealInfo() => create();
  factory FinalDealInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FinalDealInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  FinalDealInfo clone() => FinalDealInfo()..mergeFromMessage(this);
  FinalDealInfo copyWith(void Function(FinalDealInfo) updates) => super.copyWith((message) => updates(message as FinalDealInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FinalDealInfo create() => FinalDealInfo._();
  FinalDealInfo createEmptyInstance() => create();
  static $pb.PbList<FinalDealInfo> createRepeated() => $pb.PbList<FinalDealInfo>();
  @$core.pragma('dart2js:noInline')
  static FinalDealInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FinalDealInfo>(create);
  static FinalDealInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Hand> get hands => $_getList(0);
}

class TopSwapInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TopSwapInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..aOM<Card>(1, 'card1', subBuilder: Card.create)
    ..aOM<Card>(2, 'card2', subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  TopSwapInfo._() : super();
  factory TopSwapInfo() => create();
  factory TopSwapInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TopSwapInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TopSwapInfo clone() => TopSwapInfo()..mergeFromMessage(this);
  TopSwapInfo copyWith(void Function(TopSwapInfo) updates) => super.copyWith((message) => updates(message as TopSwapInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TopSwapInfo create() => TopSwapInfo._();
  TopSwapInfo createEmptyInstance() => create();
  static $pb.PbList<TopSwapInfo> createRepeated() => $pb.PbList<TopSwapInfo>();
  @$core.pragma('dart2js:noInline')
  static TopSwapInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TopSwapInfo>(create);
  static TopSwapInfo _defaultInstance;

  @$pb.TagNumber(1)
  Card get card1 => $_getN(0);
  @$pb.TagNumber(1)
  set card1(Card v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCard1() => $_has(0);
  @$pb.TagNumber(1)
  void clearCard1() => clearField(1);
  @$pb.TagNumber(1)
  Card ensureCard1() => $_ensure(0);

  @$pb.TagNumber(2)
  Card get card2 => $_getN(1);
  @$pb.TagNumber(2)
  set card2(Card v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCard2() => $_has(1);
  @$pb.TagNumber(2)
  void clearCard2() => clearField(2);
  @$pb.TagNumber(2)
  Card ensureCard2() => $_ensure(1);
}

class HandSwapInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('HandSwapInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..a<$core.int>(1, 'userIndex1', $pb.PbFieldType.O3, protoName: 'userIndex1')
    ..a<$core.int>(2, 'userIndex2', $pb.PbFieldType.O3, protoName: 'userIndex2')
    ..pc<Card>(3, 'cards1', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..pc<Card>(4, 'cards2', $pb.PbFieldType.PM, subBuilder: Card.create)
    ..hasRequiredFields = false
  ;

  HandSwapInfo._() : super();
  factory HandSwapInfo() => create();
  factory HandSwapInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HandSwapInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  HandSwapInfo clone() => HandSwapInfo()..mergeFromMessage(this);
  HandSwapInfo copyWith(void Function(HandSwapInfo) updates) => super.copyWith((message) => updates(message as HandSwapInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static HandSwapInfo create() => HandSwapInfo._();
  HandSwapInfo createEmptyInstance() => create();
  static $pb.PbList<HandSwapInfo> createRepeated() => $pb.PbList<HandSwapInfo>();
  @$core.pragma('dart2js:noInline')
  static HandSwapInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HandSwapInfo>(create);
  static HandSwapInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get userIndex1 => $_getIZ(0);
  @$pb.TagNumber(1)
  set userIndex1($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserIndex1() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserIndex1() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get userIndex2 => $_getIZ(1);
  @$pb.TagNumber(2)
  set userIndex2($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUserIndex2() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserIndex2() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<Card> get cards1 => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<Card> get cards2 => $_getList(3);
}

class LoginCredentials extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('LoginCredentials', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..aOS(1, 'userID', protoName: 'userID')
    ..aOS(2, 'passCode', protoName: 'passCode')
    ..hasRequiredFields = false
  ;

  LoginCredentials._() : super();
  factory LoginCredentials() => create();
  factory LoginCredentials.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LoginCredentials.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  LoginCredentials clone() => LoginCredentials()..mergeFromMessage(this);
  LoginCredentials copyWith(void Function(LoginCredentials) updates) => super.copyWith((message) => updates(message as LoginCredentials));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static LoginCredentials create() => LoginCredentials._();
  LoginCredentials createEmptyInstance() => create();
  static $pb.PbList<LoginCredentials> createRepeated() => $pb.PbList<LoginCredentials>();
  @$core.pragma('dart2js:noInline')
  static LoginCredentials getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoginCredentials>(create);
  static LoginCredentials _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userID => $_getSZ(0);
  @$pb.TagNumber(1)
  set userID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserID() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserID() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get passCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set passCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPassCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassCode() => clearField(2);
}

class LobbyInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('LobbyInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..aOS(1, 'host')
    ..pc<PlayerEntry>(2, 'players', $pb.PbFieldType.PM, subBuilder: PlayerEntry.create)
    ..aOB(3, 'canStart', protoName: 'canStart')
    ..aOB(4, 'canJoin', protoName: 'canJoin')
    ..hasRequiredFields = false
  ;

  LobbyInfo._() : super();
  factory LobbyInfo() => create();
  factory LobbyInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LobbyInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  LobbyInfo clone() => LobbyInfo()..mergeFromMessage(this);
  LobbyInfo copyWith(void Function(LobbyInfo) updates) => super.copyWith((message) => updates(message as LobbyInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static LobbyInfo create() => LobbyInfo._();
  LobbyInfo createEmptyInstance() => create();
  static $pb.PbList<LobbyInfo> createRepeated() => $pb.PbList<LobbyInfo>();
  @$core.pragma('dart2js:noInline')
  static LobbyInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LobbyInfo>(create);
  static LobbyInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get host => $_getSZ(0);
  @$pb.TagNumber(1)
  set host($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHost() => $_has(0);
  @$pb.TagNumber(1)
  void clearHost() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<PlayerEntry> get players => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get canStart => $_getBF(2);
  @$pb.TagNumber(3)
  set canStart($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCanStart() => $_has(2);
  @$pb.TagNumber(3)
  void clearCanStart() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get canJoin => $_getBF(3);
  @$pb.TagNumber(4)
  set canJoin($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasCanJoin() => $_has(3);
  @$pb.TagNumber(4)
  void clearCanJoin() => clearField(4);
}

class PlayerEntry extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PlayerEntry', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..aOS(1, 'userID', protoName: 'userID')
    ..aOB(2, 'ready')
    ..hasRequiredFields = false
  ;

  PlayerEntry._() : super();
  factory PlayerEntry() => create();
  factory PlayerEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlayerEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PlayerEntry clone() => PlayerEntry()..mergeFromMessage(this);
  PlayerEntry copyWith(void Function(PlayerEntry) updates) => super.copyWith((message) => updates(message as PlayerEntry));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PlayerEntry create() => PlayerEntry._();
  PlayerEntry createEmptyInstance() => create();
  static $pb.PbList<PlayerEntry> createRepeated() => $pb.PbList<PlayerEntry>();
  @$core.pragma('dart2js:noInline')
  static PlayerEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlayerEntry>(create);
  static PlayerEntry _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userID => $_getSZ(0);
  @$pb.TagNumber(1)
  set userID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserID() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserID() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get ready => $_getBF(1);
  @$pb.TagNumber(2)
  set ready($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReady() => $_has(1);
  @$pb.TagNumber(2)
  void clearReady() => clearField(2);
}

class UserIDs extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('UserIDs', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..pPS(1, 'ids')
    ..hasRequiredFields = false
  ;

  UserIDs._() : super();
  factory UserIDs() => create();
  factory UserIDs.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserIDs.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  UserIDs clone() => UserIDs()..mergeFromMessage(this);
  UserIDs copyWith(void Function(UserIDs) updates) => super.copyWith((message) => updates(message as UserIDs));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static UserIDs create() => UserIDs._();
  UserIDs createEmptyInstance() => create();
  static $pb.PbList<UserIDs> createRepeated() => $pb.PbList<UserIDs>();
  @$core.pragma('dart2js:noInline')
  static UserIDs getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserIDs>(create);
  static UserIDs _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get ids => $_getList(0);
}

class SimpleInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SimpleInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..aOS(1, 'info')
    ..hasRequiredFields = false
  ;

  SimpleInfo._() : super();
  factory SimpleInfo() => create();
  factory SimpleInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SimpleInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  SimpleInfo clone() => SimpleInfo()..mergeFromMessage(this);
  SimpleInfo copyWith(void Function(SimpleInfo) updates) => super.copyWith((message) => updates(message as SimpleInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SimpleInfo create() => SimpleInfo._();
  SimpleInfo createEmptyInstance() => create();
  static $pb.PbList<SimpleInfo> createRepeated() => $pb.PbList<SimpleInfo>();
  @$core.pragma('dart2js:noInline')
  static SimpleInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SimpleInfo>(create);
  static SimpleInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get info => $_getSZ(0);
  @$pb.TagNumber(1)
  set info($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearInfo() => clearField(1);
}

class SocketMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SocketMessage', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..e<SocketMessage_Type>(1, 'type', $pb.PbFieldType.OE, defaultOrMaker: SocketMessage_Type.ERROR, valueOf: SocketMessage_Type.valueOf, enumValues: SocketMessage_Type.values)
    ..aOS(2, 'json')
    ..hasRequiredFields = false
  ;

  SocketMessage._() : super();
  factory SocketMessage() => create();
  factory SocketMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SocketMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  SocketMessage clone() => SocketMessage()..mergeFromMessage(this);
  SocketMessage copyWith(void Function(SocketMessage) updates) => super.copyWith((message) => updates(message as SocketMessage));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SocketMessage create() => SocketMessage._();
  SocketMessage createEmptyInstance() => create();
  static $pb.PbList<SocketMessage> createRepeated() => $pb.PbList<SocketMessage>();
  @$core.pragma('dart2js:noInline')
  static SocketMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SocketMessage>(create);
  static SocketMessage _defaultInstance;

  @$pb.TagNumber(1)
  SocketMessage_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SocketMessage_Type v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get json => $_getSZ(1);
  @$pb.TagNumber(2)
  set json($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearJson() => clearField(2);
}

class ActivePlayerIndex extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ActivePlayerIndex', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..a<$core.int>(1, 'index', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  ActivePlayerIndex._() : super();
  factory ActivePlayerIndex() => create();
  factory ActivePlayerIndex.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ActivePlayerIndex.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ActivePlayerIndex clone() => ActivePlayerIndex()..mergeFromMessage(this);
  ActivePlayerIndex copyWith(void Function(ActivePlayerIndex) updates) => super.copyWith((message) => updates(message as ActivePlayerIndex));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ActivePlayerIndex create() => ActivePlayerIndex._();
  ActivePlayerIndex createEmptyInstance() => create();
  static $pb.PbList<ActivePlayerIndex> createRepeated() => $pb.PbList<ActivePlayerIndex>();
  @$core.pragma('dart2js:noInline')
  static ActivePlayerIndex getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActivePlayerIndex>(create);
  static ActivePlayerIndex _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);
}

class FriendItemInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FriendItemInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..aOS(1, 'userID', protoName: 'userID')
    ..aOB(2, 'online')
    ..aOB(3, 'invitable')
    ..aOS(4, 'statusText', protoName: 'statusText')
    ..aOS(5, 'color')
    ..hasRequiredFields = false
  ;

  FriendItemInfo._() : super();
  factory FriendItemInfo() => create();
  factory FriendItemInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FriendItemInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  FriendItemInfo clone() => FriendItemInfo()..mergeFromMessage(this);
  FriendItemInfo copyWith(void Function(FriendItemInfo) updates) => super.copyWith((message) => updates(message as FriendItemInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FriendItemInfo create() => FriendItemInfo._();
  FriendItemInfo createEmptyInstance() => create();
  static $pb.PbList<FriendItemInfo> createRepeated() => $pb.PbList<FriendItemInfo>();
  @$core.pragma('dart2js:noInline')
  static FriendItemInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FriendItemInfo>(create);
  static FriendItemInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userID => $_getSZ(0);
  @$pb.TagNumber(1)
  set userID($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserID() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserID() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get online => $_getBF(1);
  @$pb.TagNumber(2)
  set online($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOnline() => $_has(1);
  @$pb.TagNumber(2)
  void clearOnline() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get invitable => $_getBF(2);
  @$pb.TagNumber(3)
  set invitable($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInvitable() => $_has(2);
  @$pb.TagNumber(3)
  void clearInvitable() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get statusText => $_getSZ(3);
  @$pb.TagNumber(4)
  set statusText($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatusText() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatusText() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get color => $_getSZ(4);
  @$pb.TagNumber(5)
  set color($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasColor() => $_has(4);
  @$pb.TagNumber(5)
  void clearColor() => clearField(5);
}

class RequestHigherLowerChoiceInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('RequestHigherLowerChoiceInfo', package: const $pb.PackageName('palace'), createEmptyInstance: create)
    ..a<$core.int>(1, 'value', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  RequestHigherLowerChoiceInfo._() : super();
  factory RequestHigherLowerChoiceInfo() => create();
  factory RequestHigherLowerChoiceInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RequestHigherLowerChoiceInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  RequestHigherLowerChoiceInfo clone() => RequestHigherLowerChoiceInfo()..mergeFromMessage(this);
  RequestHigherLowerChoiceInfo copyWith(void Function(RequestHigherLowerChoiceInfo) updates) => super.copyWith((message) => updates(message as RequestHigherLowerChoiceInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static RequestHigherLowerChoiceInfo create() => RequestHigherLowerChoiceInfo._();
  RequestHigherLowerChoiceInfo createEmptyInstance() => create();
  static $pb.PbList<RequestHigherLowerChoiceInfo> createRepeated() => $pb.PbList<RequestHigherLowerChoiceInfo>();
  @$core.pragma('dart2js:noInline')
  static RequestHigherLowerChoiceInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RequestHigherLowerChoiceInfo>(create);
  static RequestHigherLowerChoiceInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get value => $_getIZ(0);
  @$pb.TagNumber(1)
  set value($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => clearField(1);
}

