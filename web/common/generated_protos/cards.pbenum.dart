///
//  Generated code. Do not modify.
//  source: cards.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' show int, dynamic, String, List, Map;
import 'package:protobuf/protobuf.dart' as $pb;

class Card_Type extends $pb.ProtobufEnum {
  static const Card_Type BASIC = const Card_Type._(0, 'BASIC');
  static const Card_Type REVERSE = const Card_Type._(1, 'REVERSE');
  static const Card_Type BOMB = const Card_Type._(2, 'BOMB');
  static const Card_Type HIGHER_LOWER = const Card_Type._(3, 'HIGHER_LOWER');
  static const Card_Type WILD = const Card_Type._(4, 'WILD');
  static const Card_Type TOP_SWAP = const Card_Type._(5, 'TOP_SWAP');
  static const Card_Type HAND_SWAP = const Card_Type._(6, 'HAND_SWAP');
  static const Card_Type DISCARD_OR_ROCK = const Card_Type._(7, 'DISCARD_OR_ROCK');

  static const List<Card_Type> values = const <Card_Type> [
    BASIC,
    REVERSE,
    BOMB,
    HIGHER_LOWER,
    WILD,
    TOP_SWAP,
    HAND_SWAP,
    DISCARD_OR_ROCK,
  ];

  static final Map<int, Card_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Card_Type valueOf(int value) => _byValue[value];
  static void $checkItem(Card_Type v) {
    if (v is! Card_Type) $pb.checkItemFailed(v, 'Card_Type');
  }

  const Card_Type._(int v, String n) : super(v, n);
}

class HigherLowerChoice_Type extends $pb.ProtobufEnum {
  static const HigherLowerChoice_Type HIGHER = const HigherLowerChoice_Type._(0, 'HIGHER');
  static const HigherLowerChoice_Type LOWER = const HigherLowerChoice_Type._(1, 'LOWER');

  static const List<HigherLowerChoice_Type> values = const <HigherLowerChoice_Type> [
    HIGHER,
    LOWER,
  ];

  static final Map<int, HigherLowerChoice_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HigherLowerChoice_Type valueOf(int value) => _byValue[value];
  static void $checkItem(HigherLowerChoice_Type v) {
    if (v is! HigherLowerChoice_Type) $pb.checkItemFailed(v, 'HigherLowerChoice_Type');
  }

  const HigherLowerChoice_Type._(int v, String n) : super(v, n);
}

