part of server;

class BotSocket extends CommonWebSocket {
  @override
  start() async {
    final completer = new Completer();
    done = completer.future;
  }

  final rand = new Random();

  final hand = <Card>[];

  // named send but is actually the receiving end
  @override
  send(SocketMessage_Type type, [pb.GeneratedMessage generatedMessage]) async {
    // split this into methods
    switch (type) {
      case SocketMessage_Type.MATCH_INVITE:
        MatchManager.shared.matchAccept(this);
        break;

      case SocketMessage_Type.SET_MULLIGANABLE_CARDS:
        await new Future.delayed(const Duration(seconds: 8));

        final match = MatchManager.shared.matchFromSocket(this);

        if (match == null) break;

        final lowCardThreshold = 5;
        final lowCardIDs = new CardIDs();

        // get rid of this, is kinda cheating
        for (var card in match.topTowers[this].cards) {
          if (card.type == Card_Type.BASIC && card.value < lowCardThreshold) {
            lowCardIDs.ids.add(card.id);
          }
        }

        match.userPlay(this, lowCardIDs);

        break;
      case SocketMessage_Type.SET_SELECTABLE_CARDS:
        await new Future.delayed(const Duration(milliseconds: 1500));

        final match = MatchManager.shared.matchFromSocket(this);

        final selectableDs = generatedMessage as CardIDs;
        final cards = match.cardListFromCardIDList(selectableDs.ids);

        final selectedIDs = new CardIDs();

        // TODO make smarter
        final handSwapIndex =
            cards.indexWhere((card) => card.type == Card_Type.HAND_SWAP);
        if (handSwapIndex > 0) {
          selectedIDs.ids.add(selectableDs.ids[handSwapIndex]);
          match.userPlay(this, selectedIDs);
          break;
        }

        final topSwapIndex =
            cards.indexWhere((card) => card.type == Card_Type.TOP_SWAP);
        if (topSwapIndex > 0) {
          // TODO make smarter
          selectedIDs.ids.add(selectableDs.ids[topSwapIndex]);
          match.userPlay(this, selectedIDs);
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

        match.userPlay(this, selectedIDs);
        break;
      case SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE:
        await new Future.delayed(const Duration(milliseconds: 1500));

        final match = MatchManager.shared.matchFromSocket(this);

        final higherLowerChoice = new HigherLowerChoice()
          ..choice = rand.nextBool()
              ? HigherLowerChoice_Type.HIGHER
              : HigherLowerChoice_Type.LOWER;

        match.onHigherLowerChoice(this, higherLowerChoice);
        break;
      case SocketMessage_Type.REQUEST_TOPSWAP_CHOICE:
        await new Future.delayed(const Duration(milliseconds: 1500));

        final match = MatchManager.shared.matchFromSocket(this);

        final selectableCardIDs = generatedMessage as CardIDs;

        final lowCardIDs = new CardIDs();

        final random = new Random();
        lowCardIDs.ids.add(selectableCardIDs
            .ids[random.nextInt(selectableCardIDs.ids.length)]);

        var nextIndex = random.nextInt(selectableCardIDs.ids.length);
        while (lowCardIDs.ids.contains(selectableCardIDs.ids[nextIndex])) {
          nextIndex = random.nextInt(selectableCardIDs.ids.length);
        }
        lowCardIDs.ids.add(selectableCardIDs.ids[nextIndex]);

        match.userPlay(this, lowCardIDs);
        break;
      case SocketMessage_Type.REQUEST_HANDSWAP_CHOICE:
        await new Future.delayed(const Duration(milliseconds: 1500));

        final match = MatchManager.shared.matchFromSocket(this);

        final selectableCardIDs = generatedMessage as CardIDs;

        final lowCardIDs = new CardIDs();

        lowCardIDs.ids.add(selectableCardIDs.ids.first);
        match.userPlay(this, lowCardIDs);
        break;
      default:
    }
  }
}
