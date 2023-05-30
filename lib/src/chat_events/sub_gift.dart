import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';

import '../emote.dart';

class SubGift extends ChatMessage {
  final String giftedName;
  final String tier;
  final String systemMessage;

  SubGift({
    required id,
    required badges,
    required color,
    required authorName,
    required authorId,
    required emotes,
    required message,
    required timestamp,
    required highlightType,
    required isAction,
    required isDeleted,
    required rawData,
    required this.tier,
    required this.giftedName,
    required this.systemMessage,
  }) : super(
          id: id,
          badges: badges,
          color: color,
          authorName: authorName,
          authorId: authorId,
          emotes: emotes,
          message: message,
          timestamp: timestamp,
          highlightType: highlightType,
          isAction: isAction,
          isDeleted: isDeleted,
          rawData: rawData,
        );

  factory SubGift.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
  }) {
    final Map<String, String> messageMapped = {};

    List messageSplited = message.split(';');
    messageSplited.forEach((element) {
      List elementSplited = element.split('=');
      messageMapped[elementSplited[0]] = elementSplited[1];
    });

    String color =
        ChatMessage.randomUsernameColor(messageMapped['display-name']!);

    Map<String, List<List<String>>> emotesIdsPositions =
        ChatMessage.parseEmotes(messageMapped);

    List messageList = messageSplited.last.split(':').sublist(2);
    String messageString = messageList.join(':');

    return SubGift(
      id: messageMapped['id'] as String,
      badges: ChatMessage.parseBadges(
          messageMapped['badges'].toString(), twitchBadges),
      color: color,
      authorName: messageMapped['display-name'] as String,
      authorId: messageMapped['user-id'] as String,
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.subscriptionGifted,
      isAction: false,
      isDeleted: false,
      rawData: message,
      tier: messageMapped["msg-param-sub-plan"] as String,
      giftedName: messageMapped["msg-param-recipient-display-name"] as String,
      systemMessage: messageMapped["system-msg"] as String,
    );
  }
}
