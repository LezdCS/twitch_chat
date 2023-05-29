import 'package:twitch_chat/src/badge.dart';
import 'package:collection/collection.dart';

enum HighlightType {
  firstTimeChatter,
  subscription,
  subscriptionGifted,
  bitDonation,
  incomingRaid,
  channelPointRedemption,
  announcement,
  shoutout,
}

class ChatMessage {
  final String id;
  final List<Badge> badges;
  final String color;
  final String authorName;
  final String authorId;
  final Map<String, List> emotes;
  final String message;
  final int timestamp;
  final HighlightType? highlightType;
  final bool isAction;
  bool isDeleted;

  ChatMessage({
    required this.id,
    required this.badges,
    required this.color,
    required this.authorName,
    required this.authorId,
    required this.emotes,
    required this.message,
    required this.timestamp,
    required this.highlightType,
    required this.isAction,
    required this.isDeleted,
  });

  static Map<String, List<List<String>>> parseEmotes(
      Map<String, String> messageMapped) {
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

  static List<Badge> getBadges(
      String badgesString, List<Badge> twitchBadges) {
    List<Badge> badges = <Badge>[];
    List badgesSplited = badgesString.split(',');
    if (badgesSplited.isNotEmpty) {
      for (var i in badgesSplited) {
        Badge? badgeFound = twitchBadges.firstWhereOrNull((badge) =>
        badge.setId == i.split('/')[0] &&
            badge.versionId == i.split('/')[1]);
        if (badgeFound != null) {
          badges.add(badgeFound);
        }
      }
    }
    return badges;
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
}