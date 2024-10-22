import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
  final String? emoteSetId;
  final String? ownerId;
  final String? color;
  final EmoteType emoteType;
  final bool isZeroWidth;

  const Emote({
    required this.id,
    required this.name,
    required this.url1x,
    required this.url2x,
    required this.url4x,
    required this.emoteSetId,
    required this.ownerId,
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
        default:
          emoteType = EmoteType.global;
          break;
      }
    }

    return Emote(
      id: map['id'] as String,
      name: map['name'] as String,
      url1x: map['images']['url_1x'] as String,
      url2x: map['images']['url_2x'] as String,
      url4x: map['images']['url_4x'] as String,
      emoteSetId: map['emote_set_id'],
      ownerId: map['owner_id'],
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
      emoteSetId: null,
      ownerId: null,
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
      emoteSetId: null,
      ownerId: null,
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
      emoteSetId: null,
      ownerId: null,
      color: null,
      emoteType: EmoteType.thirdPart,
      isZeroWidth: false,
    );
  }

  factory Emote.fromJson7Tv(Map<String, dynamic> map) {
    String url = map['data']['host']['url'];
    
    // 7TV return host url like "//cdn.7tv.app/emote/5f1e0d3f8af3612d56a8f6e2"
    // We need to remove the "//" to have a valid url
    url = url.substring(2);

    // Find in a list of files the objects with attribute format: AVIF,  If there is no AVIF format, find the first WEBP format
    List webpfNames = (map['data']['host']['files'] as List)
        .where((element) => element['format'] == "WEBP")
        .toList();

    String url1x = 'https://$url/${webpfNames[0]['name']}';
    String url2x = 'https://$url/${webpfNames[1]['name']}';
    String url4x = 'https://$url/${webpfNames[2]['name']}';

    return Emote(
      id: map["id"].toString(),
      name: map["name"],
      url1x: url1x,
      url2x: url2x,
      url4x: url4x,
      emoteSetId: null,
      ownerId: null,
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

      List<List<String>> chunks = <List<String>>[];
      for (int i = 0; i < setId.length; i += 100) {
        chunks.add(setId.sublist(i, i + 100 > setId.length ? setId.length : i + 100));
      }


      for (List<String> chunk in chunks) {
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

  // toString
  @override
  String toString() {
    return 'Emote{id: $id, name: $name, url1x: $url1x, url2x: $url2x, url4x: $url4x, color: $color, emoteType: $emoteType, isZeroWidth: $isZeroWidth}';
  }
}
