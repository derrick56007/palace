part of encodable;

class MatchInvite implements Encodable {
  final String msg;
  final String matchID;

  const MatchInvite(this.msg, this.matchID);

  factory MatchInvite.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new MatchInvite(list[msgIndex], list[matchIDIndex]);
  }

  static const msgIndex = 0;
  static const matchIDIndex = 1;

  @override
  String toJson() => jsonEncode([msg, matchID]);
}
