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
  send(MessageType type, [Encodable encodable]) {
    if (encodable == null) {
      _webSocket.add(type.index.toString());
    } else {
      _webSocket.add(jsonEncode([type.index, encodable.toJson()]));
    }
  }
}
