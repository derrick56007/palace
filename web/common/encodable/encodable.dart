library encodable;

import 'dart:convert';

import '../card_type.dart';

part 'src/bomb_info.dart';
part 'src/pick_up_pile_info.dart';
part 'src/play_from_hand_info.dart';
part 'src/card.dart';
part 'src/draw_info.dart';
part 'src/cards_to_hand_info.dart';
part 'src/deal_tower_info.dart';
part 'src/login_info.dart';
part 'src/match_invite.dart';
part 'src/second_deal_tower_info.dart';
part 'src/final_deal_info.dart';
part 'src/simple_info.dart';
part 'src/user_play.dart';

abstract class Encodable {
  String toJson();
}