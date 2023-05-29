import 'package:twitch_chat/src/badge.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/src/emote.dart';

class BitDonation extends ChatMessage {
  final int totalBits;

  BitDonation({
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
    required this.totalBits,
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
  );

  factory BitDonation.fromString({
    required List<Badge> twitchBadges,
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

    String color =
    ChatMessage.randomUsernameColor(messageMapped['display-name']!);

    Map<String, List<List<String>>> emotesIdsPositions =
    ChatMessage.parseEmotes(messageMapped);

    List messageList = messageSplited.last.split(':').sublist(2);
    String messageString = messageList.join(':');


    return BitDonation(
      id: messageMapped['id'] as String,
      badges: ChatMessage.parseBadges(
          messageMapped['badges'].toString(), twitchBadges),
      color: color,
      authorName: messageMapped['display-name'] as String,
      authorId: messageMapped['user-id'] as String,
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.bitDonation,
      isAction: false,
      isDeleted: false,
      totalBits:
      messageMapped['bits'] == null ? 0 : int.parse(messageMapped['bits']!),
    );
  }
}
