import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class TwitchBadge {
  final String setId;
  final String versionId;
  final String imageUrl1x;
  final String imageUrl2x;
  final String imageUrl4x;

  const TwitchBadge({
    required this.setId,
    required this.versionId,
    required this.imageUrl1x,
    required this.imageUrl2x,
    required this.imageUrl4x,
  });

  factory TwitchBadge.fromJson(String setId, Map<String, dynamic> map) {
    return TwitchBadge(
      setId: setId,
      versionId: map['id'] as String,
      imageUrl1x: map['image_url_1x'] as String,
      imageUrl2x: map['image_url_2x'] as String,
      imageUrl4x: map['image_url_4x'] as String,
    );
  }

  static Future<List<TwitchBadge>> getBadges(
    String token,
    String channelId,
    String kTwitchAuthClientId,
  ) async {
    Response response;
    var dio = Dio();
    List<TwitchBadge> badges = <TwitchBadge>[];
    try {
      dio.options.headers['Client-Id'] = kTwitchAuthClientId;
      dio.options.headers["authorization"] = "Bearer $token";
      response =
          await dio.get('https://api.twitch.tv/helix/chat/badges/global');

      response.data['data'].forEach(
        (set) => set['versions'].forEach((version) =>
            badges.add(TwitchBadge.fromJson(set['set_id'], version))),
      );

      response = await dio.get(
          'https://api.twitch.tv/helix/chat/badges?broadcaster_id=$channelId');

      response.data['data'].forEach(
            (set) => set['versions'].forEach((version) =>
            badges.add(TwitchBadge.fromJson(set['set_id'], version))),
      );
    } on DioError catch (e) {
      debugPrint(e.toString());
    }
    return badges;
  }
}
