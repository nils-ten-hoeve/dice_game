import 'dart:async';
import 'dart:math';

import 'package:dice_game/game/cell/cell.value.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

enum DieFace {
  one(BootstrapIcons.dice_1, BootstrapIcons.dice_1_fill),
  two(BootstrapIcons.dice_2, BootstrapIcons.dice_2_fill),
  three(BootstrapIcons.dice_3, BootstrapIcons.dice_3_fill),
  four(BootstrapIcons.dice_4, BootstrapIcons.dice_4_fill),
  five(BootstrapIcons.dice_5, BootstrapIcons.dice_5_fill),
  six(BootstrapIcons.dice_6, BootstrapIcons.dice_6_fill);

  final IconData filledIcon;
  final IconData outlineIcon;
  const DieFace(this.outlineIcon, this.filledIcon);

  factory DieFace.random() => values[Random().nextInt(values.length)];
}

class Die {
  final Color color;
  final DieFace face;

  static const Color _white = Colors.white;

  Die(this.color, this.face);
  Die.white(this.face) : color = _white;

  bool get isWhite => color == _white;

  @override
  String toString() => 'Die{color: $color, face: $face}';
}

class Dice extends ChangeNotifier {
  final Game game;
  late List<Die> all = _createNewDice();
  bool isRolling = false;
  final int faceRollDurationInMilliSeconds = 100;
  final int numberOfFaceRollsPerThrow = 12;
  Dice(this.game);

  void roll() {
    isRolling = true;
    Timer.periodic(Duration(milliseconds: faceRollDurationInMilliSeconds),
        (timer) {
      all = _createNewDice();
      notifyListeners();
      if (timer.tick >= numberOfFaceRollsPerThrow) {
        timer.cancel();
      }
    });
    isRolling = false;
  }

  List<Die> _createNewDice() => [
        Die.white(DieFace.random()),
        Die.white(DieFace.random()),
        for (var color in CellColor.values)
          if (!game.isClosed(color)) Die(color.dark, DieFace.random()),
      ];
}
