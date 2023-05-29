import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../emote.dart';

class TwitchApi {

  static Future<List<Emote>> getTwitchGlobalEmotes(String token, String clientId) async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];
    try {
      dio.options.headers['Client-Id'] = clientId;
      dio.options.headers["authorization"] = "Bearer $token";
      response =
      await dio.get('https://api.twitch.tv/helix/chat/emotes/global');

      response.data['data'].forEach(
            (emote) => emotes.add(
          Emote.fromJson(emote),
        ),
      );

    } on DioError catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }

  static Future<List<Emote>> getTwitchChannelEmotes(
      String accessToken,
      String broadcasterId,
      String clientId,
      ) async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];
    try {
      dio.options.headers['Client-Id'] = clientId;
      dio.options.headers["authorization"] = "Bearer $accessToken";
      response = await dio.get(
        'https://api.twitch.tv/helix/chat/emotes',
        queryParameters: {'broadcaster_id': broadcasterId},
      );

      response.data['data'].forEach(
            (emote) => emotes.add(
          Emote.fromJson(emote),
        ),
      );

    } on DioError catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }

  static Future<List<Emote>> getCheerEmotes(
      String token,
      String broadcasterId,
      String clientId,
      ) async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];
    try {
      dio.options.headers['Client-Id'] = clientId;
      dio.options.headers["authorization"] = "Bearer $token";
      response = await dio.get(
        'https://api.twitch.tv/helix/bits/cheermotes',
        queryParameters: {'broadcaster_id': broadcasterId},
      );

      response.data['data'].forEach(
            (prefix) => prefix['tiers'].forEach(
              (emote) => emotes.add(
            Emote.fromJsonCheerEmotes(emote, prefix['prefix']),
          ),
        ),
      );
    } on DioError catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }

  static Future<String?> getTwitchUserChannelId(
      String username,
      String token,
      String clientId,
      ) async {
    Response response;
    var dio = Dio();
    String? userChannelId;
    try {
      dio.options.headers['Client-Id'] = clientId;
      dio.options.headers["authorization"] = "Bearer $token";

      response = await dio.get(
        'https://api.twitch.tv/helix/users',
        queryParameters: {'login': username},
      );

      userChannelId = response.data['data'][0]['id'];
    } on DioError catch (e) {
      debugPrint(e.toString());
    }

    return userChannelId;
  }

}
