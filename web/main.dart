library client;

import 'dart:async';
import 'dart:convert';

import 'client_websocket.dart';

import 'client_card.dart';
import 'common/encodable/encodable.dart';
import 'common/message_type.dart';

main() async {
  final client = new ClientWebSocket();
  final client2 = new ClientWebSocket();

  setupListeners(client, print);
  setupListeners(client2, (var e) {});

  await client.start();
  await client2.start();

  ///////////////////////////////// TESTING ////////////////////////////////////
  final loginInfo1 = LoginInfo('derp1', 'merp');
  final loginInfo2 = LoginInfo('derp2', 'merp');

  final friendUserId1 = SimpleInfo('derp1');
  final friendUserId2 = SimpleInfo('derp2');

  client.send(MessageType.login, loginInfo1);
//  client.send(MessageType.register, loginInfo1);
//  await new Future.delayed(const Duration(seconds: 1));
//  client.send(MessageType.login, loginInfo1);
  await new Future.delayed(const Duration(seconds: 1));
//  client2.send(MessageType.register, loginInfo1);
//  client2.send(MessageType.register, loginInfo2);
//  await new Future.delayed(const Duration(seconds: 1));
//  client2.send(MessageType.login, loginInfo1);
  client2.send(MessageType.login, loginInfo2);
  await new Future.delayed(const Duration(seconds: 1));

//  client.send(MessageType.addFriend, friendUserId2);

  await new Future.delayed(const Duration(seconds: 1));

//  client2.send(MessageType.acceptFriendRequest, friendUserId1);
//  client2.send(MessageType.addFriend, friendUserId1);

  client.send(MessageType.sendMatchInvite, friendUserId2);
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
    ..on(MessageType.loginSuccessful, () {
      myPrint('login successful');
    })
    ..on(MessageType.error, (var json) {
      final info = jsonDecode(json);

      myPrint(info);
    })
    ..on(MessageType.friendRequest, (var json) {
      final friendID = jsonDecode(json);

      myPrint('friend request from $friendID');
    })
    ..on(MessageType.matchInvite, (var json) {
      final matchInvite = MatchInvite.fromJson(json);
      final matchID = SimpleInfo(matchInvite.matchID);

      ws.send(MessageType.matchAccept, matchID);

      myPrint('match invite id -> ${matchInvite.matchID}');
    })
    ..on(MessageType.matchInviteCancel, (var json) {
      final friendID = jsonDecode(json);

      myPrint('match invitation canceled by $friendID');
    })
    ..on(MessageType.matchStart, () {
      myPrint('match started!');
    })
    ..on(MessageType.firstDealTowerInfo, (var json) {
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
          final botCard =
              new ClientCard.fromJson(bTowers[playerIndex][cardIndex]);
          bottomTowers[playerIndex][cardIndex] = botCard;
          cardRegistry['${botCard.id}'] = botCard;
          myPrint('deal bottom $botCard -> $playerIndex');
        }
      }

      for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
        for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
          final topCard =
              new ClientCard.fromJson(tTowers[playerIndex][cardIndex]);
          topTowers[playerIndex][cardIndex] = topCard;
          cardRegistry['${topCard.id}'] = topCard;
          myPrint('deal top $topCard -> $playerIndex');
        }
      }
    })
    ..on(MessageType.towerCardIDsToHand, (var json) {
      final cardsToHandInfo = new CardsToHandInfo.fromJson(json);

      final numPlayers = cardsToHandInfo.hands.length;

      for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
        final newHand = cardsToHandInfo.hands[playerIndex];
        final topTower = topTowers[playerIndex];
        final hand = hands[playerIndex];

        for (var cardID in newHand) {
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
    ..on(MessageType.secondDealTowerInfo, (var json) {
      myPrint('second deal info: $json');

      final secondDealTowerInfo = new SecondDealTowerInfo.fromJson(json);

      final numPlayers = secondDealTowerInfo.topTowers.length;

      for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
        for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
          if (cardIndex < secondDealTowerInfo.topTowers[playerIndex].length) {
            final topCard = new ClientCard.fromJson(
                secondDealTowerInfo.topTowers[playerIndex][cardIndex]);

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
    ..on(MessageType.finalDealInfo, (var json) {
      myPrint('final deal info: $json');
      final finalDealInfo = new FinalDealInfo.fromJson(json);

      final numPlayers = finalDealInfo.hands.length;

      for (var cardIndex = 0; cardIndex < towerLength; cardIndex++) {
        for (var playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
          if (cardIndex < finalDealInfo.hands[playerIndex].length) {
            final topCard = new ClientCard.fromJson(
                finalDealInfo.hands[playerIndex][cardIndex]);
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
    ..on(MessageType.setMulliganableCards, (var json) {
      final selectableCards = new UserPlay.fromJson(json);

      for (var cardID in selectableCards.cardIDs) {
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

      final userPlay = UserPlay(cardsMulliganed);

      ws.send(MessageType.userPlay, userPlay);
    })
    ..on(MessageType.setSelectableCards, (var json) {
      final selectableCards = new UserPlay.fromJson(json);

      final cards = <Card>[];

      for (var cardID in selectableCards.cardIDs) {
        final card = cardRegistry['$cardID'];
        card.selectable = true;
        cards.add(card);

        myPrint('selectable card: $card');
      }

      // bot
      var lowestTypeIndex = 0;
      for (var i = 0; i < cards.length; i++) {
        if (cards[i].type.index <= cards[lowestTypeIndex].type.index) {
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

      final selectedCards = new UserPlay(cardIDs);

      myPrint('selected $cardIDs');

      ws.send(MessageType.userPlay, selectedCards);
    })
    ..on(MessageType.clearSelectableCards, () {
      for (var card in cardRegistry.values.toList()) {
        card.selectable = false;
      }
      myPrint('clear selectables');
    })
    ..on(MessageType.drawInfo, (var json) {
      final drawInfo = new DrawInfo.fromJson(json);

      for (var cardInfo in drawInfo.cardInfos) {
        final card = new ClientCard.fromJson(cardInfo);

        cardRegistry['${card.id}'] = card;

        hands[drawInfo.userIndex].add(card);
        myPrint('draw card $card -> ${drawInfo.userIndex}');

        deckLength--;
      }
      myPrint('hand ${drawInfo.userIndex}: ${hands[drawInfo.userIndex]}');
      myPrint('deck length $deckLength');
    })
    ..on(MessageType.playFromHandInfo, (var json) {
      final playFromHandInfo = new PlayFromHandInfo.fromJson(json);

      for (var cardInfo in playFromHandInfo.cardInfos) {
        final tempCard = new ClientCard.fromJson(cardInfo);

        final card = cardRegistry['${tempCard.id}'];
        card.type = tempCard.type;
        card.value = tempCard.value;
        card.hidden = false;

        hands[playFromHandInfo.userIndex].remove(card);

        playedCards.add(card);

        myPrint('play card from hand ${playFromHandInfo.userIndex} -> $card');
      }

      myPrint(
          'hand ${playFromHandInfo.userIndex}: ${hands[playFromHandInfo.userIndex]}');
    })
    ..on(MessageType.pickUpPileInfo, (var json) {
      final pickUpPileInfo = new PickUpPileInfo.fromJson(json);

      for (var cardInfo in pickUpPileInfo.cardInfos) {
        final tempCard = new ClientCard.fromJson(cardInfo);

        final card = cardRegistry['${tempCard.id}'];
        card.hidden = tempCard.hidden;

        hands[pickUpPileInfo.userIndex].add(card);
        myPrint('pick up from pile $card -> ${pickUpPileInfo.userIndex}');
      }

      playedCards.clear();

      myPrint(
          'hand ${pickUpPileInfo.userIndex}: ${hands[pickUpPileInfo.userIndex]}');
    })
    ..on(MessageType.bombInfo, (var json) {
      final bombInfo = new BombInfo.fromJson(json);

      for (var cardID in bombInfo.cardIDs) {
        cardRegistry.remove('$cardID');
      }

      playedCards.clear();

      myPrint('bombed pile: $playedCards');
    });
}
