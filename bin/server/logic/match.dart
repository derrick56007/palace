part of server;

class Match {
  final List<ServerWebSocket> players;
  final hands = <ServerWebSocket, Hand>{};
  final bottomTowers = <ServerWebSocket, Tower>{};
  final topTowers = <ServerWebSocket, Tower>{};

  static const fullDeckLength = 52; // 56;
  static const towerLength = 3;
  static const basicCardLength = 9;
  static const suitLength = 4;
  static const specialDefaultCardValue = 10;

  final cardRegistry = <String, Card>{};

  ServerWebSocket activePlayer;

  final deck = <Card>[];
  final playedCards = [];

  bool mulliganWindowActive = false;
  bool gameStarted = false;
  bool gameEnded = false;

  int gameDirection = 1;

  Card _discardOrRock;

  static final _emptyCard = new Card();

  Match(this.players) {
    newGame();
  }

  newGame() async {
    gameStarted = true;
    gameEnded = false;
    mulliganWindowActive = false;
    _discardOrRock = null;
    gameDirection = 1;

    createDeck();
    deck.shuffle();
    firstTowerDeal();
    await startMulliganWindow();
    print('end mulligan window');
    secondTowerDeal();
    finalDeal();

    await new Future.delayed(const Duration(seconds: 1));

    chooseStartingPlayer();
  }

  List<Card> cardListFromCardIDList(List cardIDs) {
    final lst = <Card>[];

    for (var cardID in cardIDs) {
      lst.add(cardRegistry[cardID]);
    }

    return lst;
  }

  userPlay(ServerWebSocket socket, CardIDs userPlay) {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (mulliganWindowActive) {
      final chosenCards = cardListFromCardIDList(userPlay.ids);

      // check if card is in your tower
      for (var card in chosenCards) {
        if (!topTowers[socket].cards.contains(card)) {
          // TODO error
          return;
        }
      }

      if (chosenCards.contains(null)) {
        // TODO error missing cards
        return;
      }

      print('socket ${players.indexOf(socket)} mulliganed $chosenCards');
      mulliganCards(socket, chosenCards);

      return;
    }

    if (activePlayer != socket) {
      // TODO print error
      return;
    }

    final chosenCards = cardListFromCardIDList(userPlay.ids);
    print('socket ${players.indexOf(socket)} played $chosenCards');

    if (chosenCards.contains(null)) {
      print('error missing cards 1');
      return;
    }

    final playableCards = getSelectableCardIDs(socket);

    // check if chosen cards are playable
    for (var chosenCardID in userPlay.ids) {
      if (!playableCards.contains(chosenCardID)) {
        print('error missing cards 2');
        return;
      }
    }

    // multiple card play
    if (chosenCards.length > 1) {
      // error if chosen cards contains single play cards
      for (var chosenCard in chosenCards) {
        if (chosenCard.type == Card_Type.TOP_SWAP) {
          return;
        } else if (chosenCard.type == Card_Type.HAND_SWAP) {
          return;
        } else if (chosenCard.type == Card_Type.DISCARD_OR_ROCK) {
          return;
        }
      }

      final type = chosenCards.first.type;

      // check if all types same
      for (var chosenCard in chosenCards) {
        if (chosenCard.type != type) {
          print('types not same');
          return;
        }
      }
    }

    applyCardEffect(socket, chosenCards);
  }

