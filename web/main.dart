library client;

import 'dart:async';
import 'dart:convert';

import 'client_websocket.dart';

import 'client_card.dart';

import 'common/generated_protos.dart';
import 'common/generated_protos/socket_message.pbenum.dart';

main() async {
  final client = new ClientWebSocket();
  final client2 = new ClientWebSocket();

  setupListeners(client, print);
  setupListeners(client2, (var e) {});

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

setupListeners(ClientWebSocket ws, myPrint) {
  final hands = <List<ClientCard>>[];
  final bottomTowers = <List<ClientCard>>[];
  final topTowers = <List<ClientCard>>[];
  final cardRegistry = <String, ClientCard>{};
  final playedCards = <ClientCard>[];

  const towerLength = 3;
  var deckLength = 52;

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
      final dealTowerInfo = new DealTowerInfo.fromJson(json);
      myPrint('deal info: $json');

      final numPlayers = dealTowerInfo.bottomTowers.length;
      final bTowers = dealTowerInfo.bottomTowers;
      final tTowers = dealTowerInfo.topTowers;

      // generate tower lists
      for (var userIndex = 0; userIndex < numPlayers; userIndex++) {
        bottomTowers.add(new List<ClientCard>(towerLength));
        topTowers.add(new List<ClientCard>(towerLength));
        hands.add(new List<ClientCard>());
      }

      for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
        for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
          final botCard = new ClientCard(bTowers[playerIndex].cards[cardIndex]);
          bottomTowers[playerIndex][cardIndex] = botCard;
          cardRegistry['${botCard.id}'] = botCard;
          myPrint('deal bottom $botCard -> $playerIndex');
        }
      }

      for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
        for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
          final topCard = new ClientCard(tTowers[playerIndex].cards[cardIndex]);
          topTowers[playerIndex][cardIndex] = topCard;
          cardRegistry['${topCard.id}'] = topCard;
          myPrint('deal top $topCard -> $playerIndex');
        }
      }
    })
    ..on(SocketMessage_Type.TOWER_CARD_IDS_TO_HAND, (var json) {
      final cardsToHandInfo = new TowerCardsToHandsInfo.fromJson(json);

      final numPlayers = cardsToHandInfo.hands.length;

      for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
        final newHandIDs = cardsToHandInfo.hands[playerIndex];
        final topTower = topTowers[playerIndex];
        final hand = hands[playerIndex];

        for (var cardID in newHandIDs.ids) {
          final card = cardRegistry['$cardID'];

          if (playerIndex != 0) {
            card.hidden = true;
          }

          hand.add(card);

          myPrint('move $card -> $playerIndex');

          if (topTower.contains(card)) {
            final cardIndex = topTower.indexOf(card);
            topTower[cardIndex] = null;
          }
        }
      }
    })
    ..on(SocketMessage_Type.SECOND_DEAL_TOWER_INFO, (var json) {
      myPrint('second deal info: $json');

      final secondDealTowerInfo = new SecondDealTowerInfo.fromJson(json);

      final numPlayers = secondDealTowerInfo.topTowers.length;

      for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
        for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
          if (cardIndex <
              secondDealTowerInfo.topTowers[playerIndex].cards.length) {
            final topCard = new ClientCard(
                secondDealTowerInfo.topTowers[playerIndex].cards[cardIndex]);

            for (var index = 0; index < towerLength; index++) {
              if (topTowers[playerIndex][index] == null) {
                topTowers[playerIndex][index] = topCard;
                break;
              }
            }

            cardRegistry['${topCard.id}'] = topCard;
            myPrint('deal top $topCard -> $playerIndex');
          }
        }
      }
    })
    ..on(SocketMessage_Type.FINAL_DEAL_INFO, (var json) {
      myPrint('final deal info: $json');
      final finalDealInfo = new FinalDealInfo.fromJson(json);

      final numPlayers = finalDealInfo.hands.length;

      for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
        for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
          if (cardIndex < finalDealInfo.hands[playerIndex].cards.length) {
            final topCard = new ClientCard(
                finalDealInfo.hands[playerIndex].cards[cardIndex]);
            hands[playerIndex].add(topCard);
            cardRegistry['${topCard.id}'] = topCard;
            myPrint('deal $topCard -> $playerIndex');
          }
        }
      }

      print('current state');
      myPrint(hands);
      myPrint(topTowers);
      myPrint(bottomTowers);
    })
    ..on(SocketMessage_Type.SET_MULLIGANABLE_CARDS, (var json) {
      final selectableCards = new CardIDs.fromJson(json);

      for (var cardID in selectableCards.ids) {
        final card = cardRegistry['$cardID'];
        card.selectable = true;

        myPrint('mulliganable card: $card');
      }

      /////////////////////////////////////////////////////////////

      final cardsMulliganed = <String>[];

      for (var card in topTowers.first) {
        if (card.value < 8) {
          cardsMulliganed.add('${card.id}');
        }
      }

      final userPlay = CardIDs()..ids.addAll(cardsMulliganed);

      ws.send(SocketMessage_Type.USER_PLAY, userPlay);
    })
    ..on(SocketMessage_Type.SET_SELECTABLE_CARDS, (var json) {
      final selectableCards = new CardIDs.fromJson(json);

      final cards = <ClientCard>[];

      for (var cardID in selectableCards.ids) {
        final card = cardRegistry['$cardID'];
        card.selectable = true;
        cards.add(card);

        myPrint('selectable card: $card');
      }

      // bot
      var lowestTypeIndex = 0;
      for (var i = 0; i < cards.length; i++) {
        if (cards[i].type.value <= cards[lowestTypeIndex].type.value) {
          lowestTypeIndex = i;
        }
      }

      final cardIDs = <String>[];
      cardIDs.add('${cards[lowestTypeIndex].id}');

      for (var card in cards) {
        if (card.type == cards[lowestTypeIndex].type &&
            card != cards[lowestTypeIndex] &&
            card.value == cards[lowestTypeIndex].value) {
          cardIDs.add('${card.id}');
        }
      }

      final selectedCards = new CardIDs()..ids.addAll(cardIDs);

      myPrint('selected $cardIDs');

      ws.send(SocketMessage_Type.USER_PLAY, selectedCards);
    })
    ..on(SocketMessage_Type.CLEAR_SELECTABLE_CARDS, () {
      for (var card in cardRegistry.values.toList()) {
        card.selectable = false;
      }
      myPrint('clear selectables');
    })
    ..on(SocketMessage_Type.DRAW_INFO, (var json) {
      final drawInfo = new DrawInfo.fromJson(json);

      for (var card in drawInfo.cards) {
        final clientCard = new ClientCard(card);

        cardRegistry['${card.id}'] = clientCard;

        hands[drawInfo.userIndex].add(clientCard);
        myPrint('draw card $card -> ${drawInfo.userIndex}');

        deckLength--;
      }
      myPrint('hand ${drawInfo.userIndex}: ${hands[drawInfo.userIndex]}');
      myPrint('deck length $deckLength');
    })
    ..on(SocketMessage_Type.PLAY_FROM_HAND_INFO, (var json) {
      final playFromHandInfo = new PlayFromHandInfo.fromJson(json);

      for (var card in playFromHandInfo.cards) {
        final tempCard = new ClientCard(card);

        final clientCard = cardRegistry['${tempCard.id}'];
        clientCard.type = tempCard.type;
        clientCard.value = tempCard.value;
        clientCard.hidden = false;

        hands[playFromHandInfo.userIndex].remove(clientCard);

        playedCards.add(clientCard);

        myPrint(
            'play card from hand ${playFromHandInfo.userIndex} -> $clientCard');
      }

      myPrint(
          'hand ${playFromHandInfo.userIndex}: ${hands[playFromHandInfo.userIndex]}');
    })
    ..on(SocketMessage_Type.PICK_UP_PILE_INFO, (var json) {
      final pickUpPileInfo = new PickUpPileInfo.fromJson(json);

      for (var card in pickUpPileInfo.cards) {
        final tempCard = new ClientCard(card);

        final clientCard = cardRegistry['${tempCard.id}'];
        clientCard.hidden = tempCard.hidden;

        hands[pickUpPileInfo.userIndex].add(clientCard);
        myPrint('pick up from pile $clientCard -> ${pickUpPileInfo.userIndex}');
      }

      playedCards.clear();

      myPrint(
          'hand ${pickUpPileInfo.userIndex}: ${hands[pickUpPileInfo.userIndex]}');
    })
    ..on(SocketMessage_Type.DISCARD_INFO, (var json) {
      final bombInfo = new DiscardInfo.fromJson(json);

      for (var cardID in bombInfo.cardIDs) {
        cardRegistry.remove('$cardID');
      }

      playedCards.clear();

      myPrint('bombed pile: $playedCards');
    })
    ..on(SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, (var json) {})
    ..on(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, (var json) {})
    ..on(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE, (var json) {});
}
