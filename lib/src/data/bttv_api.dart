import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../emote.dart';

class BttvApi {
  static Future<List<Emote>> getGlobalEmotes() async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];
    try {
      response = await dio.get(
        'https://api.betterttv.net/3/cached/emotes/global',
      );

      response.data.forEach(
        (emote) => emotes.add(
          Emote.fromJsonBttv(emote),
        ),
      );
    } on DioError catch (e) {
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
        'https://api.betterttv.net/3/cached/users/twitch/$broadcasterId',
      );

      response.data['channelEmotes'].forEach(
        (emote) => emotes.add(
          Emote.fromJsonBttv(emote),
        ),
      );

      response.data['sharedEmotes'].forEach(
        (emote) => emotes.add(
          Emote.fromJsonBttv(emote),
        ),
      );
    } on DioError catch (e) {
      debugPrint(e.toString());
    }

    return emotes;
  }
}
