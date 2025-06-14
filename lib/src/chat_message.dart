import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/twitch_chat_parameters.dart';
import 'package:twitch_chat/src/utils/badges_parser.dart';
import 'package:uuid/uuid.dart';

import 'emote.dart';

enum HighlightType {
  firstTimeChatter,
  subscription,
  subscriptionGifted,
  bitDonation,
  incomingRaid,
  channelPointRedemption,
  announcement,
  shoutout,
  highlightedMessage,
}

class ChatMessage {
  final String id;
  final List<TwitchBadge> badges;
  final String color;
  final String displayName;
  final String username;
  final String authorId;
  final Map<String, List> emotes;
  final String message;
  final int timestamp;
  final HighlightType? highlightType;
  final bool isAction;
  final bool isSubscriber;
  final bool isModerator;
  final bool isVip;
  bool isDeleted;
  String rawData;

  ChatMessage({
    required this.id,
    required this.badges,
    required this.color,
    required this.displayName,
    required this.username,
    required this.authorId,
    required this.emotes,
    required this.message,
    required this.timestamp,
    required this.highlightType,
    required this.isAction,
    required this.isSubscriber,
    required this.isModerator,
    required this.isVip,
    required this.isDeleted,
    required this.rawData,
  });

  factory ChatMessage.fromString({
    required List<TwitchBadge> twitchBadges,
    required List<Emote> cheerEmotes,
    required List<Emote> thirdPartEmotes,
    required String message,
    required TwitchChatParameters params,
    required List<String> messageSplited,
    required Map<String, String> messageMapped,
    required String trailing,
  }) {
    List<TwitchBadge> badges = parseBadges(
      messageMapped['badges'].toString(),
      twitchBadges,
    );

    String color = messageMapped['color']!;
    if (color == "") {
      color = randomUsernameColor(messageMapped['display-name']!);
    }

    Map<String, List<List<String>>> emotesIdsPositions =
        parseEmotes(messageMapped);

    HighlightType? highlightType;
    if (params.addFirstMessages && messageMapped["first-msg"] == "1") {
      highlightType = HighlightType.firstTimeChatter;
    } else if (params.addHighlightedMessages &&
        messageMapped["msg-id"] == "highlighted-message") {
      highlightType = HighlightType.highlightedMessage;
    }

    String messageString = trailing;
    String username = messageMapped['display-name']?.toLowerCase() ?? '';

    bool isAction = messageString.startsWith("ACTION");
    if (isAction) {
      messageString = messageString
          .replaceFirst("ACTION", '')
          .replaceFirst("", '')
          .trim();
    }

    return ChatMessage(
      id: messageMapped['id'] as String,
      badges: badges,
      color: color,
      displayName: messageMapped['display-name'] as String,
      username: username,
      authorId: messageMapped['user-id'] as String,
      emotes: emotesIdsPositions,
      message: messageString,
      timestamp: int.parse(messageMapped['tmi-sent-ts'] as String),
      highlightType: highlightType,
      isAction: isAction,
      isSubscriber: messageMapped['subscriber'] == '1',
      isModerator: messageMapped['mod'] == '1',
      isVip: messageMapped['vip'] != null,
      isDeleted: false,
      rawData: message,
    );
  }

  static Map<String, List<List<String>>> parseEmotes(
    Map<String, String> messageMapped,
  ) {
    Map<String, List<List<String>>> emotesIdsPositions = {};

    List<String> tempEmoteList = [];
    //We get the emotes
    if (messageMapped['emotes'] != "") {
      //We check if there is multiple emotes
      bool multipleEmotes = messageMapped['emotes']!.contains('/');
      //If there is multiple emotes, we split them
      if (multipleEmotes) {
        tempEmoteList = messageMapped['emotes']!.split('/');
      } else {
        tempEmoteList = [messageMapped['emotes']!];
      }

      //We get the emotes positions
      for (var element in tempEmoteList) {
        List<List<String>> positions = [];
        //We check if there is multiple positions for the same emote
        bool sameEmote = element.split(':')[1].toString().contains(',');
        //If there is multiple positions for the same emote, we split them
        if (sameEmote) {
          for (String position in element.split(':')[1].split(',')) {
            positions.add(position.split('-'));
          }
        } else {
          positions = [element.split(':')[1].split('-')];
        }

        //We add the emote id and the positions to the map
        emotesIdsPositions[element.split(':')[0]] = positions;
      }
    }
    return emotesIdsPositions;
  }

  static String randomUsernameColor(String username) {
    List<List<String>> defaultColors = [
      ["Red", "#FF0000"],
      ["Blue", "#0000FF"],
      ["Green", "#00FF00"],
      ["FireBrick", "#B22222"],
      ["Coral", "#FF7F50"],
      ["YellowGreen", "#9ACD32"],
      ["OrangeRed", "#FF4500"],
      ["SeaGreen", "#2E8B57"],
      ["GoldenRod", "#DAA520"],
      ["Chocolate", "#D2691E"],
      ["CadetBlue", "#5F9EA0"],
      ["DodgerBlue", "#1E90FF"],
      ["HotPink", "#FF69B4"],
      ["BlueViolet", "#8A2BE2"],
      ["SpringGreen", "#00FF7F"]
    ];

    var n = username.codeUnitAt(0) + username.codeUnitAt(username.length - 1);
    return defaultColors[n % defaultColors.length][1];
  }

  factory ChatMessage.randomGeneration(
      HighlightType? highlightType, String? message, String? u) {
    Uuid uuid = const Uuid();
    String username = 'Lezd_';
    String color = randomUsernameColor(username);

    return ChatMessage(
      id: uuid.v4(),
      badges: [],
      color: color,
      displayName: username,
      username: username,
      authorId: uuid.v4(),
      emotes: {},
      message: 'What a nice stream!',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      highlightType: highlightType,
      isAction: false,
      isSubscriber: false,
      isModerator: false,
      isVip: false,
      isDeleted: false,
      rawData: '',
    );
  }

  // toString
  @override
  String toString() {
    return 'ChatMessage(id: $id, badges: $badges, color: $color, displayName: $displayName, username: $username, authorId: $authorId, emotes: $emotes, message: $message, timestamp: $timestamp, highlightType: $highlightType, isAction: $isAction, isSubscriber: $isSubscriber, isModerator: $isModerator, isVip: $isVip isDeleted: $isDeleted, rawData: $rawData)';
  }
}