  applyCardEffect(ServerWebSocket socket, List<Card> cards) {
    for (var socket in players) {
      socket.send(SocketMessage_Type.CLEAR_SELECTABLE_CARDS);
    }

    print('applying played $cards');

    cards.forEach((card) {
      card.hidden = false;
    });

    final playFromHandInfo = new PlayFromHandInfo()..cards.addAll(cards);
    for (var socketToSendTo in players) {
      socketToSendTo.send(
          SocketMessage_Type.PLAY_FROM_HAND_INFO, playFromHandInfo);
    }

    playedCards.addAll(cards);

    final hand = hands[socket];
    final topTower = topTowers[socket];
    final bottomTower = bottomTowers[socket];

    for (var card in cards) {
      if (hand.cards.contains(card)) {
        hand.cards.remove(card);
      } else if (topTower.cards.contains(card)) {
        topTower.cards[topTower.cards.indexOf(card)] = _emptyCard;
      } else if (bottomTower.cards.contains(card)) {
        bottomTower.cards[bottomTower.cards.indexOf(card)] = _emptyCard;
      }
    }

    final card = cards.first;

    if (card.type == Card_Type.BASIC) {
      endPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.HAND_SWAP) {
      final cardIDsInOtherHands = getCardIDsInOtherHands(socket);
      final selectedCards = new CardIDs()..ids.addAll(cardIDsInOtherHands);

      socket.send(SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, selectedCards);
      return;
    }

    if (card.type == Card_Type.TOP_SWAP) {
      if (socketWon(socket)) {
        onWin(socket);
        return;
      }

      final allExposedTowerCardIDs = getAllExposedTowerCardIDs();

      final selectedCards = new CardIDs()..ids.addAll(allExposedTowerCardIDs);
      socket.send(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, selectedCards);
      return;
    }

    if (card.type == Card_Type.DISCARD_OR_ROCK) {
      final drawNum = hand.cards.length;
      discardCards(hand.cards);

      //// draw cards
      final newHand = <Card>[];
      while (newHand.length < drawNum && deck.isNotEmpty) {
        final newCard = deckDraw();
        newHand.add(newCard);
      }

      hand.cards.addAll(newHand);
      sendDrawInfo(socket, newHand);

      endPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.BOMB) {
      discardCards(playedCards.where((e) => e is Card));
      playedCards.clear();
      endPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.REVERSE) {
      gameDirection = -gameDirection;
      endPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.WILD) {
      if (socketWon(socket)) {
        onWin(socket);
        return;
      }
      // send all selectable cards
      final playableCardIDs = getSelectableCardIDs(socket);

      final selectableCards = new CardIDs()..ids.addAll(playableCardIDs);
      socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
      return;

//
//      // send exposed tower cards if no more hand and no more deck
//      if (hand.cards.isEmpty && deck.isEmpty) {
//        final exposedTowerCardIds = getExposedTowerCardIDs(socket);
//        final selectableCards = new CardIDs()..ids.addAll(exposedTowerCardIds);
//        socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
//        return;
//      }
    }

    if (card.type == Card_Type.HIGHER_LOWER) {
      if (socketWon(socket)) {
        onWin(socket);
        return;
      }

      socket.send(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE);
      return;
    }
  }

  onWin(ServerWebSocket socket) {
    gameEnded = true;
    print("win -> ${players.indexOf(socket)}");

    print('hand: ${hands[socket].cards}');
    print('top tower: ${topTowers[socket].cards}');
    print('bot tower: ${topTowers[socket].cards}');
  }

  socketWon(ServerWebSocket socket) =>
      hands[socket].cards.isEmpty &&
      topTowers[socket].cards.where((card) => card == _emptyCard).length == 3 &&
      bottomTowers[socket].cards.where((card) => card == _emptyCard).length ==
          3;

  List<String> getCardIDsInOtherHands(ServerWebSocket socket) {
    final otherCardIDsInOtherHands = <String>[];
    for (var hand in hands.values.where((hand) => hand != hands[socket])) {
      for (var card in hand.cards) {
        otherCardIDsInOtherHands.add('${card.id}');
      }
    }

    return otherCardIDsInOtherHands;
  }

  List<String> getAllExposedTowerCardIDs() {
    final allExposedTowerCardIDs = <String>[];
    for (var socket in players) {
      final exposedTowerCardIDs = getExposedTowerCardIDs(socket);
      allExposedTowerCardIDs.addAll(exposedTowerCardIDs);
    }

    return allExposedTowerCardIDs;
  }

  List<String> getExposedTowerCardIDs(ServerWebSocket socket) {
    final topTower = topTowers[socket];
    final bottomTower = bottomTowers[socket];
    final cardIDs = <String>[];

    for (var index = 0; index < towerLength; index++) {
      if (topTower.cards[index] != _emptyCard) {
        cardIDs.add('${topTower.cards[index].id}');
      } else if (bottomTower.cards[index] != _emptyCard) {
        cardIDs.add('${bottomTower.cards[index].id}');
      }
    }

    return cardIDs;
  }

  List<Card> getExposedTowerCards(ServerWebSocket socket) {
    final topTower = topTowers[socket];
    final bottomTower = bottomTowers[socket];
    final cards = <Card>[];

    for (var index = 0; index < towerLength; index++) {
      if (topTower.cards[index] != _emptyCard) {
        cards.add(topTower.cards[index]);
      } else if (bottomTower.cards[index] != _emptyCard) {
        cards.add(bottomTower.cards[index]);
      }
    }

    return cards;
  }

