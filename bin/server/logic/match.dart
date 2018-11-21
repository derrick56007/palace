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
  final playedCards = <Card>[];

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

  userPlay(ServerWebSocket socket, UserPlay userPlay) {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (mulliganWindowActive) {
      final chosenCards = cardListFromCardIDList(userPlay.cardIDs);

      if (chosenCards.contains(null)) {
        // TODO error missing cards
        return;
      }

      print('socket ${players.indexOf(socket)} mulliganed $chosenCards');
      mulliganCards(socket, chosenCards);

      return;
    }

    if (activePlayer == socket) {
      final chosenCards = cardListFromCardIDList(userPlay.cardIDs);
      print('socket ${players.indexOf(socket)} played $chosenCards');

      if (chosenCards.contains(null)) {
        print('error missing cards 1');
        return;
      }

      final playableCards = getSelectableCardIDs(socket);

      // check if chosen cards are playable
      for (var chosenCardID in userPlay.cardIDs) {
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
  }

  applyCardEffect(ServerWebSocket socket, List<Card> cards) {
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
      socketToSendTo.send(MessageType.playFromHandInfo, playFromHandInfo);
    }

    playedCards.addAll(cards);

    final hand = hands[socket];

    for (var card in cards) {
      hand.remove(card);
    }

    final card = cards.first;

    if (card.type == CardType.topSwap) {
      setActivePlayerAndSendSelectableCards(socket);
      return;
    } else if (card.type == CardType.handSwap) {
      setActivePlayerAndSendSelectableCards(socket);
      return;
    } else if (card.type == CardType.discardOrRock) {
      final hand = hands[socket];
      final handLength = max(hand.length, 3);
      for (var card in hand) {
        cardRegistry.remove('${card.id}');
      }
      hand.clear();

      final newHand = <Card>[];

      for (var i = 0; i < handLength; i++) {
        if (deck.isNotEmpty) {
          newHand.add(deckDraw());
        }
      }

      sendDrawInfo(socket, newHand);
      hand.addAll(newHand);

      setActivePlayerAndSendSelectableCards(socket);
      return;
    } else if (card.type == CardType.bomb) {
      bombPile();
    }

    final newHand = <Card>[];
    while (hand.length < 3 && deck.isNotEmpty) {
      final newCard = deckDraw();
      newHand.add(newCard);
      hand.add(newCard);
    }
    sendDrawInfo(socket, newHand);

    final nextIndex =
        (players.indexOf(socket) + gameDirection) % players.length;
    setActivePlayerAndSendSelectableCards(players[nextIndex]);
  }

  bombPile() {
    final bombedCards = playedCards;
    playedCards.clear();

    final bombedCardIDs = <int>[];

    for (var card in bombedCards) {
      bombedCardIDs.add(card.id);

      cardRegistry.remove('${card.id}');
    }

    if (bombedCardIDs.isNotEmpty) {
      final bombInfo = new BombInfo(bombedCardIDs);

      for (var socket in players) {
        socket.send(MessageType.bombInfo, bombInfo);
      }
    }
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
      socketToSendTo.send(MessageType.drawInfo, drawInfo);

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
      _discardOrRock.type = CardType.basic;
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

      final selectableCards = new UserPlay(cardIDs);

      socket.send(MessageType.setMulliganableCards, selectableCards);
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
        socket.send(MessageType.clearSelectableCards);
      }

      completer.complete();
    });

    return completer.future;
  }

  chooseStartingPlayer() {
    // TODO choose random player to start
    setActivePlayerAndSendSelectableCards(players.first);
  }

  List<String> getSelectableCardIDs(ServerWebSocket socket) {
    final hand = hands[socket];

    final playableCardIDs = <String>[];
    final cardsToReCheck = <Card>[];

    for (var card in hand) {
      // special cards always work
      if (card.type == CardType.reverse ||
          card.type == CardType.wild ||
          card.type == CardType.higherLower ||
          card.type == CardType.bomb) {
        playableCardIDs.add('${card.id}');
      } else if (card.type == CardType.handSwap ||
          card.type == CardType.topSwap ||
          card.type == CardType.discardOrRock) {
        // ace cards are sometimes, check at the end
        cardsToReCheck.add(card);
      } else if (card.type == CardType.basic &&
          valueBeatsLastValue(card.value)) {
        playableCardIDs.add('${card.id}');
      }
    }

    for (var card in cardsToReCheck) {
      if (card.type == CardType.handSwap) {
        if (otherPlayersCardsExist(socket)) {
          playableCardIDs.add('${card.id}');
        } else if (hand.length == 1) {
          playableCardIDs.add('${card.id}');
        }
      } else if (card.type == CardType.topSwap) {
        if (playedCards.isEmpty) {
          playableCardIDs.add('${card.id}');
        } else if (playableCardIDs.isNotEmpty) {
          playableCardIDs.add('${card.id}');
        } else if (hand.length == 1) {
          playableCardIDs.add('${card.id}');
        }
      } else if (card.type == CardType.discardOrRock) {
        if (deck.isNotEmpty) {
          playableCardIDs.add('${card.id}');
        } else if (valueBeatsLastValue(card.value)) {
          playableCardIDs.add('${card.id}');
        }
      }
    }

    return playableCardIDs;
  }

  setActivePlayerAndSendSelectableCards(ServerWebSocket socket) {
    print('socket ${players.indexOf(socket)} turn');
    activePlayer = socket;

    for (var socket in players) {
      socket.send(MessageType.clearSelectableCards);
    }

    final playableCardIDs = getSelectableCardIDs(socket);

    if (playableCardIDs.isNotEmpty) {
      final selectableCards = new UserPlay(playableCardIDs);
      socket.send(MessageType.setSelectableCards, selectableCards);
    } else {
      // pick up cards
      final pickedUpCards = playedCards;

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
        socketToSendTo.send(MessageType.pickUpPileInfo, pickUpPileInfo);

        if (socketToSendTo == socket) {
          pickedUpCards.forEach((card) {
            card.hidden = false;
          });
        }
      }

      // clear pile and add to hand
      final hand = hands[socket];
      hand.addAll(playedCards);
      playedCards.clear();

      // end turn
      final nextIndex =
          (players.indexOf(socket) + gameDirection) % players.length;
      setActivePlayerAndSendSelectableCards(players[nextIndex]);
    }

    // TODO choose higher lower if player does not and time runs out
  }

  otherPlayersCardsExist(ServerWebSocket socket) {
    final myHand = hands[socket];
    for (var hand in hands.values.toList()) {
      if (hand != myHand) {
        if (hand.isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  onHigherSelection(ServerWebSocket socket) {
    final lastCard = playedCards.last;
    if (lastCard.type == CardType.higherLower) {
//      playedCards.add(CardType.higher);
    }
  }

  onLowerSelection(ServerWebSocket socket) {
    final lastCard = playedCards.last;
    if (lastCard.type == CardType.higherLower) {
//      playedCards.add(CardType.lower);
    }
  }

  valueBeatsLastValue(int value) {
    if (playedCards.isEmpty) {
      return true;
    }

    var lastValue = 0;
    for (var item in playedCards.reversed) {
      if (item is Card) {
        if (item.type == CardType.basic) {
          lastValue = item.value;
          break;
        } else if (item.type == CardType.discardOrRock) {
          lastValue = item.value;
          break;
        }
      }
    }

    // TODO fix this
    // modifier
    if (playedCards.last is Card) {
      if (value >= lastValue) {
        return true;
      } else {
        return false;
      }
    }/* else {
      // card value must be lower
      if (playedCards.last == CardType.lower) {
        if (value <= lastValue) {
          return true;
        } else {
          return false;
        }
      } else {
        // card value must be higher
        if (value >= lastValue) {
          return true;
        } else {
          return false;
        }
      }
    }*/
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

    final uuids = <int>[];

    for (var i = 0; i < fullDeckLength; i++) {
      uuids.add(i);
    }
    uuids.shuffle();

    // create value cards
    for (var j = 0; j < suitLength; j++) {
      for (var cardValue = 0; cardValue < basicCardLength; cardValue++) {
        final card =
            Card(uuids.removeLast(), true, CardType.basic, cardValue + 1);
        deck.add(card);
        registerCard(card);
      }
    }

    for (var i = 0; i < suitLength; i++) {
      final reverse = Card(
          uuids.removeLast(), true, CardType.reverse, specialDefaultCardValue);
      final wild = Card(
          uuids.removeLast(), true, CardType.wild, specialDefaultCardValue);
      final higherLower =
          Card(uuids.removeLast(), true, CardType.higherLower, 0);
      final bomb = Card(
          uuids.removeLast(), true, CardType.bomb, specialDefaultCardValue);

      deck.addAll([reverse, wild, higherLower, bomb]);
      registerAllCards([reverse, wild, higherLower, bomb]);
    }

    return;

    final topSwap = Card(
        uuids.removeLast(), true, CardType.topSwap, specialDefaultCardValue);
    final handSwap = Card(
        uuids.removeLast(), true, CardType.handSwap, specialDefaultCardValue);
    final rock = Card(uuids.removeLast(), true, CardType.basic, 0);
    final discardOrRock = Card(uuids.removeLast(), true, CardType.discardOrRock,
        specialDefaultCardValue);

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
        topTower[i] = deckDraw()..flip();
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

      socket.send(MessageType.firstDealTowerInfo, dealTowerInfo);
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

      socket.send(MessageType.towerCardIDsToHand, cardsToHandInfo);
    }

    final newTopCards = new List<List<Card>>(players.length);

    for (var playerIndex = 0; playerIndex < players.length; playerIndex++) {
      final socket = players[playerIndex];
      final tower = topTowers[socket];

      final newCards = <Card>[];

      for (var index = 0; index < towerLength; index++) {
        if (tower[index] == null) {
          final newCard = deckDraw();
          newCard.flip();
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

      socket.send(MessageType.secondDealTowerInfo, secondDealTowerInfo);
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

      socket.send(MessageType.finalDealInfo, finalDealTowerInfo);

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
}
