import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class Badge {
  final String setId;
  final String versionId;
  final String imageUrl1x;
  final String imageUrl2x;
  final String imageUrl4x;

  const Badge({
    required this.setId,
    required this.versionId,
    required this.imageUrl1x,
    required this.imageUrl2x,
    required this.imageUrl4x,
  });

  static Future<List<Badge>> getBadges(
    String token,
    String channelId,
    String kTwitchAuthClientId,
  ) async {
    Response response;
    var dio = Dio();
    List<Badge> badges = <Badge>[];
    try {
      dio.options.headers['Client-Id'] = kTwitchAuthClientId;
      dio.options.headers["authorization"] = "Bearer $token";
      response =
          await dio.get('https://api.twitch.tv/helix/chat/badges/global');

      // response.data['data'].forEach(
      //   (set) => set['versions'].forEach((version) =>
      //       badges.add(TwitchBadgeDTO.fromJson(set['set_id'], version))),
      // );

      response = await dio.get(
          'https://api.twitch.tv/helix/chat/badges?broadcaster_id=$channelId');

      // response.data['data'].forEach(
      //       (set) => set['versions'].forEach((version) =>
      //       badges.add(TwitchBadgeDTO.fromJson(set['set_id'], version))),
      // );
    } on DioError catch (e) {
      debugPrint(e.toString());
    }
    return badges;
  }
}
