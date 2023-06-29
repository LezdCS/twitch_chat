# twitch_chat
![Pub Version (including pre-releases)](https://img.shields.io/pub/v/twitch_chat?color=%23027DFD)
![GitHub last commit](https://img.shields.io/github/last-commit/lezdcs/twitch_chat)
![GitHub](https://img.shields.io/github/license/lezdcs/twitch_chat?color=%236441a5)

Package to connect and use the Twitch Chat by Websocket and IRC.

## Features

- [x] Connect to chat
- [x] Connect anonymously
- [x] Get badges
- [x] Get emotes
- [x] Get BTTV, FFZ & 7TV emotes
- [x] Ban, Timeout, Delete message

## Getting started

- Get your access token
- Use the following scopes:

## Usage

Initiate a chat 

```dart
TwitchChat twitchChat = TwitchChat(
  channelToJoin,
  yourUsername,
  accessToken,
  clientId: clientId,
  onConnected: () {},
  onClearChat: () {},
  onDeletedMessageByUserId: (String? userId) {},
  onDeletedMessageByMessageId: (String? messageId) {},
  onDone: () {},
  onError: () {},
  params: TwitchChatParameters(addFirstMessages: true),
);
```

Connect to the chat
```dart
twitchChat.connect();
```

Listen to the chat messages
```dart
twitchChat.chatStream.listen((message) {});
```

Listen to connection status changes
```dart
twitchChat!.isConnected.addListener(() {
  if (twitchChat.isConnected.value) {
  } else {
  }
});
```
## Noticable applications using this package

- [irl-link](https://github.com/LezdCS/irl-link) for IRL streamers
