import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../emote.dart';

class FfzApi {
  static Future<List<Emote>> getEmotes(String broadcasterId) async {
    Response response;
    var dio = Dio();
    List<Emote> emotes = <Emote>[];
    try {
      response = await dio.get(
        'https://api.frankerfacez.com/v1/room/id/$broadcasterId',
      );

      response.data['sets'][response.data['sets'].keys.toList()[0]]['emoticons']
          .forEach((emote) => {
                emotes.add(
                  Emote.fromJsonFrankerfacez(emote),
                ),
              });
    } on DioException catch (e) {
      debugPrint(e.toString());
    }
    return emotes;
  }
}
