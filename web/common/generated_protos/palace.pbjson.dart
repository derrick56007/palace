///
//  Generated code. Do not modify.
//  source: palace.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

const Card$json = const {
  '1': 'Card',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.palace.Card.Type', '10': 'type'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'value', '3': 3, '4': 1, '5': 5, '10': 'value'},
    const {'1': 'hidden', '3': 4, '4': 1, '5': 8, '10': 'hidden'},
    const {'1': 'playerIndex', '3': 5, '4': 1, '5': 5, '10': 'playerIndex'},
    const {'1': 'activated', '3': 6, '4': 1, '5': 8, '10': 'activated'},
  ],
  '4': const [Card_Type$json],
};

const Card_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'BASIC', '2': 0},
    const {'1': 'REVERSE', '2': 1},
    const {'1': 'BOMB', '2': 2},
    const {'1': 'HIGHER_LOWER', '2': 3},
    const {'1': 'WILD', '2': 4},
    const {'1': 'TOP_SWAP', '2': 5},
    const {'1': 'HAND_SWAP', '2': 6},
    const {'1': 'DISCARD_OR_ROCK', '2': 7},
  ],
};

const Tower$json = const {
  '1': 'Tower',
  '2': const [
    const {'1': 'cards', '3': 1, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards'},
  ],
};

const CardIDs$json = const {
  '1': 'CardIDs',
  '2': const [
    const {'1': 'ids', '3': 1, '4': 3, '5': 9, '10': 'ids'},
  ],
};

const HigherLowerChoice$json = const {
  '1': 'HigherLowerChoice',
  '2': const [
    const {'1': 'choice', '3': 1, '4': 1, '5': 14, '6': '.palace.HigherLowerChoice.Type', '10': 'choice'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '4': const [HigherLowerChoice_Type$json],
};

const HigherLowerChoice_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'HIGHER', '2': 0},
    const {'1': 'LOWER', '2': 1},
  ],
};

const DealTowerInfo$json = const {
  '1': 'DealTowerInfo',
  '2': const [
    const {'1': 'topTowers', '3': 1, '4': 3, '5': 11, '6': '.palace.Tower', '10': 'topTowers'},
    const {'1': 'bottomTowers', '3': 2, '4': 3, '5': 11, '6': '.palace.Tower', '10': 'bottomTowers'},
  ],
};

const SecondDealTowerInfo$json = const {
  '1': 'SecondDealTowerInfo',
  '2': const [
    const {'1': 'topTowers', '3': 1, '4': 3, '5': 11, '6': '.palace.Tower', '10': 'topTowers'},
  ],
};

