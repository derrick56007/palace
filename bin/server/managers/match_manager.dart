part of server;

class Lobby {
  final CommonWebSocket host;
  final _invitedPlayersReadyStatus = <CommonWebSocket, bool>{};

  List<CommonWebSocket> getPlayers() => _invitedPlayersReadyStatus.keys.toList();

  bool playersReady() => !_invitedPlayersReadyStatus.values.contains(false);

  addPlayer(CommonWebSocket socket) {
    _invitedPlayersReadyStatus[socket] = false;

    // send update
  }

  acceptInvite(CommonWebSocket socket) {
    _invitedPlayersReadyStatus[socket] = true;

    // send update
  }

  declineInvite(CommonWebSocket socket) {
    _invitedPlayersReadyStatus.remove(socket);

    // send update
  }

  Lobby(this.host);
}

class MatchManager {
  static final shared = MatchManager._internal();

  MatchManager._internal();

  final _lobbyBySocket = <CommonWebSocket, Lobby>{};
  final _matchBySocket = <CommonWebSocket, Match>{};

  bool socketInLobby(CommonWebSocket socket) =>
      _lobbyBySocket.containsKey(socket);
  bool socketInMatch(CommonWebSocket socket) =>
      _matchBySocket.containsKey(socket);
  bool userIDInvitable(String username) {
    if (!LoginManager.shared.userIDLoggedIn(username)) return false;

    final socket = LoginManager.shared.socketFromUserID(username);

    if (socketInMatch(socket) || socketInLobby(socket)) return false;

    return true;
  }

  Lobby lobbyFromSocket(CommonWebSocket socket) => _lobbyBySocket[socket];
  Match matchFromSocket(CommonWebSocket socket) => _matchBySocket[socket];

  sendMatchInvite(CommonWebSocket socket, String friendID) async {
    if (socketInMatch(socket) || socketInLobby(socket)) return;

    // add user to lobby
    final lobby = new Lobby(socket);

    var friendSocket;
    if (friendID == 'bot') {
      final botSocket = new BotSocket();
      friendSocket = botSocket;

      SocketReceiver.handle(botSocket);
    } else {
      if (!LoginManager.shared.userIDLoggedIn(friendID)) {
        // TODO send error
        return;
      }
      // TODO check if friend already in match

      friendSocket = LoginManager.shared.socketFromUserID(friendID);

      _lobbyBySocket[friendSocket] = lobby;
    }

    lobby.addPlayer(friendSocket);

    final userID = LoginManager.shared.userIDFromSocket(socket);

    final friendMatchInvite = new MatchInvite()
      ..msg = 'Play with $userID?'
      ..userID = userID;
    friendSocket.send(SocketMessage_Type.MATCH_INVITE, friendMatchInvite);
  }

  matchAccept(CommonWebSocket socket) {
    if (!socketInLobby(socket) || socketInMatch(socket)) {
      // TODO send error
      return;
    }

    final lobby = lobbyFromSocket(socket);
    lobby.acceptInvite(socket);
  }

  startMatch(CommonWebSocket socket) {
    if (!socketInLobby(socket) || socketInMatch(socket)) {
      // TODO send error
      return;
    }

    final lobby = lobbyFromSocket(socket);

    // only host can start
    if (socket != lobby.host) return;

    // players not ready
    if (!lobby.playersReady()) return;

    final players = <CommonWebSocket>[lobby.host];
    players.addAll(lobby.getPlayers());

    final match = new Match(players);

    for (var socket in players) {
      _matchBySocket[socket] = match;
      _lobbyBySocket.remove(socket);

      socket.send(SocketMessage_Type.MATCH_START);
    }
  }

  matchDecline(CommonWebSocket socket) {
    if (!socketInLobby(socket) || socketInMatch(socket)) {
      // TODO send error
      return;
    }

    final lobby = lobbyFromSocket(socket);
    lobby.declineInvite(socket);
  }

  logout(CommonWebSocket socket) {
    if (socketInMatch(socket)) {
      final match = matchFromSocket(socket);
      // TODO replace with bot
    }

    // remove from lobby if exists
    if (socketInLobby(socket)) {
      final lobby = lobbyFromSocket(socket);
      lobby.declineInvite(socket);
    }
  }
}
