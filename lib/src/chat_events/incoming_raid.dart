import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/emote.dart';
import '../chat_message.dart';

class IncomingRaid extends ChatMessage {
  final int viewerCount;
  final String raidingChannelName;

  IncomingRaid({
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
    required this.viewerCount,
    required this.raidingChannelName,
  });

  factory IncomingRaid.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
    required List<String> messageSplited,
    required Map<String, String> messageMapped,
  }) {

    return IncomingRaid(
      id: messageMapped['id'] as String,
      badges: <TwitchBadge>[],
      color: "",
      displayName: messageMapped['display-name'] as String,
      username: '',
      authorId: messageMapped['user-id'] as String,
      emotes: <String, List<dynamic>>{},
      message: "",
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.incomingRaid,
      isAction: false,
      isSubscriber: messageMapped['subscriber'] == '1',
      isModerator: messageMapped['mod'] == '1',
      isVip: messageMapped['vip'] != null,
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
      displayName: 'Lezd',
      username: 'Lezd',
      authorId: '123456789',
      emotes: <String, List<dynamic>>{},
      message: '',
      timestamp: 123456789,
      highlightType: HighlightType.incomingRaid,
      isAction: false,
      isSubscriber: false,
      isModerator: false,
      isVip: false,
      isDeleted: false,
      viewerCount: 123,
      raidingChannelName: 'Lezd_',
      rawData: '',
    );
  }
}
