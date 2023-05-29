import 'package:flutter/cupertino.dart';
import 'package:twitch_chat/src/badge.dart';
import 'package:twitch_chat/src/chat_message.dart';

import '../emote.dart';

class Announcement extends ChatMessage {
  final String announcementColor;

  Announcement({
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
    required this.announcementColor,
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

  factory Announcement.fromString({
    required List<Badge> badges,
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
      color =
          ChatMessage.randomUsernameColor(messageMapped['display-name']!);
    }

    Map<String, List<List<String>>> emotesIdsPositions =
    ChatMessage.parseEmotes(messageMapped);

    List messageList = messageSplited.last.split(':').sublist(2);
    String messageString = messageList.join(':');

    return Announcement(
      id: messageMapped['id'] as String,
      badges: ChatMessage.getBadges(
          messageMapped['badges'].toString(), badges),
      color: color,
      authorName: messageMapped['display-name'] as String,
      authorId: messageMapped['user-id'] as String,
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: HighlightType.announcement,
      isAction: false,
      isDeleted: false,
      announcementColor: messageMapped["msg-param-color"] as String,
    );
  }
}
