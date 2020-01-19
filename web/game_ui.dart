import 'dart:async';
import 'dart:html' as html;
import 'dart:math' hide Point;

import 'package:stagexl/stagexl.dart';

import 'client_card.dart';
import 'client_websocket.dart';
import 'common/generated_protos.dart';
import 'math_helper.dart';
import 'selectable_manager.dart';
import 'toast.dart';

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

  static const midPoint = Vector2(gameWidth / 2, gameHeight / 2);

  static const defaultDeckLength = 56;

  final ClientWebSocket socket;

  GameUI(this.socket);

  static TextureAtlas textureAtlas;

  final options = StageOptions()
    ..backgroundColor = Color.Transparent
    ..transparent = true
    ..renderEngine = RenderEngine.WebGL;

  final canvas = html.querySelector('#stage');
  Stage stage;

  final selectableCardIDs = <String>[];

  Bitmap currentPlayerToken;

  final Bitmap blackOverlay =
      Bitmap(BitmapData(gameWidth * 2, gameHeight * 2, Color.Black));

  Sprite higherChoice;
  Sprite lowerChoice;
  Sprite playedCardsHoverSprite;
  Sprite cardsLeftHoverSprite;

  final Bitmap playedCardsHoverBitmap =
      Bitmap(BitmapData(cardHeight, cardHeight, Color.Transparent));
  final Bitmap cardsLeftHoverBitmap =
      Bitmap(BitmapData(cardWidth, cardHeight, Color.Transparent));

  Bitmap higher;
  Bitmap lower;

  TextField mulliganTimerTextField;
  TextField mulliganTitleTextField;
  TextField mulliganSubtitleTextField;

