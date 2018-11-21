part of encodable;

class PlayFromHandInfo implements Encodable {
  final int userIndex;
  final cardInfos;

  const PlayFromHandInfo(this.userIndex, this.cardInfos);

  factory PlayFromHandInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new PlayFromHandInfo(list[userIndexIndex], list[cardsIndex]);
  }

  static const userIndexIndex = 0;
  static const cardsIndex = 1;

  @override
  String toJson() => jsonEncode([userIndex, cardInfos]);
}
