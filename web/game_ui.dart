import 'dart:async';
import 'dart:html' as html;
import 'dart:math' hide Point;

import 'package:stagexl/stagexl.dart';

import 'client_card.dart';
import 'client_websocket.dart';
import 'common/generated_protos.dart';
import 'selectable_manager.dart';

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

  final ClientWebSocket socket;

  GameUI(this.socket);

  static final resourceManager = new ResourceManager();
  final options = new StageOptions()
    ..backgroundColor = Color.Transparent
    ..transparent = true
    ..renderEngine = RenderEngine.WebGL;

  final canvas = html.querySelector('#stage');
  Stage stage;

  final selectableCardIDs = <String>[];

  final cardFaceBitmapDatum = <String, BitmapData>{};

  Bitmap currentPlayerToken;

  final Bitmap blackOverlay =
      new Bitmap(new BitmapData(gameWidth, gameHeight, Color.Black));

  Sprite higherChoice;
  Sprite lowerChoice;

  Bitmap higher;
  Bitmap lower;

  init() async {
    canvas.onClick.listen((_) {
      (html.querySelector('#toggle-1') as html.InputElement).checked = false;
    });

    stage = new Stage(canvas,
        width: gameWidth, height: gameHeight, options: options);

    final renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

    resourceManager.addBitmapData("crown", "images/crown.png");
    resourceManager.addBitmapData("LOWER_CHOICE", "images/LOWER_CHOICE.png");
    resourceManager.addBitmapData("LOWER", "images/LOWER.png");
    resourceManager.addBitmapData("HIGHER_CHOICE", "images/HIGHER_CHOICE.png");
    resourceManager.addBitmapData("HIGHER", "images/HIGHER.png");
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

    lower = new Bitmap(resourceManager.getBitmapData("LOWER"));
    higher = new Bitmap(resourceManager.getBitmapData("HIGHER"));

    currentPlayerToken = new Bitmap(resourceManager.getBitmapData("crown"));
    currentPlayerToken.x = midPoint.x;
    currentPlayerToken.y = midPoint.y;
    currentPlayerToken.pivotX = currentPlayerToken.width / 2;
    currentPlayerToken.pivotY = currentPlayerToken.height / 2;
    stage.addChild(currentPlayerToken);

    lowerChoice = new Sprite();
    lowerChoice.children
        .add(new Bitmap(resourceManager.getBitmapData("LOWER_CHOICE")));
    lowerChoice.pivotX = lowerChoice.width / 2;
    lowerChoice.pivotY = lowerChoice.height / 2;
    lowerChoice.x = midPoint.x - lowerChoice.width / 2 - 25;
    lowerChoice.y = midPoint.y;
    lowerChoice.mouseCursor = MouseCursor.POINTER;
    lowerChoice.filters = [
      new DropShadowFilter(1),
      new GlowFilter(Color.LimeGreen, 15, 15, 2),
      new GlowFilter(Color.LimeGreen, 15, 15, 2)
    ];
    lowerChoice.onMouseClick.listen((_) {
      chooseHigherLower(HigherLowerChoice_Type.LOWER);
    });

    higherChoice = new Sprite();
    higherChoice.children
        .add(new Bitmap(resourceManager.getBitmapData("HIGHER_CHOICE")));
    higherChoice.pivotX = higherChoice.width / 2;
    higherChoice.pivotY = higherChoice.height / 2;
    higherChoice.x = midPoint.x + higherChoice.width / 2 + 25;
    higherChoice.y = midPoint.y;
    higherChoice.mouseCursor = MouseCursor.POINTER;
    higherChoice.filters = [
      new DropShadowFilter(1),
      new GlowFilter(Color.LimeGreen, 15, 15, 2),
      new GlowFilter(Color.LimeGreen, 15, 15, 2)
    ];
    higherChoice.onMouseClick.listen((_) {
      chooseHigherLower(HigherLowerChoice_Type.HIGHER);
    });

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

    stage.onMouseMove.listen((MouseEvent e) {
      final objects = stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));

      final cardsTouched = objects.where((e) => e.parent is ClientCard);

      for (var card in playedCards) {
        if (!stage.juggler.containsTweens(card)) {
          card.alpha = 1;
        }
      }

      for (var card in cardsTouched) {
        final parent = card.parent as ClientCard;

        if (playedCards.contains(parent) &&
            parent.cardInfo.type != Card_Type.BASIC &&
            parent.cardInfo.type != Card_Type.HIGHER_LOWER &&
            parent.cardInfo.type != Card_Type.WILD) {
          parent.alpha = 0.1;
        }
      }

      if (hands.isEmpty) return;

      final hand = hands.first;

      if (cardsTouched.isEmpty) return;

      final lastCardTouched = cardsTouched.last.parent;

      final startY = gameHeight;

      for (var i = 0; i < hand.length; i++) {
        final card = hand[i];

        if (!card.interactable) continue;

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

  createDeck() {
    final cardsToRemove = <DisplayObject>[];

    stage.children
        .where((child) => child is ClientCard)
        .forEach((card) => cardsToRemove.add(card));

    for (var card in cardsToRemove) {
      card.removeFromParent();
    }

    deck.clear();
    for (var i = 0; i < defaultDeckLength; i++) {
      final cardSprite = new ClientCard();
      cardSprite.x = gameWidth / 2 - cardWidth - 100;
      cardSprite.y = gameHeight / 2;

      stage.children.add(cardSprite);
      deck.add(cardSprite);
    }
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
    if (SelectableManager.shared.selectedIDs.isEmpty) return;

    final cardIDs = new CardIDs()
      ..ids.addAll(SelectableManager.shared.selectedIDs);

    socket.send(SocketMessage_Type.USER_PLAY, cardIDs);
    print('sent $cardIDs');

    clearSelectableCards();

    SelectableManager.shared.selectedIDs.clear();
  }

  onDealTowerInfo(DealTowerInfo info) async {
    createDeck();
    hands.clear();
    topTowers.clear();
    botTowers.clear();

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
        newCard.hidden = false;
        dealTowerAnim(newCard, topTowers, userIndex, cardIndex, .6);
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }

    final cardIDs = new CardIDs()
      ..ids.addAll(topTowers.first.map((cCard) => cCard.cardInfo.id));
    setSelectableCards(cardIDs);
  }

  onTowerCardsToHand(TowerCardsToHandInfo info) async {
    final newCards = <ClientCard>[];

    final initialHandLength = hands[info.userIndex].length;

    for (var cardID in info.cardIDs) {
      if (cardRegistry.containsKey(cardID)) {
        final card = cardRegistry[cardID];

        if (info.userIndex != 0) {
          card.hidden = true;
        }

        stage.setChildIndex(card, stage.children.length - 1);

        hands[info.userIndex].add(card);

        final tower = topTowers[info.userIndex];
        tower[tower.indexOf(card)] = null;

        newCards.add(card);
      }
    }

    animateCardsInHand(
        info.userIndex, .75, Transition.easeOutQuintic, initialHandLength);

    for (var card in newCards) {
      animateCardToHand(card, info.userIndex, 1, Transition.easeInOutCubic);
      await new Future.delayed(const Duration(milliseconds: 150));
    }
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
    for (var userIndex = 0; userIndex < info.hands.length; userIndex++) {
      final newCards = <ClientCard>[];

      final initialHandLength = hands[userIndex].length;

      for (var cardInfo in info.hands[userIndex].cards) {
        final newCard = drawFromDeck(cardInfo);

        hands[userIndex].add(newCard);
        newCards.add(newCard);
      }

      animateCardsInHand(
          userIndex, .75, Transition.easeOutQuintic, initialHandLength);

      for (var card in newCards) {
        stage.setChildIndex(card, stage.children.length - 1);
        animateCardToHand(card, userIndex, 1, Transition.easeOutQuintic);
        await new Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  final rand = new Random();

  onPlayFromHandInfo(PlayFromHandInfo info) async {
    final revealedCards = <ClientCard>[];

    for (var card in info.cards) {
      final revealedCard = cardRegistry[card.id];
      revealedCard.cardInfo = card;
      revealedCard.interactable = false;

      playedCards.add(revealedCard);
      revealedCards.add(revealedCard);

      hands[info.userIndex].remove(revealedCard);
    }

    animateCardsInHand(info.userIndex, .75, Transition.easeOutQuintic,
        hands[info.userIndex].length);

    for (var revealedCard in revealedCards) {
      stage.juggler.removeTweens(revealedCard);

      final tween =
          stage.juggler.addTween(revealedCard, 1, Transition.easeOutQuintic);

      final offSetX = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetY = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetRotation = rand.nextDouble() / 2 * (rand.nextBool() ? -1 : 1);

      tween.animate.x.to(midPoint.x + offSetX);
      tween.animate.y.to(midPoint.y + offSetY);
      tween.animate.rotation.by(offSetRotation);

      stage.setChildIndex(revealedCard, stage.children.length - 1);

      await new Future.delayed(const Duration(milliseconds: 200));
    }
  }

  onPickUpPileInfo(PickUpPileInfo info) async {
    final pickedUpCards = <ClientCard>[];

    final initialHandLength = hands[info.userIndex].length;

    for (var cardInfo in info.cards) {
      final pickedUpCard = cardRegistry[cardInfo.id];
      pickedUpCard.cardInfo = cardInfo;

      hands[info.userIndex].add(pickedUpCard);
      pickedUpCards.add(pickedUpCard);
    }

    animateCardsInHand(
        info.userIndex, .75, Transition.easeOutQuintic, initialHandLength);

    for (var pickedUpCard in pickedUpCards) {
      animateCardToHand(
          pickedUpCard, info.userIndex, 1, Transition.easeInOutCubic);
      await new Future.delayed(const Duration(milliseconds: 125));
    }

    for (var card in playedCards) {
      card.alpha = 1;
    }

    playedCards.clear();

    bringHandCardsToTop();
  }

  onDiscardInfo(DiscardInfo info) {
    for (var cardInfo in info.cards) {
      final discardedCard = cardRegistry[cardInfo.id];
      discardedCard.cardInfo = cardInfo;

      List<ClientCard> cardHand;

      for (var hand in hands) {
        if (hand.contains(discardedCard)) {
          cardHand = hand;
        }
      }

      if (cardHand != null) {
        cardHand.remove(discardedCard);
        final tween =
            stage.juggler.addTween(discardedCard, 2, Transition.easeOutQuintic);
        tween.animate.alpha.to(0);
        tween.animate.pivotY.by(300);
        tween.onComplete = () {
          discardedCard.removeFromParent();
        };
      } else {
        final tween =
            stage.juggler.addTween(discardedCard, 1, Transition.easeOutQuintic);
        tween.animate.alpha.to(0);
        tween.onComplete = () {
          discardedCard.removeFromParent();
        };
      }

      cardRegistry.remove(cardInfo.id);

      if (playedCards.contains(discardedCard)) {
        playedCards.remove(discardedCard);
      }
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

    final newCards = <ClientCard>[];

    final initalHandLength = hands[info.userIndex].length;

    for (var cardInfo in info.cards) {
      final newCard = drawFromDeck(cardInfo);
      hands[info.userIndex].add(newCard);

      newCards.add(newCard);
    }

    animateCardsInHand(
        info.userIndex, .75, Transition.easeOutQuintic, initalHandLength);
    await new Future.delayed(const Duration(milliseconds: 500));

    for (var cCard in newCards) {
      stage.setChildIndex(cCard, stage.children.length - 1);

      animateCardToHand(cCard, info.userIndex, 1, Transition.easeInOutCubic);
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

    stage.juggler.removeTweens(cCard);

    final tween = stage.juggler.addTween(cCard, animDuration, transition);

    final handWidth = hand.length * 75 - cardWidth / 2;
    final startingX = gameWidth / 2 - handWidth / 2;
    final startingY = gameHeight;

    final x = startingX + hand.indexOf(cCard) * 75;
    var y = startingY;

    if (handIndex % 2 != 0) {
      y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
    }

    final rotatedPoint =
        rotatePoint(midPoint.x, midPoint.y, x, y, handIndex * -90);

    tween.animate.x.to(rotatedPoint.x);
    tween.animate.y.to(rotatedPoint.y);
    tween.animate.rotation.to(handIndex * pi / 2);

    tween.onComplete = () {
      if (handIndex == 0) {
        cCard.interactable = true;
      }
    };

//    stage.setChildIndex(cCard, stage.children.length - 1);
  }

  animateCardsInHand(
      int handIndex, num animDuration, var transition, int range) {
    final hand = hands[handIndex];

    final handWidth = hand.length * 75 - cardWidth / 2;
    final startingX = gameWidth / 2 - handWidth / 2;
    final startingY = gameHeight;

    for (var j = 0; j < range; j++) {
      final _card = hand[j];

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
    for (var hand in hands.reversed) {
      for (var card in hand) {
        stage.setChildIndex(card, stage.children.length - 1);
      }
    }
  }

  setActivePlayerIndex(int index) {
    num y = gameHeight - cardHeight - 75;
    final x = midPoint.x - cardWidth;

    final tween = stage.juggler
        .addTween(currentPlayerToken, 1, Transition.easeInOutCubic);

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

  onRequest_HigherLowerChoice() {
    blackOverlay.alpha = 0;

    stage.addChild(blackOverlay);

    final tween =
        stage.juggler.addTween(blackOverlay, .5, Transition.easeOutQuintic);
    tween.animate.alpha.to(.75);

    higherChoice.alpha = 0;
    lowerChoice.alpha = 0;
    stage.addChild(higherChoice);
    stage.addChild(lowerChoice);

    final tween2 =
        stage.juggler.addTween(higherChoice, .5, Transition.easeOutQuintic);
    tween2.animate.alpha.to(1);

    final tween3 =
        stage.juggler.addTween(lowerChoice, .5, Transition.easeOutQuintic);
    tween3.animate.alpha.to(1);
  }

  chooseHigherLower(HigherLowerChoice_Type type) {
    blackOverlay.removeFromParent();
    lowerChoice.removeFromParent();
    higherChoice.removeFromParent();

    final higherLowerChoice = new HigherLowerChoice()..choice = type;
    socket.send(SocketMessage_Type.HIGHERLOWER_CHOICE, higherLowerChoice);
  }

  onHigherLowerChoice(HigherLowerChoice choice) {
    assert(playedCards.last.cardInfo.type == Card_Type.HIGHER_LOWER);

    final card = playedCards.last;
    card.front.removeFromParent();
    card.front = new Bitmap(
        GameUI.resourceManager.getBitmapData("BASIC${choice.value}"));
    card.addChild(card.front);

    if (choice.choice == HigherLowerChoice_Type.HIGHER) {
      higher.removeFromParent();
      card.addChild(higher);
    } else {
      lowerChoice.removeFromParent();
      card.addChild(lower);
    }
  }

  void onChangeDiscardToRock(Card card) {
    card.hidden = false;

    final revealedCard = cardRegistry[card.id];
    revealedCard.cardInfo = card;
  }

  void onHandSwapInfo(HandSwapInfo handSwapInfo) {
    final revealedCards1 = <ClientCard>[];

    for (var card in handSwapInfo.cards1) {
      final revealedCard = cardRegistry[card.id];
      revealedCard.cardInfo = card;

      if (handSwapInfo.userIndex1 == 0) {
        revealedCard.interactable = true;
        revealedCard.hidden = false;
      } else {
        revealedCard.interactable = false;
        revealedCard.hidden = true;
      }

      revealedCards1.add(revealedCard);
    }

    hands[handSwapInfo.userIndex1] = revealedCards1;

    final revealedCards2 = <ClientCard>[];

    for (var card in handSwapInfo.cards2) {
      final revealedCard = cardRegistry[card.id];
      revealedCard.cardInfo = card;

      if (handSwapInfo.userIndex2 == 0) {
        revealedCard.interactable = true;
        revealedCard.hidden = false;
      } else {
        revealedCard.interactable = false;
        revealedCard.hidden = true;
      }

      revealedCards2.add(revealedCard);
    }

    hands[handSwapInfo.userIndex2] = revealedCards2;

    for (var i = 0; i < hands[handSwapInfo.userIndex1].length; i++) {
      final card = hands[handSwapInfo.userIndex1][i];

      animateCardToHand(
          card, handSwapInfo.userIndex1, 1, Transition.easeInOutCubic);
    }

    for (var i = 0; i < hands[handSwapInfo.userIndex2].length; i++) {
      final card = hands[handSwapInfo.userIndex2][i];

      animateCardToHand(
          card, handSwapInfo.userIndex2, 1, Transition.easeInOutCubic);
    }

    bringHandCardsToTop();
  }

  void onTopSwapInfo(TopSwapInfo topSwapInfo) {
    final card1 = cardRegistry[topSwapInfo.card1.id];
    final card2 = cardRegistry[topSwapInfo.card2.id];

    int card1TowerIndex;
    List<List<ClientCard>> card1Towers;
    if (topTowers.where((tower) => tower.contains(card1)).isNotEmpty) {
      card1TowerIndex = topTowers.indexWhere((tower) => tower.contains(card1));
      card1Towers = topTowers;
    }
    if (botTowers.where((tower) => tower.contains(card1)).isNotEmpty) {
      card1TowerIndex = botTowers.indexWhere((tower) => tower.contains(card1));
      card1Towers = botTowers;
    }

    int card2TowerIndex;
    List<List<ClientCard>> card2Towers;
    if (topTowers.where((tower) => tower.contains(card2)).isNotEmpty) {
      card2TowerIndex = topTowers.indexWhere((tower) => tower.contains(card2));
      card2Towers = topTowers;
    }
    if (botTowers.where((tower) => tower.contains(card2)).isNotEmpty) {
      card2TowerIndex = botTowers.indexWhere((tower) => tower.contains(card2));
      card2Towers = botTowers;
    }
    final card1Index = card1Towers[card1TowerIndex].indexOf(card1);
    final card2Index = card2Towers[card2TowerIndex].indexOf(card2);

    dealTowerAnim(card1, card2Towers, card2TowerIndex, card2Index, 1.25);
    dealTowerAnim(card2, card1Towers, card1TowerIndex, card1Index, 1.25);

    bringHandCardsToTop();
  }
}
