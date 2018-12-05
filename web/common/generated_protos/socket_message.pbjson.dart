///
//  Generated code. Do not modify.
//  source: socket_message.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

const SocketMessage$json = const {
  '1': 'SocketMessage',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.palace.SocketMessage.Type', '10': 'type'},
    const {'1': 'json', '3': 2, '4': 1, '5': 9, '10': 'json'},
  ],
  '4': const [SocketMessage_Type$json],
};

const SocketMessage_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'ERROR', '2': 0},
    const {'1': 'LOGIN_SUCCESSFUL', '2': 1},
    const {'1': 'FRIEND_REQUEST', '2': 2},
    const {'1': 'MATCH_INVITE', '2': 3},
    const {'1': 'MATCH_INVITE_CANCEL', '2': 4},
    const {'1': 'MATCH_START', '2': 5},
    const {'1': 'FIRST_DEAL_TOWER_INFO', '2': 6},
    const {'1': 'SECOND_DEAL_TOWER_INFO', '2': 7},
    const {'1': 'FINAL_DEAL_INFO', '2': 8},
    const {'1': 'TOWER_CARD_IDS_TO_HAND', '2': 9},
    const {'1': 'SET_SELECTABLE_CARDS', '2': 10},
    const {'1': 'SET_MULLIGANABLE_CARDS', '2': 11},
    const {'1': 'CLEAR_SELECTABLE_CARDS', '2': 12},
    const {'1': 'DRAW_INFO', '2': 13},
    const {'1': 'PLAY_FROM_HAND_INFO', '2': 14},
    const {'1': 'PICK_UP_PILE_INFO', '2': 15},
    const {'1': 'DISCARD_INFO', '2': 16},
    const {'1': 'REQUEST_HANDSWAP_CHOICE', '2': 17},
    const {'1': 'REQUEST_TOPSWAP_CHOICE', '2': 18},
    const {'1': 'REQUEST_HIGHERLOWER_CHOICE', '2': 19},
    const {'1': 'ACTIVE_PLAYER_INDEX', '2': 20},
    const {'1': 'LOGIN', '2': 21},
    const {'1': 'REGISTER', '2': 22},
    const {'1': 'ADD_FRIEND', '2': 23},
    const {'1': 'ACCEPT_FRIEND_REQUEST', '2': 24},
    const {'1': 'SEND_MATCH_INVITE', '2': 25},
    const {'1': 'MATCH_ACCEPT', '2': 26},
    const {'1': 'MATCH_DECLINE', '2': 27},
    const {'1': 'USER_PLAY', '2': 28},
    const {'1': 'HANDSWAP_CHOICE', '2': 29},
    const {'1': 'TOPSWAP_CHOICE', '2': 30},
    const {'1': 'HIGHERLOWER_CHOICE', '2': 31},
    const {'1': 'DECLINE_FRIEND_REQUEST', '2': 32},
    const {'1': 'START', '2': 33},
    const {'1': 'FRIEND_ITEM_INFO', '2': 34},
    const {'1': 'LOBBY_INFO', '2': 35},
    const {'1': 'LOGOUT_SUCCESSFULL', '2': 36},
  ],
};

const ActivePlayerIndex$json = const {
  '1': 'ActivePlayerIndex',
  '2': const [
    const {'1': 'index', '3': 1, '4': 1, '5': 5, '10': 'index'},
  ],
};

const FriendItemInfo$json = const {
  '1': 'FriendItemInfo',
  '2': const [
    const {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    const {'1': 'online', '3': 2, '4': 1, '5': 8, '10': 'online'},
    const {'1': 'invitable', '3': 3, '4': 1, '5': 8, '10': 'invitable'},
    const {'1': 'statusText', '3': 4, '4': 1, '5': 9, '10': 'statusText'},
    const {'1': 'color', '3': 5, '4': 1, '5': 9, '10': 'color'},
  ],
};

