part of encodable;

class DealTowerInfo implements Encodable {
  final topTowers;
  final bottomTowers;

  const DealTowerInfo(this.topTowers, this.bottomTowers);

  factory DealTowerInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new DealTowerInfo(list[topTowerIndex], list[bottomTowerIndex]);
  }

  static const topTowerIndex = 0;
  static const bottomTowerIndex = 1;

  @override
  String toJson() => jsonEncode([topTowers, bottomTowers]);
}
