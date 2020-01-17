import 'dart:html';

import '../../../client_websocket.dart';
import '../../../common/generated_protos.dart';
import '../../../toast.dart';

class FriendHandler {
  final Element addFriendBtn = querySelector('#add-friend-btn');
  final InputElement addFriendUsername = querySelector('#add_friend_username');
  final UListElement friendRequestList = querySelector('#friend-request-list');
  final UListElement friendsList = querySelector('#friends-list');

  final ClientWebSocket client;

  FriendHandler(this.client) {
    addFriendBtn.onClick.listen((_) {
      addFriend();
    });

    client
      ..on(SocketMessage_Type.FRIEND_REQUEST, (var json) {
        final friendInfo = SimpleInfo.fromJson(json);

        toast('friend request from ${friendInfo.info}');

        friendRequestList.children.add(createFriendRequestCard(friendInfo));
      })
      ..on(SocketMessage_Type.FRIEND_ITEM_INFO, (var json) {
        final friendItemInfo = FriendItemInfo.fromJson(json);

        final existingFriendItemIndex = friendsList.children.indexWhere((e) =>
            e.querySelector('#user-id').text.trim() ==
            friendItemInfo.userID.trim());

        final el = createFriendCollectionItemCard(friendItemInfo);

        if (existingFriendItemIndex < 0) {
          friendsList.children.add(el);
        } else {
          friendsList.children.removeAt(existingFriendItemIndex);
          friendsList.children.insert(existingFriendItemIndex, el);
        }
      });
  }

  Element createFriendCollectionItemCard(FriendItemInfo info) {
    Element el;

    if (info.invitable) {
      el = new Element.html('''
                    <li class="collection-item card">
                        <div class="collection-item-text">
                            <div id="user-id" class="collection-item-friend-header">${info.userID}</div>
                        </div>
                        <div class="collection-item-btn">
                            <a href="#!" class="secondary-content">
                                <a id="invite-btn" class="btn-small waves-effect waves-light teal">
                                    Invite
                                </a>
                            </a>
                        </div>
                    </li>
      ''');

      final inviteBtn = el.querySelector('#invite-btn');

      var inviteSent = false;
      inviteBtn.onClick.listen((_) {
        if (inviteSent) return;

        final userIDInfo = new SimpleInfo()..info = info.userID;

        client.send(SocketMessage_Type.SEND_MATCH_INVITE, userIDInfo);

        inviteBtn.classes.add('disabled');
        inviteBtn.text = 'Sent';
        inviteSent = true;
      });
    } else if (!info.online){
      el = new Element.html('''
                    <li class="collection-item card">
                        <div class="collection-item-text">
                            <div id="user-id" class="collection-item-friend-header">${info.userID}</div>
                        </div>
                        <div class="collection-item-btn">
                            <a href="#!" class="secondary-content">
                                <a class="btn-small waves-effect waves-light red disabled">
                                    Offline
                                </a>
                            </a>
                        </div>
                    </li>
      ''');
    } else {
      el = new Element.html('''
                    <li class="collection-item card">
                        <div class="collection-item-text">
                            <div id="user-id" class="collection-item-friend-header">${info.userID}</div>
                        </div>
                        <div class="collection-item-btn">
                            <a href="#!" class="secondary-content">
                                <a class="btn-small waves-effect waves-light red disabled">
                                    In game
                                </a>
                            </a>
                        </div>
                    </li>
      ''');
    }

    return el;
  }

  Element createFriendRequestCard(SimpleInfo userInfo) {
    final el = new Element.html('''
                     <li class="collection-item card">
                        <div class="collection-item-text">
                            <div class="collection-item-title">Friend Request</div>
                            ${userInfo.info}
                        </div>
                        <div class="collection-item-btns">
                            <a class="secondary-content">
                                <a  id="accept-btn" class="btn-floating btn-small waves-effect waves-light teal">
                                    <i class="material-icons">check</i>
                                </a>
                                <a  id="decline-btn" class="btn-floating btn-small waves-effect waves-light red">
                                    <i class="material-icons">close</i>
                                </a>
                            </a>
                        </div>
                    </li>
    ''');

    el.querySelector('#accept-btn').onClick.listen((_) {
      acceptFriendRequest(userInfo);
      el.remove();
    });

    el.querySelector('#decline-btn').onClick.listen((_) {
      declineFriendRequest(userInfo);
      el.remove();
    });

    return el;
  }

  declineFriendRequest(SimpleInfo userInfo) {
    if (!client.isConnected()) {
      toast('Not connected');
      return;
    }

    // validate username
    if (userInfo.info == 'null' || userInfo.info.isEmpty) {
      toast('invalid username');
      return;
    }

    client.send(SocketMessage_Type.DECLINE_FRIEND_REQUEST, userInfo);
  }

  acceptFriendRequest(SimpleInfo userInfo) {
    if (!client.isConnected()) {
      toast('Not connected');
      return;
    }

    // validate username
    if (userInfo.info == 'null' || userInfo.info.isEmpty) {
      toast('invalid username');
      return;
    }

    client.send(SocketMessage_Type.ACCEPT_FRIEND_REQUEST, userInfo);
  }

  addFriend() {
    if (!client.isConnected()) {
      toast('Not connected');
      return;
    }

    final username = addFriendUsername.value.trim();

    // validate username
    if (username == 'null' || username.isEmpty) {
      toast('invalid username');
      return;
    }

    addFriendUsername.value = '';

    // send add
    final friendIDInfo = new SimpleInfo()..info = username;
    client.send(SocketMessage_Type.ADD_FRIEND, friendIDInfo);
  }
}
