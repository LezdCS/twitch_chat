import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/src/utils/badges_parser.dart';

import '../emote.dart';

class RewardRedemption extends ChatMessage {
  final String rewardId;

  RewardRedemption({
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
    required this.rewardId,
  });

  factory RewardRedemption.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
    required List<String> messageSplited,
  }) {
    final Map<String, String> messageMapped = {};

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

    return RewardRedemption(
      id: messageMapped['id'] as String,
      badges: parseBadges(
          messageMapped['badges'].toString(), twitchBadges),
      color: color,
      displayName: messageMapped['display-name'] as String,
      username: '',
      authorId: messageMapped['user-id'] as String,
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.channelPointRedemption,
      isAction: false,
      isSubscriber: messageMapped['subscriber'] == '1',
      isModerator: messageMapped['mod'] == '1',
      isVip: messageMapped['vip'] != null,
      isDeleted: false,
      rawData: message,
      rewardId: messageMapped['custom-reward-id'] as String,
    );
  }

  factory RewardRedemption.randomGeneration() {
    String message = "Finally got my 10000 points reward!";
    List<TwitchBadge> badges = <TwitchBadge>[
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
    return RewardRedemption(
      id: '123456789',
      badges: badges,
      color: ChatMessage.randomUsernameColor('Lezd'),
      displayName: 'Lezd',
      username: 'Lezd',
      authorId: '123456789',
      emotes: <String, List<dynamic>>{},
      message: message,
      timestamp: 123456789,
      highlightType: HighlightType.channelPointRedemption,
      isAction: false,
      isSubscriber: false,
      isModerator: false,
      isVip: false,
      isDeleted: false,
      rewardId: '123456789',
      rawData: '',
    );
  }
}
