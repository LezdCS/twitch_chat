import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:quiver/iterables.dart';

enum EmoteType {
  global,
  follower,
  subscriptions,
  bitsTier,
  thirdPart,
  cheer,
}

class Emote {
  final String id;
  final String name;
  final String url1x;
  final String url2x;
  final String url4x;
  final String? color;
  final EmoteType emoteType;
  final bool isZeroWidth;

  const Emote({
    required this.id,
    required this.name,
    required this.url1x,
    required this.url2x,
    required this.url4x,
    required this.color,
    required this.emoteType,
    required this.isZeroWidth,
  });

  factory Emote.fromJson(Map<String, dynamic> map) {
    EmoteType emoteType = EmoteType.global;
    if (map['emote_type'] != null) {
      switch (map['emote_type']) {
        case "subscriptions":
          emoteType = EmoteType.subscriptions;
          break;
        case "follower":
          emoteType = EmoteType.follower;
          break;
        case "bitstier":
          emoteType = EmoteType.bitsTier;
          break;
      }
    }

    return Emote(
      id: map['id'] as String,
      name: map['name'] as String,
      url1x: map['images']['url_1x'] as String,
      url2x: map['images']['url_2x'] as String,
      url4x: map['images']['url_4x'] as String,
      color: null,
      emoteType: emoteType,
      isZeroWidth: false,
    );
  }

  static Future<List<Emote>> getTwitchSetsEmotes(
    String token,
    List<String> setId,
    String kTwitchAuthClientId,
  ) async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];

    try {
      dio.options.headers['Client-Id'] = kTwitchAuthClientId;
      dio.options.headers["authorization"] = "Bearer $token";

      var chunks = partition(setId, 25);

      for (var chunk in chunks) {
        await Future.delayed(const Duration(seconds: 5), () async {
          response = await dio.get(
            "https://api.twitch.tv/helix/chat/emotes/set",
            queryParameters: {'emote_set_id': chunk},
          );
          response.data['data'].forEach(
            (emote) => emotes.add(
              Emote.fromJson(emote),
            ),
          );
        });
      }
    } on DioError catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }
}
