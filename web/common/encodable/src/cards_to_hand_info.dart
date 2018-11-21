part of encodable;

class CardsToHandInfo implements Encodable {
  final hands;

  const CardsToHandInfo(this.hands);

  factory CardsToHandInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new CardsToHandInfo(list[handsIndex]);
  }

  static const handsIndex = 0;

  @override
  String toJson() => jsonEncode([hands]);
}
