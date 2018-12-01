///
//  Generated code. Do not modify.
//  source: socket_message.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' show int, dynamic, String, List, Map;
import 'package:protobuf/protobuf.dart' as $pb;

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
  static const SocketMessage_Type LOGIN = const SocketMessage_Type._(21, 'LOGIN');
  static const SocketMessage_Type REGISTER = const SocketMessage_Type._(22, 'REGISTER');
  static const SocketMessage_Type ADD_FRIEND = const SocketMessage_Type._(23, 'ADD_FRIEND');
  static const SocketMessage_Type ACCEPT_FRIEND_REQUEST = const SocketMessage_Type._(24, 'ACCEPT_FRIEND_REQUEST');
  static const SocketMessage_Type SEND_MATCH_INVITE = const SocketMessage_Type._(25, 'SEND_MATCH_INVITE');
  static const SocketMessage_Type MATCH_ACCEPT = const SocketMessage_Type._(26, 'MATCH_ACCEPT');
  static const SocketMessage_Type MATCH_DECLINE = const SocketMessage_Type._(27, 'MATCH_DECLINE');
  static const SocketMessage_Type USER_PLAY = const SocketMessage_Type._(28, 'USER_PLAY');
  static const SocketMessage_Type HANDSWAP_CHOICE = const SocketMessage_Type._(29, 'HANDSWAP_CHOICE');
  static const SocketMessage_Type TOPSWAP_CHOICE = const SocketMessage_Type._(30, 'TOPSWAP_CHOICE');
  static const SocketMessage_Type HIGHERLOWER_CHOICE = const SocketMessage_Type._(31, 'HIGHERLOWER_CHOICE');

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
  ];

  static final Map<int, SocketMessage_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SocketMessage_Type valueOf(int value) => _byValue[value];
  static void $checkItem(SocketMessage_Type v) {
    if (v is! SocketMessage_Type) $pb.checkItemFailed(v, 'SocketMessage_Type');
  }

  const SocketMessage_Type._(int v, String n) : super(v, n);
}

