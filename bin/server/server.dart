library server;

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:http_server/http_server.dart';
import 'package:password_hash/password_hash.dart';
import 'package:objectdb/objectdb.dart';
import 'package:quiver/async.dart';
import 'package:protobuf/protobuf.dart' as pb;

import '../../web/common/common_websocket.dart';
import '../../web/common/regex_rules.dart';
import '../../web/common/generated_protos.dart';

part 'logic/match.dart';

part 'logic/bot_socket.dart';

part 'logic/elo_calculation.dart';

part 'managers/database_manager.dart';

part 'managers/friend_manager.dart';

part 'managers/login_manager.dart';

part 'managers/match_manager.dart';

part 'server_websocket.dart';

part 'socket_receiver.dart';

part 'string_validator.dart';

void main(List<String> args) async {
  const defaultPort = 8080;

  final port = Platform.environment.containsKey('PORT')
      ? int.parse(Platform.environment['PORT'])
      : defaultPort;

  final defaultPage = File('build/index.html');

  final staticFiles = VirtualDirectory('build/');
  staticFiles
    ..jailRoot = false
    ..allowDirectoryListing = true
    ..directoryHandler = (dir, request) async {
      final indexUri = Uri.file(dir.path).resolve('index.html');

      var file = File(indexUri.toFilePath());

      if (!(await file.exists())) {
        file = defaultPage;
      }
      staticFiles.serveFile(file, request);
    };

  final server = await HttpServer.bind('0.0.0.0', port);

  print('server started at ${server.address.address}:${server.port}');

  await for (HttpRequest request in server) {
    request.response.headers.set('cache-control', 'no-cache');

    // handle webSocket connection
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = ServerWebSocket.upgradeRequest(request);

      SocketReceiver.handle(socket);

      continue;
    }

    await staticFiles.serveRequest(request);
  }
}
