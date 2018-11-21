part of encodable;

class DrawInfo implements Encodable {
  final int userIndex;
  final cardInfos;

  const DrawInfo(this.userIndex, this.cardInfos);

  factory DrawInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new DrawInfo(list[userIndexIndex], list[cardsIndex]);
  }

  static const userIndexIndex = 0;
  static const cardsIndex = 1;

  @override
  String toJson() => jsonEncode([userIndex, cardInfos]);
}
