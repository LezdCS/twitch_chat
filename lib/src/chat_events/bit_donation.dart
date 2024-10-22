import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/src/emote.dart';
import 'package:twitch_chat/src/utils/badges_parser.dart';

class BitDonation extends ChatMessage {
  final int totalBits;

  BitDonation({
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
    required this.totalBits,
  });

  factory BitDonation.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
    required List<String> messageSplited,
    required Map<String, String> messageMapped,
  }) {

    String color =
        ChatMessage.randomUsernameColor(messageMapped['display-name']!);

    Map<String, List<List<String>>> emotesIdsPositions =
        ChatMessage.parseEmotes(messageMapped);

    List messageList = messageSplited.last.split(':').sublist(2);
    String messageString = messageList.join(':');

    return BitDonation(
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
      highlightType: HighlightType.bitDonation,
      isAction: false,
      isSubscriber: messageMapped['subscriber'] == '1',
      isModerator: messageMapped['mod'] == '1',
      isVip: messageMapped['vip'] != null,
      isDeleted: false,
      rawData: message,
      totalBits:
          messageMapped['bits'] == null ? 0 : int.parse(messageMapped['bits']!),
    );
  }

  factory BitDonation.randomGeneration() {
    String message = "Here for you :)";
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
    return BitDonation(
      id: '123456789',
      badges: badges,
      color: ChatMessage.randomUsernameColor('Lezd'),
      displayName: 'Lezd',
      username: 'Lezd',
      authorId: '123456789',
      emotes: <String, List<dynamic>>{},
      message: message,
      timestamp: 123456789,
      highlightType: HighlightType.bitDonation,
      isAction: false,
      isSubscriber: false,
      isModerator: false,
      isVip: false,
      isDeleted: false,
      totalBits: 400,
      rawData: '',
    );
  }
}
