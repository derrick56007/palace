part of server;

class ELOPlayer {
  final CommonWebSocket socket;
  final int place;
  final int eloPre;

  int eloPost;
  int eloChange = 0;

  ELOPlayer(this.socket, this.place, this.eloPre);
}

class EloMatch {
  final players = <ELOPlayer>[];

  void addPlayer(CommonWebSocket socket, int place, int elo) {
    final player = ELOPlayer(socket, place, elo);
    players.add(player);
  }

  void calculate() {
    final n = players.length;
    num k = 32 / (n - 1);

    for (var i = 0; i < n; i++) {
      var curPlace = players[i].place;
      var curELO = players[i].eloPre;

      for (var j = 0; j < n; j++) {
        if (i != j) {
          var opponentPlace = players[j].place;
          var opponentELO = players[j].eloPre;

          num S;
          if (curPlace < opponentPlace) {
            S = 1.0;
          } else if (curPlace == opponentPlace) {
            S = 0.5;
          } else {
            S = 0.0;
          }

          num EA = 1.0 / (1.0 + pow(10.0, (opponentELO - curELO) / 400.0));

          players[i].eloChange += (k * (S - EA)).round();
        }
      }

      players[i].eloPost = players[i].eloPre + players[i].eloChange;
    }
  }
}
