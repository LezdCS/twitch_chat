import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:twitch_chat/src/badge.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/src/data/ffz_api.dart';
import 'package:twitch_chat/src/data/seventv_api.dart';
import 'package:twitch_chat/src/data/twitch_api.dart';
import 'package:twitch_chat/src/parameters.dart';
import 'package:web_socket_channel/io.dart';

import 'chat_events/announcement.dart';
import 'chat_events/bit_donation.dart';
import 'chat_events/incoming_raid.dart';
import 'chat_events/reward_redemption.dart';
import 'chat_events/sub_gift.dart';
import 'chat_events/subscription.dart';
import 'data/bttv_api.dart';
import 'emote.dart';

class TwitchChat {
  String _channel;
  String? _channelId;
  final String _username;
  final String _token;

  String? _clientId;

  IOWebSocketChannel? _webSocketChannel;
  StreamSubscription? _streamSubscription;

  Parameters? _params;
  List<ChatMessage> _chatMessages = <ChatMessage>[];
  List<Badge> _badges = [];
  List<Emote> _emotes = [];
  List<Emote> _emotesFromSets = [];
  List<Emote> _cheerEmotes = [];
  List<Emote> _thirdPartEmotes = [];

  bool isConnected = false;

  TwitchChat(this._channel, this._username, this._token,
      {Parameters? params, String? clientId})
      : _params = params,
        _clientId = clientId;

  factory TwitchChat.anonymous(String channel) {
    return TwitchChat(channel, 'justinfan1243', '');
  }

  void changeChannel(String channel) {
    _webSocketChannel?.sink.add('PART #$_channel');
    _channel = channel;
    _webSocketChannel?.sink.add('JOIN #$channel');
    if (_clientId != null) {
      _getChannelId();
    }
  }

  void _getChannelId() {
    _badges.clear();
    _emotes.clear();
    _cheerEmotes.clear();
    _thirdPartEmotes.clear();

    TwitchApi.getTwitchUserChannelId(_username, _token, _clientId!)
        .then((value) {
      _channelId = value;
      Badge.getBadges(_token, _channelId!, _clientId!)
          .then((value) => _badges = value);
      TwitchApi.getTwitchGlobalEmotes(_token, _clientId!)
          .then((value) => _emotes = value);
      TwitchApi.getTwitchChannelEmotes(_token, _channelId!, _clientId!)
          .then((value) => _emotes = value);
      _getThirdPartEmotes().then((value) => _thirdPartEmotes = value);
      TwitchApi.getCheerEmotes(_token, _channelId!, _clientId!).then(
        (value) => _cheerEmotes = value,
      );
    });
  }

  void quit() {
    isConnected = false;
    _webSocketChannel?.sink.add('PART #$_channel');
  }

  //close websocket connection
  void close() {
    isConnected = false;
    _webSocketChannel?.sink.close();
    _streamSubscription?.cancel();
  }

  //login to twitch chat through websocket
  void connect() {
    _webSocketChannel =
        IOWebSocketChannel.connect("wss://irc-ws.chat.twitch.tv:443");

    _streamSubscription = _webSocketChannel?.stream
        .listen((data) => chatListener(data), onDone: onDone, onError: onError);

    _webSocketChannel?.sink.add('CAP REQ :twitch.tv/membership');
    _webSocketChannel?.sink.add('CAP REQ :twitch.tv/tags');
    _webSocketChannel?.sink.add('CAP REQ :twitch.tv/commands');
    _webSocketChannel?.sink.add('PASS oauth:$_token');
    _webSocketChannel?.sink.add('NICK $_username');

    _webSocketChannel?.sink.add('JOIN #$_channel');

    if (_clientId != null) {
      _getChannelId();
    }
  }

  void onDone() {
    debugPrint("done");
    isConnected = false;
  }

  void onError(Object o, StackTrace s) {
    isConnected = false;
    debugPrint(o.toString());
    debugPrint(s.toString());
  }

