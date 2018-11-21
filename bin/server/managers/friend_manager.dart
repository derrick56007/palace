part of server;

class FriendManager {
  static final shared = FriendManager._internal();

  static const defaultAddFriendErrorString = SimpleInfo("Invalid userID");

  FriendManager._internal() {}

  addFriend(ServerWebSocket socket, friendID) async {
    // check if userId is valid
    if (friendID == null ||
        friendID.trim().isEmpty ||
        friendID.toLowerCase() == 'null' ||
        !StringValidator.isValidUsername(friendID)) {
      socket.send(MessageType.error, defaultAddFriendErrorString);
      return;
    }

    // search for friendID
    final friendIdSearchResults =
        await DataBaseManager.shared.userDB.find({'userID': friendID});

    // check if friendID exists
    if (friendIdSearchResults.isEmpty) {
      socket.send(MessageType.error, defaultAddFriendErrorString);
      return;
    }

    final userID = LoginManager.shared.userIDFromSocket(socket);

    final friendExistingFriends =
        friendIdSearchResults.first['friends'] as List;

    print('friend request sent $userID -> $friendID');

    // already existing friends
    if (friendExistingFriends.contains(userID)) {
      print('already existing friends! $userID & $friendID');
      return;
    }

    // check if friend is online
    if (LoginManager.shared.userIDLoggedIn(friendID)) {
      final friendSocket = LoginManager.shared.socketFromUserID(friendID);
      friendSocket.send(MessageType.friendRequest, SimpleInfo(userID));
    } else {
      final existingFriendRequests =
          friendIdSearchResults.first['friend_requests'] as List;
      existingFriendRequests.add(userID);

      // save friendRequest to messages
      DataBaseManager.shared.userDB
        ..update(
            {'userID': friendID}, {'friend_requests': existingFriendRequests})
        ..tidy();
    }
  }

  acceptFriendRequest(ServerWebSocket socket, friendID) async {
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
