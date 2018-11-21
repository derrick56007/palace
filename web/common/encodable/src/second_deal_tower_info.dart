part of encodable;

class SecondDealTowerInfo implements Encodable {
  final topTowers;

  const SecondDealTowerInfo(this.topTowers);

  factory SecondDealTowerInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new SecondDealTowerInfo(list[topTowerIndex]);
  }

  static const topTowerIndex = 0;

  @override
  String toJson() => jsonEncode([topTowers]);
}