//  TextField sendButton;
  TextField pickUpButton;

  AlphaMaskFilter mask;

  static final cardsInDeckEl = html.querySelector('#cards-in-deck');
  static final cardsInPileEl = html.querySelector('#cards-in-pile');

  final cardsInDeckToolTip = HtmlObject(cardsInDeckEl);
  final cardsInPileToolTip = HtmlObject(cardsInPileEl);

  final greenGlowFilter = GlowFilter(Color.LimeGreen, 15, 15, 2);

  Sprite3D sendButton3D;

  Bitmap sendButtonFrontBitmap;
  Bitmap sendButtonBackBitmap;

  Future<void> init() async {
    cardsInDeckToolTip
      ..x = midPoint.x - cardWidth - 170 - cardWidth / 2
      ..y = midPoint.y - cardHeight / 2 - 50;

    updatePileToolTip();

    cardsInPileToolTip
      ..x = midPoint.x - cardWidth / 2 - 160
      ..y = midPoint.y - cardHeight / 2 - 40;

    canvas.onClick.listen((_) {
      (html.querySelector('#toggle-1') as html.InputElement).checked = false;
      (html.querySelector('#toggle-2') as html.InputElement).checked = false;
    });

    var fullscreen = false;
    final fullscreenIcon = html.querySelector('#fullscreen-icon');

    html.window.onKeyDown.listen((e) {
//      print('${e.keyCode} ${html.KeyCode.ESC}');

      if (e.keyCode == html.KeyCode.ESC && fullscreen) {
        // make not fullscreen
        fullscreenIcon.text = 'fullscreen';
        html.document.exitFullscreen();

        fullscreen = false;
      }
    });

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

    stage =
        Stage(canvas, width: gameWidth, height: gameHeight, options: options);

    blackOverlay
      ..pivotX = blackOverlay.width / 2
      ..pivotY = blackOverlay.height / 2
      ..x = gameWidth / 2
      ..y = gameHeight / 2;

    final renderLoop = RenderLoop();
    renderLoop.addStage(stage);

    final resourceManager = ResourceManager();
    resourceManager.addTextureAtlas(
        'spritesheet', 'images/spritesheet.json', TextureAtlasFormat.JSONARRAY);
    await resourceManager.load();

    textureAtlas = resourceManager.getTextureAtlas('spritesheet');

    lower = Bitmap(textureAtlas.getBitmapData('LOWER'));
    higher = Bitmap(textureAtlas.getBitmapData('HIGHER'));

    currentPlayerToken = Bitmap(textureAtlas.getBitmapData('CROWN'));
    currentPlayerToken
      ..x = midPoint.x
      ..y = midPoint.y
      ..pivotX = currentPlayerToken.width / 2
      ..pivotY = currentPlayerToken.height / 2;
    stage.addChild(currentPlayerToken);

    lowerChoice = Sprite();
    lowerChoice.children
        .add(Bitmap(textureAtlas.getBitmapData('LOWER_CHOICE')));
    lowerChoice
      ..pivotX = lowerChoice.width / 2
      ..pivotY = lowerChoice.height / 2
      ..x = midPoint.x - lowerChoice.width / 2 - 100
      ..y = midPoint.y
      ..mouseCursor = MouseCursor.POINTER
      ..filters = [
        DropShadowFilter(1),
        GlowFilter(Color.LimeGreen, 15, 15, 2),
        GlowFilter(Color.LimeGreen, 15, 15, 2)
      ]
      ..onMouseClick.listen((_) {
        chooseHigherLower(HigherLowerChoice_Type.LOWER);
      });

    higherChoice = Sprite();
    higherChoice.children
        .add(Bitmap(textureAtlas.getBitmapData('HIGHER_CHOICE')));
    higherChoice
      ..pivotX = higherChoice.width / 2
      ..pivotY = higherChoice.height / 2
      ..x = midPoint.x + higherChoice.width / 2 + 100
      ..y = midPoint.y
      ..mouseCursor = MouseCursor.POINTER
      ..filters = [
        DropShadowFilter(1),
        GlowFilter(Color.LimeGreen, 15, 15, 2),
        GlowFilter(Color.LimeGreen, 15, 15, 2)
      ]
      ..onMouseClick.listen((_) {
        chooseHigherLower(HigherLowerChoice_Type.HIGHER);
      });

    playedCardsHoverSprite = Sprite();
    playedCardsHoverSprite
      ..children.add(playedCardsHoverBitmap)
      ..pivotX = cardHeight / 2
      ..pivotY = cardHeight / 2
      ..x = midPoint.x
      ..y = midPoint.y;
    stage.addChild(playedCardsHoverSprite);

    cardsLeftHoverSprite = Sprite();
    cardsLeftHoverSprite
      ..children.add(cardsLeftHoverBitmap)
      ..pivotX = cardWidth / 2
      ..pivotY = cardHeight / 2
      ..x = midPoint.x - cardWidth - 170
      ..y = midPoint.y;
    stage.addChild(cardsLeftHoverSprite);

    final textFormat = TextFormat('Cardenio', 50, Color.White,
        weight: 500, strokeColor: Color.Black, strokeWidth: 3);

    sendButtonFrontBitmap = Bitmap(textureAtlas.getBitmapData('SEND_BUTTON'));
    sendButtonBackBitmap = Bitmap(textureAtlas.getBitmapData('SEND_BACK'));
    sendButton3D = Sprite3D()
      ..addChild(sendButtonBackBitmap)
      ..x = midPoint.x + 280
      ..y = midPoint.y + 190
      ..pivotX = sendButtonBackBitmap.width / 2
      ..pivotY = sendButtonBackBitmap.height / 2
      ..rotationX = -pi
      ..onMouseClick.listen((_) {
        sendSelectedCards();
      })
      ..onMouseMove.listen((_) {
        if (SelectableManager.shared.selectedIDs.isNotEmpty) {
          sendButton3D.mouseCursor = MouseCursor.POINTER;
        } else {
          sendButton3D.mouseCursor = MouseCursor.DEFAULT;
        }
      });
    sendButton3D.userData = sendButton3D.pivotY;
    stage.addChild(sendButton3D);

    pickUpButton = TextField('Pick Up', textFormat);
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

    final mulliganTimerTextFormat = TextFormat('Cardenio', 50, Color.White,
        align: TextFormatAlign.CENTER,
        strokeColor: Color.Black,
        strokeWidth: 3);
    mulliganTimerTextField = TextField('', mulliganTimerTextFormat)
      ..height = 60
      ..width = 500;
    mulliganTimerTextField
      ..pivotX = mulliganTimerTextField.width / 2
      ..pivotY = mulliganTimerTextField.height / 2
      ..x = midPoint.x
      ..y = midPoint.y + 120;

    final mulliganTitleTextFormat = TextFormat('Cardenio', 75, Color.White,
        weight: 500,
        align: TextFormatAlign.CENTER,
        strokeColor: Color.Black,
        strokeWidth: 5);
    mulliganTitleTextField = TextField('Tower Cards', mulliganTitleTextFormat)
      ..height = 100
      ..width = 300;
    mulliganTitleTextField
      ..pivotX = mulliganTitleTextField.width / 2
      ..pivotY = mulliganTitleTextField.height / 2
      ..x = midPoint.x
      ..y = midPoint.y - 70
      ..filters = [GlowFilter(Color.Gold, 15, 15, 2)];

    final mulliganSubtitleTextFormat = TextFormat('Cardenio', 50, Color.White,
        weight: 500,
        align: TextFormatAlign.CENTER,
        strokeColor: Color.Black,
        strokeWidth: 3);

    mulliganSubtitleTextField =
        TextField('Keep or Replace Cards', mulliganSubtitleTextFormat)
          ..height = 100
          ..width = 400;
    mulliganSubtitleTextField
      ..pivotX = mulliganSubtitleTextField.width / 2
      ..pivotY = mulliganSubtitleTextField.height / 2
      ..x = midPoint.x
      ..y = midPoint.y + 20
      ..filters = [GlowFilter(Color.Gold, 15, 15, 2)];

    var cardHovered;
    var pileHovered = false;
    var deckHovered = false;

    stage.onMouseMove.listen((MouseEvent e) {
      final objects = stage.getObjectsUnderPoint(Point(e.stageX, e.stageY));

      // check if mouse is hovering over played cards pile
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

          stage.addChild(cardsInPileToolTip);

          pileHovered = true;
        }
        return;
      } else if (pileHovered) {
        for (var card in playedCards) {
          card.alpha = 1;
        }

        cardsInPileToolTip.removeFromParent();

        pileHovered = false;
      }

      // check if mouse is hovering over cards left in the deck
      if (objects.contains(cardsLeftHoverBitmap)) {
        if (!deckHovered) {
          // display number of cards left tooltip
          stage.addChild(cardsInDeckToolTip);

          deckHovered = true;
        }

        return;
      } else if (deckHovered) {
        // remove tooltip
        cardsInDeckToolTip.removeFromParent();

        deckHovered = false;
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

      if (cardHovered != null &&
          !SelectableManager.shared.selectedIDs
              .contains(cardHovered.cardInfo.id)) {
        final tween =
            stage.juggler.addTween(cardHovered, 1, Transition.easeOutQuintic);
        tween.animate.pivotY.to(cardHovered.userData);

        cardHovered = null;
      }

      if (hand.contains(lastCardTouched)) {
        final tween = stage.juggler
            .addTween(lastCardTouched, 1, Transition.easeOutQuintic);
        tween.animate.pivotY.to(lastCardTouched.userData + 100);

        cardHovered = lastCardTouched;
      }
    });

    mask = AlphaMaskFilter(BitmapData(gameWidth, gameHeight, Color.Black));
    mask.matrix.scale(0, 0);

    hideGame();
  }

  void createDeck() {
    final cardsToRemove = <DisplayObject>[];

    stage.children
        .whereType<ClientCard>()
        .forEach((card) => cardsToRemove.add(card));

    for (var card in cardsToRemove) {
      card.removeFromParent();
    }

    deck.clear();
    for (var i = 0; i < defaultDeckLength; i++) {
      final cardSprite = ClientCard(this);
      cardSprite.x = midPoint.x - cardWidth - 170;
      cardSprite.y = midPoint.y;

      stage.children.add(cardSprite);
      deck.add(cardSprite);
    }
  }

  void updatePileToolTip() {
    final count = <String, int>{
      '0': 0,
      '1': 0,
      '2': 0,
      '3': 0,
      '4': 0,
      '5': 0,
      '6': 0,
      '7': 0,
      '8': 0,
      '9': 0,
      'B': 0,
      'R': 0,
      'HL': 0,
      'W': 0,
      'D': 0,
      'H': 0,
      'T': 0,
    };

    for (var card in playedCards) {
      final info = card.cardInfo;
      switch (info.type) {
        case Card_Type.BASIC:
          count['${info.value}']++;
          break;
        case Card_Type.BOMB:
          count['B']++;
          break;
        case Card_Type.REVERSE:
          count['R']++;
          break;
        case Card_Type.WILD:
          count['W']++;
          break;
        case Card_Type.HIGHER_LOWER:
          count['HL']++;
          break;
        case Card_Type.DISCARD_OR_ROCK:
          count['D']++;
          break;
        case Card_Type.TOP_SWAP:
          count['T']++;
          break;
        case Card_Type.HAND_SWAP:
          count['H']++;
          break;
        default:
          break;
      }
    }

    var html = '';

    count.forEach((key, val) {
      if (val > 0) {
        html += '''
            <div class="pile-card-collection-item">
              <div class="pile-card-thumb">$key</div>
              <div>&nbsp;x&nbsp;$val</div>
            </div>
        ''';
      }
    });

    cardsInPileEl.innerHtml = '<div>$html</div>';
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

  void sendSelectedCards() {
    if (SelectableManager.shared.selectedIDs.isEmpty) return;

    final cardIDs = CardIDs()..ids.addAll(SelectableManager.shared.selectedIDs);

    socket.send(SocketMessage_Type.USER_PLAY, cardIDs);

    clearSelectableCards();

    animateCardsInHand(0, .75, Transition.easeOutQuintic, hands.first.length);

    SelectableManager.shared.selectedIDs.clear();
  }

  Future<void> onDealTowerInfo(DealTowerInfo info) async {
    revealGame();

    hands.clear();
    topTowers.clear();
    botTowers.clear();
    playedCards.clear();
    
    updatePileToolTip();

    createDeck();

    final usersLength = info.topTowers.length;

    for (var i = 0; i < usersLength; i++) {
      hands.add([]);
      topTowers.add(List<ClientCard>(towerLength));
      botTowers.add(List<ClientCard>(towerLength));
    }
    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < usersLength; userIndex++) {
        final newCard =
            drawFromDeck(info.bottomTowers[userIndex].cards[cardIndex]);
        dealTowerAnim(newCard, botTowers, userIndex, cardIndex, .6);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
      for (var userIndex = 0; userIndex < usersLength; userIndex++) {
        final newCard =
            drawFromDeck(info.topTowers[userIndex].cards[cardIndex]);
        newCard.hidden = false;
        dealTowerAnim(newCard, topTowers, userIndex, cardIndex, .6);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<void> onTowerCardsToHand(TowerCardsToHandInfo info) async {
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
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> secondTowerDealInfo(SecondDealTowerInfo info) async {
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
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }

    bringHandCardsToTop();
  }

  Future<void> onFinalDealInfo(FinalDealInfo info) async {
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
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
  }

  final rand = Random();

  Future<void> onPlayFromHandInfo(PlayFromHandInfo info) async {
    final revealedCards = <ClientCard>[];

    for (var card in info.cards) {
      final revealedCard = cardRegistry[card.id];
      playedCards.add(revealedCard);

      revealedCard.cardInfo = card;
      revealedCard.interactable = false;

      revealedCards.add(revealedCard);

      hands[info.userIndex].remove(revealedCard);
    }

    updatePileToolTip();

    animateCardsInHand(info.userIndex, .75, Transition.easeOutQuintic,
        hands[info.userIndex].length);

    for (var revealedCard in revealedCards) {
      stage.juggler.removeTweens(revealedCard);

      final tween =
          stage.juggler.addTween(revealedCard, 1, Transition.easeOutQuintic);

      final offSetX = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetY = rand.nextInt(15) * (rand.nextBool() ? -1 : 1);
      final offSetRotation = rand.nextDouble() / 2 * (rand.nextBool() ? -1 : 1);

      tween.animate
        ..x.to(midPoint.x + offSetX)
        ..y.to(midPoint.y + offSetY)
        ..rotation.by(offSetRotation)
        ..pivotY.to(cardHeight / 2)
        ..pivotX.to(cardWidth / 2);

      stage.setChildIndex(revealedCard, stage.children.length - 1);

      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> onPickUpPileInfo(PickUpPileInfo info) async {
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
      await Future.delayed(const Duration(milliseconds: 125));
    }

    for (var card in playedCards) {
      card.alpha = 1;
    }

    playedCards.clear();

    updatePileToolTip();

    bringHandCardsToTop();
  }

  void onDiscardInfo(DiscardInfo info) {
    for (var cardInfo in info.cards) {
      final discardedCard = cardRegistry[cardInfo.id];
      discardedCard.cardInfo = cardInfo;
      discardedCard.hidden = false;

      List<ClientCard> cardHand;

      for (var hand in hands) {
        if (hand.contains(discardedCard)) {
          cardHand = hand;
          break;
        }
      }

      if (cardHand != null) {
        cardHand.remove(discardedCard);
        final tween =
            stage.juggler.addTween(discardedCard, 2, Transition.easeOutQuintic);
        tween
          ..animate.alpha.to(0)
          ..animate.pivotY.by(250)
          ..onComplete = () {
            discardedCard.removeFromParent();
          };
      } else {
        final tween =
            stage.juggler.addTween(discardedCard, 1, Transition.easeOutQuintic);
        tween
          ..animate.alpha.to(0)
          ..onComplete = () {
            discardedCard.removeFromParent();
          };
      }

      cardRegistry.remove(cardInfo.id);

      if (playedCards.contains(discardedCard)) {
        playedCards.remove(discardedCard);
      }
    }

    updatePileToolTip();
  }

  void clearSelectableCards() {
    for (var cardID in selectableCardIDs) {
      if (cardRegistry.containsKey(cardID)) {
        final card = cardRegistry[cardID];
        card.selectable = false;
      }
    }

    selectableCardIDs.clear();

    animateSendButton(false);
  }

  bool sendButtonEnabled = false;

  void animateSendButton(bool enable) {
    if (sendButtonEnabled == enable) return;

    stage.setChildIndex(sendButton3D, stage.children.length - 1);

    sendButtonEnabled = enable;

    final tween = stage.juggler.addTween(sendButton3D, 0.2)
      ..animate3D.rotationX.to(pi / 2)
      ..animate.scaleX.to(1.75)
      ..animate.scaleY.to(1.75)
      ..animate.pivotY.to(sendButton3D.userData - 50);

    tween.onComplete = () {
      sendButton3D.children.clear();

      if (enable) {
        sendButton3D.children.add(sendButtonFrontBitmap);
      } else {
        sendButton3D
          ..children.add(sendButtonBackBitmap)
          ..filters.clear();
      }

      stage.juggler.addTween(sendButton3D, 0.2)
        ..animate3D.rotationX.to(pi)
        ..animate.scaleX.to(1)
        ..animate.scaleY.to(1)
        ..animate.pivotY.to(sendButton3D.userData);
    };
  }

  Future<void> setMulliganableCards(CardIDs cardIDs) async {
    displayBlackOverlay();

    stage
      ..addChild(mulliganTitleTextField)
      ..setChildIndex(mulliganTitleTextField, stage.children.length - 1)
      ..addChild(mulliganSubtitleTextField)
      ..setChildIndex(mulliganSubtitleTextField, stage.children.length - 1)
      ..addChild(mulliganTimerTextField)
      ..setChildIndex(mulliganTimerTextField, stage.children.length - 1);

    for (var id in cardIDs.ids) {
      if (cardRegistry.containsKey(id)) {
        final card = cardRegistry[id];
        card.selectable = true;
        stage.setChildIndex(card, stage.children.length - 1);
        selectableCardIDs.add(id);
      }
    }

    stage.setChildIndex(sendButton3D, stage.children.length - 1);

    await Future.delayed(const Duration(milliseconds: 400));

    animateSendButton(true);
  }

  Future<void> setSelectableCards(CardIDs cardIDs) async {
    for (var id in cardIDs.ids) {
      if (cardRegistry.containsKey(id)) {
        final card = cardRegistry[id];
        card.selectable = true;

        selectableCardIDs.add(id);
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));

    animateSendButton(true);
  }

  Future<void> onDrawInfo(DrawInfo info) async {
    final newCards = <ClientCard>[];

    final initialHandLength = hands[info.userIndex].length;

    for (var cardInfo in info.cards) {
      final newCard = drawFromDeck(cardInfo);
      hands[info.userIndex].add(newCard);

      newCards.add(newCard);
    }

    animateCardsInHand(
        info.userIndex, .75, Transition.easeOutQuintic, initialHandLength);
    await Future.delayed(const Duration(milliseconds: 500));

    for (var cCard in newCards) {
      stage.setChildIndex(cCard, stage.children.length - 1);

      animateCardToHand(cCard, info.userIndex, 1, Transition.easeInOutCubic);
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  ClientCard drawFromDeck(Card cardInfo) {
    final cCard = deck.removeLast()..cardInfo = cardInfo;
    cardRegistry[cardInfo.id] = cCard;

    cardsInDeckEl.text =
        '${deck.length} ${deck.length == 1 ? 'Card' : 'Cards'} Left';

    return cCard;
  }

  static const range = 1.5708 / 3;
  static const leftCorner = Vector2(0, cardHeight * .9);
  static const rightCorner = Vector2(cardWidth, cardHeight * .9);

  void animateCardToHand(
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
    final cardAngle = initialAngle + angle;
    final origin = lerp(rightCorner, leftCorner, angle / range);

    final x = midPoint.x - (hand.length / 2 * 35) + cardIndex * 35 + 35;
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

  void animateCardsInHand(
      int handIndex, num duration, var transition, int cards) {
    final hand = hands[handIndex];

    final increment = range / hand.length;
    final initialAngle = hand.length % 2 == 0
        ? -increment / 2 + (-increment * (hand.length / 2 - 1))
        : -increment * (hand.length / 2).floor();

    for (var j = 0; j < cards; j++) {
      final _card = hand[j];

      final tween = stage.juggler.addTween(_card, duration, transition);

      final angle = j * increment;
      final cardAngle = initialAngle + angle;
      final origin = lerp(rightCorner, leftCorner, angle / range);

      final x = midPoint.x - (hand.length / 2 * 35) + j * 35 + 35;
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

  void bringHandCardsToTop() {
    for (var hand in hands.reversed) {
      for (var card in hand) {
        stage.setChildIndex(card, stage.children.length - 1);
      }
    }
  }

  void setActivePlayerIndex(int index) {
    num y = gameHeight - cardHeight - 75;
    final x = midPoint.x - cardWidth;

    final tween = stage.juggler
        .addTween(currentPlayerToken, 1, Transition.easeInOutCubic);

    if (index % 2 != 0) {
      y += ((gameWidth / 2) - (gameHeight / 2)).round() + 30;
    }

    final rotatedPoint = rotatePoint(midPoint.x, midPoint.y, x, y, index * -90);

    tween.animate
      ..x.to(rotatedPoint.x)
      ..y.to(rotatedPoint.y)
      ..rotation.to(index * pi / 2);
  }

  Point<num> rotatePoint(num cx, num cy, num x, num y, num angle) {
    final radians = (pi / 180) * angle;
    final cs = cos(radians);
    final sn = sin(radians);
    final nx = (cs * (x - cx)) + (sn * (y - cy)) + cx;
    final ny = (cs * (y - cy)) - (sn * (x - cx)) + cy;
    return Point(nx, ny);
  }

  void displayBlackOverlay() {
    blackOverlay.alpha = 0;

    stage
      ..addChild(blackOverlay)
      ..setChildIndex(blackOverlay, stage.children.length - 1);

    final tween =
        stage.juggler.addTween(blackOverlay, .5, Transition.easeOutQuintic);
    tween.animate.alpha.to(.75);
  }

  void hideBlackOverlay() {
    if (blackOverlay.parent == null) return;

    final tween =
        stage.juggler.addTween(blackOverlay, .5, Transition.easeOutQuintic);
    tween
      ..animate.alpha.to(0)
      ..onComplete = () {
        blackOverlay.removeFromParent();
      };
  }

  void onRequest_HigherLowerChoice(int value) {
    displayBlackOverlay();

    higherChoice.alpha = 0;
    lowerChoice.alpha = 0;
    stage
      ..addChild(higherChoice)
      ..addChild(lowerChoice)
      ..setChildIndex(higherChoice, stage.children.length - 1)
      ..setChildIndex(lowerChoice, stage.children.length - 1);

    final tween2 =
        stage.juggler.addTween(higherChoice, .5, Transition.easeOutQuintic);
    tween2.animate.alpha.to(1);

    final tween3 =
        stage.juggler.addTween(lowerChoice, .5, Transition.easeOutQuintic);
    tween3
      ..animate.alpha.to(1)
      ..onComplete = () {
        final cardInfo = Card()
          ..type = Card_Type.BASIC
          ..value = value
          ..id = playedCards.last.cardInfo.id;
        playedCards.last.cardInfo = cardInfo;

        final tween4 = stage.juggler
            .addTween(playedCards.last, .5, Transition.easeOutQuintic);
        tween4.animate
          ..rotation.to(0)
          ..x.to(gameWidth / 2)
          ..y.to(gameHeight / 2);
      };

    stage.setChildIndex(playedCards.last, stage.children.length - 1);
    playedCards.last.filters.addAll(
        [GlowFilter(Color.Gold, 15, 15, 2), GlowFilter(Color.Gold, 15, 15, 2)]);
  }

  void chooseHigherLower(HigherLowerChoice_Type type) {
    hideBlackOverlay();
    lowerChoice.removeFromParent();
    higherChoice.removeFromParent();

    final higherLowerChoice = HigherLowerChoice()..choice = type;
    socket.send(SocketMessage_Type.HIGHERLOWER_CHOICE, higherLowerChoice);

    playedCards.last.filters.removeWhere((filter) => filter is GlowFilter);
  }

  void onHigherLowerChoice(HigherLowerChoice choice) {
    final card = playedCards.last;
    card.front.removeFromParent();
    card.front =
        Bitmap(GameUI.textureAtlas.getBitmapData('BASIC${choice.value}'));
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
        revealedCard
          ..interactable = true
          ..hidden = false;
      } else {
        revealedCard
          ..interactable = false
          ..hidden = true;
      }

      revealedCards1.add(revealedCard);
    }

    hands[handSwapInfo.userIndex1] = revealedCards1;

    final revealedCards2 = <ClientCard>[];

    for (var card in handSwapInfo.cards2) {
      final revealedCard = cardRegistry[card.id];
      revealedCard.cardInfo = card;

      if (handSwapInfo.userIndex2 == 0) {
        revealedCard
          ..interactable = true
          ..hidden = false;
      } else {
        revealedCard
          ..interactable = false
          ..hidden = true;
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
    if (topTowers.singleWhere((tower) => tower.contains(card1),
            orElse: () => null) !=
        null) {
      card1TowerIndex = topTowers.indexWhere((tower) => tower.contains(card1));
      card1Towers = topTowers;
    }
    if (botTowers.singleWhere((tower) => tower.contains(card1),
            orElse: () => null) !=
        null) {
      card1TowerIndex = botTowers.indexWhere((tower) => tower.contains(card1));
      card1Towers = botTowers;
    }

    int card2TowerIndex;
    List<List<ClientCard>> card2Towers;
    if (topTowers.singleWhere((tower) => tower.contains(card2),
            orElse: () => null) !=
        null) {
      card2TowerIndex = topTowers.indexWhere((tower) => tower.contains(card2));
      card2Towers = topTowers;
    }
    if (botTowers.singleWhere((tower) => tower.contains(card2),
            orElse: () => null) !=
        null) {
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

  void onGameEndInfo(GameEndInfo info) {
    toast('Rank changed by ${info.eloChanged}');
    toast('Rank now ${info.eloPost}');
  }
}
