part of server;

class ServerWebSocket extends CommonWebSocket {
  final HttpRequest _req;

  WebSocket _webSocket;

  ServerWebSocket.upgradeRequest(this._req);

  String userID;

  @override
  Future<void> start() async {
    _webSocket = await WebSocketTransformer.upgrade(_req)
      ..listen(onMessageToDispatch);

    done = _webSocket.done;
  }

  @override
  void send(SocketMessage_Type type, [pb.GeneratedMessage generatedMessage]) {
    if (generatedMessage == null) {
      _webSocket.add(SocketMessage_Type.values.indexOf(type).toString());
    } else {
      _webSocket.add(jsonEncode([
        SocketMessage_Type.values.indexOf(type),
        generatedMessage.writeToJson()
      ]));
    }
  }
}
