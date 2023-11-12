@Timeout(Duration(seconds: 90000))

import 'package:collection/collection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twitch_chat/src/data/seventv_api.dart';
import 'package:twitch_chat/twitch_chat.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  String token = dotenv.env["USER_TOKEN"]!;
  String clientId = dotenv.env["TWITCH_CLIENT_ID"]!;

  // Get the 7TV emotes of the user Lezd_
  test('get 7TV emotes', () async {
    String? channelId = await TwitchApi.getTwitchUserChannelId(
      "Lezd_",
      token,
      clientId,
    );

    List<Emote> emotes = await SeventvApi.getChannelEmotes(
      channelId!,
    );

    expect(emotes, isNotEmpty);
  });

  test('connect anonymously to a chat', () async {
    TwitchChat chat = TwitchChat.anonymous(
      "lezd_",
    );

    // chat.chatStream.listen((event) => debugPrint(event.highlightType.toString()));

    chat.connect();
    await Future.delayed(const Duration(seconds: 90000), () {});
    // expectLater(chat.isConnected, true);
    // chat.quit();
    // chat.close();
  });

  test('connect to a chat', () async {
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

  test('switch to another chat', () async {
    TwitchChat chat = TwitchChat.anonymous(
      "Lezd_",
    );

    chat.connect();
    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(chat.isConnected, true);
    chat.changeChannel("xqc");
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
    chat.sendMessage("Hello World!");
    chat.quit();
    chat.close();
  });

  test('get messages from chat', () async {
    List<ChatMessage> messages = [];

    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );

    chat.connect();
    chat.chatStream.listen((message) {
      expect(message, isA<ChatMessage>());
      messages.add(message);
    });

    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(messages, messages.isNotEmpty);

    chat.quit();
    chat.close();
  });

  test("clear all messages", () async {
    List<ChatMessage> messages = [];

    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );

    chat.connect();

    chat.onClearChat = (() {
      messages.clear();
    });

    await Future.delayed(const Duration(seconds: 8), () {});
    expectLater(messages, messages.isEmpty);

    chat.quit();
    chat.close();
  });

  test("delete message by user id", () async {
    List<ChatMessage> messages = [];

    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );
    chat.connect();

    String? channelId = await TwitchApi.getTwitchUserChannelId(
      "Lezd_",
      token,
      clientId,
    );

    late ChatMessage messageDeleted;
    chat.chatStream.listen((message) {
      messageDeleted = message;
      TwitchApi.banUser(token, channelId!, message, 10, clientId);
    });

    chat.onDeletedMessageByUserId = ((userId) {
      messages
          .firstWhereOrNull((element) => element.authorId == userId)
          ?.isDeleted = true;
    });

    await Future.delayed(const Duration(seconds: 8), () {});
    expect(messageDeleted.isDeleted, true);

    chat.quit();
    chat.close();
  });

  test("delete message by message id", () async {
    List<ChatMessage> messages = [];

    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );
    chat.connect();

    String? channelId = await TwitchApi.getTwitchUserChannelId(
      "Lezd_",
      token,
      clientId,
    );

    late ChatMessage messageDeleted;
    chat.chatStream.listen((message) {
      messageDeleted = message;
      TwitchApi.deleteMessage(token, channelId!, message, clientId);
    });

    chat.onDeletedMessageByMessageId = ((messageId) {
      messages
          .firstWhereOrNull((element) => element.id == messageId)
          ?.isDeleted = true;
    });

    await Future.delayed(const Duration(seconds: 8), () {});
    expect(messageDeleted.isDeleted, true);

    chat.quit();
    chat.close();
  });
}
