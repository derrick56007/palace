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

class FirstDeal extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = new $pb.BuilderInfo('FirstDeal', package: const $pb.PackageName('palace'))
    ..pp<Tower>(1, 'topTowers', $pb.PbFieldType.PM, Tower.$checkItem, Tower.create)
    ..hasRequiredFields = false
  ;

  FirstDeal() : super();
  FirstDeal.fromBuffer(List<int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromBuffer(i, r);
  FirstDeal.fromJson(String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) : super.fromJson(i, r);
  FirstDeal clone() => new FirstDeal()..mergeFromMessage(this);
  FirstDeal copyWith(void Function(FirstDeal) updates) => super.copyWith((message) => updates(message as FirstDeal));
  $pb.BuilderInfo get info_ => _i;
  static FirstDeal create() => new FirstDeal();
  static $pb.PbList<FirstDeal> createRepeated() => new $pb.PbList<FirstDeal>();
  static FirstDeal getDefault() => _defaultInstance ??= create()..freeze();
  static FirstDeal _defaultInstance;
  static void $checkItem(FirstDeal v) {
    if (v is! FirstDeal) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  List<Tower> get topTowers => $_getList(0);
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

