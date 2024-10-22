import 'dart:async';

import 'package:api_7tv/api_7tv.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:twitch_chat/src/twitch_badge.dart';
import 'package:twitch_chat/src/chat_message.dart';
import 'package:twitch_chat/src/data/ffz_api.dart';
import 'package:twitch_chat/src/data/twitch_api.dart';
import 'package:twitch_chat/src/twitch_chat_parameters.dart';
import 'package:twitch_chat/src/utils/split_function.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat_events/announcement.dart';
import 'chat_events/bit_donation.dart';
import 'chat_events/incoming_raid.dart';
import 'chat_events/reward_redemption.dart';
import 'chat_events/sub_gift.dart';
import 'chat_events/subscription.dart';
import 'data/bttv_api.dart';
import 'emote.dart';

typedef MessageDeletedCallback = void Function(String);

class TwitchChat {
  String _channel;
  String? _channelId;
  final String _username;
  final String _token;

  String? _clientId;

  WebSocketChannel? _webSocketChannel;
  StreamSubscription? _streamSubscription;

  final StreamController<ChatMessage> _chatStreamController =
      StreamController.broadcast();

  Stream<ChatMessage> get chatStream => _chatStreamController.stream;

  final VoidCallback? onClearChat;
  final MessageDeletedCallback? onDeletedMessageByUserId;
  final MessageDeletedCallback? onDeletedMessageByMessageId;
  final VoidCallback? onConnected;
  VoidCallback? onDone;
  final Function? onError;

  TwitchChatParameters _params;
  List<TwitchBadge> _badges = [];
  List<Emote> _channelEmotes = [];
  List<Emote> _globalEmotes = [];
  List<Emote> _emotesFromSets =
      []; // Emotes that the user have access to (sub emotes for example)
  List<Emote> _cheerEmotes = [];
  List<Emote> _thirdPartEmotes = [];

  ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  TwitchChat(
    this._channel,
    this._username,
    this._token, {
    TwitchChatParameters params = const TwitchChatParameters(),
    String? clientId,
    this.onClearChat,
    this.onDeletedMessageByUserId,
    this.onDeletedMessageByMessageId,
    this.onConnected,
    this.onDone,
    this.onError,
    bool? allowDebug,
  })  : _params = params,
        _clientId = clientId;

  String get channel => _channel;

  String? get channelId => _channelId;

  List<TwitchBadge> get badges => _badges;

  List<Emote> get globalEmotes => _globalEmotes;

  List<Emote> get emotesFromSets => _emotesFromSets;

  List<Emote> get cheerEmotes => _cheerEmotes;

  List<Emote> get thirdPartEmotes => _thirdPartEmotes;

  set onClearChat(VoidCallback? onClearChat) {
    this.onClearChat = onClearChat;
  }

  set onDeletedMessageByUserId(
    MessageDeletedCallback? onDeletedMessageByUserId,
  ) {
    this.onDeletedMessageByUserId = onDeletedMessageByUserId;
  }

  set onDeletedMessageByMessageId(
    MessageDeletedCallback? onDeletedMessageByMessageId,
  ) {
    this.onDeletedMessageByMessageId = onDeletedMessageByMessageId;
  }

  set onConnected(VoidCallback? onConnected) {
    this.onConnected = onConnected;
  }

  set onError(Function? onError) {
    this.onError = onError;
  }

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
    _globalEmotes.clear();
    _channelEmotes.clear();
    _cheerEmotes.clear();
    _thirdPartEmotes.clear();

