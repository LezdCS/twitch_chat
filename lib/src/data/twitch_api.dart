import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../emote.dart';

class TwitchApi {
  static Future<List<Emote>> getTwitchGlobalEmotes(
      String token, String clientId) async {
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
    } on DioException catch (e) {
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
    } on DioException catch (e) {
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
    } on DioException catch (e) {
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
    } on DioException catch (e) {
      debugPrint(e.toString());
    }

    return userChannelId;
  }

  static Future<void> deleteMessage(
    String token,
    String channelId,
    String messageId,
    String clientId,
  ) async {
    var dio = Dio();
    try {
      dio.options.headers['Client-Id'] = clientId;
      dio.options.headers["authorization"] = "Bearer $token";
      await dio.delete(
        'https://api.twitch.tv/helix/moderation/chat',
        queryParameters: {
          'broadcaster_id': channelId,
          'moderator_id': channelId,
          'message_id': messageId,
        },
      );
    } on DioException catch (e) {
      debugPrint(e.response.toString());
    }
  }

  static Future<void> banUser(
    String token,
    String broadcasterId,
    String authorId,
    int? duration,
    String clientId,
  ) async {
    var dio = Dio();
    try {
      dio.options.headers['Client-Id'] = clientId;
      dio.options.headers["authorization"] = "Bearer $token";
      Map body = {
        "data": {
          "user_id": authorId,
        },
      };
      if (duration != null) {
        body['data']['duration'] = duration.toString();
      }

      await dio.post(
        'https://api.twitch.tv/helix/moderation/bans',
        queryParameters: {
          'broadcaster_id': broadcasterId,
          'moderator_id': broadcasterId,
        },
        data: jsonEncode(body),
      );
    } on DioException catch (e) {
      debugPrint(e.response.toString());
    }
  }
}
