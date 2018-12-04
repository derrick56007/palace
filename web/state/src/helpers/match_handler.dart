import '../../../client_websocket.dart';
import '../../../common/generated_protos.dart';

class MatchHandler {
  final ClientWebSocket client;

  MatchHandler(this.client) {
    client
      ..on(SocketMessage_Type.MATCH_INVITE, (var json) {
        final matchInvite = new MatchInvite.fromJson(json);
        final userID = new SimpleInfo()..info = matchInvite.userID;

//        final confirm = context.callMethod('confirm', ['Join game $matchID?']);

        print('match invite from id -> ${matchInvite.userID}');
//
//        if (confirm) {
//          client.send(SocketMessage_Type.MATCH_ACCEPT);
//        }
      })
      ..on(SocketMessage_Type.MATCH_INVITE_CANCEL, (var json) {
        final friendID = SimpleInfo.fromJson(json);

        print('match invitation canceled by $friendID');
      });
  }
}
