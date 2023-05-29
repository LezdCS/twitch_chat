import 'dart:async';

import 'package:collection/collection.dart';
import 'package:twitch_chat/src/badge.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/src/parameters.dart';
import 'package:web_socket_channel/io.dart';

import 'chat_events/announcement.dart';
import 'chat_events/bit_donation.dart';
import 'chat_events/incoming_raid.dart';
import 'chat_events/reward_redemption.dart';
import 'chat_events/sub_gift.dart';
import 'chat_events/subscription.dart';
import 'emote.dart';

class TwitchChat {
  String _channel;
  String? _channelId;
  final String _username;
  final String _token;

  IOWebSocketChannel? webSocketChannel;
  StreamSubscription? streamSubscription;

  Parameters? params;
  List<ChatMessage> chatMessages = <ChatMessage>[];
  List<Badge> badges = [];
  List<Emote> emotes = [];
  List<Emote> emotesFromSets = [];
  List<Emote> cheerEmotes = [];
  List<Emote> thirdPartEmotes = [];

  TwitchChat(this._channel, this._username, this._token, {this.params});

  IOWebSocketChannel get webSocket => webSocketChannel!;

  StreamSubscription get stream => streamSubscription!;

  void changeChannel(String channel) {
    webSocketChannel?.sink.add('PART #$_channel');
    _channel = channel;
    webSocketChannel?.sink.add('JOIN #$channel');
    getChannelId();
  }

  void getChannelId() {
    badges.clear();
    emotes.clear();
    cheerEmotes.clear();
    thirdPartEmotes.clear();
    //TODO call twitch API to get channelId
    Badge.getBadges(_token, _channelId!, '').then((value) => badges = value);
    // Emote.getTwitchEmotes().then((value) => twitchEmotes = value);
    // Emote.getThirdPartEmotes().then((value) => thirdPartEmotes = value);
    // Emote.getTwitchCheerEmotes().then((value) => cheerEmotes = value);
  }

  //close websocket connection
  void close() {
    webSocketChannel?.sink.close();
    streamSubscription?.cancel();
  }

  //login to twitch chat through websocket
  void login() {
    webSocketChannel =
        IOWebSocketChannel.connect("wss://irc-ws.chat.twitch.tv:443");

    streamSubscription = webSocketChannel?.stream
        .listen((data) => chatListener(data), onDone: onDone, onError: onError);

    webSocketChannel?.sink.add('CAP REQ :twitch.tv/membership');
    webSocketChannel?.sink.add('CAP REQ :twitch.tv/tags');
    webSocketChannel?.sink.add('CAP REQ :twitch.tv/commands');
    webSocketChannel?.sink.add('PASS oauth:$_token');
    webSocketChannel?.sink.add('NICK $_username');

    webSocketChannel?.sink.add('JOIN #$_channel');

    getChannelId();
  }

  void onDone() {}

  void onError(Object o, StackTrace s) {}

  void chatListener(String message) {
    if (message.startsWith('PING ')) {
      webSocketChannel?.sink.add("PONG :tmi.twitch.tv\r\n");
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
                if (params?.addBitsDonations != null &&
                    !params!.addBitsDonations!) {
                  return;
                }
                BitDonation bitDonation = BitDonation.fromString(
                  twitchBadges: badges,
                  cheerEmotes: cheerEmotes,
                  thirdPartEmotes: thirdPartEmotes,
                  message: message,
                );
                chatMessages.add(bitDonation);
                break;
              }
              if (messageMapped["custom-reward-id"] != null) {
                if (params?.addRewardsRedemptions != null &&
                    !params!.addRewardsRedemptions!) {
                  return;
                }
                RewardRedemption rewardRedemption = RewardRedemption.fromString(
                  twitchBadges: badges,
                  thirdPartEmotes: thirdPartEmotes,
                  cheerEmotes: cheerEmotes,
                  message: message,
                );
                chatMessages.add(rewardRedemption);
                break;
              }
              ChatMessage chatMessage = ChatMessage.fromString(
                twitchBadges: badges,
                thirdPartEmotes: thirdPartEmotes,
                cheerEmotes: cheerEmotes,
                message: message,
              );
              chatMessages.add(chatMessage);
            }
            break;
          case 'ROOMSTATE':
            break;
          case "CLEARCHAT":
            {
              if (messageMapped['target-user-id'] != null) {
                // @ban-duration=43;room-id=169185650;target-user-id=107285371;tmi-sent-ts=1642601142470 :tmi.twitch.tv CLEARCHAT #robcdee :lezd_
                String userId = messageMapped['target-user-id']!;
                for (var message in chatMessages) {
                  if (message.authorId == userId) {
                    message.isDeleted = true;
                  }
                }
              } else {
                //@room-id=107285371;tmi-sent-ts=1642256684032 :tmi.twitch.tv CLEARCHAT #lezd_
                chatMessages.clear();
              }
            }
            break;
          case "CLEARMSG":
            {
              //clear a specific msg by the id
              // @login=lezd_;room-id=;target-msg-id=5ecb6458-198c-498c-b91b-16f1e12f58b4;tmi-sent-ts=1640717427981
              // :tmi.twitch.tv CLEARMSG #lezd_ :okokok

              chatMessages
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
                if (params?.addAnnouncements != null &&
                    !params!.addAnnouncements!) {
                  return;
                }
                Announcement announcement = Announcement.fromString(
                  badges: badges,
                  thirdPartEmotes: thirdPartEmotes,
                  cheerEmotes: cheerEmotes,
                  message: message,
                );
                chatMessages.add(announcement);
                break;
              case "sub":
                if (params?.addSubscriptions != null &&
                    !params!.addSubscriptions!) {
                  return;
                }
                Subscription subMessage = Subscription.fromString(
                  twitchBadges: badges,
                  thirdPartEmotes: thirdPartEmotes,
                  cheerEmotes: cheerEmotes,
                  message: message,
                );
                chatMessages.add(subMessage);
                break;
              case "resub":
                if (params?.addSubscriptions != null &&
                    !params!.addSubscriptions!) {
                  return;
                }
                Subscription subMessage = Subscription.fromString(
                  twitchBadges: badges,
                  thirdPartEmotes: thirdPartEmotes,
                  cheerEmotes: cheerEmotes,
                  message: message,
                );
                chatMessages.add(subMessage);
                break;
              case "subgift":
                if (params?.addSubscriptions != null &&
                    !params!.addSubscriptions!) {
                  return;
                }
                SubGift subGift = SubGift.fromString(
                  twitchBadges: badges,
                  thirdPartEmotes: thirdPartEmotes,
                  cheerEmotes: cheerEmotes,
                  message: message,
                );
                chatMessages.add(subGift);
                break;
              case "raid":
                if (params?.addRaids != null && !params!.addRaids!) {
                  return;
                }
                IncomingRaid raid = IncomingRaid.fromString(
                  twitchBadges: badges,
                  thirdPartEmotes: thirdPartEmotes,
                  cheerEmotes: cheerEmotes,
                  message: message,
                );
                chatMessages.add(raid);
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
      Emote.getTwitchSetsEmotes(_token, emoteSetsIds, '').then((value) {
        for (var emote in value) {
          emotesFromSets.add(emote);
        }
      });
    }
  }
}
