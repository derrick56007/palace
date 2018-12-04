part of server;

class FriendManager {
  static final shared = FriendManager._internal();

  static final defaultAddFriendErrorString = SimpleInfo()
    ..info = "Invalid userID";

  FriendManager._internal() {}

  Future<List> friendIDsFromUserID(String userID) async {
    // search for userID
    final userIDSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': userID});

    if (userIDSearchResults.isEmpty) {
      // TODO send error msg
      return null;
    }

    return userIDSearchResults.first['friends'] as List;
  }

  addFriend(ServerWebSocket socket, friendID) async {
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
    DataBaseManager.shared.userDB
      ..update(
          {'userID': friendID}, {'friend_requests': existingFriendRequests})
      ..tidy();
  }

  static sendAllExistingFriendRequests(ServerWebSocket socket) async {
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
      final info = new SimpleInfo()..info = friendID;
      socket.send(SocketMessage_Type.FRIEND_REQUEST, info);
    }
  }

  declineFriendRequest(ServerWebSocket socket, String notFriendID) async {
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

    DataBaseManager.shared.userDB
      ..update({'userID': userID}, {'friend_requests': userFriendRequests})
      ..tidy();
  }

  acceptFriendRequest(ServerWebSocket socket, String friendID) async {
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
    DataBaseManager.shared.userDB
      ..update({
        'userID': userID
      }, {
        'friends': userExistingFriends,
        'friend_requests': userFriendRequests
      })
      ..update({
        'userID': friendID
      }, {
        'friends': friendExistingFriends,
        'friend_requests': friendFriendRequests
      })
      ..tidy();

    print('new friends $userID & $friendID');
  }
}
