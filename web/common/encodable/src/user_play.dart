part of encodable;

class UserPlay implements Encodable {
  final cardIDs;

  const UserPlay(this.cardIDs);

  factory UserPlay.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new UserPlay(list[cardsIndex]);
  }

  static const cardsIndex = 0;

  @override
  String toJson() => jsonEncode([cardIDs]);

}