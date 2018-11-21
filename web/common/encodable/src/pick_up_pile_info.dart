part of encodable;

class PickUpPileInfo implements Encodable {
  final int userIndex;
  final cardInfos;

  const PickUpPileInfo(this.userIndex, this.cardInfos);

  factory PickUpPileInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new PickUpPileInfo(list[userIndexIndex], list[cardsIndex]);
  }

  static const userIndexIndex = 0;
  static const cardsIndex = 1;

  @override
  String toJson() => jsonEncode([userIndex, cardInfos]);
}
