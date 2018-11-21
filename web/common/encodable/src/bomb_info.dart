part of encodable;

class BombInfo implements Encodable {
  final cardIDs;

  const BombInfo(this.cardIDs);

  factory BombInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new BombInfo(list[cardsIndex]);
  }

  static const cardsIndex = 0;

  @override
  String toJson() => jsonEncode([cardIDs]);

}