part of encodable;

class LoginInfo implements Encodable {
  final String userID;
  final String passCode;

  const LoginInfo(this.userID, this.passCode);

  factory LoginInfo.fromJson(var json) {
    var list;

    if (json is List) {
      list = json;
    } else {
      list = jsonDecode(json) as List;
    }

    return new LoginInfo(list[userIDIndex], list[passCodeIndex]);
  }

  static const userIDIndex = 0;
  static const passCodeIndex = 1;

  @override
  String toJson() => jsonEncode([userID, passCode]);
}
