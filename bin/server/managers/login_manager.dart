part of server;

class LoginManager {
  // shared instance
  static final shared = new LoginManager._internal();

  // PBKDF2 generator
  static final _pbkdf2 = new PBKDF2();

  // default login error string
  static final _defaultLoginErrorString =
      SimpleInfo()..info = 'Invalid username or password';

  // default userId already exists error string
  static final _defaultUserIdExistsErrorString =
      SimpleInfo()..info = 'Username already exists';

  var _matches = <String, Match>{};
  var _socketForUserID = <ServerWebSocket, String>{};
  var _userIDForSocket = <String, ServerWebSocket>{};

  // create singleton
  LoginManager._internal();

  // returns true if socket is logged in
  bool socketLoggedIn(ServerWebSocket socket) =>
      _socketForUserID.containsKey(socket);

  // returns true if username is logged in
  bool userIDLoggedIn(String username) =>
      _socketForUserID.containsValue(username);

  // returns socket from userID
  ServerWebSocket socketFromUserID(String userID) => _userIDForSocket[userID];

  // returns username from socket
  String userIDFromSocket(ServerWebSocket socket) => _socketForUserID[socket];

  // get all sockets
  getSockets() => _socketForUserID.keys;

  // get all lobbies
  getMatches() => _matches.values;

  // get all userIDs
  getUserIDs() => _socketForUserID.values;

  // register user
  register(ServerWebSocket socket, String userID, String passCode) async {
    // logout socket if previously logged in
    logout(socket);

    // validate username
    if (userID == null ||
        userID.trim().isEmpty ||
        userID.toLowerCase() == 'null' ||
        !StringValidator.isValidUsername(userID)) {
      socket.send(SocketMessage_Type.ERROR, _defaultLoginErrorString);
      return;
    }

    final userIdSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': userID});

    // check if username already exists
    if (userIdSearchResults.isNotEmpty) {
      socket.send(SocketMessage_Type.ERROR, _defaultUserIdExistsErrorString);
      return;
    }

    // validate password
    if (passCode == null ||
        passCode.trim().isEmpty ||
        passCode.toLowerCase() == 'null') {
      socket.send(SocketMessage_Type.ERROR, _defaultLoginErrorString);
      return;
    }

    final saltLength = 24;
    final salt = Salt.generateAsBase64String(saltLength);
    final hash = _pbkdf2.generateKey(passCode, salt, 1000, 32);
    final hashString = new String.fromCharCodes(hash);

    // salt prepended to hash
    final saltWithHash = '$salt$hashString';

    final userInfo = {
      'userID': userID,
      'passCode': saltWithHash,
      'friends': [],
      'friend_requests': []
    };

    DataBaseManager.shared.userDB
      ..insert(userInfo)
      ..tidy();

    print('registered $userID');
  }

  // logs in socket with username
  login(ServerWebSocket socket, String userID, String passCode) async {
    // logout socket if previously logged in
    logout(socket);

    // validate username
    if (userID == null ||
        userID.trim().isEmpty ||
        userID.toLowerCase() == 'null' ||
        !StringValidator.isValidUsername(userID)) {
      socket.send(SocketMessage_Type.ERROR, _defaultLoginErrorString);
      return;
    }

    final userIdSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': userID});

    // check if username exists
    if (userIdSearchResults.isEmpty) {
      socket.send(SocketMessage_Type.ERROR, _defaultLoginErrorString);
      return;
    }

    // validate password
    if (passCode == null ||
        passCode.trim().isEmpty ||
        passCode.toLowerCase() == 'null') {
      socket.send(SocketMessage_Type.ERROR, _defaultLoginErrorString);
      return;
    }

    final userInfo = userIdSearchResults.first;
    final hashedPassCode = userInfo['passCode'] as String;

    final saltStringLength = 32;
    final salt = hashedPassCode.substring(0, saltStringLength);
    final hash = _pbkdf2.generateKey(passCode, salt, 1000, saltStringLength);
    final hashString = new String.fromCharCodes(hash);

    // check if hashed passCode matches
    if (hashString != hashedPassCode.substring(saltStringLength)) {
      socket.send(SocketMessage_Type.ERROR, _defaultLoginErrorString);
      return;
    }

    // add user
    _socketForUserID[socket] = userID;
    _userIDForSocket[userID] = socket;

    // alert successful login
    socket.send(SocketMessage_Type.LOGIN_SUCCESSFUL);

    print('logged in $userID');
  }

  // logs out socket
  logout(ServerWebSocket socket) {
    // check if socket is logged in
    if (!socketLoggedIn(socket)) return;

    final userID = _socketForUserID.remove(socket);

    _userIDForSocket.remove(userID);

    print('logged out $userID');
  }
}
