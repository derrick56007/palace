part of server;

class SocketReceiver {
  static final LoginManager _loginManager = LoginManager.shared;
  static final FriendManager _friendManager = FriendManager.shared;
  static final MatchManager _matchManager = MatchManager.shared;

  final CommonWebSocket _socket;

  SocketReceiver._internal(this._socket);

  factory SocketReceiver.handle(CommonWebSocket socket) {
    final sr = SocketReceiver._internal(socket);

    sr._init();

    return sr;
  }

  Future<void> _init() async {
    await _socket.start();

    _onStart();

    await _socket.done;

    _onClose();
  }

  void _onStart() {
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
      ..on(SocketMessage_Type.HIGHERLOWER_CHOICE, _higherLowerChoice)
      ..on(SocketMessage_Type.REQUEST_PICK_UP, _requestPickUp)
      ..on(SocketMessage_Type.QUICK_JOIN, _quickJoinMatch)
      ..on(SocketMessage_Type.LEAVE_GAME, _leaveGame)
      ..on(SocketMessage_Type.RANKED_JOIN, _rankedJoinMatch)
      ..on(SocketMessage_Type.KEEP_ALIVE, _keepAlive);
  }

  void _onClose() {
    _matchManager.logout(_socket);
    _loginManager.logout(_socket);
  }

  void _register(String json) {
    final loginInfo = LoginCredentials.fromJson(json);
    _loginManager.register(_socket, loginInfo.userID, loginInfo.passCode);
  }

  void _login(String json) {
    final loginInfo = LoginCredentials.fromJson(json);
    _loginManager.login(_socket, loginInfo.userID, loginInfo.passCode);
  }

  void _addFriend(String json) {
    final friendID = SimpleInfo.fromJson(json);
    _friendManager.addFriend(_socket, friendID.info);
  }

  void _acceptFriendRequest(String json) {
    final friendID = SimpleInfo.fromJson(json);
    _friendManager.acceptFriendRequest(_socket, friendID.info);
  }

  void _declineFriendRequest(String json) {
    final friendID = SimpleInfo.fromJson(json);
    _friendManager.declineFriendRequest(_socket, friendID.info);
  }

  void _sendMatchInvite(String json) {
    final friendID = SimpleInfo.fromJson(json);

    _matchManager.sendMatchInvite(_socket, friendID.info);
  }

  void _matchAccept() {
    _matchManager.matchAccept(_socket);
  }

  void _startMatch() {
    _matchManager.startMatch(_socket);
  }

  void _matchDecline() {
    _matchManager.matchDecline(_socket);
  }

  void _userPlay(String json) {
    if (!_matchManager.socketInMatch(_socket)) return;

    final userPlay = CardIDs.fromJson(json);

    final match = _matchManager.matchFromSocket(_socket);

    match.userPlay(_socket, userPlay);
  }

  void _higherLowerChoice(String json) {
    if (!_matchManager.socketInMatch(_socket)) return;

    final higherLowerChoice = HigherLowerChoice.fromJson(json);

    final match = _matchManager.matchFromSocket(_socket);

    match.onHigherLowerChoice(_socket, higherLowerChoice);
  }

  void _requestPickUp() {
    if (!_matchManager.socketInMatch(_socket)) return;

    final match = _matchManager.matchFromSocket(_socket);

    match.onRequestPickup(_socket);
  }

  void _quickJoinMatch() {
    _matchManager.quickMatch(_socket);
  }

  void _leaveGame() {
    _matchManager.logout(_socket);
  }

  void _rankedJoinMatch() {
    _matchManager.rankedMatch(_socket);
  }

  void _keepAlive() {}
}
