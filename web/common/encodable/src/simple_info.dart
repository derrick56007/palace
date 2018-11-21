part of encodable;

class SimpleInfo implements Encodable {
  final String info;

  const SimpleInfo(this.info);

  factory SimpleInfo.fromJson(var json) {
    return new SimpleInfo(jsonDecode(json));
  }

  @override
  String toJson() => jsonEncode(info);
}