part of server;

class Match {
  final List<CommonWebSocket> players;
  final hands = <CommonWebSocket, Hand>{};
  final bottomTowers = <CommonWebSocket, Tower>{};
  final topTowers = <CommonWebSocket, Tower>{};

  static const fullDeckLength = 56;
  static const towerLength = 3;
  static const basicCardLength = 9;
  static const suitLength = 4;

  final cardRegistry = <String, Card>{};

  CommonWebSocket activePlayer;

  final deck = <Card>[];
  final playedCards = [];

  bool mulliganWindowActive = false;
  bool gameStarted = false;
  bool gameEnded = false;

  int gameDirection = 1;

  Card _discardOrRock;

  static final _emptyCard = Card();

  final uuids = <String>[];

  final bool ranked;

  Match(this.players, this.ranked) {
    newGame();
  }

  Future<void> newGame() async {
    gameStarted = true;
    gameEnded = false;
    mulliganWindowActive = false;
    _discardOrRock = null;
    gameDirection = 1;

    playedCards.clear();
    createDeck();
    deck.shuffle();
    firstTowerDeal();

    // deal delay
    await Future.delayed(const Duration(milliseconds: 2750));

    sendMulliganableCards();

    await startMulliganWindow();
    print('end mulligan window');
    secondTowerDeal();
    finalDeal();
    createAdditionalCards();
    deck.shuffle();

    await Future.delayed(const Duration(milliseconds: 2000));

    chooseStartingPlayer();
  }

  List<Card> cardListFromCardIDList(List cardIDs) {
    final lst = <Card>[];

    for (var cardID in cardIDs) {
      lst.add(cardRegistry[cardID]);
    }

    return lst;
  }

  Future<void> userPlay(CommonWebSocket socket, CardIDs userPlay) async {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (mulliganWindowActive) {
      if (userPlay.ids.isEmpty) return;

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
      mulliganCards(socket, chosenCards);

      return;
    }

    if (activePlayer != socket) {
      // TODO print error
      return;
    }

    // ending turn without playing picks up the pile
    if (userPlay.ids.isEmpty) {
      sendSelectableCards(socket);
      return;
    }

    final chosenCards = cardListFromCardIDList(userPlay.ids);

    if (chosenCards.contains(null)) {
      print('error missing cards 1');
      return;
    }

    // check for handswap
    if (playedCards.isNotEmpty &&
        playedCards.last is Card &&
        playedCards.last.type == Card_Type.HAND_SWAP &&
        playedCards.last.playerIndex == players.indexOf(socket) &&
        !playedCards.last.activated) {
      final cardIDsInOtherHands =
          getCardIDsInOtherHands(socket).expand((i) => i).toList();
      if (chosenCards.length == 1 &&
          cardIDsInOtherHands.contains(userPlay.ids.first)) {
        await onHandSwapChoice(socket, userPlay);
      } else {
        sendSelectableCards(socket);
      }
      return;
    }

    // check for topswap
    if (playedCards.isNotEmpty &&
        playedCards.last is Card &&
        playedCards.last.type == Card_Type.TOP_SWAP &&
        playedCards.last.playerIndex == players.indexOf(socket) &&
        !playedCards.last.activated) {
      final exposedTowerCards =
          cardListFromCardIDList(getAllExposedTowerCardIDs());
      if (chosenCards.length == 2 &&
          exposedTowerCards.contains(chosenCards.first) &&
          exposedTowerCards.contains(chosenCards.last)) {
        await onTopSwapChoice(socket, userPlay);
      } else {
        sendSelectableCards(socket);
      }

      return;
    }

    final playableCards = getSelectableCardIDs(socket);

    // check if bottom tower play
    if (chosenCards.length == 1 && hands[socket].cards.isEmpty) {
      final card = chosenCards.first;

      if (bottomTowers[socket].cards.contains(card)) {
        card.hidden = false;
        // check if card flip succeeded
        if (isSelectableCard(card)) {
          await applyCardEffect(socket, [card]);
          return;
        } else {
          // did not
          final playFromHandInfo = PlayFromHandInfo()..cards.add(card);

          final socketIndex = players.indexOf(socket);
          for (var socketToSendTo in players) {
            final socketToSendToIndex = players.indexOf(socketToSendTo);

            playFromHandInfo.userIndex =
                (socketIndex - socketToSendToIndex) % players.length;
            socketToSendTo.send(
                SocketMessage_Type.PLAY_FROM_HAND_INFO, playFromHandInfo);
          }

          playedCards.add(card);

          bottomTowers[socket].cards[bottomTowers[socket].cards.indexOf(card)] =
              _emptyCard;

          await Future.delayed(const Duration(seconds: 2));

          pickUpPile(socket);

          await endPlayerTurn(socket);
          return;
        }
      }
    }

    // check if chosen cards are playable
    for (var chosenCardID in userPlay.ids) {
      if (!playableCards.contains(chosenCardID)) {
        print('error missing cards 2');
        sendSelectableCards(socket);
        return;
      }
    }

    // multiple card play
    if (chosenCards.length > 1) {
      // check if in tower (multiple bottom tower plays not allowed
      for (var chosenCard in chosenCards) {
        if (bottomTowers[socket].cards.contains(chosenCard)) {
          sendSelectableCards(socket);
          return;
        }
      }

      // error if chosen cards contains single play cards
      for (var chosenCard in chosenCards) {
        if (chosenCard.type == Card_Type.TOP_SWAP ||
            chosenCard.type == Card_Type.HAND_SWAP ||
            chosenCard.type == Card_Type.DISCARD_OR_ROCK) {
          sendSelectableCards(socket);
          return;
        }
      }

      final type = chosenCards.first.type;
      final value = chosenCards.first.value;

      // check if all types same
      for (var chosenCard in chosenCards) {
        if (chosenCard.type != type || chosenCard.value != value) {
          print('types not same');
          sendSelectableCards(socket);
          return;
        }
      }
    }

    await applyCardEffect(socket, chosenCards);
  }