    TwitchApi.getTwitchUserChannelId(_channel, _token, _clientId!)
        .then((value) {
      _channelId = value;

      // Get the badges
      TwitchBadge.getBadges(_token, _channelId!, _clientId!)
          .then((value) => _badges = value);

      // Get the Twitch global emotes
      TwitchApi.getTwitchGlobalEmotes(_token, _clientId!)
          .then((value) => _globalEmotes = value);

      // Get the channel emotes
      TwitchApi.getTwitchChannelEmotes(_token, _channelId!, _clientId!)
          .then((value) => _channelEmotes = value);

      // Get the third part emotes (BTTV, FFZ, 7TV)
      _getThirdPartEmotes().then((value) => _thirdPartEmotes = value);

      // Get the cheer emotes of the channel
      TwitchApi.getCheerEmotes(_token, _channelId!, _clientId!).then(
        (value) => _cheerEmotes = value,
      );
    });
  }

  void quit() {
    isConnected.value = false;
    _webSocketChannel?.sink.add('PART #$_channel');
  }

  //close websocket connection
  void close() {
    isConnected.value = false;
    _webSocketChannel?.sink.close();
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  //login to twitch chat through websocket
  void connect() {
    if (_streamSubscription != null) {
      return;
    }

    _webSocketChannel =
        WebSocketChannel.connect(Uri.parse("wss://irc-ws.chat.twitch.tv:443"));

    _streamSubscription = _webSocketChannel?.stream.listen(
      (data) => _chatListener(data),
      onDone: _onDone,
      onError: _onError,
    );

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

  void _onDone() {
    close();
    isConnected.value = false;
    if (onDone != null) {
      onDone!();
    }
  }

  void _onError(Object o, StackTrace s) {
    isConnected.value = false;
    debugPrint(o.toString());
    debugPrint(s.toString());
    if (onError != null) {
      onError!();
    }
  }

  void _chatListener(String message) {
    if (message.startsWith('PING ')) {
      _webSocketChannel?.sink.add("PONG :tmi.twitch.tv\r\n");
    }

    if (message.startsWith(':')) {
      if (message.toLowerCase().contains('join #${_channel.toLowerCase()}')) {
        isConnected.value = true;
        if (onConnected != null) {
          onConnected!();
        }
      }
    }

    if (message.startsWith('@')) {
      // List messageSplited = message.split(';');
      List<String> keys = [
        "PRIVMSG",
        "CLEARCHAT",
        "CLEARMSG",
        "USERNOTICE",
        "NOTICE",
        "ROOMSTATE"
      ];

      List<String> messageSplited = parseMessage(message);

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
            if (messageMapped['bits'] != null) {
              if (!_params.addBitsDonations) {
                return;
              }
              BitDonation bitDonation = BitDonation.fromString(
                twitchBadges: _badges,
                cheerEmotes: _cheerEmotes,
                thirdPartEmotes: _thirdPartEmotes,
                message: message,
                messageSplited: messageSplited,
                messageMapped: messageMapped,
              );
              _chatStreamController.add(bitDonation);
              break;
            }
            if (messageMapped["custom-reward-id"] != null) {
              if (!_params.addRewardsRedemptions) {
                return;
              }
              RewardRedemption rewardRedemption = RewardRedemption.fromString(
                twitchBadges: _badges,
                thirdPartEmotes: _thirdPartEmotes,
                cheerEmotes: _cheerEmotes,
                message: message,
                messageSplited: messageSplited,
                messageMapped: messageMapped,
              );
              _chatStreamController.add(rewardRedemption);
              break;
            }
            ChatMessage chatMessage = ChatMessage.fromString(
              twitchBadges: _badges,
              thirdPartEmotes: _thirdPartEmotes,
              cheerEmotes: _cheerEmotes,
              message: message,
              params: _params,
              messageSplited: messageSplited,
              messageMapped: messageMapped,
            );
            _chatStreamController.add(chatMessage);
          case 'ROOMSTATE':
            break;
          case "CLEARCHAT":
            if (messageMapped['target-user-id'] != null) {
              // @ban-duration=43;room-id=169185650;target-user-id=107285371;tmi-sent-ts=1642601142470 :tmi.twitch.tv CLEARCHAT #robcdee :lezd_
              String userId = messageMapped['target-user-id']!;
              if (onDeletedMessageByUserId != null) {
                onDeletedMessageByUserId!(userId);
              }
            } else {
              //@room-id=107285371;tmi-sent-ts=1642256684032 :tmi.twitch.tv CLEARCHAT #lezd_
              if (onClearChat != null) {
                onClearChat!();
              }
            }
          case "CLEARMSG":
            //clear a specific msg by the id
            // @login=lezd_;room-id=;target-msg-id=5ecb6458-198c-498c-b91b-16f1e12f58b4;tmi-sent-ts=1640717427981
            // :tmi.twitch.tv CLEARMSG #lezd_ :okokok
            if (messageMapped.containsKey('target-msg-id')) {
              String messageId = messageMapped['target-msg-id']!;
              if (onDeletedMessageByMessageId != null) {
                onDeletedMessageByMessageId!(messageId);
              }
            }
          case "NOTICE":
            //error and success messages are send by notice
            //https://dev.twitch.tv/docs/irc/msg-id
            break;
          case "USERNOTICE":
            final Map<String, String> messageMapped = {};
            //We split the message by ';' to get the different parts
            List<String> messageSplited = message.split(';');
            //We split each part by '=' to get the key and the value
            for (var element in messageSplited) {
              List elementSplited = element.split('=');
              messageMapped[elementSplited[0]] = elementSplited[1];
            }

            String messageId = messageMapped['msg-id']!;
            switch (messageId) {
              case "announcement":
                if (!_params.addAnnouncements) {
                  return;
                }
                Announcement announcement = Announcement.fromString(
                  badges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                  messageSplited: messageSplited,
                  messageMapped: messageMapped,
                );
                _chatStreamController.add(announcement);
                break;
              case "sub":
                if (!_params.addSubscriptions) {
                  return;
                }
                Subscription subMessage = Subscription.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                  messageSplited: messageSplited,
                  messageMapped: messageMapped,
                );
                _chatStreamController.add(subMessage);
                break;
              case "resub":
                if (!_params.addSubscriptions) {
                  return;
                }
                Subscription subMessage = Subscription.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                  messageSplited: messageSplited,
                  messageMapped: messageMapped,
                );
                _chatStreamController.add(subMessage);
                break;
              case "subgift":
                if (!_params.addSubscriptions) {
                  return;
                }
                SubGift subGift = SubGift.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                  messageSplited: messageSplited,
                  messageMapped: messageMapped,
                );
                _chatStreamController.add(subGift);
                break;
              case "raid":
                if (!_params.addRaids) {
                  return;
                }
                IncomingRaid raid = IncomingRaid.fromString(
                  twitchBadges: _badges,
                  thirdPartEmotes: _thirdPartEmotes,
                  cheerEmotes: _cheerEmotes,
                  message: message,
                  messageSplited: messageSplited,
                  messageMapped: messageMapped,
                );
                _chatStreamController.add(raid);
                break;
              default:
                break;
            }
        }
      }
    } else if (message.contains("GLOBALUSERSTATE")) {
      // Map the String
      final Map<String, String> messageMapped = {};
      List messageSplited = message.split(';');
      for (var element in messageSplited) {
        List elementSplited = element.split('=');
        messageMapped[elementSplited[0]] = elementSplited[1];
      }

      // Get the emote-sets that the user have access to
      List<String> emoteSetsIds = messageMapped["emote-sets"]!.split(',');
      if (_clientId != null) {
        Emote.getTwitchSetsEmotes(_token, emoteSetsIds, _clientId!)
            .then((value) {
          _emotesFromSets = value;
        });
      }
    }
  }

  void sendMessage(String message) {
    _webSocketChannel?.sink.add("PRIVMSG #$_channel :$message");
  }

  Future<List<Emote>> _getThirdPartEmotes() async {
    List<Emote> emotes = [];

    await BttvApi.getGlobalEmotes().then((value) => emotes.addAll(value));

    await BttvApi.getChannelEmotes(_channelId!)
        .then((value) => emotes.addAll(value));

    await FfzApi.getEmotes(_channelId!).then((value) => emotes.addAll(value));

    await SeventvApi.getChannelEmotes(_channelId!).then((value) => {
          value?.forEach(
            (emote) => emotes.add(
              Emote.fromJson7Tv(emote),
            ),
          )
        });

    await SeventvApi.getGlobalEmotes().then((value) => {
          value?.forEach(
            (emote) => emotes.add(
              Emote.fromJson7Tv(emote),
            ),
          )
        });

    return emotes;
  }
}
