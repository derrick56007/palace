import 'dart:html';

import '../../../client_websocket.dart';
import '../../../common/generated_protos.dart';
import '../../../toast.dart';

class MatchHandler {
  final ClientWebSocket client;

  final UListElement lobbyList = querySelector('#lobby-list');
  final Element lobbyBtn = querySelector('#lobby-btn');
  final Element lobbyCard = querySelector('#lobby-card');

  final Element quickBtn = querySelector('#quick-btn');
  final Element quickCard = querySelector('#quick-card');

  final Element matchMakingContainer = querySelector('#matchmaking-container');
  final Element inGameContainer = querySelector('#in-game-container');
  final Element exitGameBtn = querySelector('#exit-btn');

//  final Element lobbyCancelBtn = querySelector('#lobby-cancel-btn');

  MatchHandler(this.client) {
    quickBtn.onClick.listen((_) {
      if (quickBtn.classes.contains('disabled')) return;
      quickBtn.classes.add('disabled');

      client.send(SocketMessage_Type.QUICK_JOIN);
    });

    lobbyBtn.onClick.listen((_) {
      if (lobbyBtn.classes.contains('disabled')) return;

      lobbyBtn.classes.add('disabled');

      if (lobbyBtn.text == 'Start!') {
        client.send(SocketMessage_Type.START);
      }

      if (lobbyBtn.text == 'Join') {
        client.send(SocketMessage_Type.MATCH_ACCEPT);
      }
    });

    exitGameBtn.onClick.listen((_) {
      if (exitGameBtn.classes.contains('disabled')) return;

      exitGameBtn.classes.add('disabled');
      inGameContainer.style.display = 'none';
      matchMakingContainer.style.display = '';

      client.send(SocketMessage_Type.LEAVE_GAME);
    });

    client
      ..on(SocketMessage_Type.MATCH_START, () {
//        quickCard.style.display = 'none';
//        lobbyCard.style.display = 'none';

        matchMakingContainer.style.display = 'none';
        inGameContainer.style.display = '';
        exitGameBtn.classes.remove('disabled');
        quickBtn.classes.remove('disabled');

        toast('match started!');

        (querySelector('#toggle-1') as InputElement).checked = false;
      })
      ..on(SocketMessage_Type.MATCH_INVITE, (var json) {
        quickCard.style.display = 'none';
        lobbyCard.style.display = '';

        final matchInvite = LobbyInfo.fromJson(json);
        toast('match invite');

        lobbyList.children
          ..clear()
          ..add(createLobbyListItem(matchInvite.host, true));

        for (var playerEntry in matchInvite.players) {
          lobbyList.children
              .add(createLobbyListItem(playerEntry.userID, playerEntry.ready));
        }

        lobbyBtn
          ..text = 'Join'
          ..classes.remove('disabled');

        (querySelector('#toggle-1') as InputElement).checked = true;
      })
      ..on(SocketMessage_Type.MATCH_INVITE_CANCEL, (var json) {
        final friendID = SimpleInfo.fromJson(json);

        toast('match invitation canceled by $friendID');
      })
      ..on(SocketMessage_Type.LOBBY_INFO, (var json) {
        quickCard.style.display = 'none';
        lobbyCard.style.display = '';

        final lobbyInfo = LobbyInfo.fromJson(json);

        lobbyList.children
          ..clear()
          ..add(createLobbyListItem(lobbyInfo.host, true));

        for (var playerEntry in lobbyInfo.players) {
          lobbyList.children
              .add(createLobbyListItem(playerEntry.userID, playerEntry.ready));
        }

        if (lobbyInfo.canStart) {
          lobbyBtn
            ..text = 'Start!'
            ..classes.remove('disabled');
        }

        (querySelector('#toggle-1') as InputElement).checked = true;
      });
  }

  Element createLobbyListItem(String userID, bool ready) {
    Element el;

    if (ready) {
      el = Element.html('''
                    <li class="lobby-item collection-item z-depth-1">
                        <div class="lobby-item-text">
                            ${userID}
                        </div>
                        <div class="lobby-item-status card teal white-text" style="margin: auto">
                            Ready!
                        </div>
                    </li>
      ''');
    } else {
      el = Element.html('''
                    <li class="lobby-item collection-item z-depth-1">
                        <div class="lobby-item-text">
                            ${userID}
                        </div>
                        <div class="lobby-item-status card red white-text" style="margin: auto">
                            Waiting
                        </div>
                    </li>
      ''');
    }

    return el;
  }
}
