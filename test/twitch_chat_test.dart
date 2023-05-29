import 'package:flutter_test/flutter_test.dart';
import 'package:twitch_chat/twitch_chat.dart';

void main() {
  test('connect to the websocket as anonymous', () async {

    TwitchChat chat = TwitchChat.anonymous(
      "Lezd_",
    );

    chat.connect();
    await Future.delayed(const Duration(seconds: 8), (){});
    expectLater(chat.isConnected, true);
    chat.quit();
    chat.close();
  });

  test('connect to the websocket', () async {

    const token = "";
    const clientId = "";
    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );

    chat.connect();
    await Future.delayed(const Duration(seconds: 8), (){});
    expectLater(chat.isConnected, true);
    chat.quit();
    chat.close();
  });
}
