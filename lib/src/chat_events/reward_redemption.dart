import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';

import '../emote.dart';
import '../utils/split_function.dart';

class RewardRedemption extends ChatMessage {
  final String rewardId;

  RewardRedemption({
    required id,
    required badges,
    required color,
    required displayName,
    required username,
    required authorId,
    required emotes,
    required message,
    required timestamp,
    required highlightType,
    required isAction,
    required isSubscriber,
    required isModerator,
    required isVip,
    required isDeleted,
    required rawData,
    required this.rewardId,
  }) : super(
          id: id,
          badges: badges,
          color: color,
          displayName: displayName,
          username: username,
          authorId: authorId,
          emotes: emotes,
          message: message,
          timestamp: timestamp,
          highlightType: highlightType,
          isAction: isAction,
          isSubscriber: isSubscriber,
          isModerator: isModerator,
          isVip: isVip,
          isDeleted: isDeleted,
          rawData: rawData,
        );

  factory RewardRedemption.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
  }) {
    final Map<String, String> messageMapped = {};

    List messageSplited = parseMessage(message);
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
      badges: ChatMessage.parseBadges(
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
