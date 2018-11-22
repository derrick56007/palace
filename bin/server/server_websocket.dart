part of server;

class ServerWebSocket extends CommonWebSocket {
  final HttpRequest _req;

  WebSocket _webSocket;
  Future done;

  ServerWebSocket.upgradeRequest(this._req);

  @override
  start() async {
    _webSocket = await WebSocketTransformer.upgrade(_req)
      ..listen(onMessageToDispatch);

    done = _webSocket.done;
  }

  @override
  send(SocketMessage_Type type, [pb.GeneratedMessage generatedMessage]) {
    if (generatedMessage == null) {
      _webSocket.add(type.value.toString());
    } else {
      _webSocket.add(jsonEncode([type.value, generatedMessage.writeToJson()]));
    }
  }
}