  Future<void> applyCardEffect(CommonWebSocket socket, List<Card> cards) async {
    for (var socket in players) {
      socket.send(SocketMessage_Type.CLEAR_SELECTABLE_CARDS);
    }

    cards.forEach((card) {
      card.hidden = false;
      card.playerIndex = players.indexOf(socket);
      card.activated = false;
    });

    final playFromHandInfo = PlayFromHandInfo()..cards.addAll(cards);

    final socketIndex = players.indexOf(socket);
    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      playFromHandInfo.userIndex =
          (socketIndex - socketToSendToIndex) % players.length;
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
      await endPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.HAND_SWAP) {
      final cardIDsInOtherHands = getCardIDsInOtherHands(socket);

      final handswapChoiceInfo = HandSwapChoiceInfo();
      handswapChoiceInfo.hands.addAll(
          cardIDsInOtherHands.map((strs) => CardIDs()..ids.addAll(strs)));

      socket.send(
          SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, handswapChoiceInfo);
      return;
    }

    if (card.type == Card_Type.TOP_SWAP) {
      if (socketWon(socket)) {
        await onWin(socket);
        return;
      }

      final allExposedTowerCardIDs = getAllExposedTowerCardIDs();

      final selectedCards = CardIDs()..ids.addAll(allExposedTowerCardIDs);
      socket.send(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, selectedCards);
      return;
    }

    if (card.type == Card_Type.DISCARD_OR_ROCK) {
      await Future.delayed(const Duration(seconds: 1));

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

      await Future.delayed(const Duration(seconds: 2));

      await startPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.BOMB) {
      await Future.delayed(const Duration(seconds: 1));

      final cards = <Card>[];
      for (var card in playedCards) {
        if (card is Card) {
          cards.add(card);
        }
      }

      discardCards(cards);
      playedCards.clear();
      await endPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.REVERSE) {
      gameDirection = -gameDirection;
      await endPlayerTurn(socket);
      return;
    }

