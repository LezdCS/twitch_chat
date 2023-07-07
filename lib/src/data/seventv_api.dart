import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../emote.dart';

class SeventvApi {
  static Future<List<Emote>> getGlobalEmotes() async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];
    try {
      response = await dio.get(
        'https://api.7tv.app/v2/emotes/global',
      );

      response.data.forEach(
        (emote) => emotes.add(
          Emote.fromJson7Tv(emote),
        ),
      );
    } on DioException catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }

  static Future<List<Emote>> getChannelEmotes(String broadcasterId) async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];
    try {
      response = await dio.get(
        'https://api.7tv.app/v2/users/$broadcasterId/emotes',
      );

      response.data.forEach(
        (emote) => emotes.add(
          Emote.fromJson7Tv(emote),
        ),
      );
    } on DioException catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }
}
