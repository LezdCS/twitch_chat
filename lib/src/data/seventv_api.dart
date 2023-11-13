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
        'https://7tv.io/v3/emote-sets/global',
      );

      response.data['emotes'].forEach(
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
        'https://7tv.io/v3/users/twitch/$broadcasterId',
      );
      response.data['emote_set']['emotes'].forEach(
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
