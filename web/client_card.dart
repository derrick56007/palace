part of client;

class ClientCard extends Sprite {
  Card _card;

  final front = new Bitmap(GameUI.logoData);
  final back = new Bitmap(GameUI.cardBackData);
  Bitmap crossOut;

  bool draggable = false;
  ClientCard() {
    crossOut =
    new Bitmap(new BitmapData(front.width, front.height, Color.Black));
//    bd.blendMode = BlendMode.SCREEN;

    addChild(crossOut);
    addChild(front);

    pivotX = front.width / 2;
    pivotY = front.height / 2;

    userData = {};
    userData['dragging'] = false;
    userData['mouseDown'] = false;
    onMouseDown.listen((MouseEvent e) {
      if (!selectable) return;

      userData['mouseDown'] = true;
    });

    onMouseOut.listen((_) {
      userData['mouseDown'] = false;
    });

    onMouseMove.listen((MouseEvent e) {
      if (!selectable) return;

      if (!draggable) return;

      final hand = hands.first;

      if (userData['mouseDown'] && !userData['dragging']) {
        stage.juggler.removeTweens(front);

        front.y = 0;

        userData['dragging'] = true;
        startDrag(true);
      }

      if (userData['dragging'] && y < 800 - front.height / 2) {
        final handWidth = (hand.length - 1) * 50;
        final startingX = 1280 / 2 - handWidth / 2;

        var cardIndex = 0;
        for (var card in hand) {
          if (card == this) continue;

          final tween =
          stage.juggler.addTween(card, .5, Transition.easeOutQuintic);
          tween.animate.x.to(startingX + cardIndex * 75);
          tween.animate.y.to(800);
          cardIndex++;
        }

//        for (var card in hand.where((card) => card != this).toList().reversed) {
//          stage.setChildIndex(card, 0);
//        }
      }

      if (userData['dragging']) {
        stage.setChildIndex(this, hand.length - 1);
      }
    });

    onMouseUp.listen((MouseEvent e) {
      if (!selectable) return;

      if (userData['mouseDown'] && userData['dragging']) {
        stopDrag();

        final hand = hands.first;

        // TODO if statement checking if card is selected

        final handWidth = hand.length * 50;
        final startingX = 1280 / 2 - handWidth / 2;

        for (var i = hand.length - 1; i >= 0; i--) {
          final _card = hand[i];

          final tween =
          stage.juggler.addTween(_card, .5, Transition.easeOutQuintic);
          tween.animate.x.to(startingX + i * 75);
          tween.animate.y.to(800);
        }

        for (var card in hand.reversed) {
          stage.setChildIndex(card, 0);
        }

        userData['dragging'] = false;
      }

      userData['mouseDown'] = false;
    });

    onMouseClick.listen((_) {
      if (selectable && _card != null && _card.id != null) {
        // deselect
        if (SelectableManager.shared.selectedIDs.contains(_card.id)) {
          SelectableManager.shared.selectedIDs.remove(_card.id);
          filters.remove(blurFilter);
          children.remove(crossOut);
        } else {
          // select
          SelectableManager.shared.selectedIDs.add(_card.id);
          filters.add(blurFilter);
          children.add(crossOut);
        }

        print('selected: ${SelectableManager.shared.selectedIDs}');
      }
    });
  }

  set cardInfo(Card card) {
    _card = card;

    children.removeLast();
    if (card.hidden) {
      children.add(back);
    } else {
      children.add(front);
    }
  }

  Card get cardInfo => _card;

  bool get hidden => _card.hidden;

  set hidden(bool h) {
    _card.hidden = h;
  }

  bool _selectable = false;

  final glowFilter = new GlowFilter(Color.Gold, 20, 20);
  final blurFilter = new BlurFilter(4, 4, 1);

  set selectable(bool s) {
    _selectable = s;

    if (_selectable) {
      filters.add(glowFilter);
      mouseCursor = MouseCursor.POINTER;
    } else {
      filters.remove(glowFilter);
      mouseCursor = MouseCursor.DEFAULT;
    }

    filters.remove(blurFilter);
    children.remove(crossOut);
  }

  bool get selectable => _selectable;

  @override
  String toString() => _card.toString();
}
