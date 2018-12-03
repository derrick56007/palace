library client;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js';
import 'dart:math' hide Point;

import 'client_websocket.dart';
import 'selectable_manager.dart';

import 'common/generated_protos.dart';

import 'package:stagexl/stagexl.dart';

part 'game_ui.dart';
part 'client_card.dart';

main() async {
  final client = new ClientWebSocket();

  final el4 = html.document.querySelector('#invite-friends-btn');

  el4.onClick.listen((_) {
    final invitedPlayers = context.callMethod('prompt', ['Invite Players', '']);

    if (invitedPlayers.toString().trim() == '') return;

    final playerIDs = invitedPlayers.toString().trim().split(',');

    if (playerIDs.isEmpty) return;

    final userIDs = new UserIDs()..ids.addAll(playerIDs);
    client.send(SocketMessage_Type.SEND_MATCH_INVITE, userIDs);
  });

  final el3 = html.document.querySelector('#add-friend-btn');
  el3.onClick.listen((_) {
    final friendId = context.callMethod('prompt', ['Add Friend', '']);

    final friendIDInfo = new SimpleInfo()..info = friendId;
    client.send(SocketMessage_Type.ADD_FRIEND, friendIDInfo);
  });

  final el = html.document.querySelector('#login-modal-btn');
  el.style.display = '';

  html.document.querySelector('#login-btn').onClick.listen((_) {
    final usernameEl =
        html.document.querySelector('#login_user_name') as html.InputElement;
    final password =
        html.document.querySelector('#login_password') as html.InputElement;

    final loginInfo = LoginCredentials()
      ..userID = usernameEl.value.trim()
      ..passCode = password.value.trim();

    print('login info ${loginInfo}');

    if (client.isConnected()) {
      client.send(SocketMessage_Type.LOGIN, loginInfo);
    }
  });

  final el2 = html.document.querySelector('#register-modal-btn');
  el2.style.display = '';

  html.document.querySelector('#register-btn').onClick.listen((_) {
    final usernameEl =
        html.document.querySelector('#register_user_name') as html.InputElement;
    final password =
        html.document.querySelector('#register_password') as html.InputElement;

    final loginInfo = LoginCredentials()
      ..userID = usernameEl.value.trim()
      ..passCode = password.value.trim();

    print('register info ${loginInfo}');

    if (client.isConnected()) {
      client.send(SocketMessage_Type.REGISTER, loginInfo);
    }
  });

  await client.start();

  await setupListeners(client);

  ///////////////////////////////// TESTING ////////////////////////////////////
//
//  final loginInfo1 = new LoginCredentials()
//    ..userID = 'derp1'
//    ..passCode = 'merp';
//
//  client.send(SocketMessage_Type.LOGIN, loginInfo1);
//
//  await new Future.delayed(const Duration(seconds: 1));
//
//  final userIDs = new UserIDs()..ids.addAll(["bot", "bot", "bot"]);
//  client.send(SocketMessage_Type.SEND_MATCH_INVITE, userIDs);
}

