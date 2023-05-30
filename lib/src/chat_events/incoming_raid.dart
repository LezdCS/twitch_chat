import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/emote.dart';
import '../chat_message.dart';

class IncomingRaid extends ChatMessage {
  final int viewerCount;
  final String raidingChannelName;

  IncomingRaid({
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
    required this.viewerCount,
    required this.raidingChannelName,
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

  factory IncomingRaid.fromString({
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

    return IncomingRaid(
      id: messageMapped['id'] as String,
      badges: <TwitchBadge>[],
      color: "",
      authorName: messageMapped['display-name'] as String,
      authorId: messageMapped['user-id'] as String,
      emotes: <String, List<dynamic>>{},
      message: "",
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.incomingRaid,
      isAction: false,
      isDeleted: false,
      rawData: message,
      viewerCount: int.parse(messageMapped['msg-param-viewerCount'] as String),
      raidingChannelName: messageMapped['msg-param-displayName'] as String,
    );
  }

  factory IncomingRaid.randomGeneration() {
    return IncomingRaid(
      id: '123456789',
      badges: <TwitchBadge>[],
      color: ChatMessage.randomUsernameColor('Lezd'),
      authorName: 'Lezd',
      authorId: '123456789',
      emotes: <String, List<dynamic>>{},
      message: '',
      timestamp: 123456789,
      highlightType: HighlightType.incomingRaid,
      isAction: false,
      isDeleted: false,
      viewerCount: 123,
      raidingChannelName: 'Lezd_',
      rawData: '',
    );
  }
}
