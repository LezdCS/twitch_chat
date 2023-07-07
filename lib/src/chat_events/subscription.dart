import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';

import '../emote.dart';

class Subscription extends ChatMessage {
  final String months;
  final String tier;
  final bool isGift;

  Subscription({
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
    required this.months,
    required this.isGift,
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

  factory Subscription.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
  }) {
    final Map<String, String> messageMapped = {};

    List messageSplited = message.split(';');
    for (var element in messageSplited) {
      List elementSplited = element.split('=');
      messageMapped[elementSplited[0]] = elementSplited[1];
    }

    String color = messageMapped['color']!;
    if (color == "") {
      color = ChatMessage.randomUsernameColor(messageMapped['display-name']!);
    }

    Map<String, List<List<String>>> emotesIdsPositions =
        ChatMessage.parseEmotes(messageMapped);

    List messageList = messageSplited.last.split(':').sublist(2);
    String messageString = messageList.join(':');

    return Subscription(
      id: messageMapped['id'] as String,
      badges: ChatMessage.parseBadges(
          messageMapped['badges'].toString(), twitchBadges),
      color: color,
      authorName: messageMapped['display-name'] as String,
      authorId: messageMapped['user-id'] as String,
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.subscription,
      isAction: false,
      isDeleted: false,
      rawData: message,
      tier: messageMapped["msg-param-sub-plan"] as String,
      months: messageMapped["msg-param-cumulative-months"] as String,
      isGift: messageMapped["msg-param-was-gifted"] == "true",
    );
  }

  factory Subscription.randomGeneration() {
    String message = "4 months already eheh";
    List badges = <TwitchBadge>[
      const TwitchBadge(
        setId: 'sub-gifter',
        versionId: '1',
        imageUrl1x:
            'https://static-cdn.jtvnw.net/badges/v1/a5ef6c17-2e5b-4d8f-9b80-2779fd722414/1',
        imageUrl2x:
            'https://static-cdn.jtvnw.net/badges/v1/a5ef6c17-2e5b-4d8f-9b80-2779fd722414/2',
        imageUrl4x:
            'https://static-cdn.jtvnw.net/badges/v1/a5ef6c17-2e5b-4d8f-9b80-2779fd722414/3',
      ),
    ];
    return Subscription(
      id: '123456789',
      badges: badges,
      color: ChatMessage.randomUsernameColor('Lezd'),
      authorName: 'Lezd',
      authorId: '123456789',
      emotes: <String, List<dynamic>>{},
      message: message,
      timestamp: 123456789,
      highlightType: HighlightType.subscription,
      isAction: false,
      isDeleted: false,
      tier: '1000',
      months: '4',
      isGift: false,
      rawData: '',
    );
  }
}
