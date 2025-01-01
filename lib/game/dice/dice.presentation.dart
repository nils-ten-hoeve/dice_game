import 'package:dice_game/game/dice/dice.domain.dart';
import 'package:dice_game/game/game.service.dart';
import 'package:flutter/material.dart';

class DiceBar extends StatelessWidget {
  const DiceBar({super.key});

  @override
  Widget build(BuildContext context) {
    var game = GameService().currentGame;
    return ListenableBuilder(
      listenable: game.dice,
      builder: (context, child) =>
          LayoutBuilder(builder: (context, constraints) {
        var diceSize = _diceSize(constraints);
        return SizedBox(
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: diceSize / 2,
            children: [
              for (var die in game.dice.all)
                SizedBox(
                    width: diceSize, height: diceSize, child: DieWidget(die)),
            ],
          ),
        );
      }),
    );
  }

  double _diceSize(BoxConstraints constraints) => constraints.maxWidth / 16;
}

class DieWidget extends StatelessWidget {
  final Die die;

  const DieWidget(
    this.die, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var iconData = die.isWhite ? die.face.outlineIcon : die.face.filledIcon;
    var iconColor =
        die.isWhite ? Theme.of(context).colorScheme.onSurface : die.color;
    return InkWell(
      onTap: () => GameService().currentGame.dice.roll(),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );
  }
}
