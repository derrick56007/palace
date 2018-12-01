library client;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' hide Point;

import 'client_websocket.dart';
import 'selectable_manager.dart';

import 'common/generated_protos.dart';

import 'package:stagexl/stagexl.dart';

part 'game_ui.dart';
part 'client_card.dart';

main() async {
  final client = new ClientWebSocket();

  await setupListeners(client);

  await client.start();

  ///////////////////////////////// TESTING ////////////////////////////////////
  final loginInfo1 = new LoginCredentials()
    ..userID = 'derp1'
    ..passCode = 'merp';

  client.send(SocketMessage_Type.LOGIN, loginInfo1);

  await new Future.delayed(const Duration(seconds: 1));

  final userIDs = new UserIDs()..ids.addAll(["bot", "bot", "bot"]);
  client.send(SocketMessage_Type.SEND_MATCH_INVITE, userIDs);
}

setupListeners(ClientWebSocket ws) async {
  final game = new GameUI(ws);
  await game.init();

  ws
    ..on(SocketMessage_Type.LOGIN_SUCCESSFUL, () {
      print('login successful');
    })
    ..on(SocketMessage_Type.ERROR, (var json) {
      final info = jsonDecode(json);

      print(info);
    })
    ..on(SocketMessage_Type.FRIEND_REQUEST, (var json) {
      final friendID = jsonDecode(json);

      print('friend request from $friendID');
    })
    ..on(SocketMessage_Type.MATCH_INVITE, (var json) {
      final matchInvite = new MatchInvite.fromJson(json);
      final matchID = new SimpleInfo()..info = matchInvite.matchID;

      ws.send(SocketMessage_Type.MATCH_ACCEPT, matchID);

      print('match invite id -> ${matchInvite.matchID}');
    })
    ..on(SocketMessage_Type.MATCH_INVITE_CANCEL, (var json) {
      final friendID = jsonDecode(json);

      print('match invitation canceled by $friendID');
    })
    ..on(SocketMessage_Type.MATCH_START, () {
      print('match started!');
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
    ..on(SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, (var json) {

    })
    ..on(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, (var json) {

    })
    ..on(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE, (var json) {

    })
    ..on(SocketMessage_Type.ACTIVE_PLAYER_INDEX, (var json) {
      final activePlayerIndex = new ActivePlayerIndex.fromJson(json);

      game.setActivePlayerIndex(activePlayerIndex.index);
    });
}