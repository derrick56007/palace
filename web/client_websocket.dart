import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:protobuf/protobuf.dart' as pb;

import 'common/common_websocket.dart';
import 'common/generated_protos/socket_message.pbenum.dart';
//import 'common/encodable/encodable.dart';
//import 'common/message_type.dart';
//import 'common/generated_protos.dart';

class ClientWebSocket extends CommonWebSocket {
  WebSocket _webSocket;

  bool _connected = false;

  isConnected() => _connected;

  Stream<Event> onOpen, onClose, onError;

  ClientWebSocket();

  static const defaultRetrySeconds = 2;
  static const double = 2;

  @override
  Future start([int retrySeconds = defaultRetrySeconds]) {
    final completer = new Completer();

    var reconnectScheduled = false;

    final host = window.location.host;
    print('connecting to $host');
    _webSocket = new WebSocket('ws://$host/');

    _scheduleReconnect() {
      if (!reconnectScheduled) {
        new Timer(new Duration(seconds: retrySeconds),
            () async => await start(retrySeconds * double));
      }
      reconnectScheduled = true;
    }

    _webSocket
      ..onOpen.listen((Event e) {
        print('connected');
        _connected = true;

        completer.complete();
      })
      ..onMessage.listen((MessageEvent e) {
        onMessageToDispatch(e.data);
      })
      ..onClose.listen((Event e) {
        print('disconnected');
        _connected = false;
        _scheduleReconnect();
      })
      ..onError.listen((Event e) {
        print('error ${e.type}');
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
      _webSocket.send(type.value.toString());
    } else {
      _webSocket.send(jsonEncode([type.value, generatedMessage.writeToJson()]));
    }
  }
}
