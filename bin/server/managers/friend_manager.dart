part of server;

class FriendManager {
  static final shared = FriendManager._internal();

  final defaultAddFriendErrorString = SimpleInfo() //
    ..info = 'Invalid userID';

  final defaultLoginErrorString = SimpleInfo() //
    ..info = 'Invalid login credentials';

  final _friendIDsFromSocket = <ServerWebSocket, List<String>>{};

  FriendManager._internal();

  Future<void> login(ServerWebSocket socket) async {
    final userID = LoginManager.shared.userIDFromSocket(socket);

    final userIDSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': userID});

    if (userIDSearchResults.isEmpty) {
      socket.send(SocketMessage_Type.ERROR, defaultLoginErrorString);
      return null;
    }

    _friendIDsFromSocket[socket] = <String>[];

    for (var friendID in userIDSearchResults.first['friends']) {
      _friendIDsFromSocket[socket].add(friendID.toString());
    }
    sendFriendStatuses(socket);
  }

  void logout(ServerWebSocket socket) {
    for (var friendID in _friendIDsFromSocket[socket]) {
      if (!LoginManager.shared.userIDLoggedIn(friendID)) continue;

      final friendSocket = LoginManager.shared.socketFromUserID(friendID);

      sendFriendStatuses(friendSocket);
    }

    _friendIDsFromSocket.remove(socket);
  }

  Future<void> addFriend(ServerWebSocket socket, friendID) async {
    // check if userId is valid
    if (friendID == null ||
        friendID.trim().isEmpty ||
        friendID.toLowerCase() == 'null' ||
        !StringValidator.isValidUsername(friendID)) {
      socket.send(SocketMessage_Type.ERROR, defaultAddFriendErrorString);
      return;
    }

    // search for friendID
    final friendIdSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': friendID});

    final friendExistingFriends =
        friendIdSearchResults.first['friends'] as List;

    // check if friendID exists
    if (friendIdSearchResults.isEmpty) {
      socket.send(SocketMessage_Type.ERROR, defaultAddFriendErrorString);
      return;
    }

    final userID = LoginManager.shared.userIDFromSocket(socket);

    // already existing friends
    if (friendExistingFriends.contains(userID)) {
      print('already existing friends! $userID & $friendID');
      return;
    }

    // check if friend is online
    if (LoginManager.shared.userIDLoggedIn(friendID)) {
      print('friend request sent $userID -> $friendID');

      final friendSocket = LoginManager.shared.socketFromUserID(friendID);
      friendSocket.send(
          SocketMessage_Type.FRIEND_REQUEST, SimpleInfo()..info = userID);
    }

    // save friend request
    final existingFriendRequests =
        friendIdSearchResults.first['friend_requests'] as List;
    existingFriendRequests.add(userID);

    // save friendRequest to messages
    await DataBaseManager.shared.userDB.update(
        {'userID': friendID}, {'friend_requests': existingFriendRequests});
    await DataBaseManager.shared.userDB.tidy();
  }

  static Future<void> sendAllExistingFriendRequests(
      ServerWebSocket socket) async {
    final userID = LoginManager.shared.userIDFromSocket(socket);

    // search for userID
    final userIDSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': userID});

    if (userIDSearchResults.isEmpty) {
      // TODO send error msg
      return;
    }

    final userFriendRequests =
        userIDSearchResults.first['friend_requests'] as List;

    for (var friendID in userFriendRequests) {
      final info = SimpleInfo()..info = friendID;
      socket.send(SocketMessage_Type.FRIEND_REQUEST, info);
    }
  }

  Future<void> declineFriendRequest(
      ServerWebSocket socket, String notFriendID) async {
    final userID = LoginManager.shared.userIDFromSocket(socket);

    // search for userID
    final userIDSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': userID});

    // search for friendID
    final friendIDSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': notFriendID});

    // error if returns empty
    if (userIDSearchResults.isEmpty || friendIDSearchResults.isEmpty) {
      // TODO send error msg
      return;
    }

    final userFriendRequests =
        userIDSearchResults.first['friend_requests'] as List;

    // check if friendRequest exists
    if (!userFriendRequests.contains(notFriendID)) {
      // TODO error msg
      return;
    }

    userFriendRequests.remove(notFriendID);

    await DataBaseManager.shared.userDB
        .update({'userID': userID}, {'friend_requests': userFriendRequests});
    await DataBaseManager.shared.userDB.tidy();
  }

  Future<void> acceptFriendRequest(
      ServerWebSocket socket, String friendID) async {
    final userID = LoginManager.shared.userIDFromSocket(socket);

    // search for userID
    final userIDSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': userID});

    // search for friendID
    final friendIDSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': friendID});

    // error if returns empty
    if (userIDSearchResults.isEmpty || friendIDSearchResults.isEmpty) {
      // TODO send error msg
      return;
    }
    print('friend request accepted by $userID');

    final userFriendRequests =
        userIDSearchResults.first['friend_requests'] as List;
    userFriendRequests.remove(friendID);

    final friendFriendRequests =
        friendIDSearchResults.first['friend_requests'] as List;
    friendFriendRequests.remove(userID);

    final userExistingFriends = userIDSearchResults.first['friends'] as List;

    final friendExistingFriends =
        friendIDSearchResults.first['friends'] as List;

    // already existing friends
    if (friendExistingFriends.contains(userID)) {
      print('already existing friends! $userID & $friendID');
      return;
    }

    userExistingFriends.add(friendID);
    friendExistingFriends.add(userID);

    // save friendRequest to messages
    await DataBaseManager.shared.userDB.update({
      'userID': userID
    }, {
      'friends': userExistingFriends,
      'friend_requests': userFriendRequests
    });
    await DataBaseManager.shared.userDB.update({
      'userID': friendID
    }, {
      'friends': friendExistingFriends,
      'friend_requests': friendFriendRequests
    });
    await DataBaseManager.shared.userDB.tidy();

    _friendIDsFromSocket[socket].add(friendID);

    if (LoginManager.shared.userIDLoggedIn(friendID)) {
      final friendSocket = LoginManager.shared.socketFromUserID(friendID);
      _friendIDsFromSocket[friendSocket].add(userID);
    }

    print('new friends $userID & $friendID');

    sendFriendStatuses(socket);
  }

  void sendFriendStatuses(ServerWebSocket socket) {
    if (_friendIDsFromSocket[socket].isEmpty) {
      return;
    }
    final userID = LoginManager.shared.userIDFromSocket(socket);

    // send friends list to user
    for (var friendID in _friendIDsFromSocket[socket]) {
      if (LoginManager.shared.socketLoggedIn(socket)) {
        final friendItemInfo = FriendItemInfo()
          ..userID = friendID
          ..online = LoginManager.shared.userIDLoggedIn(friendID)
          ..invitable = MatchManager.shared.userIDInvitable(friendID);

        socket.send(SocketMessage_Type.FRIEND_ITEM_INFO, friendItemInfo);
      }

      // alert friend that user is online
      if (LoginManager.shared.userIDLoggedIn(friendID)) {
        final friendSocket = LoginManager.shared.socketFromUserID(friendID);

        final selfInfo = FriendItemInfo()
          ..userID = userID
          ..online = LoginManager.shared.userIDLoggedIn(userID)
          ..invitable = MatchManager.shared.userIDInvitable(userID);

        friendSocket.send(SocketMessage_Type.FRIEND_ITEM_INFO, selfInfo);
      }
    }
  }
}
