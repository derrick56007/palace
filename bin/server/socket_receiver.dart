part of server;

class SocketReceiver {
  static final LoginManager _loginManager = LoginManager.shared;
  static final FriendManager _friendManager = FriendManager.shared;
  static final MatchManager _matchManager = MatchManager.shared;

  final CommonWebSocket _socket;

  SocketReceiver._internal(this._socket);

  factory SocketReceiver.handle(CommonWebSocket socket) {
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
      ..on(SocketMessage_Type.REGISTER, _register)
      ..on(SocketMessage_Type.LOGIN, _login)
      ..on(SocketMessage_Type.ADD_FRIEND, _addFriend)
      ..on(SocketMessage_Type.ACCEPT_FRIEND_REQUEST, _acceptFriendRequest)
      ..on(SocketMessage_Type.DECLINE_FRIEND_REQUEST, _declineFriendRequest)
      ..on(SocketMessage_Type.SEND_MATCH_INVITE, _sendMatchInvite)
      ..on(SocketMessage_Type.START, _startMatch)
      ..on(SocketMessage_Type.MATCH_ACCEPT, _matchAccept)
      ..on(SocketMessage_Type.MATCH_DECLINE, _matchDecline)
      ..on(SocketMessage_Type.USER_PLAY, _userPlay)
      ..on(SocketMessage_Type.HIGHERLOWER_CHOICE, _higherLowerChoice);
  }

  _onClose() {
    _matchManager.logout(_socket);
    _loginManager.logout(_socket);
  }

  _register(String json) {
    final loginInfo = new LoginCredentials.fromJson(json);
    _loginManager.register(_socket, loginInfo.userID, loginInfo.passCode);
  }

  _login(String json) {
    final loginInfo = new LoginCredentials.fromJson(json);
    _loginManager.login(_socket, loginInfo.userID, loginInfo.passCode);
  }

  _addFriend(String json) {
    final friendID = new SimpleInfo.fromJson(json);
    _friendManager.addFriend(_socket, friendID.info);
  }

  _acceptFriendRequest(String json) {
    final friendID = new SimpleInfo.fromJson(json);
    _friendManager.acceptFriendRequest(_socket, friendID.info);
  }

  _declineFriendRequest(String json) {
    final friendID = new SimpleInfo.fromJson(json);
    _friendManager.declineFriendRequest(_socket, friendID.info);
  }

  _sendMatchInvite(String json) {
    final friendID = new SimpleInfo.fromJson(json);

    _matchManager.sendMatchInvite(_socket, friendID.info);
  }

  _matchAccept() {
    _matchManager.matchAccept(_socket);
  }

  _startMatch() {
    _matchManager.startMatch(_socket);
  }

  _matchDecline() {
    _matchManager.matchDecline(_socket);
  }

  _userPlay(String json) {
    final userPlay = new CardIDs.fromJson(json);

    if (_matchManager.socketInMatch(_socket)) {
      final match = _matchManager.matchFromSocket(_socket);

      match.userPlay(_socket, userPlay);
    }
  }

  _higherLowerChoice(String json) {
    final higherLowerChoice = new HigherLowerChoice.fromJson(json);

    if (_matchManager.socketInMatch(_socket)) {
      final match = _matchManager.matchFromSocket(_socket);

      match.onHigherLowerChoice(_socket, higherLowerChoice);
    }
  }
}
