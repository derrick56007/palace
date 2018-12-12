import 'client_websocket.dart';

import 'common/generated_protos.dart';
import 'state/state.dart';


main() async {
  final client = new ClientWebSocket();
  await client.start();

  client.on(SocketMessage_Type.ERROR, (var json) {
    final info = SimpleInfo.fromJson(json);
    print(info.info);
  });

  StateManager.shared.addAll({
    'login': new Login(client),
    'register': new Register(client),
    'play': new Play(client)
  });

  StateManager.shared.pushState('login');
}