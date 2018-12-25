import 'dart:async';
import 'dart:convert';

import 'package:protobuf/protobuf.dart' as pb;

import 'generated_protos.dart';

abstract class CommonWebSocket {
  Future done;

  static const messageTypeIndex = 0;
  static const valueIndex = 1;
  static const defaultMessageLength = 2;

  final messageDispatchers =
      new List<Function>(SocketMessage_Type.values.length);

  Future start();

  void on(SocketMessage_Type type, Function function) {
    if (messageDispatchers[SocketMessage_Type.values.indexOf(type)] != null) {
      print("warning: overriding message dispatcher ${type.name}");
    }

    messageDispatchers[SocketMessage_Type.values.indexOf(type)] = function;
  }

  void send(SocketMessage_Type type, [pb.GeneratedMessage generatedMessage]);

  void onMessageToDispatch(var data) {
    final msg = jsonDecode(data);

    // checks if is [request, data]
    if (msg is List && msg.length == defaultMessageLength) {
      // check if dispatch exists
      if (msg[messageTypeIndex] == null) {
        print('No such dispatch exists!: $msg');
      } else {
        messageDispatchers[msg[messageTypeIndex]](msg[valueIndex]);
      }
    } else if (msg is int) {
      // check if is command msg
      if (messageDispatchers[msg] == null) {
        print('No such dispatch exists!: $msg');
      } else {
        messageDispatchers[msg]();
      }
    } else {
      print('No such dispatch exists!: $msg');
    }
  }
}
