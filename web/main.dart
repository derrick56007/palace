import 'common/generated_protos.dart';
import 'state/state.dart';
import 'client_websocket.dart';
import 'toast.dart';

main() async {
  final client = new ClientWebSocket();
  await client.start();

  client.on(SocketMessage_Type.ERROR, (var json) {
    final errorInfo = new SimpleInfo.fromJson(json);
    toast(errorInfo.info);
  });

  StateManager.shared.addAll({
    'login': new Login(client),
    'register': new Register(client),
    'play': new Play(client)
  });

  StateManager.shared.pushState('login');
}
