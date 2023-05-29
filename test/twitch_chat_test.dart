import 'package:flutter_test/flutter_test.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/twitch_chat.dart';

void main() {
  const token = "";
  const clientId = "";

  test('connect anonymously to the websocket', () async {
    TwitchChat chat = TwitchChat.anonymous(
      "Lezd_",
    );

    chat.connect();
    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(chat.isConnected, true);
    chat.quit();
    chat.close();
  });

  test('connect to the websocket', () async {
    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );

    chat.connect();
    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(chat.isConnected, true);
    chat.quit();
    chat.close();
  });

  test('send message in chat', () async {
    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );

    chat.connect();
    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(chat.isConnected, true);
    chat.sendMessage("Hello World!");
    chat.quit();
    chat.close();
  });

  test('listen to chat stream', () async {
    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );

    int totalMessages = 0;

    chat.connect();
    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(chat.isConnected, true);
    chat.chatStream.listen((message) {
      expect(message, isA<ChatMessage>());
      totalMessages++;
    });
    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(totalMessages, totalMessages > 0);
    chat.quit();
    chat.close();
  });
}
