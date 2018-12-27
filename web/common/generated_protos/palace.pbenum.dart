///
//  Generated code. Do not modify.
//  source: palace.proto
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

class SocketMessage_Type extends $pb.ProtobufEnum {
  static const SocketMessage_Type ERROR = const SocketMessage_Type._(0, 'ERROR');
  static const SocketMessage_Type LOGIN_SUCCESSFUL = const SocketMessage_Type._(1, 'LOGIN_SUCCESSFUL');
  static const SocketMessage_Type FRIEND_REQUEST = const SocketMessage_Type._(2, 'FRIEND_REQUEST');
  static const SocketMessage_Type MATCH_INVITE = const SocketMessage_Type._(3, 'MATCH_INVITE');
  static const SocketMessage_Type MATCH_INVITE_CANCEL = const SocketMessage_Type._(4, 'MATCH_INVITE_CANCEL');
  static const SocketMessage_Type MATCH_START = const SocketMessage_Type._(5, 'MATCH_START');
  static const SocketMessage_Type FIRST_DEAL_TOWER_INFO = const SocketMessage_Type._(6, 'FIRST_DEAL_TOWER_INFO');
  static const SocketMessage_Type SECOND_DEAL_TOWER_INFO = const SocketMessage_Type._(7, 'SECOND_DEAL_TOWER_INFO');
  static const SocketMessage_Type FINAL_DEAL_INFO = const SocketMessage_Type._(8, 'FINAL_DEAL_INFO');
  static const SocketMessage_Type TOWER_CARD_IDS_TO_HAND = const SocketMessage_Type._(9, 'TOWER_CARD_IDS_TO_HAND');
  static const SocketMessage_Type SET_SELECTABLE_CARDS = const SocketMessage_Type._(10, 'SET_SELECTABLE_CARDS');
  static const SocketMessage_Type SET_MULLIGANABLE_CARDS = const SocketMessage_Type._(11, 'SET_MULLIGANABLE_CARDS');
  static const SocketMessage_Type CLEAR_SELECTABLE_CARDS = const SocketMessage_Type._(12, 'CLEAR_SELECTABLE_CARDS');
  static const SocketMessage_Type DRAW_INFO = const SocketMessage_Type._(13, 'DRAW_INFO');
  static const SocketMessage_Type PLAY_FROM_HAND_INFO = const SocketMessage_Type._(14, 'PLAY_FROM_HAND_INFO');
  static const SocketMessage_Type PICK_UP_PILE_INFO = const SocketMessage_Type._(15, 'PICK_UP_PILE_INFO');
  static const SocketMessage_Type DISCARD_INFO = const SocketMessage_Type._(16, 'DISCARD_INFO');
  static const SocketMessage_Type REQUEST_HANDSWAP_CHOICE = const SocketMessage_Type._(17, 'REQUEST_HANDSWAP_CHOICE');
  static const SocketMessage_Type REQUEST_TOPSWAP_CHOICE = const SocketMessage_Type._(18, 'REQUEST_TOPSWAP_CHOICE');
  static const SocketMessage_Type REQUEST_HIGHERLOWER_CHOICE = const SocketMessage_Type._(19, 'REQUEST_HIGHERLOWER_CHOICE');
  static const SocketMessage_Type ACTIVE_PLAYER_INDEX = const SocketMessage_Type._(20, 'ACTIVE_PLAYER_INDEX');
  static const SocketMessage_Type FRIEND_ITEM_INFO = const SocketMessage_Type._(21, 'FRIEND_ITEM_INFO');
  static const SocketMessage_Type LOBBY_INFO = const SocketMessage_Type._(22, 'LOBBY_INFO');
  static const SocketMessage_Type LOGOUT_SUCCESSFUL = const SocketMessage_Type._(23, 'LOGOUT_SUCCESSFUL');
  static const SocketMessage_Type CHANGE_DISCARD_TO_ROCK = const SocketMessage_Type._(24, 'CHANGE_DISCARD_TO_ROCK');
  static const SocketMessage_Type MULLIGAN_TIMER_UPDATE = const SocketMessage_Type._(25, 'MULLIGAN_TIMER_UPDATE');
  static const SocketMessage_Type ENABLE_PICK_UP = const SocketMessage_Type._(26, 'ENABLE_PICK_UP');
  static const SocketMessage_Type DISABLE_PICK_UP = const SocketMessage_Type._(27, 'DISABLE_PICK_UP');
  static const SocketMessage_Type LOGIN = const SocketMessage_Type._(28, 'LOGIN');
  static const SocketMessage_Type REGISTER = const SocketMessage_Type._(29, 'REGISTER');
  static const SocketMessage_Type ADD_FRIEND = const SocketMessage_Type._(30, 'ADD_FRIEND');
  static const SocketMessage_Type ACCEPT_FRIEND_REQUEST = const SocketMessage_Type._(31, 'ACCEPT_FRIEND_REQUEST');
  static const SocketMessage_Type SEND_MATCH_INVITE = const SocketMessage_Type._(32, 'SEND_MATCH_INVITE');
  static const SocketMessage_Type MATCH_ACCEPT = const SocketMessage_Type._(33, 'MATCH_ACCEPT');
  static const SocketMessage_Type MATCH_DECLINE = const SocketMessage_Type._(34, 'MATCH_DECLINE');
  static const SocketMessage_Type USER_PLAY = const SocketMessage_Type._(35, 'USER_PLAY');
  static const SocketMessage_Type HANDSWAP_CHOICE = const SocketMessage_Type._(36, 'HANDSWAP_CHOICE');
  static const SocketMessage_Type TOPSWAP_CHOICE = const SocketMessage_Type._(37, 'TOPSWAP_CHOICE');
  static const SocketMessage_Type HIGHERLOWER_CHOICE = const SocketMessage_Type._(38, 'HIGHERLOWER_CHOICE');
  static const SocketMessage_Type DECLINE_FRIEND_REQUEST = const SocketMessage_Type._(39, 'DECLINE_FRIEND_REQUEST');
  static const SocketMessage_Type START = const SocketMessage_Type._(40, 'START');
  static const SocketMessage_Type REQUEST_PICK_UP = const SocketMessage_Type._(41, 'REQUEST_PICK_UP');
  static const SocketMessage_Type QUICK_JOIN = const SocketMessage_Type._(42, 'QUICK_JOIN');
  static const SocketMessage_Type LEAVE_GAME = const SocketMessage_Type._(43, 'LEAVE_GAME');

