part of encodable;

class FinalDealInfo implements Encodable {
  final hands;

  const FinalDealInfo(this.hands);

  factory FinalDealInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new FinalDealInfo(list[topTowerIndex]);
  }

  static const topTowerIndex = 0;

  @override
  String toJson() => jsonEncode([hands]);
}
