library state;

import 'dart:async';
import 'dart:html';

import '../client_websocket.dart';
import '../common/generated_protos.dart';
import '../game_ui.dart';

import 'src/helpers/friend_handler.dart';
import 'src/helpers/match_handler.dart';

part 'src/play.dart';
part 'src/register.dart';
part 'src/login.dart';
part 'state_manager.dart';

abstract class State {
  final ClientWebSocket client;

  State(this.client);

  show();
  hide();
}