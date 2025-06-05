import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/src/utils/badges_parser.dart';

import '../emote.dart';

class SubGift extends ChatMessage {
  final String giftedName;
  final String tier;
  final String systemMessage;

  SubGift({
    required super.id,
    required super.badges,
    required super.color,
    required super.displayName,
    required super.username,
    required super.authorId,
    required super.emotes,
    required super.message,
    required super.timestamp,
    required super.highlightType,
    required super.isAction,
    required super.isSubscriber,
    required super.isModerator,
    required super.isVip,
    required super.isDeleted,
    required super.rawData,
    required this.tier,
    required this.giftedName,
    required this.systemMessage,
  });

  factory SubGift.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
    required List<String> messageSplited,
    required Map<String, String> messageMapped,
    required String trailing,
  }) {
    String color =
        ChatMessage.randomUsernameColor(messageMapped['display-name']!);

    Map<String, List<List<String>>> emotesIdsPositions =
        ChatMessage.parseEmotes(messageMapped);

    String messageString;
    messageString = trailing;

    return SubGift(
      id: messageMapped['id'] as String,
      badges: parseBadges(
        messageMapped['badges'].toString(),
        twitchBadges,
      ),
      color: color,
      displayName: messageMapped['display-name'] as String,
      username: '',
      authorId: messageMapped['user-id'] as String,
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.subscriptionGifted,
      isAction: false,
      isSubscriber: messageMapped['subscriber'] == '1',
      isModerator: messageMapped['mod'] == '1',
      isVip: messageMapped['vip'] != null,
      isDeleted: false,
      rawData: message,
      tier: messageMapped["msg-param-sub-plan"] as String,
      giftedName: messageMapped["msg-param-recipient-display-name"] as String,
      systemMessage: messageMapped["system-msg"] as String,
    );
  }
}
