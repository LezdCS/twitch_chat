import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';

class TwitchChat {
  String _channel;
  final String _username;
  final String _token;

  IOWebSocketChannel? webSocketChannel;
  StreamSubscription? streamSubscription;

  TwitchChat(this._channel, this._username, this._token);

  String get channel => _channel;
  String get username => _username;
  String get token => _token;

  IOWebSocketChannel get webSocket => webSocketChannel!;
  StreamSubscription get stream => streamSubscription!;

  void setChannel(String channel) {
    _channel = channel;
  }

  //close websocket connection
  void close() {
    webSocketChannel?.sink.close();
    streamSubscription?.cancel();
  }

  //login to twitch chat through websocket
  void login() {
    webSocketChannel =
        IOWebSocketChannel.connect("wss://irc-ws.chat.twitch.tv:443");

    streamSubscription = webSocketChannel?.stream.listen(
            (data) => chatListener(data),
        onDone: onDone,
        onError: onError);

    webSocketChannel?.sink.add('CAP REQ :twitch.tv/membership');
    webSocketChannel?.sink.add('CAP REQ :twitch.tv/tags');
    webSocketChannel?.sink.add('CAP REQ :twitch.tv/commands');
    webSocketChannel?.sink.add('PASS oauth:$token');
    webSocketChannel?.sink.add('NICK $username');

    webSocketChannel?.sink.add('JOIN #$channel');
  }

  void onDone() {
  }

  void onError(Object o, StackTrace s) {
  }

  void chatListener(data) {
    debugPrint(data);
  }
}
