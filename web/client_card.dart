import 'package:stagexl/stagexl.dart';

import 'common/generated_protos.dart';
import 'game_ui.dart';
import 'selectable_manager.dart';
import 'dart:html';

class ClientCard extends Sprite {
  static const cardWidth = 140;
  static const cardHeight = 200;
  Card _card;

  Bitmap front;
  final back = new Bitmap(GameUI.textureAtlas.getBitmapData("CARD_BACK"));
  Bitmap crossOut;

  bool draggable = false;
  bool interactable = false;

  isMobileDevice() =>
      window.orientation != null ||
      window.navigator.userAgent.contains('IEMobile');

  final GameUI gameUI;

  ClientCard(this.gameUI) {
    crossOut = new Bitmap(new BitmapData(cardWidth, cardHeight, Color.Green));
    crossOut.alpha = 50;
    crossOut.userData = "crossOut";

    addChild(back);

    if (!isMobileDevice()) {
      filters = [new DropShadowFilter(1)];
    }

    pivotX = cardWidth / 2;
    pivotY = cardHeight / 2;

    onMouseClick.listen((_) {
      _onClick();
    });

    onTouchBegin.listen((_) {
      _onClick();
    });
  }
  
  _onClick() {
    if (selectable && _card != null && _card.id != null) {
      // deselect
      if (SelectableManager.shared.selectedIDs.contains(_card.id)) {
        SelectableManager.shared.selectedIDs.remove(_card.id);

        children.remove(crossOut);

        if (SelectableManager.shared.selectedIDs.isEmpty) {
          gameUI.sendButton.filters.clear();
        }

      } else {
        // select
        SelectableManager.shared.selectedIDs.add(_card.id);

        children.add(crossOut);

        gameUI.sendButton.filters = [glowFilter];
      }
    }
  }

  set cardInfo(Card card) {
    _card = card;

    if (card.type != null) {
      if (card.type == Card_Type.BASIC && card.value != null) {
        front = new Bitmap(GameUI.textureAtlas
            .getBitmapData("${card.type.name}${card.value}"));
      }

      if (card.type != Card_Type.BASIC) {
        front = new Bitmap(
            GameUI.textureAtlas.getBitmapData("${card.type.name}"));
      }
    }

    this.hidden = card.hidden;
  }

  Card get cardInfo => _card;

  bool get hidden => _card.hidden;

  set hidden(bool h) {
    _card.hidden = h;

    children.removeLast();
    if (this.hidden) {
      children.add(back);
    } else {
      children.add(front);
    }
  }

  bool _selectable = false;

  final glowFilter = new GlowFilter(Color.LimeGreen, 15, 15, 2);
  final glowFilter2 = new GlowFilter(Color.LimeGreen, 15, 15, 2);

  set selectable(bool s) {
    _selectable = s;

    if (_selectable) {
      filters.add(glowFilter);
      if (!isMobileDevice()) {
        filters.add(glowFilter2);
      }
      mouseCursor = MouseCursor.POINTER;
    } else {
      filters.remove(glowFilter);
      if (!isMobileDevice()) {
        filters.remove(glowFilter2);
      }
      mouseCursor = MouseCursor.DEFAULT;
    }

    children.remove(crossOut);
  }

  bool get selectable => _selectable;

  @override
  String toString() => _card.toString();
}
