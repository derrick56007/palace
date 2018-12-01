part of server;

class MatchManager {
  static final shared = MatchManager._internal();

  // match invitation
  final _matchInvites = <CommonWebSocket, List<String>>{};
  final _matchInvitePlayers = <String, List<CommonWebSocket>>{};
  final _matchInvitePlayersReady = <String, Map<CommonWebSocket, bool>>{};

  final _matches = <CommonWebSocket, Match>{};
  final _matchesByID = <String, Match>{};

  // returns matchIDs from socket
  List<String> matchIDsFromSocket(CommonWebSocket socket) => _matchInvites[socket];

  // returns match invite players from matchID
  List<CommonWebSocket> matchInvitePlayersFromMatchID(String matchID) =>
      _matchInvitePlayers[matchID];

  // returns match invite ready players from matchID
  Map<CommonWebSocket, bool> matchInvitePlayersReadyFromMatchID(
          String matchID) =>
      _matchInvitePlayersReady[matchID];

  // returns true if socket is invited to match
  bool socketInvited(CommonWebSocket socket) =>
      _matchInvites.containsKey(socket);

  // returns match from socket
  Match matchFromSocket(CommonWebSocket socket) => _matches[socket];

  // returns match from matchID
  Match matchFromMatchID(String matchID) => _matchesByID[matchID];

  // returns true if socket is in match
  bool socketInMatch(CommonWebSocket socket) => _matches.containsKey(socket);

  MatchManager._internal();

  addInvitableSocket(CommonWebSocket socket) {
    _matchInvites[socket] = [];
  }

  sendMatchInvite(CommonWebSocket socket, List<String> friendIDs) async {
    // check for existing invitations
    if (socketInvited(socket)) {
      clearInvites(socket);
    }

    // TODO create diff method of generating match IDs

    final matchID = '${friendIDs.hashCode}';
    _matchInvitePlayers[matchID] = [];
    _matchInvitePlayersReady[matchID] = {socket: false};

    final userMatchInvite = new MatchInvite()
      ..msg = 'Play with ${friendIDs}?'
      ..matchID = matchID;

    _matchInvitePlayers[matchID].add(socket);
    _matchInvites[socket].add(matchID);

    socket.send(SocketMessage_Type.MATCH_INVITE, userMatchInvite);

    for (var friendID in friendIDs) {

      var friendSocket;
      if (friendID == 'bot') {
        final botSocket = new BotSocket();
        friendSocket = botSocket;
        _matchInvites[friendSocket] = [];

        SocketReceiver.handle(botSocket);
      } else {
        if (!LoginManager.shared.userIDLoggedIn(friendID)) {
          // TODO send error
          return;
        }
        // TODO check if friend already in match

        friendSocket = LoginManager.shared.socketFromUserID(friendID);
      }

      _matchInvitePlayers[matchID].add(friendSocket);
      _matchInvites[friendSocket].add(matchID);
      _matchInvitePlayersReady[matchID][friendSocket] = false;

      final friendMatchInvite = new MatchInvite()
        ..msg = 'Play with ${friendIDs}?'
        ..matchID = matchID;
      friendSocket.send(SocketMessage_Type.MATCH_INVITE, friendMatchInvite);
    }

  }

  matchAccept(CommonWebSocket socket, String matchID) {
    if (!socketInvited(socket)) {
      // TODO send error
      return;
    }

    _matchInvitePlayersReady[matchID][socket] = true;

    // all players ready
    if (!matchInvitePlayersReadyFromMatchID(matchID).values.contains(false)) {
      startMatch(matchID);
    }
  }

  startMatch(String matchID) {
    print('start match $matchID');

    final players = matchInvitePlayersFromMatchID(matchID);

    final match = new Match(players);

    for (var socket in players) {
      _matches[socket] = match;

      socket.send(SocketMessage_Type.MATCH_START);
    }

    _matchesByID[matchID] = match;
  }

  matchDecline(CommonWebSocket socket, matchID) {
    if (!_matchInvitePlayers.containsKey(matchID)) {
      // TODO send error
      return;
    }

    final matchInvite = matchInvitePlayersFromMatchID(matchID);

    final userID = LoginManager.shared.userIDFromSocket(socket);

    for (var sws in matchInvite) {
      sws.send(
          SocketMessage_Type.MATCH_INVITE_CANCEL, SimpleInfo()..info = userID);
      _matchInvites.remove(sws);
    }

    _matchInvitePlayers.remove(matchID);
    _matchInvitePlayersReady.remove(matchID);
  }

  clearInvites(CommonWebSocket socket) {
    if (socketInvited(socket)) {
      for (var matchID in matchIDsFromSocket(socket)) {
        matchDecline(socket, matchID);
      }
    }
  }

  exitMatch(CommonWebSocket socket) {
  }
}
