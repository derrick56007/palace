part of server;

class BotSocket extends CommonWebSocket {
  Future done;

  @override
  start() async {
    final completer = new Completer();

    done = completer.future;
  }

  @override
  send(SocketMessage_Type type, [pb.GeneratedMessage generatedMessage]) async {
    switch (type) {
      case SocketMessage_Type.MATCH_INVITE:
        final matchInvite = generatedMessage as MatchInvite;
        final matchID = new SimpleInfo()..info = matchInvite.matchID;

        MatchManager.shared.matchAccept(this, matchID.info);
        break;

      case SocketMessage_Type.SET_MULLIGANABLE_CARDS:
        await new Future.delayed(const Duration(seconds: 5));

        final match = MatchManager.shared.matchFromSocket(this);

        final lowCardThreshold = 5;
        final lowCardIDs = new CardIDs();
        for (var card in match.topTowers[this].cards) {
          if (card.type == Card_Type.BASIC && card.value < lowCardThreshold) {
            lowCardIDs.ids.add(card.id);
          }
        }

        match.userPlay(this, lowCardIDs);

        break;
      case SocketMessage_Type.SET_SELECTABLE_CARDS:
        await new Future.delayed(const Duration(seconds: 1));

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