  discardCards(List<Card> cards) {
    for (var card in cards) {
      cardRegistry.remove('${card.id}');
    }

    if (cards.isNotEmpty) {
      final discardInfo = new DiscardInfo()..cards.addAll(cards);

      for (var socket in players) {
        socket.send(SocketMessage_Type.DISCARD_INFO, discardInfo);
      }
    }

    cards.clear();
  }

  sendDrawInfo(ServerWebSocket socket, List<Card> cards) {
    if (cards.isEmpty) {
      return;
    }

    final socketIndex = players.indexOf(socket);

    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      if (socketToSendTo == socket) {
        cards.forEach((card) {
          card.hidden = false;
        });
      }

      final drawInfo = new DrawInfo()
        ..userIndex = (socketIndex - socketToSendToIndex) % players.length
        ..cards.addAll(cards);
      socketToSendTo.send(SocketMessage_Type.DRAW_INFO, drawInfo);

      if (socketToSendTo == socket) {
        cards.forEach((card) {
          card.hidden = false;
        });
      }
    }
  }

  Card deckDraw() {
    if (deck.isEmpty) {
      return null;
    }

    final card = deck.removeLast();

    if (deck.isEmpty && _discardOrRock != null) {
      _discardOrRock.type = Card_Type.BASIC;
      _discardOrRock.value = 0;
    }

    return card;
  }

  mulliganCards(ServerWebSocket socket, List<Card> cards) {
    final tower = topTowers[socket];
    final hand = hands[socket];

    for (var card in cards) {
      if (tower.cards.contains(card)) {
        hand.cards.add(card);
        tower.cards[tower.cards.indexOf(card)] = _emptyCard;
      }
    }

    final socketIndex = players.indexOf(socket);

    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      final info = new TowerCardsToHandInfo()
        ..userIndex = (socketIndex - socketToSendToIndex) % players.length
        ..cardIDs.addAll(cards.map((card) => card.id));
      socketToSendTo.send(
          SocketMessage_Type.TOWER_CARD_IDS_TO_HAND, info);
    }

    final userID = LoginManager.shared.userIDFromSocket(socket);
    print('mulligan $userID -> $cards');
    print('hand $userID -> ${hands[socket]}');
    print('top $userID -> ${topTowers[socket]}');
  }

  static const mulliganDuration = Duration(seconds: 10);

  startMulliganWindow() async {
    mulliganWindowActive = true;

    // send respective cards to mulligan
    print('open mulligan window');

    final completer = new Completer();
    new CountdownTimer(mulliganDuration, const Duration(seconds: 1)).listen(
        (CountdownTimer timer) {
      print('${timer.remaining.inSeconds} seconds left to mulligan');

      //
    }, onDone: () {
      mulliganWindowActive = false;

      for (var socket in players) {
        socket.send(SocketMessage_Type.CLEAR_SELECTABLE_CARDS);
      }

      completer.complete();
    });

    return completer.future;
  }

  chooseStartingPlayer() {
    // TODO choose random player to start
    startPlayerTurn(players.first);
  }

  int resolvePileState() {
    if (playedCards.isEmpty) return 0;

    final Card card = playedCards.lastWhere((card) => card is Card);
    return card.value;
  }

  bool isSelectableCard(Card card) {
    final pileState = resolvePileState();

    // special cards that can always be played
    if (card.type == Card_Type.REVERSE ||
        card.type == Card_Type.BOMB ||
        card.type == Card_Type.HIGHER_LOWER ||
        card.type == Card_Type.WILD) {
      return true;
    }

    // check basic cards
    if (card.type == Card_Type.BASIC) {
      // always playable if pile is empty
      if (playedCards.isEmpty) {
        return true;
      }

      // check if last card is higher lower
      if (playedCards.last is HigherLowerChoice_Type &&
          playedCards.last.choice == HigherLowerChoice_Type.LOWER) {
        if (card.value <= pileState) {
          return true;
        } else {
          return false;
        }
      }

      // card value must beat current value
      if (card.value >= pileState) {
        return true;
      }

      return false;
    }

    // cards that are supposed to be checked in getSelectableCards
    // this is because they need cards that can be played after them
    return false;
  }

  List<String> getSelectableCardIDs(ServerWebSocket socket) {
    final hand = hands[socket];

    final cards =
        hand.cards.isNotEmpty ? hand.cards : getExposedTowerCards(socket);

    final playableCardIDs = <String>[];
    final cardsToReCheck = <Card>[];

    // check basic and special cards
    for (var card in cards) {
      if (card.type == Card_Type.HAND_SWAP ||
          card.type == Card_Type.TOP_SWAP ||
          card.type == Card_Type.DISCARD_OR_ROCK) {
        cardsToReCheck.add(card);
        continue;
      }

      if (isSelectableCard(card)) {
        playableCardIDs.add('${card.id}');
      }
    }

    // check magic cards
    for (var card in cardsToReCheck) {
      // check hand swap
      if (card.type == Card_Type.HAND_SWAP && otherPlayersCardsExist(socket)) {
        playableCardIDs.add('${card.id}');
        continue;
      }

      // check top swap
      if (card.type == Card_Type.TOP_SWAP && playableCardIDs.isNotEmpty) {
        playableCardIDs.add('${card.id}');
        continue;
      }

      // check discard
      if (card.type == Card_Type.DISCARD_OR_ROCK) {
        // when deck is empty
        if (deck.isEmpty && isSelectableCard(card)) {
          playableCardIDs.add('${card.id}');
          continue;
        }

        // deck not empty
        if (deck.isNotEmpty) {
          playableCardIDs.add('${card.id}');
        }
      }
    }

    return playableCardIDs;
  }

  startPlayerTurn(ServerWebSocket socket) {
    print('socket ${players.indexOf(socket)} turn');
    activePlayer = socket;

    for (var socket in players) {
      socket.send(SocketMessage_Type.CLEAR_SELECTABLE_CARDS);
    }

    // check win
    if (socketWon(socket)) {
      onWin(socket);
      return;
    }

    final playableCardIDs = getSelectableCardIDs(socket);

    if (playableCardIDs.isNotEmpty) {
      final selectableCards = new CardIDs()..ids.addAll(playableCardIDs);
      socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
    } else {
      // no available cards to play so pick up
      pickUpPile(socket);

      // end turn
      endPlayerTurn(socket);
    }

    // TODO choose higher lower if player does not and time runs out
  }

  pickUpPile(ServerWebSocket socket) {
    // pick up cards
    final pickedUpCards = <Card>[];

    playedCards.forEach((e) {
      if (e is Card) {
        pickedUpCards.add(e);
      }
    });
    playedCards.clear();

    pickedUpCards.forEach((card) {
      card.hidden = true;
    });

    final socketIndex = players.indexOf(socket);

    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      if (socketToSendTo == socket) {
        pickedUpCards.forEach((card) {
          card.hidden = false;
        });
      }

      final pickUpPileInfo = new PickUpPileInfo()
        ..userIndex = (socketIndex - socketToSendToIndex) % players.length
        ..cards.addAll(pickedUpCards);
      socketToSendTo.send(SocketMessage_Type.PICK_UP_PILE_INFO, pickUpPileInfo);

      pickedUpCards.forEach((card) {
        card.hidden = true;
      });
    }

    // clear pile and add to hand
    final hand = hands[socket];
    hand.cards.addAll(pickedUpCards);
  }

  endPlayerTurn(ServerWebSocket socket) {
    // check if won
    if (socketWon(socket)) {
      onWin(socket);
      return;
    }

    // fill hand
    final hand = hands[socket];

    final newHand = <Card>[];
    while (newHand.length < 3 && deck.isNotEmpty) {
      final newCard = deckDraw();
      newHand.add(newCard);
    }

    hand.cards.addAll(newHand);

    sendDrawInfo(socket, newHand);

    final nextIndex =
        (players.indexOf(socket) + gameDirection) % players.length;
    startPlayerTurn(players[nextIndex]);
  }

  otherPlayersCardsExist(ServerWebSocket socket) {
    final myHand = hands[socket];
    return hands.values
        .toList()
        .where((hand) => hand != myHand && hand.cards.isNotEmpty)
        .isNotEmpty;
  }

  onHigherSelection(ServerWebSocket socket) {
    final lastCard = playedCards.last;
    if (lastCard.type == Card_Type.HIGHER_LOWER) {
      playedCards.add(HigherLowerChoice_Type.HIGHER);
    }
  }

  onLowerSelection(ServerWebSocket socket) {
    final lastCard = playedCards.last;
    if (lastCard.type == Card_Type.HIGHER_LOWER) {
      playedCards.add(HigherLowerChoice_Type.LOWER);
    }
  }

  registerAllCards(List<Card> cards) {
    for (var card in cards) {
      registerCard(card);
    }
  }

  registerCard(Card card) {
    final id = '${card.id}';

    if (cardRegistry.containsKey(id)) {
      print('error! overriding card id $id');
    }

    cardRegistry[id] = card;
  }

  createDeck() {
    deck.clear();

    final uuids = <String>[];

    for (var i = 0; i < fullDeckLength; i++) {
      uuids.add('$i');
    }
    uuids.shuffle();

    // create value cards
    for (var j = 0; j < suitLength; j++) {
      for (var cardValue = 0; cardValue < basicCardLength; cardValue++) {
        final card = Card()
          ..id = uuids.removeLast()
          ..hidden = true
          ..type = Card_Type.BASIC
          ..value = cardValue + 1;
        deck.add(card);
        registerCard(card);
      }
    }

    return;

    for (var i = 0; i < suitLength; i++) {
      final reverse = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.REVERSE
        ..value = specialDefaultCardValue;
      final wild = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.WILD
        ..value = specialDefaultCardValue;
      final higherLower = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.HIGHER_LOWER
        ..value = 0;
      final bomb = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.BOMB
        ..value = specialDefaultCardValue;

      deck.addAll([reverse, wild, higherLower, bomb]);
      registerAllCards([reverse, wild, higherLower, bomb]);
    }

    return;

    final topSwap = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.TOP_SWAP
      ..value = specialDefaultCardValue;
    final handSwap = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.HAND_SWAP
      ..value = specialDefaultCardValue;
    final rock = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.BASIC
      ..value = 0;
    final discardOrRock = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.DISCARD_OR_ROCK
      ..value = specialDefaultCardValue;

    _discardOrRock = discardOrRock;

    deck.addAll([topSwap, handSwap, rock, discardOrRock]);
    registerAllCards([topSwap, handSwap, rock, discardOrRock]);
  }

  firstTowerDeal() {
    hands.clear();
    bottomTowers.clear();
    topTowers.clear();

    // fill player towers
    for (var socket in players) {
      hands[socket] = new Hand();
      final bottomTower = new Tower();
      final topTower = new Tower();

      for (var i = 0; i < towerLength; i++) {
        bottomTower.cards.add(deckDraw());

        final topCard = deckDraw();
        topCard.hidden = !topCard.hidden;
        topTower.cards.add(topCard);
      }

      bottomTowers[socket] = bottomTower;
      topTowers[socket] = topTower;
    }

    // send deal info to all players
    for (var socket in players) {
      final List<Tower> shiftedTopTowers =
          shiftListRespectiveToSocketIndex(socket, topTowers.values.toList());
      final List<Tower> shiftedBottomTowers = shiftListRespectiveToSocketIndex(
          socket, bottomTowers.values.toList());

      final dealTowerInfo = new DealTowerInfo()
        ..topTowers.addAll(shiftedTopTowers)
        ..bottomTowers.addAll(shiftedBottomTowers);

      socket.send(SocketMessage_Type.FIRST_DEAL_TOWER_INFO, dealTowerInfo);
    }

    // send selectable cards to mulligan
    for (var socket in players) {
      final cardIDs = new CardIDs()
        ..ids.addAll(topTowers[socket].cards.map((card) => card.id));
      socket.send(SocketMessage_Type.SET_MULLIGANABLE_CARDS, cardIDs);
    }
  }

  secondTowerDeal() {
    final newTopCards = new List<Tower>(players.length);

    for (var playerIndex = 0; playerIndex < players.length; playerIndex++) {
      final socket = players[playerIndex];
      final tower = topTowers[socket];

      final newTower = new Tower();

      while (tower.cards.contains(_emptyCard)) {
        final newCard = deckDraw();
        newCard.hidden = !newCard.hidden;

        final indexOfEmptyCard = tower.cards.indexOf(_emptyCard);

        tower.cards[indexOfEmptyCard] = newCard;
        newTower.cards.add(newCard);
      }

      newTopCards[playerIndex] = newTower;
    }

    // send deal info to all players
    for (var socket in players) {
      final List<Tower> shiftedNewCards =
          shiftListRespectiveToSocketIndex(socket, newTopCards);

      final secondDealTowerInfo = new SecondDealTowerInfo()
        ..topTowers.addAll(shiftedNewCards);

      socket.send(
          SocketMessage_Type.SECOND_DEAL_TOWER_INFO, secondDealTowerInfo);
    }
  }

  finalDeal() {
    final newHands = new List<Hand>(players.length);

    for (var playerIndex = 0; playerIndex < players.length; playerIndex++) {
      final socket = players[playerIndex];
      final hand = hands[socket];

      final newHand = new Hand();

      const handLengthWithDeck = 3;

      for (var index = hand.cards.length; index < handLengthWithDeck; index++) {
        final newCard = deckDraw();
        hands[socket].cards.add(newCard);
        newHand.cards.add(newCard);
      }

      newHands[playerIndex] = newHand;
    }

    // send deal info to all players
    for (var socket in players) {
      final List<Hand> shiftedNewCards =
          shiftListRespectiveToSocketIndex(socket, newHands);

      // reveal cards in hand
      for (var card in shiftedNewCards.first.cards) {
        card.hidden = false;
      }

      final finalDealTowerInfo = new FinalDealInfo()
        ..hands.addAll(shiftedNewCards);

      socket.send(SocketMessage_Type.FINAL_DEAL_INFO, finalDealTowerInfo);

      // hide cards in hands for others
      for (var card in shiftedNewCards.first.cards) {
        card.hidden = true;
      }
    }
  }

  List shiftListRespectiveToSocketIndex(ServerWebSocket socket, List list) {
    final socketIndex = players.indexOf(socket);

    final newList = list.sublist(socketIndex);
    newList.addAll(list.sublist(0, socketIndex));

    return newList;
  }

  onTopSwapChoice(ServerWebSocket socket, CardIDs topSwapChoice) {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (activePlayer != socket) {
      return;
    }

    final lastE = playedCards.last;

    if (lastE is Card && lastE.type == Card_Type.TOP_SWAP) {
      if (topSwapChoice.ids.length != 2) {
        // TODO print error
        return;
      }

      final card1 = cardRegistry[topSwapChoice.ids.first];
      final card2 = cardRegistry[topSwapChoice.ids.last];

      final tower1 = getTowerContainingCard(card1);
      final tower2 = getTowerContainingCard(card2);

      final indexOfCard1 = tower1.indexOf(card1);
      final indexOfCard2 = tower1.indexOf(card2);

      tower1[indexOfCard1] = card2;
      tower2[indexOfCard2] = card1;

      if (!card1.hidden || !card2.hidden) {
        card1.hidden = false;
        card2.hidden = false;
      }

      // TODO send info

      startPlayerTurn(socket);
    }
  }

  List<Card> getTowerContainingCard(Card card) {
    for (var socket in players) {
      for (var index = 0; index < towerLength; index++) {
        if (topTowers[socket].cards.contains(card)) {
          return topTowers[socket].cards;
        }

        if (bottomTowers[socket].cards.contains(card)) {
          return bottomTowers[socket].cards;
        }
      }
    }

    return null;
  }

  ServerWebSocket getOwnerOfCardID(String cardID) {
    final card = cardRegistry[cardID];

    for (var socket in players) {
      final hand = hands[socket];

      if (hand.cards.contains(card)) {
        return socket;
      }
    }

    return null;
  }

  onHandSwapChoice(ServerWebSocket socket, CardIDs handSwapChoice) {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (activePlayer != socket) {
      return;
    }

    final lastE = playedCards.last;

    if (lastE is Card &&
        lastE.type == Card_Type.HAND_SWAP &&
        handSwapChoice.ids.isNotEmpty) {
      final otherSocket = getOwnerOfCardID(handSwapChoice.ids.first);

      final tempMyHand = hands[socket];
      hands[socket] = hands[otherSocket];
      hands[otherSocket] = tempMyHand;

      // TODO alert

      startPlayerTurn(socket);
    }
  }

  onHigherLowerChoice(
      ServerWebSocket socket, HigherLowerChoice higherLowerChoice) {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (activePlayer != socket) {
      return;
    }

    final lastE = playedCards.last;

    if (lastE is Card && lastE.type == Card_Type.HIGHER_LOWER) {
      playedCards.add(higherLowerChoice.choice);

      // TODO send info

      endPlayerTurn(socket);
    }
  }
}
