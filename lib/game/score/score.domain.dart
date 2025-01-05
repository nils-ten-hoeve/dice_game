import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:flutter/material.dart';

class SubScoreResult implements WithDutchMessage {
  final int points;
  final Color? color;
  @override
  final String dutchMessage;

  SubScoreResult(
      {required this.points, required this.dutchMessage, this.color});
}

abstract class SubScoreCalculation {
  SubScoreResult calculateScore(Game game);
}

class ColorScore extends SubScoreCalculation {
  final ScoreConversion scoreConversion = ScoreConversion();
  final CellColor color;
  ColorScore(this.color);

  @override
  SubScoreResult calculateScore(Game game) {
    var allCells = game.variant.rows.expand((row) => row);
    var cellsOfColor = allCells.where((cell) => cell.color == color).toList();
    var cellStates = game.cellStates.entries
        .where((entry) => cellsOfColor.contains(entry.key))
        .toList();
    var markedCells =
        cellStates.where((entry) => entry.value == CellState.marked).toList();
    var count = markedCells.length;
    var points = scoreConversion.countToPoints(count);
    var dutchMessage =
        '$count keer ${color.dutchName} is $points punten.\n$scoreConversion';
    return SubScoreResult(
        points: points, dutchMessage: dutchMessage, color: color.dark);
  }
}

class PenaltyScore extends SubScoreCalculation {
  @override
  SubScoreResult calculateScore(Game game) {
    var count = game.penalty.count;
    var points = count * -5;
    var dutchMessage =
        '${count == 1 ? '1 misworp' : '$count misworpen'} is $points punten.';
    return SubScoreResult(points: points, dutchMessage: dutchMessage);
  }
}

class TotalScoreResult {
  late final int totalPoints = subScores.fold(
      0, (previousValue, element) => previousValue + element.points);
  final List<SubScoreResult> subScores;

  TotalScoreResult(this.subScores);
}

class TotalScoreCalculation {
  final List<SubScoreCalculation> subScoreCalculations;

  TotalScoreCalculation(this.subScoreCalculations);

  TotalScoreResult calculateScore(Game game) {
    var subScores = subScoreCalculations
        .map((subScoreCalculation) => subScoreCalculation.calculateScore(game))
        .toList();
    return TotalScoreResult(subScores);
  }
}

class ScoreConversion extends DelegatingMap<int, int> {
  static final ScoreConversion _instance = ScoreConversion._internal();

  factory ScoreConversion() {
    return _instance;
  }

  ScoreConversion._internal()
      : super({
          0: 0,
          1: 1,
          2: 3,
          3: 6,
          4: 10,
          5: 15,
          6: 21,
          7: 28,
          8: 36,
          9: 45,
          10: 55,
          11: 66,
          12: 78
        });

  int countToPoints(int count) => this[count]!;

  @override
  String toString() => entries
      .where((entry) => entry.value != 0)
      .map((entry) =>
          '${entry.key} keer = ${entry.value == 1 ? '1 punt' : '${entry.value} punten'}')
      .join('\n');
}
