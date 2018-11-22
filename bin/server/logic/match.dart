part of server;

class Match {
  final List<ServerWebSocket> players;
  final hands = <ServerWebSocket, List<Card>>{};
  final bottomTowers = <ServerWebSocket, List<Card>>{};
  final topTowers = <ServerWebSocket, List<Card>>{};

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
    print(hands);
    print(topTowers);
    print(bottomTowers);
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
        if (chosenCard.type == CardType.topSwap) {
          return;
        } else if (chosenCard.type == CardType.handSwap) {
          return;
        } else if (chosenCard.type == CardType.discardOrRock) {
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

    // send play info
    final socketIndex = players.indexOf(socket);

    cards.forEach((card) {
      card.hidden = false;
    });

    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      final playFromHandInfo = new PlayFromHandInfo(
          (socketIndex - socketToSendToIndex) % players.length, cards);
      socketToSendTo.send(
          SocketMessage_Type.PLAY_FROM_HAND_INFO, playFromHandInfo);
    }

    playedCards.addAll(cards);

    final hand = hands[socket];

    for (var card in cards) {
      hand.remove(card);
    }

    final card = cards.first;

    if (card.type == CardType.basic) {
      endPlayerTurn(socket);
      return;
    }

    if (card.type == CardType.handSwap) {
      final cardIDsInOtherHands = getCardIDsInOtherHands(socket);
      final selectedCards = new CardIDs()..ids.addAll(cardIDsInOtherHands);

      socket.send(SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, selectedCards);
      return;
    }

    if (card.type == CardType.topSwap) {
      final allExposedTowerCardIDs = getAllExposedTowerCardIDs();

      final selectedCards = new CardIDs()..ids.addAll(allExposedTowerCardIDs);
      socket.send(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, selectedCards);
      return;
    }

    if (card.type == CardType.discardOrRock) {
      final drawNum = hand.length;
      discardCards(hand);
      drawCards(socket, drawNum);
      endPlayerTurn(socket);
      return;
    }

    if (card.type == CardType.bomb) {
      discardCards(playedCards.where((e) => e is Card));
      playedCards.clear();
      endPlayerTurn(socket);
      return;
    }

    if (card.type == CardType.reverse) {
      gameDirection = -gameDirection;
      endPlayerTurn(socket);
      return;
    }

    if (card.type == CardType.wild) {
      // send all cards in hand
      if (hand.isNotEmpty) {
        final playableCardIDs = <String>[];

        for (var card in hand) {
          playableCardIDs.add('${card.id}');
        }

        final selectableCards = new CardIDs()..ids.addAll(playableCardIDs);
        socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
        return;
      }

      // send exposed cards
      if (hand.isEmpty) {
        final exposedTowerCardIds = getExposedTowerCardIDs(socket);
        final selectableCards = new CardIDs()..ids.addAll(exposedTowerCardIds);
        socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
        return;
      }
    }

