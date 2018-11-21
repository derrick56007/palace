import 'dart:convert';

import 'common/card_type.dart';
import 'drawable.dart';
import 'common/encodable/encodable.dart';

class ClientCard extends Card implements Drawable {
  bool _selectable = false;

  set selectable(bool s) {
    _selectable = s;
  }

  bool get selectable => _selectable;

  ClientCard(int id, bool faceDown, [CardType type, int value])
      : super(id, faceDown, type, value);

  factory ClientCard.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    if (list.length == Card.hiddenCardJsonLength) {
      return new ClientCard(list[Card.idIndex], true);
    } else {
      return new ClientCard(list[Card.idIndex], list[Card.faceDownIndex],
          CardType.values[list[Card.cardTypeIndex]], list[Card.valueIndex]);
    }
  }

  @override
  void draw() {
    // TODO: implement draw
  }
}