  void chatListener(String message) {
    debugPrint("Twitch Chat: $message");

    if (message.startsWith('PING ')) {
      _webSocketChannel?.sink.add("PONG :tmi.twitch.tv\r\n");
    }

    if (message.startsWith('@')) {
      List messageSplited = message.split(';');
      List<String> keys = [
        "PRIVMSG",
        "CLEARCHAT",
        "CLEARMSG",
        "USERNOTICE",
        "NOTICE",
        "ROOMSTATE"
      ];
      String? keyResult =
          keys.firstWhereOrNull((key) => messageSplited.last.contains(key));

      final Map<String, String> messageMapped = {};
      for (var element in messageSplited) {
        List elementSplited = element.split('=');
        messageMapped[elementSplited[0]] = elementSplited[1];
      }

      if (keyResult != null) {
        switch (keyResult) {
          case "PRIVMSG":
            {
              if (messageMapped['bits'] != null) {
                if (_params?.addBitsDonations != null &&
                    !_params!.addBitsDonations!) {
                  return;
                }
                BitDonation bitDonation = BitDonation.fromString(
                  twitchBadges: _badges,
                  cheerEmotes: _cheerEmotes,
                  thirdPartEmotes: _thirdPartEmotes,
                  message: message,
                );
                _chatMessages.add(bitDonation);
                break;
              }
              if (messageMapped["custom-reward-id"] != null) {
                if (_params?.addRewardsRedemptions != null &&
                    !_params!.addRewardsRedemptions!) {
                  return;
                }
                RewardRedemption rewardRedemption = RewardRedemption.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                );
                _chatMessages.add(rewardRedemption);
                break;
              }
              ChatMessage chatMessage = ChatMessage.fromString(
                twitchBadges: _badges,
                thirdPartEmotes: _thirdPartEmotes,
                cheerEmotes: _cheerEmotes,
                message: message,
              );
              _chatMessages.add(chatMessage);
            }
            break;
          case 'ROOMSTATE':
            debugPrint("Twitch Chat: Connected to $_channel");
            isConnected = true;
            break;
          case "CLEARCHAT":
            {
              if (messageMapped['target-user-id'] != null) {
                // @ban-duration=43;room-id=169185650;target-user-id=107285371;tmi-sent-ts=1642601142470 :tmi.twitch.tv CLEARCHAT #robcdee :lezd_
                String userId = messageMapped['target-user-id']!;
                for (var message in _chatMessages) {
                  if (message.authorId == userId) {
                    message.isDeleted = true;
                  }
                }
              } else {
                //@room-id=107285371;tmi-sent-ts=1642256684032 :tmi.twitch.tv CLEARCHAT #lezd_
                _chatMessages.clear();
              }
            }
            break;
          case "CLEARMSG":
            {
              //clear a specific msg by the id
              // @login=lezd_;room-id=;target-msg-id=5ecb6458-198c-498c-b91b-16f1e12f58b4;tmi-sent-ts=1640717427981
              // :tmi.twitch.tv CLEARMSG #lezd_ :okokok

              _chatMessages
                  .firstWhereOrNull((message) =>
                      message.id == messageMapped['target-msg-id'])!
                  .isDeleted = true;
            }
            break;
          case "NOTICE":
            {
              //error and success messages are send by notice
              //https://dev.twitch.tv/docs/irc/msg-id
            }
            break;
          case "USERNOTICE":
            final Map<String, String> messageMapped = {};
            //We split the message by ';' to get the different parts
            List messageSplited = message.split(';');
            //We split each part by '=' to get the key and the value
            for (var element in messageSplited) {
              List elementSplited = element.split('=');
              messageMapped[elementSplited[0]] = elementSplited[1];
            }

            String messageId = messageMapped['msg-id']!;
            switch (messageId) {
              case "announcement":
                if (_params?.addAnnouncements != null &&
                    !_params!.addAnnouncements!) {
                  return;
                }
                Announcement announcement = Announcement.fromString(
                  badges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                );
                _chatMessages.add(announcement);
                break;
              case "sub":
                if (_params?.addSubscriptions != null &&
                    !_params!.addSubscriptions!) {
                  return;
                }
                Subscription subMessage = Subscription.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                );
                _chatMessages.add(subMessage);
                break;
              case "resub":
                if (_params?.addSubscriptions != null &&
                    !_params!.addSubscriptions!) {
                  return;
                }
                Subscription subMessage = Subscription.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                );
                _chatMessages.add(subMessage);
                break;
              case "subgift":
                if (_params?.addSubscriptions != null &&
                    !_params!.addSubscriptions!) {
                  return;
                }
                SubGift subGift = SubGift.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                );
                _chatMessages.add(subGift);
                break;
              case "raid":
                if (_params?.addRaids != null && !_params!.addRaids!) {
                  return;
                }
                IncomingRaid raid = IncomingRaid.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                );
                _chatMessages.add(raid);
                break;
              default:
                break;
            }
        }
      }
    } else if (message.toString().contains("GLOBALUSERSTATE")) {
      final Map<String, String> messageMapped = {};
      List messageSplited = message.split(';');
      for (var element in messageSplited) {
        List elementSplited = element.split('=');
        messageMapped[elementSplited[0]] = elementSplited[1];
      }
      List<String> emoteSetsIds = messageMapped["emote-sets"]!.split(',');
      if (_clientId != null) {
        Emote.getTwitchSetsEmotes(_token, emoteSetsIds, _clientId!)
            .then((value) {
          for (var emote in value) {
            _emotesFromSets.add(emote);
          }
        });
      }
    }
  }

  Future<List<Emote>> _getThirdPartEmotes() async {
    List<Emote> emotes = [];

    await BttvApi.getGlobalEmotes().then((value) => {emotes.addAll(value)});

    await BttvApi.getChannelEmotes(_channelId!)
        .then((value) => {emotes.addAll(value)});

    await FfzApi.getEmotes(_channelId!).then((value) => {emotes.addAll(value)});

    await SeventvApi.getChannelEmotes(_channelId!)
        .then((value) => {emotes.addAll(value)});

    await SeventvApi.getGlobalEmotes().then((value) => {emotes.addAll(value)});

    return emotes;
  }
}
