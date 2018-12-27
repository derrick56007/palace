import 'dart:async';
import 'dart:html' as html;
import 'dart:math' hide Point;

import 'package:stagexl/stagexl.dart';

import 'client_card.dart';
import 'client_websocket.dart';
import 'common/generated_protos.dart';
import 'math_helper.dart';
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

  static const midPoint = const Vector2(gameWidth / 2, gameHeight / 2);

  static const defaultDeckLength = 56;

  final ClientWebSocket socket;

  GameUI(this.socket);

  static TextureAtlas textureAtlas;

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
      new Bitmap(new BitmapData(gameWidth * 2, gameHeight * 2, Color.Black));

  Sprite higherChoice;
  Sprite lowerChoice;
  Sprite playedCardsHoverSprite;

  final Bitmap playedCardsHoverBitmap =
      new Bitmap(new BitmapData(cardHeight, cardHeight, Color.Black));
  Bitmap higher;
  Bitmap lower;

  TextField mulliganTimerTextField;
  TextField mulliganTitleTextField;
  TextField mulliganSubtitleTextField;
  TextField sendButton;
  TextField pickUpButton;

  TextField cardsInDeckTextField;
  TextField cardsInPileTextField;

  AlphaMaskFilter mask;

  final greenGlowFilter = new GlowFilter(Color.LimeGreen, 15, 15, 2);

  init() async {
    canvas.onClick.listen((_) {
      (html.querySelector('#toggle-1') as html.InputElement).checked = false;
      (html.querySelector('#toggle-2') as html.InputElement).checked = false;
    });

    var fullscreen = false;
    final fullscreenIcon = html.querySelector('#fullscreen-icon');
    html.querySelector('#fullscreen-btn').onClick.listen((_) {
      if (fullscreen) {
        // make not fullscreen
        fullscreenIcon.text = 'fullscreen';
        html.document.exitFullscreen();
      } else {
        // make fullscreen
        fullscreenIcon.text = 'fullscreen_exit';
        html.document.body.requestFullscreen();
      }

      fullscreen = !fullscreen;
    });

    stage = new Stage(canvas,
        width: gameWidth, height: gameHeight, options: options);

    blackOverlay.pivotX = blackOverlay.width / 2;
    blackOverlay.pivotY = blackOverlay.height / 2;
    blackOverlay.x = gameWidth / 2;
    blackOverlay.y = gameHeight / 2;

    final renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

    final resourceManager = new ResourceManager();
    resourceManager.addTextureAtlas(
        'spritesheet', 'images/spritesheet.json', TextureAtlasFormat.JSONARRAY);
    await resourceManager.load();

    textureAtlas = resourceManager.getTextureAtlas('spritesheet');

    lower = new Bitmap(textureAtlas.getBitmapData("LOWER"));
    higher = new Bitmap(textureAtlas.getBitmapData("HIGHER"));

    currentPlayerToken = new Bitmap(textureAtlas.getBitmapData("crown"));
    currentPlayerToken.x = midPoint.x;
    currentPlayerToken.y = midPoint.y;
    currentPlayerToken.pivotX = currentPlayerToken.width / 2;
    currentPlayerToken.pivotY = currentPlayerToken.height / 2;
    stage.addChild(currentPlayerToken);

    lowerChoice = new Sprite();
    lowerChoice.children
        .add(new Bitmap(textureAtlas.getBitmapData("LOWER_CHOICE")));
    lowerChoice.pivotX = lowerChoice.width / 2;
    lowerChoice.pivotY = lowerChoice.height / 2;
    lowerChoice.x = midPoint.x - lowerChoice.width / 2 - 100;
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
        .add(new Bitmap(textureAtlas.getBitmapData("HIGHER_CHOICE")));
    higherChoice.pivotX = higherChoice.width / 2;
    higherChoice.pivotY = higherChoice.height / 2;
    higherChoice.x = midPoint.x + higherChoice.width / 2 + 100;
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

    playedCardsHoverSprite = new Sprite();
    playedCardsHoverSprite
      ..children.add(playedCardsHoverBitmap)
      ..pivotX = cardHeight / 2
      ..pivotY = cardHeight / 2
      ..x = midPoint.x
      ..y = midPoint.y;
    stage.addChild(playedCardsHoverSprite);

    final textFormat = new TextFormat('Cardenio', 50, Color.White, weight: 500,
        strokeColor: Color.Black, strokeWidth: 3);
    sendButton = new TextField('Send', textFormat);
    sendButton
      ..x = midPoint.x + 280
      ..y = midPoint.y + 200
      ..height = 60
      ..width = 90
      ..pivotX = sendButton.width / 2
      ..pivotY = sendButton.height / 2
      ..onMouseClick.listen((_) {
        sendSelectedCards();
      })
      ..onMouseMove.listen((_) {
        if (SelectableManager.shared.selectedIDs.isNotEmpty) {
          sendButton.mouseCursor = MouseCursor.POINTER;
        } else {
          sendButton.mouseCursor = MouseCursor.DEFAULT;
        }
      });
    stage.addChild(sendButton);

    pickUpButton = new TextField('Pick Up', textFormat);
    pickUpButton
      ..x = midPoint.x + 200
      ..y = midPoint.y
      ..height = 60
      ..width = 120
      ..pivotX = pickUpButton.width / 2
      ..pivotY = pickUpButton.height / 2
      ..onMouseClick.listen((_) {
        sendPickUp();
      })
      ..onMouseOver.listen((_) {
        if (playedCards.isNotEmpty && selectableCardIDs.isNotEmpty) {
          pickUpButton.mouseCursor = MouseCursor.POINTER;
        } else {
          pickUpButton.mouseCursor = MouseCursor.DEFAULT;
        }
      });
    stage.addChild(pickUpButton);

    final mulliganTimerTextFormat = new TextFormat('Cardenio', 50, Color.White,
        align: TextFormatAlign.CENTER,
        strokeColor: Color.Black,
        strokeWidth: 3);
    mulliganTimerTextField = new TextField('', mulliganTimerTextFormat)
      ..height = 60
      ..width = 500;
    mulliganTimerTextField
      ..pivotX = mulliganTimerTextField.width / 2
      ..pivotY = mulliganTimerTextField.height / 2
      ..x = midPoint.x
      ..y = midPoint.y + 120
      ..filters = [new GlowFilter(Color.LimeGreen, 15, 15, 2)];

    final mulliganTitleTextFormat = new TextFormat('Cardenio', 75, Color.White,
        weight: 500,
        align: TextFormatAlign.CENTER,
        strokeColor: Color.Black,
        strokeWidth: 5);
    mulliganTitleTextField =
        new TextField('Tower Cards', mulliganTitleTextFormat)
          ..height = 100
          ..width = 300;
    mulliganTitleTextField
      ..pivotX = mulliganTitleTextField.width / 2
      ..pivotY = mulliganTitleTextField.height / 2
      ..x = midPoint.x
      ..y = midPoint.y - 70
      ..filters = [new GlowFilter(Color.Gold, 15, 15, 2)];

    final mulliganSubtitleTextFormat = new TextFormat(
        'Cardenio', 50, Color.White,
        weight: 500,
        align: TextFormatAlign.CENTER,
        strokeColor: Color.Black,
        strokeWidth: 3);

    mulliganSubtitleTextField =
        new TextField('Keep or Replace Cards', mulliganSubtitleTextFormat)
          ..height = 100
          ..width = 400;
    mulliganSubtitleTextField
      ..pivotX = mulliganSubtitleTextField.width / 2
      ..pivotY = mulliganSubtitleTextField.height / 2
      ..x = midPoint.x
      ..y = midPoint.y + 20
      ..filters = [new GlowFilter(Color.Gold, 15, 15, 2)];

    final cardsInPileTextFormat = new TextFormat('Cardenio', 30, Color.Black,
        align: TextFormatAlign.CENTER);
    cardsInDeckTextField = new TextField('', cardsInPileTextFormat)
      ..height = 40
      ..width = 200;
    cardsInDeckTextField
      ..pivotX = cardsInDeckTextField.width / 2
      ..pivotY = cardsInDeckTextField.height / 2
      ..x = gameWidth / 2 - cardWidth - 100
      ..y = gameHeight / 2 + cardHeight / 2 + 25;
    stage.addChild(cardsInDeckTextField);

    cardsInPileTextField = new TextField('', cardsInPileTextFormat)
      ..height = 40
      ..width = 200;
    cardsInPileTextField
      ..pivotX = cardsInPileTextField.width / 2
      ..pivotY = cardsInPileTextField.height / 2
      ..x = gameWidth / 2
      ..y = gameHeight / 2 + cardHeight / 2 + 25;
    stage.addChild(cardsInPileTextField);

    var cardHovered = null;
    var pileHovered = false;
    stage.onMouseMove.listen((MouseEvent e) {
      final objects = stage.getObjectsUnderPoint(new Point(e.stageX, e.stageY));

      if (objects.contains(playedCardsHoverBitmap)) {
        if (!pileHovered) {
          for (var card in playedCards.reversed) {
            if (card.cardInfo.type != Card_Type.BASIC &&
                card.cardInfo.type != Card_Type.HIGHER_LOWER &&
                card.cardInfo.type != Card_Type.WILD) {
              card.alpha = .1;
            } else {
              break;
            }
          }

          pileHovered = true;
        }
      } else if (pileHovered) {
        for (var card in playedCards) {
          card.alpha = 1;
        }

        pileHovered = false;
      }

      if (hands.isEmpty) return;

      final hand = hands.first;

      final cardsTouched = objects.where((e) => e.parent is ClientCard);

      // reset card positions
      if (cardsTouched.isEmpty) {
        if (cardHovered != null) {
          if (!SelectableManager.shared.selectedIDs
              .contains(cardHovered.cardInfo.id)) {
            final tween = stage.juggler
                .addTween(cardHovered, 1, Transition.easeOutQuintic);
            tween.animate.pivotY.to(cardHovered.userData);
          }

          cardHovered = null;
        }

        return;
      }

      final lastCardTouched = cardsTouched.last.parent as ClientCard;

      if (cardHovered == lastCardTouched) return;

      if (hand.contains(lastCardTouched)) {
        final tween = stage.juggler
            .addTween(lastCardTouched, 1, Transition.easeOutQuintic);
        tween.animate.pivotY.to(lastCardTouched.userData + 100);

        if (cardHovered != null &&
            !SelectableManager.shared.selectedIDs
                .contains(cardHovered.cardInfo.id)) {
          final tween =
              stage.juggler.addTween(cardHovered, 1, Transition.easeOutQuintic);
          tween.animate.pivotY.to(cardHovered.userData);
        }

        cardHovered = lastCardTouched;
      }
    });

    mask =
        new AlphaMaskFilter(new BitmapData(gameWidth, gameHeight, Color.Black));
    mask.matrix.scale(0, 0);

    hideGame();
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
      final cardSprite = new ClientCard(this);
      cardSprite.x = gameWidth / 2 - cardWidth - 100;
      cardSprite.y = gameHeight / 2;

      stage.children.add(cardSprite);
      deck.add(cardSprite);
    }

    cardsInDeckTextField.text = '${deck.length} Card(s)';
    cardsInPileTextField.text = '${playedCards.length} Card(s)';
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

    clearSelectableCards();

    animateCardsInHand(0, .75, Transition.easeOutQuintic, hands.first.length);

    SelectableManager.shared.selectedIDs.clear();
  }

  onDealTowerInfo(DealTowerInfo info) async {
    revealGame();

    hands.clear();
    topTowers.clear();
    botTowers.clear();
    playedCards.clear();
    createDeck();

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

        if (info.userIndex == 0) {
          stage.setChildIndex(card, stage.children.length - 1);
        } else {
          stage.setChildIndex(card, stage.children.indexOf(blackOverlay) - 1);
        }

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
    mulliganTitleTextField.removeFromParent();
    mulliganSubtitleTextField.removeFromParent();
    mulliganTimerTextField.removeFromParent();

    hideBlackOverlay();

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
      cardsInPileTextField.text = '${playedCards.length} Card(s)';
      revealedCards.add(revealedCard);

      hands[info.userIndex].remove(revealedCard);
    }

    animateCardsInHand(info.userIndex, .75, Transition.easeOutQuintic,
        hands[info.userIndex].length);

    for (var revealedCard in revealedCards) {
      stage.juggler.removeTweens(revealedCard);

//      revealedCard
//        ..pivotX = cardWidth / 2
//        ..pivotY = cardHeight / 2;

      final tween =
          stage.juggler.addTween(revealedCard, 1, Transition.easeOutQuintic);

      final offSetX = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetY = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetRotation = rand.nextDouble() / 2 * (rand.nextBool() ? -1 : 1);

      tween.animate
        ..x.to(midPoint.x + offSetX)
        ..y.to(midPoint.y + offSetY - 15)
        ..rotation.by(offSetRotation)
        ..pivotY.to(cardHeight / 2)
        ..pivotX.to(cardWidth / 2);

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

      stage.juggler.removeTweens(pickedUpCard);
      pickedUpCard.alpha = 1;

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

    cardsInPileTextField.text = '${playedCards.length} Card(s)';

    bringHandCardsToTop();
  }

  onDiscardInfo(DiscardInfo info) {
    for (var cardInfo in info.cards) {
      final discardedCard = cardRegistry[cardInfo.id];
      discardedCard.cardInfo = cardInfo;
      discardedCard.hidden = false;

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

        cardsInPileTextField.text = '${playedCards.length} Card(s)';
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
    sendButton.filters.clear();
  }

  setMulliganableCards(CardIDs cardIDs) {
    displayBlackOverlay();

    stage
      ..addChild(mulliganTitleTextField)
      ..setChildIndex(mulliganTitleTextField, stage.children.length - 1)
      ..addChild(mulliganSubtitleTextField)
      ..setChildIndex(mulliganSubtitleTextField, stage.children.length - 1)
      ..addChild(mulliganTimerTextField)
      ..setChildIndex(mulliganTimerTextField, stage.children.length - 1)
      ..setChildIndex(sendButton, stage.children.length - 1);

    for (var id in cardIDs.ids) {
      if (cardRegistry.containsKey(id)) {
        final card = cardRegistry[id];
        card.selectable = true;
        stage.setChildIndex(card, stage.children.length - 1);
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
    final newCards = <ClientCard>[];

    final initialHandLength = hands[info.userIndex].length;

    for (var cardInfo in info.cards) {
      final newCard = drawFromDeck(cardInfo);
      hands[info.userIndex].add(newCard);

      newCards.add(newCard);
    }

    animateCardsInHand(
        info.userIndex, .75, Transition.easeOutQuintic, initialHandLength);
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

    cardsInDeckTextField.text = '${deck.length} Card(s)';

    return cCard;
  }

  static const range = 1.5708;
  static const leftCorner = const Vector2(0, cardHeight * .9);
  static const rightCorner = const Vector2(cardWidth, cardHeight * .9);

  animateCardToHand(
      ClientCard cCard, int handIndex, num duration, var transition) {
    final hand = hands[handIndex];

    stage.juggler.removeTweens(cCard);

    final tween = stage.juggler.addTween(cCard, duration, transition);

    final increment = range / hand.length;
    final initialAngle = hand.length % 2 == 0
        ? -increment / 2 + (-increment * (hand.length / 2 - 1))
        : -increment * (hand.length / 2).floor();

    final cardIndex = hand.indexOf(cCard);
    final angle = cardIndex * increment;
    final cardAngle = initialAngle + angle + (hand.length == 1 ? 0 : .3);
    final origin = lerp(rightCorner, leftCorner, angle / range);

    final x = midPoint.x - (hand.length / 2 * 25) + cardIndex * 25 + 25;
    var y = gameHeight;

    if (handIndex % 2 != 0) {
      y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
    }

    final rotatedPoint =
        rotatePoint(midPoint.x, midPoint.y, x, y, handIndex * -90);

    tween.animate
      ..x.to(rotatedPoint.x)
      ..y.to(rotatedPoint.y)
      ..rotation.to(cardAngle + handIndex * pi / 2)
      ..pivotX.to(origin.x)
      ..pivotY.to(origin.y / 2);

    cCard.userData = origin.y / 2;

    tween.onComplete = () {
      if (handIndex == 0) {
        cCard.interactable = true;
      }
    };
  }

  animateCardsInHand(int handIndex, num duration, var transition, int cards) {
    final hand = hands[handIndex];

    final increment = range / hand.length;
    final initialAngle = hand.length % 2 == 0
        ? -increment / 2 + (-increment * (hand.length / 2 - 1))
        : -increment * (hand.length / 2).floor();

    for (var j = 0; j < cards; j++) {
      final _card = hand[j];

      final tween = stage.juggler.addTween(_card, duration, transition);

      final angle = j * increment;
      final cardAngle = initialAngle + angle + (hand.length == 1 ? 0 : .3);
      final origin = lerp(rightCorner, leftCorner, angle / range);

      final x = midPoint.x - (hand.length / 2 * 25) + j * 25 + 25;
      var y = gameHeight;

      if (handIndex % 2 != 0) {
        y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
      }

      final rotatedPoint =
          rotatePoint(midPoint.x, midPoint.y, x, y, handIndex * -90);

      tween.animate
        ..x.to(rotatedPoint.x)
        ..y.to(rotatedPoint.y)
        ..rotation.to(cardAngle + handIndex * pi / 2)
        ..pivotX.to(origin.x)
        ..pivotY.to(origin.y / 2);

      _card.userData = origin.y / 2;

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

  displayBlackOverlay() {
    blackOverlay.alpha = 0;

    stage.addChild(blackOverlay);
    stage.setChildIndex(blackOverlay, stage.children.length - 1);

    final tween =
        stage.juggler.addTween(blackOverlay, .5, Transition.easeOutQuintic);
    tween.animate.alpha.to(.75);
  }

  hideBlackOverlay() {
    if (blackOverlay.parent == null) return;

    final tween =
        stage.juggler.addTween(blackOverlay, .5, Transition.easeOutQuintic);
    tween.animate.alpha.to(0);
    tween.onComplete = () {
      blackOverlay.removeFromParent();
    };
  }

  onRequest_HigherLowerChoice(int value) {
    displayBlackOverlay();

    higherChoice.alpha = 0;
    lowerChoice.alpha = 0;
    stage.addChild(higherChoice);
    stage.addChild(lowerChoice);
    stage.setChildIndex(higherChoice, stage.children.length - 1);
    stage.setChildIndex(lowerChoice, stage.children.length - 1);

    final tween2 =
        stage.juggler.addTween(higherChoice, .5, Transition.easeOutQuintic);
    tween2.animate.alpha.to(1);

    final tween3 =
        stage.juggler.addTween(lowerChoice, .5, Transition.easeOutQuintic);
    tween3.animate.alpha.to(1);
    tween3.onComplete = () {
      final cardInfo = new Card()
        ..type = Card_Type.BASIC
        ..value = value
        ..id = playedCards.last.cardInfo.id;
      playedCards.last.cardInfo = cardInfo;

      final tween4 = stage.juggler
          .addTween(playedCards.last, .5, Transition.easeOutQuintic);
      tween4.animate.rotation.to(0);
      tween4.animate.x.to(gameWidth / 2);
      tween4.animate.y.to(gameHeight / 2);
    };

    stage.setChildIndex(playedCards.last, stage.children.length - 1);
    playedCards.last.filters.addAll([
      new GlowFilter(Color.Gold, 15, 15, 2),
      new GlowFilter(Color.Gold, 15, 15, 2)
    ]);
  }

  chooseHigherLower(HigherLowerChoice_Type type) {
    hideBlackOverlay();
    lowerChoice.removeFromParent();
    higherChoice.removeFromParent();

    final higherLowerChoice = new HigherLowerChoice()..choice = type;
    socket.send(SocketMessage_Type.HIGHERLOWER_CHOICE, higherLowerChoice);

    playedCards.last.filters.removeWhere((filter) => filter is GlowFilter);
  }

  onHigherLowerChoice(HigherLowerChoice choice) {
    final card = playedCards.last;
    card.front.removeFromParent();
    card.front =
        new Bitmap(GameUI.textureAtlas.getBitmapData("BASIC${choice.value}"));
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

  void sendPickUp() {
    if (playedCards.isNotEmpty && selectableCardIDs.isNotEmpty) {
      socket.send(SocketMessage_Type.REQUEST_PICK_UP);

      clearSelectableCards();
    }
  }

  void onMulliganTimerUpdate(String info) {
    mulliganTimerTextField.text = info;
  }

  void hideGame() {
    stage.filters = [mask];
  }

  void revealGame() {
    stage.filters.clear();
  }
}
