part of client;

final hands = <List<ClientCard>>[];
final topTowers = <List<ClientCard>>[];
final botTowers = <List<ClientCard>>[];
final cardRegistry = <String, ClientCard>{};
final playedCards = <ClientCard>[];

final deck = <ClientCard>[];

class GameUI {
  static const gameWidth = 1280;
  static const gameHeight = 800;
  static const towerLength = 3;
  static const cardWidth = 140;
  static const cardHeight = 200;

  static final Point<num> midPoint = new Point(gameWidth / 2, gameHeight / 2);

  static const defaultDeckLength = 44; //56;

  final ClientWebSocket socket;

  GameUI(this.socket);

  static final resourceManager = new ResourceManager();
  final options = new StageOptions()
    ..backgroundColor = Color.White
    ..renderEngine = RenderEngine.WebGL;

  final canvas = html.querySelector('#stage');
  Stage stage;

  final selectableCardIDs = <String>[];

  final cardFaceBitmapDatum = <String, BitmapData>{};

  Bitmap currentPlayerToken;

  init() async {
    stage = new Stage(canvas,
        width: gameWidth, height: gameHeight, options: options);

    final renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

    resourceManager.addBitmapData("crown", "images/crown.png");
    resourceManager.addBitmapData("back", "images/card_back.png");
    // 10 because of rock
    const basicCardLength = 10;
    for (var i = 0; i < basicCardLength; i++) {
      resourceManager.addBitmapData("BASIC$i", "images/BASIC$i.png");
    }
    resourceManager.addBitmapData("REVERSE", "images/REVERSE.png");
    resourceManager.addBitmapData("BOMB", "images/BOMB.png");
    resourceManager.addBitmapData("HIGHER_LOWER", "images/HIGHER_LOWER.png");
    resourceManager.addBitmapData("WILD", "images/WILD.png");
    resourceManager.addBitmapData("TOP_SWAP", "images/TOP_SWAP.png");
    resourceManager.addBitmapData("HAND_SWAP", "images/HAND_SWAP.png");
    resourceManager.addBitmapData(
        "DISCARD_OR_ROCK", "images/DISCARD_OR_ROCK.png");
    await resourceManager.load();

    currentPlayerToken = new Bitmap(resourceManager.getBitmapData("crown"));
    currentPlayerToken.x = midPoint.x;
    currentPlayerToken.y = midPoint.y;
    currentPlayerToken.pivotX = currentPlayerToken.width/2;
    currentPlayerToken.pivotY = currentPlayerToken.height/2;
    stage.addChild(currentPlayerToken);

    final sendButton =
        new TextField("Send", new TextFormat('Arial', 50, Color.Black));
    sendButton
      ..x = midPoint.x + 300
      ..y = midPoint.y
      ..height = 50
      ..width = 200
      ..pivotX = sendButton.width / 2
      ..pivotY = sendButton.height / 2
      ..onMouseClick.listen((_) {
        sendSelectedCards();
      })
      ..onMouseOver.listen((_) {
        if (selectableCardIDs.isNotEmpty) {
          sendButton.mouseCursor = MouseCursor.POINTER;
        } else {
          sendButton.mouseCursor = MouseCursor.DEFAULT;
        }
      });
    stage.addChild(sendButton);

    for (var i = 0; i < defaultDeckLength; i++) {
      final cardSprite = new ClientCard();
      cardSprite.x = gameWidth / 2 - cardWidth - 100;
      cardSprite.y = gameHeight / 2;

      stage.children.add(cardSprite);
      deck.add(cardSprite);
    }

    stage.onMouseMove.listen((MouseEvent e) {
      final objects = stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));

      if (hands.isEmpty) return;

      final hand = hands.first;

      final cardsTouched = objects.where((e) => e.parent is ClientCard);

      if (cardsTouched.isEmpty) return;

      final lastCardTouched = cardsTouched.last.parent;

      final startY = gameHeight;

      for (var i = 0; i < hand.length; i++) {
        final card = hand[i];

        if (lastCardTouched == card) {
          final tween =
              stage.juggler.addTween(card, 1, Transition.easeOutQuintic);
          tween.animate.y.to(startY - 100);
          continue;
        }

        if (SelectableManager.shared.selectedIDs.contains(card.cardInfo.id))
          continue;

        final tween =
            stage.juggler.addTween(card, 1, Transition.easeOutQuintic);
        tween.animate.y.to(startY);
      }
    });
  }

  ClientCard dealTowerAnim(ClientCard newCard, List<List<ClientCard>> towers,
      int towerIndex, int cardIndex, num animDuration) {
    final tower = towers[towerIndex];
    tower[cardIndex] = newCard;

    const padding = 5;

    final startX = gameWidth / 2 - (cardWidth + padding);
    final startY = gameHeight - (cardWidth + padding);

    final tween = stage.juggler
        .addTween(newCard, animDuration, Transition.easeOutQuintic);

    final x = startX + cardIndex * (cardWidth + padding);
    var y = startY;

    if (towerIndex % 2 != 0) {
      y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
    }

    final rotatedPoint =
        rotatePoint(midPoint.x, midPoint.y, x, y, towerIndex * -90);

    tween.animate.x.to(rotatedPoint.x);
    tween.animate.y.to(rotatedPoint.y);
    tween.animate.rotation.to(towerIndex * pi / 2);

    stage.setChildIndex(newCard, stage.children.length - 1);

    return newCard;
  }

  sendSelectedCards() {
    final cardIDs = new CardIDs()
      ..ids.addAll(SelectableManager.shared.selectedIDs);

    socket.send(SocketMessage_Type.USER_PLAY, cardIDs);
    print('sent $cardIDs');

    clearSelectableCards();

    SelectableManager.shared.selectedIDs.clear();
  }

  onDealTowerInfo(DealTowerInfo info) async {
    final usersLength = info.topTowers.length;

    for (var i = 0; i < usersLength; i++) {
      hands.add([]);
      topTowers.add(new List<ClientCard>(towerLength));
      botTowers.add(new List<ClientCard>(towerLength));
    }
    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < usersLength; userIndex++) {
        final newCard =
            drawFromDeck(info.bottomTowers[userIndex].cards[cardIndex]);
        dealTowerAnim(newCard, botTowers, userIndex, cardIndex, .6);
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }

    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < usersLength; userIndex++) {
        final newCard =
            drawFromDeck(info.topTowers[userIndex].cards[cardIndex]);
        dealTowerAnim(newCard, topTowers, userIndex, cardIndex, .6);
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }

    final cardIDs = new CardIDs()
      ..ids.addAll(topTowers.first.map((cCard) => cCard._card.id));
    setSelectableCards(cardIDs);
  }

  onTowerCardsToHand(TowerCardsToHandInfo info) async {
    for (var cardID in info.cardIDs) {
      if (cardRegistry.containsKey(cardID)) {
        final card = cardRegistry[cardID];

        if (info.userIndex != 0) {
          card.hidden = true;
        }

        animateCardToHand(card, info.userIndex, 1, Transition.easeInOutCubic);

        final tower = topTowers[info.userIndex];
        tower[tower.indexOf(card)] = null;

        await new Future.delayed(const Duration(milliseconds: 150));
      }
    }

    bringHandCardsToTop();
  }

  secondTowerDealInfo(SecondDealTowerInfo info) async {
    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < info.topTowers.length; userIndex++) {
        if (info.topTowers[userIndex].cards.isEmpty) continue;

        final cardInfo = info.topTowers[userIndex].cards.removeAt(0);
        final newCard = drawFromDeck(cardInfo);

        final emptyCardIndex =
            topTowers[userIndex].indexWhere((cCard) => cCard == null);
        dealTowerAnim(newCard, topTowers, userIndex, emptyCardIndex, 1);
        await new Future.delayed(const Duration(milliseconds: 150));
      }
    }

    bringHandCardsToTop();
  }

  onFinalDealInfo(FinalDealInfo info) async {
    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < info.hands.length; userIndex++) {
        if (info.hands[userIndex].cards.isEmpty) continue;

        final cardInfo = info.hands[userIndex].cards.removeAt(0);
        final newCard = drawFromDeck(cardInfo);

        animateCardToHand(newCard, userIndex, 1, Transition.easeOutQuintic);
        await new Future.delayed(const Duration(milliseconds: 150));
      }
    }

    bringHandCardsToTop();
  }

  final rand = new Random();

  onPlayFromHandInfo(PlayFromHandInfo info) {
    for (var card in info.cards) {
      final revealedCard = cardRegistry[card.id];
      revealedCard.cardInfo = card;

      hands[info.userIndex].remove(revealedCard);

      stage.juggler.removeTweens(revealedCard);

      final tween =
          stage.juggler.addTween(revealedCard, 1, Transition.easeOutQuintic);

      final offSetX = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetY = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetRotation = rand.nextDouble() * (rand.nextBool() ? -1 : 1);

      tween.animate.x.to(midPoint.x + offSetX);
      tween.animate.y.to(midPoint.y + offSetY);
      tween.animate.rotation.by(offSetRotation);

      stage.setChildIndex(revealedCard, stage.children.length - 1);
    }

    animateCardsInHand(info.userIndex, 1, Transition.easeOutQuintic);
  }

  onPickUpPileInfo(PickUpPileInfo info) {
    for (var cardInfo in info.cards) {
      final pickedUpCard = cardRegistry[cardInfo.id];
      pickedUpCard.cardInfo = cardInfo;

      stage.juggler.removeTweens(pickedUpCard);

      animateCardToHand(
          pickedUpCard, info.userIndex, 1, Transition.easeInOutCubic);
    }
  }

  onDiscardInfo(DiscardInfo info) {
    for (var cardInfo in info.cards) {
      final discardedCard = cardRegistry[cardInfo.id];
      discardedCard.cardInfo = cardInfo;

      final tween =
          stage.juggler.addTween(discardedCard, 1, Transition.easeOutQuintic);

      tween.animate.alpha.to(0);
    }
  }

  clearSelectableCards() {
    for (var cardID in selectableCardIDs) {
      if (cardRegistry.containsKey(cardID)) {
        final card = cardRegistry[cardID];
        card.selectable = false;
      }
    }

    selectableCardIDs.clear();
  }

  setMulliganableCards(CardIDs cardIDs) {
    for (var id in cardIDs.ids) {
      if (cardRegistry.containsKey(id)) {
        final card = cardRegistry[id];
        card.selectable = true;
        selectableCardIDs.add(id);
      }
    }
  }

  setSelectableCards(CardIDs cardIDs) {
    for (var id in cardIDs.ids) {
      if (cardRegistry.containsKey(id)) {
        final card = cardRegistry[id];
        card.selectable = true;
        selectableCardIDs.add(id);
      }
    }
  }

  onDrawInfo(DrawInfo info) async {
    print('draw info');
    print(info);

    for (var cardInfo in info.cards) {
      final newCard = drawFromDeck(cardInfo);

      animateCardToHand(newCard, info.userIndex, 1, Transition.easeInOutCubic);
      await new Future.delayed(const Duration(milliseconds: 150));
    }
  }

  ClientCard drawFromDeck(Card cardInfo) {
    final cCard = deck.removeLast()..cardInfo = cardInfo;
    cardRegistry[cardInfo.id] = cCard;

    return cCard;
  }

  animateCardToHand(
      ClientCard cCard, int handIndex, num animDuration, var transition) {
    final hand = hands[handIndex];
    hand.add(cCard);

    animateCardsInHand(handIndex, animDuration, transition);
  }

  animateCardsInHand(int handIndex, num animDuration, var transition) {
    final hand = hands[handIndex];

    final handWidth = hand.length * 75 - cardWidth / 2;
    final startingX = gameWidth / 2 - handWidth / 2;
    final startingY = gameHeight;

    for (var j = 0; j < hand.length; j++) {
      final _card = hand[j];

      stage.juggler.removeTweens(_card);

      final tween = stage.juggler.addTween(_card, animDuration, transition);

      final x = startingX + j * 75;
      var y = startingY;

      if (handIndex % 2 != 0) {
        y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
      }

      final rotatedPoint =
          rotatePoint(midPoint.x, midPoint.y, x, y, handIndex * -90);

      tween.animate.x.to(rotatedPoint.x);
      tween.animate.y.to(rotatedPoint.y);
      tween.animate.rotation.to(handIndex * pi / 2);

      for (var card in hand) {
        stage.setChildIndex(card, stage.children.length - 1);
      }
    }
  }

  bringHandCardsToTop() {
    for (var hand in hands) {
      for (var card in hand) {
        stage.setChildIndex(card, stage.children.length - 1);
      }
    }
  }

  setActivePlayerIndex(int index) {
    num y = gameHeight - cardHeight - 75;
    final x = midPoint.x - cardWidth;

    final tween = stage.juggler.addTween(currentPlayerToken, 1, Transition.easeInOutCubic);

    if (index % 2 != 0) {
      y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
    }

    final rotatedPoint = rotatePoint(midPoint.x, midPoint.y, x, y, index * -90);

    tween.animate.x.to(rotatedPoint.x);
    tween.animate.y.to(rotatedPoint.y);
    tween.animate.rotation.to(index * pi / 2);
  }

  Point<num> rotatePoint(num cx, num cy, num x, num y, num angle) {
    final radians = (pi / 180) * angle;
    final cs = cos(radians);
    final sn = sin(radians);
    final nx = (cs * (x - cx)) + (sn * (y - cy)) + cx;
    final ny = (cs * (y - cy)) - (sn * (x - cx)) + cy;
    return new Point(nx, ny);
  }

//  final serverDeck = <Card>[];
//
//  createServerCards() {
//    final uuids = <String>[];
//
//    for (var i = 0; i < defaultDeckLength; i++) {
//      uuids.add('$i');
//    }
//    uuids.shuffle();
//
//    // create value cards
//    for (var j = 0; j < 4; j++) {
//      for (var cardValue = 0; cardValue < 9; cardValue++) {
//        final card = Card()
//          ..id = uuids.removeLast()
//          ..hidden = true
//          ..type = Card_Type.BASIC
//          ..value = cardValue + 1;
//        serverDeck.add(card);
////        registerCard(card);
//      }
//    }
//  }
}