    if (card.type == CardType.higherLower) {
      socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS);
      return;
    }
  }

  List<String> getCardIDsInOtherHands(ServerWebSocket socket) {
    final otherCardIDsInOtherHands = <String>[];
    for (var hand in hands.values.where((hand) => hand != hands[socket])) {
      for (var card in hand) {
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
      if (topTower[index] != null) {
        cardIDs.add('${topTower[index].id}');
      } else if (bottomTower[index] != null) {
        cardIDs.add('${bottomTower[index].id}');
      }
    }

    return cardIDs;
  }

  discardCards(List<Card> cards) {
    final discardedCardIDs = <String>[];

    for (var card in cards) {
      discardedCardIDs.add(card.id);

      cardRegistry.remove('${card.id}');
    }

    if (discardedCardIDs.isNotEmpty) {
      final bombInfo = new DiscardInfo(discardedCardIDs);

      for (var socket in players) {
        socket.send(SocketMessage_Type.DISCARD_INFO, bombInfo);
      }
    }

    cards.clear();
  }

  drawCards(ServerWebSocket socket, int num) {
    final hand = hands[socket];

    final newHand = <Card>[];
    while (newHand.length < num && deck.isNotEmpty) {
      final newCard = deckDraw();
      newHand.add(newCard);
    }

    hand.addAll(newHand);
    sendDrawInfo(socket, newHand);
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

      final drawInfo = new DrawInfo(
          (socketIndex - socketToSendToIndex) % players.length, cards);
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

    if (deck.isEmpty) {
      _discardOrRock.type = Card_Type.BASIC;
      _discardOrRock.value = 0;
    }

    return card;
  }

  mulliganCards(ServerWebSocket socket, List<Card> cards) {
    final tower = topTowers[socket];
    final hand = hands[socket];

    for (var card in cards) {
      if (tower.contains(card)) {
        final cardIndex = tower.indexOf(card);
        hand.add(card);
        tower[cardIndex] = null;
      }
    }

    final userID = LoginManager.shared.userIDFromSocket(socket);
    print('mulligan $userID -> $cards');
    print('hand $userID -> ${hands[socket]}');
    print('top $userID -> ${topTowers[socket]}');
  }

  startMulliganWindow() async {
    mulliganWindowActive = true;

    for (var socket in players) {
      final cardIDs = topTowers[socket].map((card) => card.id).toList();

      final selectableCards = new CardIDs()..ids.addAll(cardIDs);

      socket.send(SocketMessage_Type.SET_MULLIGANABLE_CARDS, selectableCards);
    }

    // send respective cards to mulligan
    print('open mulligan window');

    final completer = new Completer();
    new CountdownTimer(const Duration(seconds: 5), const Duration(seconds: 1))
        .listen((CountdownTimer timer) {
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
    return 0;
  }

  bool isSelectableCard(Card card) {
    final pileState = resolvePileState();

    // special cards that can always be played
    if (card.type == CardType.reverse ||
        card.type == CardType.bomb ||
        card.type == CardType.higherLower ||
        card.type == CardType.wild) {
      return true;
    }

    // check basic cards
    if (card.type == CardType.basic) {
      // always playable if pile is empty
      if (playedCards.isEmpty) {
        return true;
      }

      // check if last card is higher lower
      if (playedCards.last is HigherLowerChoices &&
          playedCards.last == HigherLowerChoices.lower) {
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

    final playableCardIDs = <String>[];
    final cardsToReCheck = <Card>[];

    // check basic and special cards
    for (var card in hand) {
      if (card.type == CardType.handSwap ||
          card.type == CardType.topSwap ||
          card.type == CardType.discardOrRock) {
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
      if (card.type == CardType.handSwap && otherPlayersCardsExist(socket)) {
        playableCardIDs.add('${card.id}');
        continue;
      }

      // check top swap
      if (card.type == CardType.topSwap && playableCardIDs.isNotEmpty) {
        playableCardIDs.add('${card.id}');
        continue;
      }

      // check discard
      if (card.type == CardType.discardOrRock) {
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
    final pickedUpCards = playedCards.where((e) => e is Card) as List<Card>;
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

      final pickUpPileInfo = new PickUpPileInfo(
          (socketIndex - socketToSendToIndex) % players.length, pickedUpCards);
      socketToSendTo.send(SocketMessage_Type.PICK_UP_PILE_INFO, pickUpPileInfo);

      if (socketToSendTo == socket) {
        pickedUpCards.forEach((card) {
          card.hidden = false;
        });
      }
    }

    // clear pile and add to hand
    final hand = hands[socket];
    hand.addAll(pickedUpCards);
  }

  endPlayerTurn(ServerWebSocket socket) {
    // check if won

    // fill hand
    final hand = hands[socket];
    if (hand.length < 3) {
      drawCards(socket, 3 - hand.length);
    }

    final nextIndex =
        (players.indexOf(socket) + gameDirection) % players.length;
    startPlayerTurn(players[nextIndex]);
  }

  otherPlayersCardsExist(ServerWebSocket socket) {
    final myHand = hands[socket];
    return hands.values
        .toList()
        .where((hand) => hand != myHand && hand.isNotEmpty)
        .isNotEmpty;
  }

  onHigherSelection(ServerWebSocket socket) {
    final lastCard = playedCards.last;
    if (lastCard.type == CardType.higherLower) {
      playedCards.add(HigherLowerChoices.higher);
    }
  }

  onLowerSelection(ServerWebSocket socket) {
    final lastCard = playedCards.last;
    if (lastCard.type == CardType.higherLower) {
      playedCards.add(HigherLowerChoices.lower);
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
      uuids.add(i);
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

//    return;

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
      hands[socket] = [];
      final bottomTower = new List<Card>(towerLength);
      final topTower = new List<Card>(towerLength);

      for (var i = 0; i < towerLength; i++) {
        bottomTower[i] = deckDraw();

        final topCard = deckDraw();
        topCard.hidden = !topCard.hidden;
        topTower[i] = topCard;
      }

      bottomTowers[socket] = bottomTower;
      topTowers[socket] = topTower;
    }

    // send deal info to all players
    for (var socket in players) {
      final shiftedTopTowers =
          shiftListRespectiveToSocketIndex(socket, topTowers.values.toList());
      final shiftedBottomTowers = shiftListRespectiveToSocketIndex(
          socket, bottomTowers.values.toList());

      final dealTowerInfo =
          new DealTowerInfo(shiftedTopTowers, shiftedBottomTowers);

      socket.send(SocketMessage_Type.FIRST_DEAL_TOWER_INFO, dealTowerInfo);
    }
  }

  secondTowerDeal() {
    // send cards to hand alert
    for (var socket in players) {
      final handIDs = hands.values
          .map((hand) => hand.map((card) => card.id).toList())
          .toList();
      final shiftedHandCardIDs =
          shiftListRespectiveToSocketIndex(socket, handIDs);

      final cardsToHandInfo = new CardsToHandInfo(shiftedHandCardIDs);

      for (var card in hands[socket]) {
        card.hidden = true;
      }

      socket.send(SocketMessage_Type.TOWER_CARD_IDS_TO_HAND, cardsToHandInfo);
    }

    final newTopCards = new List<List<Card>>(players.length);

    for (var playerIndex = 0; playerIndex < players.length; playerIndex++) {
      final socket = players[playerIndex];
      final tower = topTowers[socket];

      final newCards = <Card>[];

      for (var index = 0; index < towerLength; index++) {
        if (tower[index] == null) {
          final newCard = deckDraw();
          newCard.hidden = !newCard.hidden;

          tower[index] = newCard;

          newCards.add(newCard);
        }
      }

      newTopCards[playerIndex] = newCards;
    }

    // send deal info to all players
    for (var socket in players) {
      final shiftedNewCards =
          shiftListRespectiveToSocketIndex(socket, newTopCards);

      final secondDealTowerInfo = new SecondDealTowerInfo(shiftedNewCards);

      socket.send(SocketMessage_Type.SECOND_DEAL_TOWER_INFO, secondDealTowerInfo);
    }
  }

  finalDeal() {
    final newHands = new List<List<Card>>(players.length);

    for (var playerIndex = 0; playerIndex < players.length; playerIndex++) {
      final socket = players[playerIndex];
      final hand = hands[socket];

      final newCards = <Card>[];

      const handLengthWithDeck = 3;

      for (var index = hand.length; index < handLengthWithDeck; index++) {
        final newCard = deckDraw();
        hands[socket].add(newCard);
        newCards.add(newCard);
      }

      newHands[playerIndex] = newCards;
    }

    // send deal info to all players
    for (var socket in players) {
      final shiftedNewCards =
          shiftListRespectiveToSocketIndex(socket, newHands);

      // reveal cards in hand
      for (var card in shiftedNewCards.first as List<Card>) {
        card.hidden = false;
      }

      final finalDealTowerInfo = new FinalDealInfo(shiftedNewCards);

      socket.send(SocketMessage_Type.FINAL_DEAL_INFO, finalDealTowerInfo);

      // hide cards in hands for others
      for (var card in shiftedNewCards.first as List<Card>) {
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

    if (lastE is Card && lastE.type == CardType.topSwap) {
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
        if (topTowers[socket].contains(card)) {
          return topTowers[socket];
        }

        if (bottomTowers[socket].contains(card)) {
          return bottomTowers[socket];
        }
      }
    }

    return null;
  }

  ServerWebSocket getOwnerOfCardID(String cardID) {
    final card = cardRegistry[cardID];

    for (var socket in players) {
      final hand = hands[socket];

      if (hand.contains(card)) {
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
        lastE.type == CardType.handSwap &&
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
      ServerWebSocket socket, HigherLowerChoiceInfo higherLowerChoiceInfo) {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (activePlayer != socket) {
      return;
    }

    final lastE = playedCards.last;

    if (lastE is Card && lastE.type == CardType.higherLower) {
      playedCards.add(higherLowerChoiceInfo.choice);

      // TODO send info

      endPlayerTurn(socket);
    }
  }
}
