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

        final selectableCardIDs = generatedMessage as CardIDs;

        final lowCardIDs = new CardIDs();
//        final myHand = match.cardListFromCardIDList(selectableCardIDs.ids);
        final selectedCard = match.cardRegistry[selectableCardIDs.ids.first];

        lowCardIDs.ids.add(selectableCardIDs.ids.first);
//
//        for (var selectableID in selectableCardIDs.ids.sublist(1)) {
//         final card = match.cardRegistry[selectableID];
//
//         if (card.id != selectedCard.id &&
//             card.type == selectedCard.type &&
//             card.value == selectedCard.value) {
//           lowCardIDs.ids.add(selectableID);
//         }
//        }

        match.userPlay(this, lowCardIDs);
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

        lowCardIDs.ids.add(selectableCardIDs.ids.first);
        lowCardIDs.ids.add(selectableCardIDs.ids.last);

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
