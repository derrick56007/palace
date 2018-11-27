part of server;

class MatchManager {
  static final shared = MatchManager._internal();

  // match invitation
  final _matchInvites = <ServerWebSocket, String>{};
  final _matchInvitePlayers = <String, List<ServerWebSocket>>{};
  final _matchInvitePlayersReady = <String, Map<ServerWebSocket, bool>>{};

  final _matches = <ServerWebSocket, Match>{};
  final _matchesByID = <String, Match>{};

  // returns matchID from socket
  String matchIDFromSocket(ServerWebSocket socket) => _matchInvites[socket];

  // returns match invite players from matchID
  List<ServerWebSocket> matchInvitePlayersFromMatchID(String matchID) =>
      _matchInvitePlayers[matchID];

  // returns match invite ready players from matchID
  Map<ServerWebSocket, bool> matchInvitePlayersReadyFromMatchID(
          String matchID) =>
      _matchInvitePlayersReady[matchID];

  // returns true if socket is invited to match
  bool socketInvited(ServerWebSocket socket) =>
      _matchInvites.containsKey(socket);

  // returns match from socket
  Match matchFromSocket(ServerWebSocket socket) => _matches[socket];

  // returns match from matchID
  Match matchFromMatchID(String matchID) => _matchesByID[matchID];

  // returns true if socket is in match
  bool socketInMatch(ServerWebSocket socket) => _matches.containsKey(socket);

  MatchManager._internal();

  sendMatchInvite(ServerWebSocket socket, String friendID) {
    // check for existing invitations
    if (socketInvited(socket)) {
      clearInvites(socket);
    }

    if (!LoginManager.shared.userIDLoggedIn(friendID)) {
      // TODO send error
      return;
    }

    final friendSocket = LoginManager.shared.socketFromUserID(friendID);

    if (socketInvited(friendSocket)) {
      // TODO send error
      return;
    }

    // TODO check if friend already in match

    final userID = LoginManager.shared.userIDFromSocket(socket);

    // TODO create diff method of generating match IDs
    final matchID = '$userID$friendID';

    final friendMatchInvite = new MatchInvite()
      ..msg = 'Play with $userID?'
      ..matchID = matchID;
    friendSocket.send(SocketMessage_Type.MATCH_INVITE, friendMatchInvite);

    final userMatchInvite = new MatchInvite()
      ..msg = 'Play with $friendID?'
      ..matchID = matchID;
    socket.send(SocketMessage_Type.MATCH_INVITE, userMatchInvite);

    _matchInvitePlayers[matchID] = [socket, friendSocket];
    _matchInvites[socket] = matchID;
    _matchInvites[friendSocket] = matchID;
    _matchInvitePlayersReady[matchID] = {socket: false, friendSocket: false};
  }

  matchAccept(ServerWebSocket socket, matchID) {
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

  matchDecline(ServerWebSocket socket, matchID) {
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

  clearInvites(ServerWebSocket socket) {
    if (socketInvited(socket)) {
      final matchID = matchIDFromSocket(socket);

      matchDecline(socket, matchID);
    }
  }

  exitMatch(ServerWebSocket socket) {}
}
