class TwitchChatParameters {
  final bool addBitsDonations;
  final bool addRewardsRedemptions;
  final bool addSubscriptions;
  final bool addFirstMessages;
  final bool addAnnouncements;
  final bool addRaids;
  final bool addHosts;
  final bool addHighlightedMessages;

  const TwitchChatParameters({
    this.addBitsDonations = true,
    this.addRewardsRedemptions = true,
    this.addSubscriptions = true,
    this.addFirstMessages = false,
    this.addAnnouncements = true,
    this.addRaids = true,
    this.addHosts = true,
    this.addHighlightedMessages = false,
  });
}
