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

  factory Emote.fromJsonCheerEmotes(Map<String, dynamic> map, String prefix) {
    return Emote(
      id: map["id"],
      name: prefix + map["id"],
      url1x: map['images']['dark']['animated']["1"] as String,
      url2x: map['images']['dark']['animated']["2"] as String,
      url4x: map['images']['dark']['animated']["4"] as String,
      color: map["color"] as String,
      emoteType: EmoteType.cheer,
      isZeroWidth: false,
    );
  }

  factory Emote.fromJsonFrankerfacez(Map<String, dynamic> map) {
    return Emote(
      id: map["id"].toString(),
      name: map["name"],
      url1x: map['urls']['1'],
      url2x: map['urls']['2'] ?? "",
      url4x: map['urls']['4'] ?? "",
      color: null,
      emoteType: EmoteType.thirdPart,
      isZeroWidth: false,
    );
  }

  factory Emote.fromJsonBttv(Map<String, dynamic> map) {
    return Emote(
      id: map["id"],
      name: map["code"],
      url1x: "https://cdn.betterttv.net/emote/${map['id']}/1x",
      url2x: "https://cdn.betterttv.net/emote/${map['id']}/2x",
      url4x: "https://cdn.betterttv.net/emote/${map['id']}/3x",
      color: null,
      emoteType: EmoteType.thirdPart,
      isZeroWidth: false,
    );
  }

  factory Emote.fromJson7Tv(Map<String, dynamic> map) {
    String url = map['data']['host']['url'];
    // Find in a list of files the objects with attribute format: AVIF,  If there is no AVIF format, find the first WEBP format
    List avifNames = (map['data']['host']['files'] as List)
        .where((element) => element['format'] == "AVIF")
        .toList();

    String url1x = url +
        (avifNames.isNotEmpty
            ? avifNames[0]['name']
            : map['data']['host']['files'][0]['name']);

    String url2x = url +
        (avifNames.length > 1
            ? avifNames[1]['name']
            : map['data']['host']['files'][1]['name']);

    String url4x = url +
        (avifNames.length > 2
            ? avifNames[2]['name']
            : map['data']['host']['files'][2]['name']);

    return Emote(
      id: map["id"].toString(),
      name: map["name"],
      url1x: url1x,
      url2x: url2x,
      url4x: url4x,
      color: null,
      emoteType: EmoteType.thirdPart,
      isZeroWidth: false,
          // map['visibility_simple']?.contains("ZERO_WIDTH") ? true : false,
    );
  }

  static Future<List<Emote>> getTwitchSetsEmotes(
    String token,
    List<String> setId,
    String clientId,
  ) async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];

    try {
      dio.options.headers['Client-Id'] = clientId;
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
    } on DioException catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }
}
