import 'package:collection/collection.dart';
import 'package:twitch_chat/twitch_chat.dart';

List<TwitchBadge> parseBadges(
    String badgesString,
    List<TwitchBadge> twitchBadges,
  ) {
    List<TwitchBadge> badges = <TwitchBadge>[];
    List badgesSplited = badgesString.split(',');
    if (badgesSplited.isNotEmpty) {
      for (var i in badgesSplited) {
        TwitchBadge? badgeFound = twitchBadges.firstWhereOrNull((badge) =>
            badge.setId == i.split('/')[0] &&
            badge.versionId == i.split('/')[1]);
        if (badgeFound != null) {
          badges.add(badgeFound);
        }
      }
    }
    return badges;
  }