const PlayFromHandInfo$json = const {
  '1': 'PlayFromHandInfo',
  '2': const [
    const {'1': 'userIndex', '3': 1, '4': 1, '5': 5, '10': 'userIndex'},
    const {'1': 'cards', '3': 2, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards'},
  ],
};

const DiscardInfo$json = const {
  '1': 'DiscardInfo',
  '2': const [
    const {'1': 'cards', '3': 1, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards'},
  ],
};

const DrawInfo$json = const {
  '1': 'DrawInfo',
  '2': const [
    const {'1': 'userIndex', '3': 1, '4': 1, '5': 5, '10': 'userIndex'},
    const {'1': 'cards', '3': 2, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards'},
  ],
};

const PickUpPileInfo$json = const {
  '1': 'PickUpPileInfo',
  '2': const [
    const {'1': 'userIndex', '3': 1, '4': 1, '5': 5, '10': 'userIndex'},
    const {'1': 'cards', '3': 2, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards'},
  ],
};

const Hand$json = const {
  '1': 'Hand',
  '2': const [
    const {'1': 'cards', '3': 1, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards'},
  ],
};

const TowerCardsToHandInfo$json = const {
  '1': 'TowerCardsToHandInfo',
  '2': const [
    const {'1': 'userIndex', '3': 1, '4': 1, '5': 5, '10': 'userIndex'},
    const {'1': 'cardIDs', '3': 2, '4': 3, '5': 9, '10': 'cardIDs'},
  ],
};

const FinalDealInfo$json = const {
  '1': 'FinalDealInfo',
  '2': const [
    const {'1': 'hands', '3': 1, '4': 3, '5': 11, '6': '.palace.Hand', '10': 'hands'},
  ],
};

const TopSwapInfo$json = const {
  '1': 'TopSwapInfo',
  '2': const [
    const {'1': 'card1', '3': 1, '4': 1, '5': 11, '6': '.palace.Card', '10': 'card1'},
    const {'1': 'card2', '3': 2, '4': 1, '5': 11, '6': '.palace.Card', '10': 'card2'},
  ],
};

const HandSwapInfo$json = const {
  '1': 'HandSwapInfo',
  '2': const [
    const {'1': 'userIndex1', '3': 1, '4': 1, '5': 5, '10': 'userIndex1'},
    const {'1': 'userIndex2', '3': 2, '4': 1, '5': 5, '10': 'userIndex2'},
    const {'1': 'cards1', '3': 3, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards1'},
    const {'1': 'cards2', '3': 4, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards2'},
  ],
};

const LoginCredentials$json = const {
  '1': 'LoginCredentials',
  '2': const [
    const {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    const {'1': 'passCode', '3': 2, '4': 1, '5': 9, '10': 'passCode'},
  ],
};

const LobbyInfo$json = const {
  '1': 'LobbyInfo',
  '2': const [
    const {'1': 'host', '3': 1, '4': 1, '5': 9, '10': 'host'},
    const {'1': 'players', '3': 2, '4': 3, '5': 11, '6': '.palace.PlayerEntry', '10': 'players'},
    const {'1': 'canStart', '3': 3, '4': 1, '5': 8, '10': 'canStart'},
    const {'1': 'canJoin', '3': 4, '4': 1, '5': 8, '10': 'canJoin'},
  ],
};

const PlayerEntry$json = const {
  '1': 'PlayerEntry',
  '2': const [
    const {'1': 'userID', '3': 1, '4': 1, '5': 9, '10': 'userID'},
    const {'1': 'ready', '3': 2, '4': 1, '5': 8, '10': 'ready'},
  ],
};

const UserIDs$json = const {
  '1': 'UserIDs',
  '2': const [
    const {'1': 'ids', '3': 1, '4': 3, '5': 9, '10': 'ids'},
  ],
};

const SimpleInfo$json = const {
  '1': 'SimpleInfo',
  '2': const [
    const {'1': 'info', '3': 1, '4': 1, '5': 9, '10': 'info'},
  ],
};

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
    const {'1': 'FRIEND_ITEM_INFO', '2': 21},
    const {'1': 'LOBBY_INFO', '2': 22},
    const {'1': 'LOGOUT_SUCCESSFUL', '2': 23},
    const {'1': 'CHANGE_DISCARD_TO_ROCK', '2': 24},
    const {'1': 'MULLIGAN_TIMER_UPDATE', '2': 25},
    const {'1': 'LOGIN', '2': 26},
    const {'1': 'REGISTER', '2': 27},
    const {'1': 'ADD_FRIEND', '2': 28},
    const {'1': 'ACCEPT_FRIEND_REQUEST', '2': 29},
    const {'1': 'SEND_MATCH_INVITE', '2': 30},
    const {'1': 'MATCH_ACCEPT', '2': 31},
    const {'1': 'MATCH_DECLINE', '2': 32},
    const {'1': 'USER_PLAY', '2': 33},
    const {'1': 'HANDSWAP_CHOICE', '2': 34},
    const {'1': 'TOPSWAP_CHOICE', '2': 35},
    const {'1': 'HIGHERLOWER_CHOICE', '2': 36},
    const {'1': 'DECLINE_FRIEND_REQUEST', '2': 37},
    const {'1': 'START', '2': 38},
    const {'1': 'REQUEST_PICK_UP', '2': 39},
    const {'1': 'QUICK_JOIN', '2': 40},
    const {'1': 'LEAVE_GAME', '2': 41},
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

const RequestHigherLowerChoiceInfo$json = const {
  '1': 'RequestHigherLowerChoiceInfo',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 5, '10': 'value'},
  ],
};

