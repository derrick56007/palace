part of encodable;

class DiscardInfo implements Encodable {
  final cardIDs;

  const DiscardInfo(this.cardIDs);

  factory DiscardInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new DiscardInfo(list[cardsIndex]);
  }

  static const cardsIndex = 0;

  @override
  String toJson() => jsonEncode([cardIDs]);
}