    if (card.type == Card_Type.WILD) {
      if (socketWon(socket)) {
        await onWin(socket);
        return;
      }
      // send all selectable cards
      final playableCardIDs = getSelectableCardIDs(socket);

      final selectableCards = CardIDs()..ids.addAll(playableCardIDs);
      socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
      return;
    }

    if (card.type == Card_Type.HIGHER_LOWER) {
      if (socketWon(socket)) {
        await onWin(socket);
        return;
      }

      final requestInfo = RequestHigherLowerChoiceInfo()
        ..value = resolvePileState();
      socket.send(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE, requestInfo);
      return;
    }
  }

  Future<void> onWin(CommonWebSocket socket) async {
    gameEnded = true;

    if (ranked) {
      final eloMatch = EloMatch();
      for (final s in players) {
        eloMatch.addPlayer(s, s == socket ? 1 : 2, s.elo);
      }
      eloMatch.calculate();

      for (final p
          in eloMatch.players.where((p) => p.socket is ServerWebSocket)) {
        final gameEndInfo = GameEndInfo();
        gameEndInfo
          ..eloPre = p.socket.elo
          ..eloChanged = p.eloChange
          ..eloPost = p.eloPost;
        p.socket.send(SocketMessage_Type.GAME_END_INFO, gameEndInfo);

        await DataBaseManager.shared.userDB.update(
            {'userID': (p.socket as ServerWebSocket).userID},
            {'elo': p.eloPost});

        // update elo
        p.socket.elo = p.eloPost;
      }

      await DataBaseManager.shared.userDB.tidy();
    }

    await Future.delayed(const Duration(seconds: 3));

    await newGame();
  }

  bool socketWon(CommonWebSocket socket) =>
      hands[socket].cards.isEmpty &&
      topTowers[socket].cards.where((card) => card == _emptyCard).length == 3 &&
      bottomTowers[socket].cards.where((card) => card == _emptyCard).length ==
          3;

  // gets cards in clockwise pattern
  List<List<String>> getCardIDsInOtherHands(CommonWebSocket socket) {
    final otherCardIDsInOtherHands = <List<String>>[];

    for (var i = 0; i < players.length; i++) {
      if (i == players.indexOf(socket)) {
        continue;
      }

      final hand = hands.values.elementAt(i);

      final cards = <String>[];

      for (var card in hand.cards) {
        cards.add('${card.id}');
      }

      if (cards.isNotEmpty) {
        otherCardIDsInOtherHands.add(cards);
      }
    }
//
//    for (var hand in hands.values.where((hand) => hand != hands[socket])) {
//      for (var card in hand.cards) {
//        otherCardIDsInOtherHands.add('${card.id}');
//      }
//    }

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

  List<String> getExposedTowerCardIDs(CommonWebSocket socket) {
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

  List<Card> getFaceUpTowerCards(CommonWebSocket socket) {
    final topTower = topTowers[socket];
    final bottomTower = bottomTowers[socket];
    final cards = <Card>[];

    for (var index = 0; index < towerLength; index++) {
      if (topTower.cards[index] != _emptyCard) {
        cards.add(topTower.cards[index]);
      } else if (bottomTower.cards[index] != _emptyCard &&
          !bottomTower.cards[index].hidden) {
        cards.add(bottomTower.cards[index]);
      }
    }

    return cards;
  }

  List<Card> getExposedBottomTowerCards(CommonWebSocket socket) {
    final topTower = topTowers[socket];
    final bottomTower = bottomTowers[socket];
    final cards = <Card>[];

    for (var index = 0; index < towerLength; index++) {
      if (topTower.cards[index] == _emptyCard &&
          bottomTower.cards[index] != _emptyCard &&
          bottomTower.cards[index].hidden) {
        cards.add(bottomTower.cards[index]);
      }
    }

    return cards;
  }

  void discardCards(List<Card> cards) {
    for (var card in cards) {
      cardRegistry.remove('${card.id}');
    }

    if (cards.isNotEmpty) {
      final discardInfo = DiscardInfo()..cards.addAll(cards);

      for (var socket in players) {
        socket.send(SocketMessage_Type.DISCARD_INFO, discardInfo);
      }
    }

    cards.clear();
  }

  void sendDrawInfo(CommonWebSocket socket, List<Card> cards) {
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

      final drawInfo = DrawInfo()
        ..userIndex = (socketIndex - socketToSendToIndex) % players.length
        ..cards.addAll(cards);
      socketToSendTo.send(SocketMessage_Type.DRAW_INFO, drawInfo);

      if (socketToSendTo == socket) {
        cards.forEach((card) {
          card.hidden = true;
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
      // last card is discard
      if (card == _discardOrRock) {
        _discardOrRock.type = Card_Type.BASIC;
        _discardOrRock.value = 0;
      } else {
        for (var player in players) {
          final hand = hands[player];

          if (!hand.cards.contains(_discardOrRock)) continue;
          _discardOrRock.type = Card_Type.BASIC;
          _discardOrRock.value = 0;
          player.send(
              SocketMessage_Type.CHANGE_DISCARD_TO_ROCK, _discardOrRock);
          break;
        }
      }
    }

    return card;
  }

  void mulliganCards(CommonWebSocket socket, List<Card> cards) {
    final tower = topTowers[socket];
    final hand = hands[socket];

    for (var card in tower.cards) {
      if (cards.contains(card)) {
        hand.cards.add(card);
      }
    }

    for (var card in cards) {
      if (tower.cards.contains(card)) {
        tower.cards[tower.cards.indexOf(card)] = _emptyCard;
      }
    }

    cards = hand.cards;

    final socketIndex = players.indexOf(socket);

    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      final info = TowerCardsToHandInfo()
        ..userIndex = (socketIndex - socketToSendToIndex) % players.length
        ..cardIDs.addAll(cards.map((card) => card.id));
      socketToSendTo.send(SocketMessage_Type.TOWER_CARD_IDS_TO_HAND, info);
    }
  }

  static const mulliganDuration = Duration(seconds: 12);

  Future startMulliganWindow() async {
    mulliganWindowActive = true;

    final mulliganTimerWaitingInfo = SimpleInfo();

    final mulliganTimerUpdateInfo = SimpleInfo()
      ..info = '${mulliganDuration.inSeconds} seconds left to mulligan';

    for (var socket in players) {
      socket.send(
          SocketMessage_Type.MULLIGAN_TIMER_UPDATE, mulliganTimerUpdateInfo);
    }

    final completer = Completer();
    CountdownTimer(mulliganDuration, const Duration(seconds: 1)).listen(
        (CountdownTimer timer) {
      final secondsLeft = timer.remaining.inSeconds;
      mulliganTimerUpdateInfo.info = '$secondsLeft seconds left to mulligan';
      mulliganTimerWaitingInfo.info = 'Waiting for others...($secondsLeft)';

      for (var socket in players) {
        if (hands[socket].cards.isEmpty) {
          socket.send(SocketMessage_Type.MULLIGAN_TIMER_UPDATE,
              mulliganTimerUpdateInfo);
        } else {
          socket.send(SocketMessage_Type.MULLIGAN_TIMER_UPDATE,
              mulliganTimerWaitingInfo);
        }
      }
      //
    }, onDone: () {
      mulliganWindowActive = false;

      final doneInfo = SimpleInfo()..info = '';

      for (var socket in players) {
        socket.send(SocketMessage_Type.MULLIGAN_TIMER_UPDATE, doneInfo);
        socket.send(SocketMessage_Type.CLEAR_SELECTABLE_CARDS);
      }

      completer.complete();
    });

    return completer.future;
  }

  void chooseStartingPlayer() {
    if (activePlayer == null) {
      startPlayerTurn(players[(Random()).nextInt(players.length)]);
      return;
    }

    startPlayerTurn(activePlayer);
  }

  int resolvePileState() {
    if (playedCards.isEmpty) return 0;

    // get "real" cards (played cards could include HigherLowerChoice)
    final cards = <Card>[];
    for (var card in playedCards) {
      if (card is Card) cards.add(card);
    }

    // higher lower card value by itself is the mean of basic values (5)
    if (cards.length == 1 && cards.first.type == Card_Type.HIGHER_LOWER) {
      return cards.first.value;
    }

    // collect cards with "value"
    final valueCards = <Card>[];
    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];

      // check HIGHER_LOWER special case
      if (card.type == Card_Type.HIGHER_LOWER) {
        // check if previous card exists and is WILD
        if (i > 0 && cards[i - 1].type == Card_Type.WILD) {
          // add HIGHER_LOWER as value card
          valueCards.add(card);
        }
        continue;
      }

      // cards with no value
      if (card.type != Card_Type.TOP_SWAP &&
          card.type != Card_Type.HAND_SWAP &&
          card.type != Card_Type.DISCARD_OR_ROCK &&
          // card.type != Card_Type.WILD && // makes state 0
          card.type != Card_Type.REVERSE &&
          card.type != Card_Type.BOMB) {
        valueCards.add(card);
      }
    }

    // return 0 if no value cards
    if (valueCards.isEmpty) {
      // if last card is higher lower
      if (playedCards.last == Card_Type.HIGHER_LOWER) {
        return playedCards.last.value;
      }
      return 0;
    }

    return valueCards.last.value;
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

    if (card.type == Card_Type.DISCARD_OR_ROCK && deck.isNotEmpty) {
      return true;
    }

    // check basic cards
    if (card.type == Card_Type.BASIC) {
      // always playable if pile is empty
      if (playedCards.isEmpty) {
        return true;
      }

      var lower = false;

      for (var card in playedCards.reversed) {
        if (card is Card) {
          if (card.type == Card_Type.BASIC) {
            break;
          }

          if (card.type == Card_Type.REVERSE ||
              card.type == Card_Type.DISCARD_OR_ROCK ||
              card.type == Card_Type.TOP_SWAP ||
              card.type == Card_Type.HAND_SWAP) {
            continue;
          } else {
            break;
          }
        } else {
          if (card == HigherLowerChoice_Type.LOWER) {
            lower = true;
          }
          break;
        }
      }

      // check if last card is higher lower
      if (lower) {
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

  List<String> getSelectableCardIDs(CommonWebSocket socket) {
    // check if last card was handswap
    if (playedCards.isNotEmpty &&
        playedCards.last is Card &&
        playedCards.last.type == Card_Type.HAND_SWAP &&
        playedCards.last.playerIndex == players.indexOf(socket) &&
        !playedCards.last.activated) {
      return getCardIDsInOtherHands(socket).expand((i) => i).toList();
    }

    // check for topswap
    if (playedCards.isNotEmpty &&
        playedCards.last is Card &&
        playedCards.last.type == Card_Type.TOP_SWAP &&
        playedCards.last.playerIndex == players.indexOf(socket) &&
        !playedCards.last.activated) {
      return getAllExposedTowerCardIDs();
    }

    // check for higher lower
//    if (playedCards.isNotEmpty &&
//        playedCards.last is Card &&
//        playedCards.last.type == Card_Type.HIGHER_LOWER &&
//        playedCards.last.playerIndex == players.indexOf(socket) &&
//        !playedCards.last.activated) {
//      socket.send(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE);
//      return;
//      return getAllExposedTowerCardIDs();
//    }

    final hand = hands[socket];

    final cards =
        hand.cards.isNotEmpty ? hand.cards : getFaceUpTowerCards(socket);

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
      if (card.type == Card_Type.TOP_SWAP) {
        // has other cards to play
        if (playableCardIDs.isNotEmpty) {
          playableCardIDs.add('${card.id}');
          continue;
        }

        final cardsToPlayAfter = getFaceUpTowerCards(socket)
            .where((card) => isSelectableCard(card))
            .toList()
              ..addAll(getExposedBottomTowerCards(socket));
        if (hand.cards.length == 1 &&
            hand.cards.first == card &&
            cardsToPlayAfter.isNotEmpty) {
          playableCardIDs.add('${card.id}');
          continue;
        }
        continue;
      }

      // check discard
      if (card.type == Card_Type.DISCARD_OR_ROCK && isSelectableCard(card)) {
        playableCardIDs.add('${card.id}');
        continue;
      }
    }

    if (hand.cards.isEmpty) {
      final exposedBottomCards = getExposedBottomTowerCards(socket);
      for (var card in exposedBottomCards) {
        playableCardIDs.add(card.id);
      }
    }

    return playableCardIDs;
  }

  Future<void> startPlayerTurn(CommonWebSocket socket) async {
    activePlayer = socket;

    final socketIndex = players.indexOf(socket);

    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      final activePlayerIndex = ActivePlayerIndex()
        ..index = (socketIndex - socketToSendToIndex) % players.length;
      socketToSendTo.send(SocketMessage_Type.CLEAR_SELECTABLE_CARDS);
      socketToSendTo.send(
          SocketMessage_Type.ACTIVE_PLAYER_INDEX, activePlayerIndex);
    }

    final playableCardIDs = getSelectableCardIDs(socket);

    if (playableCardIDs.isNotEmpty) {
      final selectableCards = CardIDs()..ids.addAll(playableCardIDs);
      socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
    } else {
      // no available cards to play so pick up
      await Future.delayed(const Duration(seconds: 1));

      pickUpPile(socket);

      // end turn
      await endPlayerTurn(socket);
    }

    // TODO choose higher lower if player does not and time runs out
  }

  void sendSelectableCards(CommonWebSocket socket) {
    final playableCardIDs = getSelectableCardIDs(socket);

    if (playableCardIDs.isNotEmpty) {
      final selectableCards = CardIDs()..ids.addAll(playableCardIDs);
      socket.send(SocketMessage_Type.SET_SELECTABLE_CARDS, selectableCards);
    }
  }

  void pickUpPile(CommonWebSocket socket) {
    // pick up cards
    final pickedUpCards = <Card>[];

    playedCards.forEach((e) {
      if (e is Card) {
        e.activated = false;
        pickedUpCards.add(e);
      }
    });
    playedCards.clear();

    pickedUpCards.forEach((card) {
      card.hidden = true;

      if (_discardOrRock != null &&
          card == _discardOrRock &&
          card.type == Card_Type.DISCARD_OR_ROCK &&
          deck.isEmpty) {
        _discardOrRock.type = Card_Type.BASIC;
        _discardOrRock.value = 0;
      }
    });

    final socketIndex = players.indexOf(socket);

    for (var socketToSendTo in players) {
      final socketToSendToIndex = players.indexOf(socketToSendTo);

      if (socketToSendTo == socket) {
        pickedUpCards.forEach((card) {
          card.hidden = false;
        });
      }

      final pickUpPileInfo = PickUpPileInfo()
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

  Future<void> endPlayerTurn(CommonWebSocket socket) async {
    // check if won
    if (socketWon(socket)) {
      await onWin(socket);
      return;
    }

    // fill hand
    final hand = hands[socket];

    final newHand = <Card>[];
    while (hand.cards.length < 3 && deck.isNotEmpty) {
      final newCard = deckDraw();
      newHand.add(newCard);

      hand.cards.add(newCard);
    }

    sendDrawInfo(socket, newHand);

    final nextIndex =
        (players.indexOf(socket) + gameDirection) % players.length;
    await startPlayerTurn(players[nextIndex]);
  }

  bool otherPlayersCardsExist(CommonWebSocket socket) {
    final myHand = hands[socket];
    return hands.values
        .toList()
        .where((hand) => hand != myHand && hand.cards.isNotEmpty)
        .isNotEmpty;
  }

  void registerAllCards(List<Card> cards) {
    for (var card in cards) {
      registerCard(card);
    }
  }

  void registerCard(Card card) {
    final id = '${card.id}';

    cardRegistry[id] = card;
  }

  void createDeck() {
    deck.clear();
    uuids.clear();

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

    for (var i = 0; i < suitLength; i++) {
      final reverse = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.REVERSE
        ..value = 0;
      final wild = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.WILD
        ..value = 0;
      final higherLower = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.HIGHER_LOWER
        ..value = 5;
      final bomb = Card()
        ..id = uuids.removeLast()
        ..hidden = true
        ..type = Card_Type.BOMB
        ..value = 0;

      deck.addAll([reverse, wild, higherLower, bomb]);
      registerAllCards([reverse, wild, higherLower, bomb]);
    }
  }

  void createAdditionalCards() {
    final discardOrRock = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.DISCARD_OR_ROCK
      ..value = 0;

    _discardOrRock = discardOrRock;

    final rock = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.BASIC
      ..value = 0;
    final handSwap = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.HAND_SWAP
      ..value = 0;

    final topSwap = Card()
      ..id = uuids.removeLast()
      ..hidden = true
      ..type = Card_Type.TOP_SWAP
      ..value = 0;

    deck.addAll([topSwap, handSwap, rock, discardOrRock]);
    registerAllCards([topSwap, handSwap, rock, discardOrRock]);
  }

  void firstTowerDeal() {
    hands.clear();
    bottomTowers.clear();
    topTowers.clear();

    // fill player towers
    for (var socket in players) {
      hands[socket] = Hand();
      final bottomTower = Tower();
      final topTower = Tower();

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

      final dealTowerInfo = DealTowerInfo()
        ..topTowers.addAll(shiftedTopTowers)
        ..bottomTowers.addAll(shiftedBottomTowers);

      socket.send(SocketMessage_Type.FIRST_DEAL_TOWER_INFO, dealTowerInfo);
    }
  }

  void sendMulliganableCards() {
    for (var socket in players) {
      final cardIDs = CardIDs()
        ..ids.addAll(topTowers[socket].cards.map((card) => card.id));
      socket.send(SocketMessage_Type.SET_MULLIGANABLE_CARDS, cardIDs);
    }
  }

  void secondTowerDeal() {
    final newTopCards = List<Tower>(players.length);

    for (var playerIndex = 0; playerIndex < players.length; playerIndex++) {
      final socket = players[playerIndex];
      final tower = topTowers[socket];

      final newTower = Tower();

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

      final secondDealTowerInfo = SecondDealTowerInfo()
        ..topTowers.addAll(shiftedNewCards);

      socket.send(
          SocketMessage_Type.SECOND_DEAL_TOWER_INFO, secondDealTowerInfo);
    }
  }

  void finalDeal() {
    final newHands = List<Hand>(players.length);

    for (var playerIndex = 0; playerIndex < players.length; playerIndex++) {
      final socket = players[playerIndex];
      final hand = hands[socket];

      final newHand = Hand();

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

      final finalDealTowerInfo = FinalDealInfo()..hands.addAll(shiftedNewCards);

      socket.send(SocketMessage_Type.FINAL_DEAL_INFO, finalDealTowerInfo);

      // hide cards in hands for others
      for (var card in shiftedNewCards.first.cards) {
        card.hidden = true;
      }
    }
  }

  List shiftListRespectiveToSocketIndex(CommonWebSocket socket, List list) {
    final socketIndex = players.indexOf(socket);

    final newList = list.sublist(socketIndex);
    newList.addAll(list.sublist(0, socketIndex));

    return newList;
  }

  Future<void> onTopSwapChoice(
      CommonWebSocket socket, CardIDs topSwapChoice) async {
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
      final indexOfCard2 = tower2.indexOf(card2);

      tower1[indexOfCard1] = card2;
      tower2[indexOfCard2] = card1;

      for (var socketToSendTo in players) {
        final topSwapInfo = TopSwapInfo()
          ..card1 = card1
          ..card2 = card2;

        socketToSendTo.send(SocketMessage_Type.TOPSWAP_CHOICE, topSwapInfo);
      }

      lastE.activated = true;

      await Future.delayed(const Duration(milliseconds: 1500));

      await startPlayerTurn(socket);
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

  CommonWebSocket getOwnerOfCardID(String cardID) {
    final card = cardRegistry[cardID];

    for (var socket in players) {
      final hand = hands[socket];

      if (hand.cards.contains(card)) {
        return socket;
      }
    }

    return null;
  }

  Future<void> onHandSwapChoice(
      CommonWebSocket socket, CardIDs handSwapChoice) async {
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
      final otherHand = hands[otherSocket];
      hands[socket] = otherHand;
      hands[otherSocket] = tempMyHand;

      final socketIndex = players.indexOf(socket);
      final otherSocketIndex = players.indexOf(otherSocket);

      for (var socketToSendTo in players) {
        final socketToSendToIndex = players.indexOf(socketToSendTo);

        if (socketToSendTo == socket) {
          otherHand.cards.forEach((card) {
            card.hidden = false;
          });
        }

        final handSwapInfo1 = HandSwapInfo()
          ..userIndex1 = (socketIndex - socketToSendToIndex) % players.length
          ..userIndex2 =
              (otherSocketIndex - socketToSendToIndex) % players.length
          ..cards1.addAll(otherHand.cards)
          ..cards2.addAll(tempMyHand.cards);

        socketToSendTo.send(SocketMessage_Type.HANDSWAP_CHOICE, handSwapInfo1);

        if (socketToSendTo == socket) {
          otherHand.cards.forEach((card) {
            card.hidden = true;
          });
        }
      }

      lastE.activated = true;
      await Future.delayed(const Duration(milliseconds: 1250));

      await startPlayerTurn(socket);
    }
  }

  int getRelativeSocketIndexFromSocket(CommonWebSocket s1, CommonWebSocket s2) {
    return (players.indexOf(s2) - players.indexOf(s1)) % players.length;
  }

  void onHigherLowerChoice(
      CommonWebSocket socket, HigherLowerChoice higherLowerChoice) {
    if (!gameStarted || gameEnded) {
      // TODO send error
      return;
    }

    if (activePlayer != socket) {
      return;
    }

    if (playedCards.isEmpty) return;

    final lastE = playedCards.last;

    if (lastE is Card &&
        lastE.type == Card_Type.HIGHER_LOWER &&
        !lastE.activated) {
      playedCards.add(higherLowerChoice.choice);

      higherLowerChoice.value = resolvePileState();

      const specialCards = [
        Card_Type.REVERSE,
        Card_Type.BOMB,
        Card_Type.HIGHER_LOWER,
        Card_Type.WILD,
        Card_Type.HAND_SWAP,
        Card_Type.TOP_SWAP
      ];

      // there is no other card other than the HL card, therefore use the
      // median value
      if (playedCards.length == 1 ||
          playedCards.every((card) =>
              card is HigherLowerChoice ||
              card is Card && specialCards.contains(card.type))) {
        higherLowerChoice.value == 5;
      }

      for (var socket in players) {
        socket.send(SocketMessage_Type.HIGHERLOWER_CHOICE, higherLowerChoice);
      }

      lastE.activated = true;
      endPlayerTurn(socket);
    }
  }

  Future onRequestPickup(CommonWebSocket socket) async {
    if (activePlayer == socket) {
      final last = playedCards.last;
      if (getSelectableCardIDs(socket).isNotEmpty && playedCards.isNotEmpty) {
        // deny picking up immediately after playing
        if (last is Card &&
            last.playerIndex == players.indexOf(socket) &&
            (last.type == Card_Type.HAND_SWAP ||
                last.type == Card_Type.TOP_SWAP ||
                last.type == Card_Type.DISCARD_OR_ROCK)) {
          sendSelectableCards(socket);
          return;
        }

        pickUpPile(socket);
        await Future.delayed(const Duration(milliseconds: 1500));

        await endPlayerTurn(socket);
      } else {
        sendSelectableCards(socket);
      }
    }
  }
}
