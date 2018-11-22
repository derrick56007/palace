part of encodable;

class HigherLowerChoiceInfo implements Encodable {
  final HigherLowerChoices choice;

  const HigherLowerChoiceInfo(this.choice);

  factory HigherLowerChoiceInfo.fromJson(var json) {
    return new HigherLowerChoiceInfo(
        HigherLowerChoices.values[jsonDecode(json)]);
  }

  @override
  String toJson() => jsonEncode(choice.index);
}
