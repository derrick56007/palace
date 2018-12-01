///
//  Generated code. Do not modify.
//  source: cards.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore: UNUSED_SHOWN_NAME
import 'dart:core' show int, bool, double, String, List, override;

import 'package:protobuf/protobuf.dart' as $pb;

import 'cards.pbenum.dart';

export 'cards.pbenum.dart';

class Card extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('Card', package: const $pb.PackageName('palace'))
    ..e<Card_Type>(1, 'type', $pb.PbFieldType.OE, Card_Type.BASIC, Card_Type.valueOf, Card_Type.values)
    ..aOS(2, 'id')
    ..a<int>(3, 'value', $pb.PbFieldType.O3)
    ..aOB(4, 'hidden')
    ..hasRequiredFields = false
  ;

  Card() : super();
  Card.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  Card.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  Card clone() => new Card()..mergeFromMessage(this);
  Card copyWith(void Function(Card) updates) => super.copyWith((message) => updates(message as Card));
  $pb.BuilderInfo get info_ => _i;
  static Card create() => new Card();
  static $pb.PbList<Card> createRepeated() => new $pb.PbList<Card>();
  static Card getDefault() => _defaultInstance ??= create()..freeze();
  static Card _defaultInstance;
  static void $checkItem(Card v) {
    if (v is! Card) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  Card_Type get type => $_getN(0);
  set type(Card_Type v) { setField(1, v); }
  bool hasType() => $_has(0);
  void clearType() => clearField(1);

  String get id => $_getS(1, '');
  set id(String v) { $_setString(1, v); }
  bool hasId() => $_has(1);
  void clearId() => clearField(2);

  int get value => $_get(2, 0);
  set value(int v) { $_setSignedInt32(2, v); }
  bool hasValue() => $_has(2);
  void clearValue() => clearField(3);

  bool get hidden => $_get(3, false);
  set hidden(bool v) { $_setBool(3, v); }
  bool hasHidden() => $_has(3);
  void clearHidden() => clearField(4);
}

class Tower extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('Tower', package: const $pb.PackageName('palace'))
    ..pp<Card>(1, 'cards', $pb.PbFieldType.PM, Card.$checkItem, Card.create)
    ..hasRequiredFields = false
  ;

  Tower() : super();
  Tower.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  Tower.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  Tower clone() => new Tower()..mergeFromMessage(this);
  Tower copyWith(void Function(Tower) updates) => super.copyWith((message) => updates(message as Tower));
  $pb.BuilderInfo get info_ => _i;
  static Tower create() => new Tower();
  static $pb.PbList<Tower> createRepeated() => new $pb.PbList<Tower>();
  static Tower getDefault() => _defaultInstance ??= create()..freeze();
  static Tower _defaultInstance;
  static void $checkItem(Tower v) {
    if (v is! Tower) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<Card> get cards => $_getList(0);
}

class CardIDs extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('CardIDs', package: const $pb.PackageName('palace'))
    ..pPS(1, 'ids')
    ..hasRequiredFields = false
  ;

  CardIDs() : super();
  CardIDs.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  CardIDs.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  CardIDs clone() => new CardIDs()..mergeFromMessage(this);
  CardIDs copyWith(void Function(CardIDs) updates) => super.copyWith((message) => updates(message as CardIDs));
  $pb.BuilderInfo get info_ => _i;
  static CardIDs create() => new CardIDs();
  static $pb.PbList<CardIDs> createRepeated() => new $pb.PbList<CardIDs>();
  static CardIDs getDefault() => _defaultInstance ??= create()..freeze();
  static CardIDs _defaultInstance;
  static void $checkItem(CardIDs v) {
    if (v is! CardIDs) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<String> get ids => $_getList(0);
}

