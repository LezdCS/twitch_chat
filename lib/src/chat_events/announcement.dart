import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';

import '../emote.dart';
import '../utils/split_function.dart';

class Announcement extends ChatMessage {
  final String announcementColor;

  Announcement({
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
    required isDeleted,
    required rawData,
    required this.announcementColor,
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
          isDeleted: isDeleted,
          rawData: rawData,
        );

  factory Announcement.fromString({
    required List<TwitchBadge> badges,
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

    return Announcement(
      id: messageMapped['id'] as String,
      badges:
          ChatMessage.parseBadges(messageMapped['badges'].toString(), badges),
      color: color,
      displayName: messageMapped['display-name'] as String,
      authorId: messageMapped['user-id'] as String,
      username: '',
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.announcement,
      isAction: false,
      isDeleted: false,
      rawData: message,
      announcementColor: messageMapped["msg-param-color"] as String,
    );
  }

  factory Announcement.randomGeneration() {
    String message = "This is an important announcement!";
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
    return Announcement(
      id: '123456789',
      badges: badges,
      color: ChatMessage.randomUsernameColor('Lezd'),
      displayName: 'Lezd',
      username: 'Lezd',
      authorId: '123456789',
      emotes: <String, List<dynamic>>{},
      message: message,
      timestamp: 123456789,
      highlightType: HighlightType.announcement,
      isAction: false,
      isDeleted: false,
      announcementColor: '#000000',
      rawData: '',
    );
  }
}