  static const List<SocketMessage_Type> values = const <SocketMessage_Type> [
    ERROR,
    LOGIN_SUCCESSFUL,
    FRIEND_REQUEST,
    MATCH_INVITE,
    MATCH_INVITE_CANCEL,
    MATCH_START,
    FIRST_DEAL_TOWER_INFO,
    SECOND_DEAL_TOWER_INFO,
    FINAL_DEAL_INFO,
    TOWER_CARD_IDS_TO_HAND,
    SET_SELECTABLE_CARDS,
    SET_MULLIGANABLE_CARDS,
    CLEAR_SELECTABLE_CARDS,
    DRAW_INFO,
    PLAY_FROM_HAND_INFO,
    PICK_UP_PILE_INFO,
    DISCARD_INFO,
    REQUEST_HANDSWAP_CHOICE,
    REQUEST_TOPSWAP_CHOICE,
    REQUEST_HIGHERLOWER_CHOICE,
    ACTIVE_PLAYER_INDEX,
    FRIEND_ITEM_INFO,
    LOBBY_INFO,
    LOGOUT_SUCCESSFUL,
    CHANGE_DISCARD_TO_ROCK,
    MULLIGAN_TIMER_UPDATE,
    ENABLE_PICK_UP,
    DISABLE_PICK_UP,
    LOGIN,
    REGISTER,
    ADD_FRIEND,
    ACCEPT_FRIEND_REQUEST,
    SEND_MATCH_INVITE,
    MATCH_ACCEPT,
    MATCH_DECLINE,
    USER_PLAY,
    HANDSWAP_CHOICE,
    TOPSWAP_CHOICE,
    HIGHERLOWER_CHOICE,
    DECLINE_FRIEND_REQUEST,
    START,
    REQUEST_PICK_UP,
    QUICK_JOIN,
    LEAVE_GAME,
  ];

  static final Map<int, SocketMessage_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SocketMessage_Type valueOf(int value) => _byValue[value];
  static void $checkItem(SocketMessage_Type v) {
    if (v is! SocketMessage_Type) $pb.checkItemFailed(v, 'SocketMessage_Type');
  }

  const SocketMessage_Type._(int v, String n) : super(v, n);
}

