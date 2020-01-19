import 'common/generated_protos.dart';
import 'state/state.dart';
import 'client_websocket.dart';
import 'toast.dart';

void main() async {
  final client = ClientWebSocket();
  await client.start();

  client.on(SocketMessage_Type.ERROR, (var json) {
    final errorInfo = SimpleInfo.fromJson(json);
    toast(errorInfo.info);
  });

  StateManager.shared.addAll({
    'login': Login(client),
    'register': Register(client),
    'play': Play(client)
  });

  StateManager.shared.pushState('login');
}
