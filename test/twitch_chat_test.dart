@Timeout(Duration(seconds: 90000))
library;

import 'package:api_7tv/api_7tv.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twitch_chat/twitch_chat.dart';

Future<void> main() async {
  String token = 'USER_TOKEN';
  String clientId = 'TWITCH_CLIENT_ID';

  // Get the 7TV emotes of the user Lezd_
  test('get 7TV emotes', () async {
    String? channelId = await TwitchApi.getTwitchUserChannelId(
      "Lezd_",
      token,
      clientId,
    );

    List emotesCall = await SeventvApi.getChannelEmotes(channelId!) ?? [];
    List<Emote> emotes = [];
    for (var emote in emotesCall) {
      emotes.add(
        Emote.fromJson7Tv(emote),
      );
    }

    expect(emotes, isNotEmpty);
  });

  test('connect anonymously to a chat', () async {
    TwitchChat chat = TwitchChat.anonymous(
      "lezd_",
    );

    chat.chatStream.listen((event) {
      debugPrint(event.toString());
    });

    chat.connect();
    await Future.delayed(const Duration(seconds: 100), () {});
    expectLater(chat.isConnected, true);
    chat.close();
  });

  test('connect to a chat', () async {
    TwitchChat chat = TwitchChat(
      "Lezd_",
      "Lezd_",
      token,
      clientId: clientId,
    );

    chat.connect();
    chat.isConnected.addListener(() {
      if (chat.isConnected.value) {
        expect(chat.isConnected, true);
      }
    });
    await Future.delayed(const Duration(seconds: 30), () {
      chat.close();
    });
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
      TwitchApi.banUser(token, channelId!, message.authorId, 10, clientId);
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
      TwitchApi.deleteMessage(token, channelId!, message.id, clientId);
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