class HigherLowerChoice extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('HigherLowerChoice', package: const $pb.PackageName('palace'))
    ..e<HigherLowerChoice_Type>(1, 'choice', $pb.PbFieldType.OE, HigherLowerChoice_Type.HIGHER, HigherLowerChoice_Type.valueOf, HigherLowerChoice_Type.values)
    ..a<int>(2, 'value', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  HigherLowerChoice() : super();
  HigherLowerChoice.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  HigherLowerChoice.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  HigherLowerChoice clone() => new HigherLowerChoice()..mergeFromMessage(this);
  HigherLowerChoice copyWith(void Function(HigherLowerChoice) updates) => super.copyWith((message) => updates(message as HigherLowerChoice));
  $pb.BuilderInfo get info_ => _i;
  static HigherLowerChoice create() => new HigherLowerChoice();
  static $pb.PbList<HigherLowerChoice> createRepeated() => new $pb.PbList<HigherLowerChoice>();
  static HigherLowerChoice getDefault() => _defaultInstance ??= create()..freeze();
  static HigherLowerChoice _defaultInstance;
  static void $checkItem(HigherLowerChoice v) {
    if (v is! HigherLowerChoice) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  HigherLowerChoice_Type get choice => $_getN(0);
  set choice(HigherLowerChoice_Type v) { setField(1, v); }
  bool hasChoice() => $_has(0);
  void clearChoice() => clearField(1);

  int get value => $_get(1, 0);
  set value(int v) { $_setSignedInt32(1, v); }
  bool hasValue() => $_has(1);
  void clearValue() => clearField(2);
}

class DealTowerInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('DealTowerInfo', package: const $pb.PackageName('palace'))
    ..pp<Tower>(1, 'topTowers', $pb.PbFieldType.PM, Tower.$checkItem, Tower.create)
    ..pp<Tower>(2, 'bottomTowers', $pb.PbFieldType.PM, Tower.$checkItem, Tower.create)
    ..hasRequiredFields = false
  ;

  DealTowerInfo() : super();
  DealTowerInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  DealTowerInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  DealTowerInfo clone() => new DealTowerInfo()..mergeFromMessage(this);
  DealTowerInfo copyWith(void Function(DealTowerInfo) updates) => super.copyWith((message) => updates(message as DealTowerInfo));
  $pb.BuilderInfo get info_ => _i;
  static DealTowerInfo create() => new DealTowerInfo();
  static $pb.PbList<DealTowerInfo> createRepeated() => new $pb.PbList<DealTowerInfo>();
  static DealTowerInfo getDefault() => _defaultInstance ??= create()..freeze();
  static DealTowerInfo _defaultInstance;
  static void $checkItem(DealTowerInfo v) {
    if (v is! DealTowerInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<Tower> get topTowers => $_getList(0);

  List<Tower> get bottomTowers => $_getList(1);
}

class SecondDealTowerInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('SecondDealTowerInfo', package: const $pb.PackageName('palace'))
    ..pp<Tower>(1, 'topTowers', $pb.PbFieldType.PM, Tower.$checkItem, Tower.create)
    ..hasRequiredFields = false
  ;

  SecondDealTowerInfo() : super();
  SecondDealTowerInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  SecondDealTowerInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  SecondDealTowerInfo clone() => new SecondDealTowerInfo()..mergeFromMessage(this);
  SecondDealTowerInfo copyWith(void Function(SecondDealTowerInfo) updates) => super.copyWith((message) => updates(message as SecondDealTowerInfo));
  $pb.BuilderInfo get info_ => _i;
  static SecondDealTowerInfo create() => new SecondDealTowerInfo();
  static $pb.PbList<SecondDealTowerInfo> createRepeated() => new $pb.PbList<SecondDealTowerInfo>();
  static SecondDealTowerInfo getDefault() => _defaultInstance ??= create()..freeze();
  static SecondDealTowerInfo _defaultInstance;
  static void $checkItem(SecondDealTowerInfo v) {
    if (v is! SecondDealTowerInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<Tower> get topTowers => $_getList(0);
}

class PlayFromHandInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('PlayFromHandInfo', package: const $pb.PackageName('palace'))
    ..a<int>(1, 'userIndex', $pb.PbFieldType.O3)
    ..pp<Card>(2, 'cards', $pb.PbFieldType.PM, Card.$checkItem, Card.create)
    ..hasRequiredFields = false
  ;

  PlayFromHandInfo() : super();
  PlayFromHandInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  PlayFromHandInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  PlayFromHandInfo clone() => new PlayFromHandInfo()..mergeFromMessage(this);
  PlayFromHandInfo copyWith(void Function(PlayFromHandInfo) updates) => super.copyWith((message) => updates(message as PlayFromHandInfo));
  $pb.BuilderInfo get info_ => _i;
  static PlayFromHandInfo create() => new PlayFromHandInfo();
  static $pb.PbList<PlayFromHandInfo> createRepeated() => new $pb.PbList<PlayFromHandInfo>();
  static PlayFromHandInfo getDefault() => _defaultInstance ??= create()..freeze();
  static PlayFromHandInfo _defaultInstance;
  static void $checkItem(PlayFromHandInfo v) {
    if (v is! PlayFromHandInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  int get userIndex => $_get(0, 0);
  set userIndex(int v) { $_setSignedInt32(0, v); }
  bool hasUserIndex() => $_has(0);
  void clearUserIndex() => clearField(1);

  List<Card> get cards => $_getList(1);
}

class DiscardInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('DiscardInfo', package: const $pb.PackageName('palace'))
    ..pp<Card>(1, 'cards', $pb.PbFieldType.PM, Card.$checkItem, Card.create)
    ..hasRequiredFields = false
  ;

  DiscardInfo() : super();
  DiscardInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  DiscardInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  DiscardInfo clone() => new DiscardInfo()..mergeFromMessage(this);
  DiscardInfo copyWith(void Function(DiscardInfo) updates) => super.copyWith((message) => updates(message as DiscardInfo));
  $pb.BuilderInfo get info_ => _i;
  static DiscardInfo create() => new DiscardInfo();
  static $pb.PbList<DiscardInfo> createRepeated() => new $pb.PbList<DiscardInfo>();
  static DiscardInfo getDefault() => _defaultInstance ??= create()..freeze();
  static DiscardInfo _defaultInstance;
  static void $checkItem(DiscardInfo v) {
    if (v is! DiscardInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<Card> get cards => $_getList(0);
}

class DrawInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('DrawInfo', package: const $pb.PackageName('palace'))
    ..a<int>(1, 'userIndex', $pb.PbFieldType.O3)
    ..pp<Card>(2, 'cards', $pb.PbFieldType.PM, Card.$checkItem, Card.create)
    ..hasRequiredFields = false
  ;

  DrawInfo() : super();
  DrawInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  DrawInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  DrawInfo clone() => new DrawInfo()..mergeFromMessage(this);
  DrawInfo copyWith(void Function(DrawInfo) updates) => super.copyWith((message) => updates(message as DrawInfo));
  $pb.BuilderInfo get info_ => _i;
  static DrawInfo create() => new DrawInfo();
  static $pb.PbList<DrawInfo> createRepeated() => new $pb.PbList<DrawInfo>();
  static DrawInfo getDefault() => _defaultInstance ??= create()..freeze();
  static DrawInfo _defaultInstance;
  static void $checkItem(DrawInfo v) {
    if (v is! DrawInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  int get userIndex => $_get(0, 0);
  set userIndex(int v) { $_setSignedInt32(0, v); }
  bool hasUserIndex() => $_has(0);
  void clearUserIndex() => clearField(1);

  List<Card> get cards => $_getList(1);
}

class PickUpPileInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('PickUpPileInfo', package: const $pb.PackageName('palace'))
    ..a<int>(1, 'userIndex', $pb.PbFieldType.O3)
    ..pp<Card>(2, 'cards', $pb.PbFieldType.PM, Card.$checkItem, Card.create)
    ..hasRequiredFields = false
  ;

  PickUpPileInfo() : super();
  PickUpPileInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  PickUpPileInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  PickUpPileInfo clone() => new PickUpPileInfo()..mergeFromMessage(this);
  PickUpPileInfo copyWith(void Function(PickUpPileInfo) updates) => super.copyWith((message) => updates(message as PickUpPileInfo));
  $pb.BuilderInfo get info_ => _i;
  static PickUpPileInfo create() => new PickUpPileInfo();
  static $pb.PbList<PickUpPileInfo> createRepeated() => new $pb.PbList<PickUpPileInfo>();
  static PickUpPileInfo getDefault() => _defaultInstance ??= create()..freeze();
  static PickUpPileInfo _defaultInstance;
  static void $checkItem(PickUpPileInfo v) {
    if (v is! PickUpPileInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  int get userIndex => $_get(0, 0);
  set userIndex(int v) { $_setSignedInt32(0, v); }
  bool hasUserIndex() => $_has(0);
  void clearUserIndex() => clearField(1);

  List<Card> get cards => $_getList(1);
}

class Hand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('Hand', package: const $pb.PackageName('palace'))
    ..pp<Card>(1, 'cards', $pb.PbFieldType.PM, Card.$checkItem, Card.create)
    ..hasRequiredFields = false
  ;

  Hand() : super();
  Hand.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  Hand.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  Hand clone() => new Hand()..mergeFromMessage(this);
  Hand copyWith(void Function(Hand) updates) => super.copyWith((message) => updates(message as Hand));
  $pb.BuilderInfo get info_ => _i;
  static Hand create() => new Hand();
  static $pb.PbList<Hand> createRepeated() => new $pb.PbList<Hand>();
  static Hand getDefault() => _defaultInstance ??= create()..freeze();
  static Hand _defaultInstance;
  static void $checkItem(Hand v) {
    if (v is! Hand) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<Card> get cards => $_getList(0);
}

class TowerCardsToHandInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('TowerCardsToHandInfo', package: const $pb.PackageName('palace'))
    ..a<int>(1, 'userIndex', $pb.PbFieldType.O3)
    ..pPS(2, 'cardIDs')
    ..hasRequiredFields = false
  ;

  TowerCardsToHandInfo() : super();
  TowerCardsToHandInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  TowerCardsToHandInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  TowerCardsToHandInfo clone() => new TowerCardsToHandInfo()..mergeFromMessage(this);
  TowerCardsToHandInfo copyWith(void Function(TowerCardsToHandInfo) updates) => super.copyWith((message) => updates(message as TowerCardsToHandInfo));
  $pb.BuilderInfo get info_ => _i;
  static TowerCardsToHandInfo create() => new TowerCardsToHandInfo();
  static $pb.PbList<TowerCardsToHandInfo> createRepeated() => new $pb.PbList<TowerCardsToHandInfo>();
  static TowerCardsToHandInfo getDefault() => _defaultInstance ??= create()..freeze();
  static TowerCardsToHandInfo _defaultInstance;
  static void $checkItem(TowerCardsToHandInfo v) {
    if (v is! TowerCardsToHandInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  int get userIndex => $_get(0, 0);
  set userIndex(int v) { $_setSignedInt32(0, v); }
  bool hasUserIndex() => $_has(0);
  void clearUserIndex() => clearField(1);

  List<String> get cardIDs => $_getList(1);
}

class FinalDealInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('FinalDealInfo', package: const $pb.PackageName('palace'))
    ..pp<Hand>(1, 'hands', $pb.PbFieldType.PM, Hand.$checkItem, Hand.create)
    ..hasRequiredFields = false
  ;

  FinalDealInfo() : super();
  FinalDealInfo.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  FinalDealInfo.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  FinalDealInfo clone() => new FinalDealInfo()..mergeFromMessage(this);
  FinalDealInfo copyWith(void Function(FinalDealInfo) updates) => super.copyWith((message) => updates(message as FinalDealInfo));
  $pb.BuilderInfo get info_ => _i;
  static FinalDealInfo create() => new FinalDealInfo();
  static $pb.PbList<FinalDealInfo> createRepeated() => new $pb.PbList<FinalDealInfo>();
  static FinalDealInfo getDefault() => _defaultInstance ??= create()..freeze();
  static FinalDealInfo _defaultInstance;
  static void $checkItem(FinalDealInfo v) {
    if (v is! FinalDealInfo) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<Hand> get hands => $_getList(0);
}

