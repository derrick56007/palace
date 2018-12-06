part of state;

class Play extends State {
  final Element playCard = querySelector('#play-card');

  StreamSubscription submitSub;

  Play(ClientWebSocket client) : super(client) {
    final game = new GameUI(client);
    game.init();

    FriendHandler(client);
    MatchHandler(client);

    client
      ..on(SocketMessage_Type.FIRST_DEAL_TOWER_INFO, (var json) {
        final info = new DealTowerInfo.fromJson(json);
        game.onDealTowerInfo(info);
      })
      ..on(SocketMessage_Type.TOWER_CARD_IDS_TO_HAND, (var json) {
        final info = new TowerCardsToHandInfo.fromJson(json);
        game.onTowerCardsToHand(info);
      })
      ..on(SocketMessage_Type.SECOND_DEAL_TOWER_INFO, (var json) {
        final info = new SecondDealTowerInfo.fromJson(json);
        game.secondTowerDealInfo(info);
      })
      ..on(SocketMessage_Type.FINAL_DEAL_INFO, (var json) {
        final info = new FinalDealInfo.fromJson(json);
        game.onFinalDealInfo(info);
      })
      ..on(SocketMessage_Type.SET_MULLIGANABLE_CARDS, (var json) {
        final cardIDs = new CardIDs.fromJson(json);
        game.setMulliganableCards(cardIDs);
      })
      ..on(SocketMessage_Type.SET_SELECTABLE_CARDS, (var json) {
        final cardIDs = new CardIDs.fromJson(json);
        game.setSelectableCards(cardIDs);
      })
      ..on(SocketMessage_Type.CLEAR_SELECTABLE_CARDS, () {
        game.clearSelectableCards();
      })
      ..on(SocketMessage_Type.DRAW_INFO, (var json) {
        final info = new DrawInfo.fromJson(json);
        game.onDrawInfo(info);
      })
      ..on(SocketMessage_Type.PLAY_FROM_HAND_INFO, (var json) {
        final info = new PlayFromHandInfo.fromJson(json);
        game.onPlayFromHandInfo(info);
      })
      ..on(SocketMessage_Type.PICK_UP_PILE_INFO, (var json) {
        final info = new PickUpPileInfo.fromJson(json);
        game.onPickUpPileInfo(info);
      })
      ..on(SocketMessage_Type.DISCARD_INFO, (var json) {
        final info = new DiscardInfo.fromJson(json);
        game.onDiscardInfo(info);
      })
      ..on(SocketMessage_Type.REQUEST_HANDSWAP_CHOICE, (var json) {
        final cardIDs = new CardIDs.fromJson(json);
        game.setSelectableCards(cardIDs);
      })
      ..on(SocketMessage_Type.REQUEST_TOPSWAP_CHOICE, (var json) {
        final cardIDs = new CardIDs.fromJson(json);
        game.setSelectableCards(cardIDs);
      })
      ..on(SocketMessage_Type.REQUEST_HIGHERLOWER_CHOICE, () {
        game.onRequest_HigherLowerChoice();
      })
      ..on(SocketMessage_Type.ACTIVE_PLAYER_INDEX, (var json) {
        final activePlayerIndex = new ActivePlayerIndex.fromJson(json);
        game.setActivePlayerIndex(activePlayerIndex.index);
      })
      ..on(SocketMessage_Type.HIGHERLOWER_CHOICE, (var json) {
        final higherLowerChoice = new HigherLowerChoice.fromJson(json);
        game.onHigherLowerChoice(higherLowerChoice);
      })
      ..on(SocketMessage_Type.HANDSWAP_CHOICE, (var json) {
        final handSwapInfo = new HandSwapInfo.fromJson(json);
        game.onHandSwapInfo(handSwapInfo);
      })
      ..on(SocketMessage_Type.TOPSWAP_CHOICE, (var json) {
        final topSwapInfo = new TopSwapInfo.fromJson(json);
        game.onTopSwapInfo(topSwapInfo);
      })
      ..on(SocketMessage_Type.CHANGE_DISCARD_TO_ROCK, (var json) {
        final card = new Card.fromJson(json);
        game.onChangeDiscardToRock(card);
      });
  }

  @override
  show() {
    playCard.style.display = '';
  }

  @override
  hide() {
    playCard.style.display = 'none';
    submitSub?.cancel();
  }
}
