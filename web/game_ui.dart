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

  static const defaultDeckLength = 56;

  GameUI();

  final resourceManager = new ResourceManager();
  final options = new StageOptions()
    ..backgroundColor = Color.White
    ..renderEngine = RenderEngine.WebGL;

  final canvas = html.querySelector('#stage');
  Stage stage;

  static BitmapData logoData;
  static BitmapData cardBackData;

  final selectableCardIDs = <String>[];

  init() async {
    stage = new Stage(canvas,
        width: gameWidth, height: gameHeight, options: options);

    final renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

    resourceManager.addBitmapData("dart", "images/card.jpg");
    resourceManager.addBitmapData("back", "images/card_back.png");
    await resourceManager.load();

    logoData = resourceManager.getBitmapData("dart");
    cardBackData = resourceManager.getBitmapData("back");

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
      cardSprite.filters = [new DropShadowFilter(1)];
      cardSprite.x = gameWidth / 2 - cardWidth - 50;
      cardSprite.y = gameHeight / 2;

      stage.children.add(cardSprite);
      deck.add(cardSprite);
    }

    // TODO move to game start
//    createServerCards();
//
//    setSelectableCards(
//        topTowers.first.map((ccard) => ccard.cardInfo.id).toList());

//    for (int j = 0; j < 7; j++) {
//      for (var i = 0; i < 4; i++) {
//        drawCardAnim(i, "derp", .75);
//        await new Future.delayed(const Duration(milliseconds: 500));
//      }
//    }

    /////////////////////////////////////

//    final hand = hands.first;

    stage.onMouseMove.listen((MouseEvent e) {
      final objects = stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));

      if (hands.isEmpty) return;

      final hand = hands.first;

      if (hand.where((card) => card.userData['dragging']).isNotEmpty) return;

      final y = 0;

      for (var i = 0; i < hand.length; i++) {
        final card = hand[i];

        if (card.userData['dragging']) {
          continue;
        }

        if (objects.isNotEmpty && objects.last.parent == card) {
          final tween = stage.juggler
              .addTween(card.children.last, 1, Transition.easeOutQuintic);
          tween.animate.y.to(y - 100);
          continue;
        }

        final tween = stage.juggler
            .addTween(card.children.last, 1, Transition.easeOutQuintic);
        tween.animate.y.to(y);
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
        rotate_point(midPoint.x, midPoint.y, x, y, towerIndex * 90);

    tween.animate.x.to(rotatedPoint.x);
    tween.animate.y.to(rotatedPoint.y);
    tween.animate.rotation.to(towerIndex * pi / 2);

    stage.setChildIndex(newCard, stage.children.length - 1);

    return newCard;
  }

  sendSelectedCards() {
    final cardIDs = SelectableManager.shared.selectedIDs;

//    //TODO remove test
//    onTowerCardsToHand(new TowerCardsToHandsInfo()
//      ..hands.add(new CardIDs()..ids.addAll(cardIDs)));
    print('sent $cardIDs');

    clearSelectableCards();
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
        dealTowerAnim(newCard, botTowers, userIndex, cardIndex, .5);
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }

    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < usersLength; userIndex++) {
        final newCard =
            drawFromDeck(info.topTowers[userIndex].cards[cardIndex]);
        dealTowerAnim(newCard, topTowers, userIndex, cardIndex, .5);
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  onTowerCardsToHand(TowerCardsToHandsInfo info) {
    for (var towerIndex = 0; towerIndex < info.hands.length; towerIndex++) {
      for (var cardID in info.hands[towerIndex].ids)
        if (cardRegistry.containsKey(cardID)) {
          final card = cardRegistry[cardID];
          animateCardToHand(card, towerIndex, .5);

          final tower = topTowers[towerIndex];
          tower[tower.indexOf(card)] = null;
        }
    }
  }

  secondTowerDealInfo(SecondDealTowerInfo info) {
    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < info.topTowers.length; userIndex++) {
        if (info.topTowers[userIndex].cards.isEmpty) continue;

        final cardInfo = info.topTowers[userIndex].cards.removeAt(0);
        final newCard = drawFromDeck(cardInfo);

        final emptyCardIndex =
            topTowers[userIndex].indexWhere((cCard) => cCard == null);
        dealTowerAnim(newCard, topTowers, emptyCardIndex, cardIndex, .5);
      }
    }
  }

  onFinalDealInfo(FinalDealInfo info) async {
    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < info.hands.length; userIndex++) {
        if (info.hands[userIndex].cards.isEmpty) continue;

        final cardInfo = info.hands[userIndex].cards.removeAt(0);
        final newCard = drawFromDeck(cardInfo);

        animateCardToHand(newCard, userIndex, .5);
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  onPlayFromHandInfo(PlayFromHandInfo info) {
    for (var card in info.cards) {
      final revealedCard = cardRegistry[card.id];
      revealedCard.cardInfo = card;

      final tween = stage.juggler
          .addTween(revealedCard, .75, Transition.easeOutQuintic);

      tween.animate.x.to(midPoint.x);
      tween.animate.y.to(midPoint.y);
    }
  }

  onPickUpPileInfo(PickUpPileInfo info) {
    for (var cardInfo in info.cards) {
      final pickedUpCard = cardRegistry[cardInfo.id];
      pickedUpCard.cardInfo = cardInfo;

      animateCardToHand(pickedUpCard, info.userIndex, .5);
    }
  }

  onDiscardInfo(DiscardInfo info) {
    for (var cardInfo in info.cards) {
      final discardedCard = cardRegistry[cardInfo.id];
      discardedCard.cardInfo = cardInfo;

      final tween = stage.juggler
          .addTween(discardedCard, .75, Transition.easeOutQuintic);

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
    for (var cardInfo in info.cards) {
      final newCard = drawFromDeck(cardInfo);

      animateCardToHand(newCard, info.userIndex, .5);
      await new Future.delayed(const Duration(milliseconds: 100));
    }
  }

  ClientCard drawFromDeck(Card cardInfo) {
    final cCard = deck.removeLast()..cardInfo = cardInfo;
    cardRegistry[cardInfo.id] = cCard;

    return cCard;
  }

  animateCardToHand(ClientCard cCard, int handIndex, num animDuration) {
    final hand = hands[handIndex];
    hand.add(cCard);

    final handWidth = hand.length * 50;
    final startingX = gameWidth / 2 - handWidth / 2;
    final startingY = gameHeight;

    for (var j = 0; j < hand.length; j++) {
      final _card = hand[j];
      final tween = stage.juggler
          .addTween(_card, animDuration, Transition.easeOutQuintic);

      final x = startingX + j * 75;
      var y = startingY;

      if (handIndex % 2 != 0) {
        y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
      }

      final rotatedPoint =
          rotate_point(midPoint.x, midPoint.y, x, y, handIndex * 90);

      tween.animate.x.to(rotatedPoint.x);
      tween.animate.y.to(rotatedPoint.y);
      tween.animate.rotation.to(handIndex * pi / 2);

      for (var card in hand) {
        stage.setChildIndex(card, stage.children.length - 1);
      }
    }
  }

  Point<num> rotate_point(num cx, num cy, num x, num y, num angle) {
    var radians = (pi / 180) * angle;
    var cs = cos(radians);
    var sn = sin(radians);
    var nx = (cs * (x - cx)) + (sn * (y - cy)) + cx;
    var ny = (cs * (y - cy)) - (sn * (x - cx)) + cy;
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
