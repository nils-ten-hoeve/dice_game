import 'package:dice_game/game/action_bar/score_bar.presentation.dart';
import 'package:dice_game/game/cell/cell.presentation.dart';
import 'package:dice_game/game/dice/dice.presentation.dart';
import 'package:dice_game/game/game.service.dart';
import 'package:flutter/material.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final GameService gameService = GameService();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 5 / 3,
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
                  }
                  if (game.dutchMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showMessageDialog(context);
                    });
                  }
                  return Column(
                    children: [
                      GameRow(game: game, cellRow: game.variant.row1),
                      Spacer(),
                      GameRow(game: game, cellRow: game.variant.row2),
                      Spacer(),
                      GameRow(game: game, cellRow: game.variant.row3),
                      Spacer(),
                      GameRow(game: game, cellRow: game.variant.row4),
                      Spacer(),
                      ScoreAndActionBar(),
                      Spacer(),
                      if (game.showDice) DiceBar(),
                      if (game.showDice) Spacer(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      );
}
