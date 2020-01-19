part of server;

class BotSocket extends CommonWebSocket {
  @override
  Future<void> start() async {
    final completer = Completer();
    done = completer.future;
  }

  final rand = Random();

  final hand = <Card>[];

  @override
  int elo = 1200;

  // named send but is actually the receiving end
  @override
  Future<void> send(SocketMessage_Type type,
      [pb.GeneratedMessage message]) async {
    // split this into methods
    switch (type) {
      case SocketMessage_Type.MATCH_INVITE:
        MatchManager.shared.matchAccept(this);
        break;

      case SocketMessage_Type.SET_MULLIGANABLE_CARDS:
        await Future.delayed(Duration(seconds: 6 + rand.nextInt(3)));
        final match = MatchManager.shared.matchFromSocket(this);

        if (match == null) break;

        final lowCardThreshold = 5;
        final lowCardIDs = CardIDs();

        // get rid of this, is kinda cheating
        for (var card in match.topTowers[this].cards) {
          if (card.type == Card_Type.BASIC && card.value < lowCardThreshold) {
            lowCardIDs.ids.add(card.id);
          }
        }

        await match.userPlay(this, lowCardIDs);

        break;
      case SocketMessage_Type.SET_SELECTABLE_CARDS:
        await Future.delayed(const Duration(milliseconds: 1500));
        final match = MatchManager.shared.matchFromSocket(this);

        if (match == null) {
          break;
        }

        final selectableDs = message as CardIDs;
        final cards = match.cardListFromCardIDList(selectableDs.ids);

        final selectedIDs = CardIDs();

        // TODO make smarter
        final handSwapIndex =
            cards.indexWhere((card) => card.type == Card_Type.HAND_SWAP);
        if (handSwapIndex > 0) {
          selectedIDs.ids.add(selectableDs.ids[handSwapIndex]);
          await match.userPlay(this, selectedIDs);
          break;
        }

        final topSwapIndex =
            cards.indexWhere((card) => card.type == Card_Type.TOP_SWAP);
        if (topSwapIndex > 0) {
          // TODO make smarter
          selectedIDs.ids.add(selectableDs.ids[topSwapIndex]);
          await match.userPlay(this, selectedIDs);
          break;
        }
        // check for handswap

        final selectedCard = match.cardRegistry[selectableDs.ids.first];

        selectedIDs.ids.add(selectableDs.ids.first);

        // choose multiple if not bottom tower card
        if (!match.bottomTowers[this].cards.contains(selectedCard) &&
            !match.topTowers[this].cards.contains(selectedCard)) {
          for (var selectableID in selectableDs.ids.sublist(1)) {
            final card = match.cardRegistry[selectableID];

            if (card.type == selectedCard.type &&
                card.value == selectedCard.value) {
              selectedIDs.ids.add(selectableID);
            }
          }
        }

        await match.userPlay(this, selectedIDs);
        break;
      case SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE:
        await Future.delayed(const Duration(milliseconds: 1500));
        final match = MatchManager.shared.matchFromSocket(this);

        if (match == null) {
          break;
        }

        final boardState = match.resolvePileState();

        final higherLowerChoice = HigherLowerChoice()
          ..choice = boardState > 5
              ? HigherLowerChoice_Type.HIGHER
              : HigherLowerChoice_Type.LOWER;

        match.onHigherLowerChoice(this, higherLowerChoice);
        break;
      case SocketMessage_Type.REQUEST_TOPSWAP_CHOICE:
        await Future.delayed(const Duration(milliseconds: 1500));
        final match = MatchManager.shared.matchFromSocket(this);

        if (match == null) {
          break;
        }
        final selectableCardIDs = message as CardIDs;

        final lowCardIDs = CardIDs();

        lowCardIDs.ids.add(
            selectableCardIDs.ids[rand.nextInt(selectableCardIDs.ids.length)]);

        var nextIndex = rand.nextInt(selectableCardIDs.ids.length);
        while (lowCardIDs.ids.contains(selectableCardIDs.ids[nextIndex])) {
          nextIndex = rand.nextInt(selectableCardIDs.ids.length);
        }
        lowCardIDs.ids.add(selectableCardIDs.ids[nextIndex]);

        await match.userPlay(this, lowCardIDs);
        break;
      case SocketMessage_Type.REQUEST_HANDSWAP_CHOICE:
        await Future.delayed(const Duration(milliseconds: 1500));
        final match = MatchManager.shared.matchFromSocket(this);

        if (match == null) {
          break;
        }

        final lowCardIDs = CardIDs();
        final handSwapChoiceInfo = message as HandSwapChoiceInfo;

        CardIDs minHand;

        for (final hand in handSwapChoiceInfo.hands) {
          if (minHand == null) {
            minHand = hand;

            continue;
          }

          if (hand.ids.length < minHand.ids.length) {
            minHand = hand;
          }
        }

        lowCardIDs.ids.add(minHand.ids.first);

//        print('handswap index ${cardIndex}');

        await match.userPlay(this, lowCardIDs);
        break;
      default:
    }
  }
}
