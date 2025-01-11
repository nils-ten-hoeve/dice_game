import 'package:dice_game/game/action_bar/action_bar.presentation.dart';
import 'package:dice_game/game/cell/cell.presentation.dart';
import 'package:dice_game/game/dice/dice.presentation.dart';
import 'package:dice_game/game/game.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final GameService gameService = GameService();

  @override
  Widget build(BuildContext context) {
    hideSystemBar();
    setPreferedOriantations();
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 15 / 8,
        child: ListenableBuilder(
          listenable: gameService,
          builder: (context, child) {
            var game = gameService.currentGame;
            return ListenableBuilder(
              listenable: game,
              builder: (context, child) {
                if (game.finished) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showFinishedDialog(context);
                  });
                } else if (game.dutchMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showMessageDialog(context, game.dutchMessage!);
                  });
                } else if (gameService.lastPlayedVariant == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showNewGameDialog(context);
                  });
                }
                return Column(
                  children: [
                    GameRow(game: game, cellRow: game.variant.rows[0]),
                    Spacer(),
                    GameRow(game: game, cellRow: game.variant.rows[1]),
                    Spacer(),
                    GameRow(game: game, cellRow: game.variant.rows[2]),
                    Spacer(),
                    GameRow(game: game, cellRow: game.variant.rows[3]),
                    Spacer(),
                    ScoreAndActionBar(),
                    Spacer(),
                    if (game.showDice) DiceBar(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void hideSystemBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  void setPreferedOriantations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
