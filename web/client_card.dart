

import 'package:stagexl/stagexl.dart';

import 'common/generated_protos/cards.pb.dart';
import 'game_ui.dart';
import 'selectable_manager.dart';

class ClientCard extends Sprite {
  static const cardWidth = 140;
  static const cardHeight = 200;
  Card _card;

  Bitmap front;
  final back = new Bitmap(GameUI.resourceManager.getBitmapData("back"));
  Bitmap crossOut;

  bool draggable = false;
  bool interactable = false;

  ClientCard() {
    crossOut =
        new Bitmap(new BitmapData(cardWidth, cardHeight, Color.Green));
    crossOut.alpha = 50;
    crossOut.userData = "crossOut";
//    bd.blendMode = BlendMode.SCREEN;

//    addChild(crossOut);
    addChild(back);

//    filters = [new DropShadowFilter(1)];

    pivotX = cardWidth / 2;
    pivotY = cardHeight / 2;

    onMouseClick.listen((_) {
      if (selectable && _card != null && _card.id != null) {
        // deselect
        if (SelectableManager.shared.selectedIDs.contains(_card.id)) {
          SelectableManager.shared.selectedIDs.remove(_card.id);

          children.remove(crossOut);
        } else {
          // select
          SelectableManager.shared.selectedIDs.add(_card.id);

          children.add(crossOut);
        }
      }
    });
  }

  set cardInfo(Card card) {
    _card = card;

    if (card.type != null) {
      if (card.type == Card_Type.BASIC && card.value != null) {
        front = new Bitmap(GameUI.resourceManager
            .getBitmapData("${card.type.name}${card.value}"));
      }

      if (card.type != Card_Type.BASIC) {
        front = new Bitmap(
            GameUI.resourceManager.getBitmapData("${card.type.name}"));
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
      filters.add(glowFilter2);
      mouseCursor = MouseCursor.POINTER;
    } else {
      filters.remove(glowFilter);
      filters.remove(glowFilter2);
      mouseCursor = MouseCursor.DEFAULT;
    }

    children.remove(crossOut);
  }

  bool get selectable => _selectable;

  @override
  String toString() => _card.toString();
}
