import 'dart:async';
import 'dart:convert';

import 'message_type.dart';

import 'encodable/encodable.dart';

abstract class CommonWebSocket {
  static const messageTypeIndex = 0;
  static const valueIndex = 1;
  static const defaultMessageLength = 2;

  final messageDispatchers = new List<Function>(MessageType.values.length);

  Future start();

  void on(MessageType type, Function function) {
    if (messageDispatchers[type.index] != null) {
      print("warning: overriding message dispatcher ${type.index}");
    }

    messageDispatchers[type.index] = function;
  }

  void send(MessageType type, [Encodable encodable]);

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
