library client;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'client_websocket.dart';
import 'selectable_manager.dart';

import 'common/generated_protos.dart';

import 'package:stagexl/stagexl.dart';

part 'game_ui.dart';
part 'client_card.dart';

main() async {
  final game = new GameUI();
  await game.init();

  final client = new ClientWebSocket();
  final client2 = new ClientWebSocket();

  await setupListeners(client, print);
  await setupListeners(client2, (var e) {});

  await client.start();
  await client2.start();

  ///////////////////////////////// TESTING ////////////////////////////////////
  final loginInfo1 = new LoginCredentials()
    ..userID = 'derp1'
    ..passCode = 'merp';
  final loginInfo2 = new LoginCredentials()
    ..userID = 'derp2'
    ..passCode = 'merp';

//  final friendUserId1 = SimpleInfo('derp1');
//  final friendUserId2 = SimpleInfo('derp2');

  final userID = new SimpleInfo()..info = 'derp2';

  client.send(SocketMessage_Type.LOGIN, loginInfo1);
//  client.send(MessageType.register, loginInfo1);
//  await new Future.delayed(const Duration(seconds: 1));
//  client.send(MessageType.login, loginInfo1);
  await new Future.delayed(const Duration(seconds: 1));
//  client2.send(MessageType.register, loginInfo1);
//  client2.send(MessageType.register, loginInfo2);
//  await new Future.delayed(const Duration(seconds: 1));
//  client2.send(MessageType.login, loginInfo1);
  client2.send(SocketMessage_Type.LOGIN, loginInfo2);
  await new Future.delayed(const Duration(seconds: 1));

//  client.send(MessageType.addFriend, friendUserId2);

  await new Future.delayed(const Duration(seconds: 1));

//  client2.send(MessageType.acceptFriendRequest, friendUserId1);
//  client2.send(MessageType.addFriend, friendUserId1);

  client.send(SocketMessage_Type.SEND_MATCH_INVITE, userID);
//  client.send(MessageType.send_match_invite, friendUserId2);
//  client2.send(MessageType.send_match_invite, friendUserId1);

  //////////////////////////////////////////////////////////////////////////////
}

setupListeners(ClientWebSocket ws, myPrint) async {
  final game = new GameUI();
  await game.init();

  ws
    ..on(SocketMessage_Type.LOGIN_SUCCESSFUL, () {
      myPrint('login successful');
    })
    ..on(SocketMessage_Type.ERROR, (var json) {
      final info = jsonDecode(json);

      myPrint(info);
    })
    ..on(SocketMessage_Type.FRIEND_REQUEST, (var json) {
      final friendID = jsonDecode(json);

      myPrint('friend request from $friendID');
    })
    ..on(SocketMessage_Type.MATCH_INVITE, (var json) {
      final matchInvite = new MatchInvite.fromJson(json);
      final matchID = new SimpleInfo()..info = matchInvite.matchID;

      ws.send(SocketMessage_Type.MATCH_ACCEPT, matchID);

      myPrint('match invite id -> ${matchInvite.matchID}');
    })
    ..on(SocketMessage_Type.MATCH_INVITE_CANCEL, (var json) {
      final friendID = jsonDecode(json);

      myPrint('match invitation canceled by $friendID');
    })
    ..on(SocketMessage_Type.MATCH_START, () {
      myPrint('match started!');
    })
    ..on(SocketMessage_Type.FIRST_DEAL_TOWER_INFO, (var json) {
      final info = new DealTowerInfo.fromJson(json);

    
    })
    ..on(SocketMessage_Type.TOWER_CARD_IDS_TO_HAND, (var json) {
      final info = new TowerCardsToHandsInfo.fromJson(json);


    })
    ..on(SocketMessage_Type.SECOND_DEAL_TOWER_INFO, (var json) {
      final info = new SecondDealTowerInfo.fromJson(json);

    })
    ..on(SocketMessage_Type.FINAL_DEAL_INFO, (var json) {
      final info = new FinalDealInfo.fromJson(json);

    })
    ..on(SocketMessage_Type.SET_SELECTABLE_CARDS, (var json) {
      final cardIDs = new CardIDs.fromJson(json);

    })
    ..on(SocketMessage_Type.CLEAR_SELECTABLE_CARDS, () {

    })
    ..on(SocketMessage_Type.DRAW_INFO, (var json) {
      final drawInfo = new DrawInfo.fromJson(json);

    })
    ..on(SocketMessage_Type.PLAY_FROM_HAND_INFO, (var json) {
      final playFromHandInfo = new PlayFromHandInfo.fromJson(json);

    })
    ..on(SocketMessage_Type.PICK_UP_PILE_INFO, (var json) {
      final pickUpPileInfo = new PickUpPileInfo.fromJson(json);

    })
    ..on(SocketMessage_Type.DISCARD_INFO, (var json) {
      final discardInfo = new DiscardInfo.fromJson(json);

    })
    ..on(SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, (var json) {

    })
    ..on(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, (var json) {

    })
    ..on(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE, (var json) {

    });
}
