part of server;

class SocketReceiver {
  static final LoginManager _loginManager = LoginManager.shared;
  static final FriendManager _friendManager = FriendManager.shared;
  static final MatchManager _matchManager = MatchManager.shared;

  final ServerWebSocket _socket;

  SocketReceiver._internal(this._socket);

  factory SocketReceiver.handle(ServerWebSocket socket) {
    final sr = new SocketReceiver._internal(socket);

    sr._init();

    return sr;
  }

  _init() async {
    await _socket.start();

    _onStart();

    await _socket.done;

    _onClose();
  }

  _onStart() {
    _socket
      ..on(MessageType.register, _register)
      ..on(MessageType.login, _login)
      ..on(MessageType.addFriend, _addFriend)
      ..on(MessageType.acceptFriendRequest, _acceptFriendRequest)
      ..on(MessageType.sendMatchInvite, _sendMatchInvite)
      ..on(MessageType.matchAccept, _matchAccept)
      ..on(MessageType.matchDecline, _matchDecline)
      ..on(MessageType.userPlay, _userPlay);
  }

  _onClose() {
    _matchManager.clearInvites(_socket);
    _matchManager.exitMatch(_socket);
    _loginManager.logout(_socket);
  }

  _register(String json) {
    final loginInfo = new LoginInfo.fromJson(json);

    _loginManager.register(_socket, loginInfo.userID, loginInfo.passCode);
  }

  _login(String json) {
    final loginInfo = new LoginInfo.fromJson(json);

    _loginManager.login(_socket, loginInfo.userID, loginInfo.passCode);
  }

  _addFriend(String json) {
    final friendID = jsonDecode(json);

    _friendManager.addFriend(_socket, friendID);
  }

  _acceptFriendRequest(String json) {
    final friendID = jsonDecode(json);

    _friendManager.acceptFriendRequest(_socket, friendID);
  }

  _sendMatchInvite(String json) {
    final friendID = jsonDecode(json);

    _matchManager.sendMatchInvite(_socket, friendID);
  }

  _matchAccept(String json) {
    final matchID = jsonDecode(json);

    _matchManager.matchAccept(_socket, matchID);
  }

  _matchDecline(String json) {
    final matchID = jsonDecode(json);

    _matchManager.matchDecline(_socket, matchID);
  }

  _userPlay(String json) {
    final userPlay = new UserPlay.fromJson(json);

    if (_matchManager.socketInMatch(_socket)) {
      final match = _matchManager.matchFromSocket(_socket);

      match.userPlay(_socket, userPlay);
    }
  }
}
