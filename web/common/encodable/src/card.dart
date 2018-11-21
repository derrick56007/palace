part of encodable;

class Card implements Encodable {
  final int id;
  bool hidden;

  CardType type;
  int value;

  static const hiddenCardJsonLength = 2;

  Card(this.id, this.hidden, [this.type, this.value]);

  factory Card.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    if (list.length == hiddenCardJsonLength) {
      return new Card(list[idIndex], true);
    } else {
      return new Card(list[idIndex], list[faceDownIndex],
          CardType.values[list[cardTypeIndex]], list[valueIndex]);
    }
  }

  flip() {
    hidden = !hidden;
  }

  static const idIndex = 0;
  static const faceDownIndex = 1;
  static const cardTypeIndex = 2;
  static const valueIndex = 3;

  @override
  String toJson() {
    if (hidden) {
      return hiddenJson();
    } else {
      return jsonEncode([id, hidden, type.index, value]);
    }
  }

  String hiddenJson() {
    return jsonEncode([id, true]);
  }

  @override
  String toString() => hidden ? '(#$id)' : '(#$id, ${type.index}, $value)';
}
