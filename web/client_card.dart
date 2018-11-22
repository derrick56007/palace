import 'common/generated_protos/cards.pb.dart';

class ClientCard {
  final Card _card;

  Card_Type get type => _card.type;
  set type(Card_Type t) {
    _card.type = t;
  }

  String get id => _card.id;

  int get value => _card.value;
  set value(int v) {
    _card.value = v;
  }

  bool get hidden => _card.hidden;

  set hidden(bool h) {
    _card.hidden = h;
  }

  bool _selectable = false;

  set selectable(bool s) {
    _selectable = s;
  }

  bool get selectable => _selectable;

  ClientCard._internal(this._card);

  factory ClientCard.fromJson(var json) =>
      ClientCard._internal(new Card.fromJson(json));
}
