///
//  Generated code. Do not modify.
//  source: cards.proto
///
// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import

const Card$json = const {
  '1': 'Card',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.palace.Card.Type', '10': 'type'},
    const {'1': 'id', '3': 2, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'value', '3': 3, '4': 1, '5': 5, '10': 'value'},
    const {'1': 'hidden', '3': 4, '4': 1, '5': 8, '10': 'hidden'},
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
    const {'1': 'cards', '3': 1, '4': 3, '5': 11, '6': '.palace.Card', '10': 'cards'},
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

