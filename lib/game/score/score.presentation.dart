import 'package:dice_game/game/action_bar/action_bar.presentation.dart';
import 'package:dice_game/game/game.service.dart';
import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var onSurface = Theme.of(context).colorScheme.onSurface;
    var game = GameService().currentGame;
    var score = game.variant.scoreCalculation.calculateScore(game);
    var children = <Widget>[];
    for (var subScore in score.subScores) {
      if (children.isNotEmpty) {
        children.add(Text(subScore.points < 0 ? '-' : '+',
            style: _textStyle(onSurface)));
      }
      //
      children.add(InkWell(
        onTap: () {
          showMessageDialog(context, subScore.dutchMessage);
        },
        child: Text(
          subScore.points.abs().toString(),
          style: _textStyle(subScore.color ?? onSurface),
        ),
      ));
    }
    children.add(Text('=', style: _textStyle(onSurface)));
    children
        .add(Text(score.totalPoints.toString(), style: _textStyle(onSurface)));
    return Transform.scale(
      scale: 0.9,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Row(children: children),
      ),
    );
  }

  TextStyle _textStyle(Color color) => TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      );
}
