import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:protobuf/protobuf.dart' as pb;

import 'common/common_websocket.dart';
import 'common/generated_protos.dart';
import 'toast.dart';

class ClientWebSocket extends CommonWebSocket {
  WebSocket _webSocket;

  bool _connected = false;

  isConnected() => _connected;

  Stream<Event> onOpen, onClose, onError;

  String host = window.location.host;

  ClientWebSocket() {
    // check if in webdev serve mode
    if (document.documentElement.outerHtml.contains('dev_compiler')) {
      host =
          'localhost:8080'; // replace this with your custom port for the server
    }
  }

  static const defaultRetrySeconds = 2;
  static const double = 2;

  @override
  Future start([int retrySeconds = defaultRetrySeconds]) {
    final completer = Completer();

    var reconnectScheduled = false;

    toast('connecting to $host');
    _webSocket = WebSocket('wss://$host/');

    _scheduleReconnect() {
      if (!reconnectScheduled) {
        new Timer(Duration(seconds: retrySeconds),
            () async => await start(retrySeconds * double));
      }
      reconnectScheduled = true;
    }

    _webSocket
      ..onOpen.listen((Event e) {
        toast('connected');
        _connected = true;

        completer.complete();
      })
      ..onMessage.listen((MessageEvent e) {
        onMessageToDispatch(e.data);
      })
      ..onClose.listen((Event e) {
        toast('disconnected');
        _connected = false;
        _scheduleReconnect();
      })
      ..onError.listen((Event e) {
        toast('error ${e.type}');
        _connected = false;
        _scheduleReconnect();
      });

    onOpen = _webSocket.onOpen;
    onClose = _webSocket.onClose;
    onError = _webSocket.onError;

    return completer.future;
  }

  @override
  send(SocketMessage_Type type, [pb.GeneratedMessage generatedMessage]) {
    if (generatedMessage == null) {
      _webSocket.send(SocketMessage_Type.values.indexOf(type).toString());
    } else {
      _webSocket.send(jsonEncode([
        SocketMessage_Type.values.indexOf(type),
        generatedMessage.writeToJson()
      ]));
    }
  }
}
