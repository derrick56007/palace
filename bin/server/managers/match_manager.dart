part of server;

class Lobby {
  CommonWebSocket host;
  final _invitedPlayersReadyStatus = <CommonWebSocket, bool>{};

  Iterable<CommonWebSocket> get players => _invitedPlayersReadyStatus.keys;

  List<CommonWebSocket> getReadyPlayers() {
    final readyPlayers = <CommonWebSocket>[];
    for (var player in _invitedPlayersReadyStatus.keys) {
      if (_invitedPlayersReadyStatus[player]) continue;

      readyPlayers.add(player);
    }

    return readyPlayers;
  }

  addPlayer(CommonWebSocket socket) {
    _invitedPlayersReadyStatus[socket] = false;

    _sendInfoToPlayers();
  }

  acceptInvite(CommonWebSocket socket) {
    _invitedPlayersReadyStatus[socket] = true;

    _sendInfoToPlayers();
  }

  declineInvite(CommonWebSocket socket) {
    _invitedPlayersReadyStatus.remove(socket);

    if (_invitedPlayersReadyStatus.isEmpty) return;

    if (socket != host) return;

    host = _invitedPlayersReadyStatus.keys.first;

    _sendInfoToPlayers();
  }

  _sendInfoToPlayers() {
    final lobbyInfo = new LobbyInfo()
      ..host = LoginManager.shared.userIDFromSocket(host)
      ..canStart = false;

    // add player entries
    for (var socket in _invitedPlayersReadyStatus.keys) {
      final playerID = LoginManager.shared.userIDFromSocket(socket);

      final playerEntry = new PlayerEntry()
        ..userID = playerID
        ..ready = _invitedPlayersReadyStatus[socket];
      lobbyInfo.players.add(playerEntry);
    }

    // send to players
    for (var socket in _invitedPlayersReadyStatus.keys) {
      socket.send(SocketMessage_Type.LOBBY_INFO, lobbyInfo);
    }

    // host has more options
    lobbyInfo.canStart = true;
    host.send(SocketMessage_Type.LOBBY_INFO, lobbyInfo);
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

    final players = <CommonWebSocket>[lobby.host];
    players.addAll(lobby.getReadyPlayers());

    final match = new Match(players);

    for (var socket in lobby.players) {
      _lobbyBySocket.remove(socket);
    }

    for (var socket in players) {
      _matchBySocket[socket] = match;
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
    _lobbyBySocket.remove(socket);
  }

  logout(CommonWebSocket socket) {
    // remove from lobby if exists
    if (socketInLobby(socket)) {
      final lobby = lobbyFromSocket(socket);
      lobby.declineInvite(socket);
      _lobbyBySocket.remove(socket);
    }

    // replace with bot
    if (socketInMatch(socket)) {
      _matchBySocket.remove(socket);

      final match = matchFromSocket(socket);
      final botSocket = new BotSocket();
      SocketReceiver.handle(botSocket);

      final indexOfPlayer = match.players.indexOf(socket);

      if (indexOfPlayer == -1) return;

      match.players[indexOfPlayer] = botSocket;

      if (match.activePlayer != socket) return;

      match.startPlayerTurn(botSocket);
    }
  }
}