setupListeners(ClientWebSocket ws) async {
  final game = new GameUI(ws);
  await game.init();

  ws
    ..onOpen.listen((_) {
      final el = html.document.getElementById('login-modal-btn');
      el.style.display = '';
    })
    ..on(SocketMessage_Type.LOGIN_SUCCESSFUL, () {
      print('login successful');

      final el3 = html.document.querySelector('#add-friend-btn');
      el3.style.display = '';

      final el4 = html.document.querySelector('#invite-friends-btn');
      el4.style.display = '';

      final el = html.document.querySelector('#login-modal-btn');
      el.style.display = 'none';

      final el2 = html.document.querySelector('#register-modal-btn');
      el2.style.display = 'none';
    })
    ..on(SocketMessage_Type.ERROR, (var json) {
      final info = SimpleInfo.fromJson(json);

      print(info.info);
//      toast(info.info);
    })
    ..on(SocketMessage_Type.FRIEND_REQUEST, (var json) {
      final friendID = SimpleInfo.fromJson(json);

      print('friend request from $friendID');

      final confirm =
          context.callMethod('confirm', ['Friend request from $friendID']);

      if (confirm) {
        ws.send(SocketMessage_Type.ACCEPT_FRIEND_REQUEST, friendID);
      }
    })
    ..on(SocketMessage_Type.MATCH_INVITE, (var json) {
      final matchInvite = new MatchInvite.fromJson(json);
      final matchID = new SimpleInfo()..info = matchInvite.matchID;


      final confirm =
      context.callMethod('confirm', ['Join game $matchID?']);

      print('match invite id -> ${matchInvite.matchID}');

      if (confirm) {
        ws.send(SocketMessage_Type.MATCH_ACCEPT, matchID);
      }
    })
    ..on(SocketMessage_Type.MATCH_INVITE_CANCEL, (var json) {
      final friendID = SimpleInfo.fromJson(json);

      print('match invitation canceled by $friendID');
    })
    ..on(SocketMessage_Type.MATCH_START, () {
      print('match started!');

      final el3 = html.document.querySelector('#add-friend-btn');
      el3.style.display = 'none';

      final el4 = html.document.querySelector('#invite-friends-btn');
      el4.style.display = 'none';
    })
    ..on(SocketMessage_Type.FIRST_DEAL_TOWER_INFO, (var json) {
      final info = new DealTowerInfo.fromJson(json);
      game.onDealTowerInfo(info);
    })
    ..on(SocketMessage_Type.TOWER_CARD_IDS_TO_HAND, (var json) {
      final info = new TowerCardsToHandInfo.fromJson(json);
      game.onTowerCardsToHand(info);
    })
    ..on(SocketMessage_Type.SECOND_DEAL_TOWER_INFO, (var json) {
      final info = new SecondDealTowerInfo.fromJson(json);
      game.secondTowerDealInfo(info);
    })
    ..on(SocketMessage_Type.FINAL_DEAL_INFO, (var json) {
      final info = new FinalDealInfo.fromJson(json);
      game.onFinalDealInfo(info);
    })
    ..on(SocketMessage_Type.SET_MULLIGANABLE_CARDS, (var json) {
      final cardIDs = new CardIDs.fromJson(json);
      game.setMulliganableCards(cardIDs);
    })
    ..on(SocketMessage_Type.SET_SELECTABLE_CARDS, (var json) {
      final cardIDs = new CardIDs.fromJson(json);
      game.setSelectableCards(cardIDs);
    })
    ..on(SocketMessage_Type.CLEAR_SELECTABLE_CARDS, () {
      game.clearSelectableCards();
    })
    ..on(SocketMessage_Type.DRAW_INFO, (var json) {
      final info = new DrawInfo.fromJson(json);
      game.onDrawInfo(info);
    })
    ..on(SocketMessage_Type.PLAY_FROM_HAND_INFO, (var json) {
      final info = new PlayFromHandInfo.fromJson(json);
      game.onPlayFromHandInfo(info);
    })
    ..on(SocketMessage_Type.PICK_UP_PILE_INFO, (var json) {
      final info = new PickUpPileInfo.fromJson(json);
      game.onPickUpPileInfo(info);
    })
    ..on(SocketMessage_Type.DISCARD_INFO, (var json) {
      final info = new DiscardInfo.fromJson(json);
      game.onDiscardInfo(info);
    })
    ..on(SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, () {
//      game.onRequestHandSwapChoice();
    })
    ..on(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, () {})
    ..on(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE, () {
      game.onRequest_HigherLowerChoice();
    })
    ..on(SocketMessage_Type.ACTIVE_PLAYER_INDEX, (var json) {
      final activePlayerIndex = new ActivePlayerIndex.fromJson(json);

      game.setActivePlayerIndex(activePlayerIndex.index);
    })
    ..on(SocketMessage_Type.HIGHERLOWER_CHOICE, (var json) {
      final higherLowerChoice = new HigherLowerChoice.fromJson(json);

      game.onHigherLowerChoice(higherLowerChoice);
    })
    ..on(SocketMessage_Type.HANDSWAP_CHOICE, (var json) {})
    ..on(SocketMessage_Type.TOPSWAP_CHOICE, (var json) {});
}
