import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.value.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:flutter/material.dart';

class SubScoreResult {
  final int count;
  final int points;
  final Color? color;

  SubScoreResult({required this.count, required this.points, this.color});
}

abstract class SubScoreCalculation {
  SubScoreResult calculateScore(Game game);
}

class ColorScore extends SubScoreCalculation {
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
    var points = ScoreConversion().countToPoints(count);
    return SubScoreResult(count: count, points: points, color: color.dark);
  }
}

class PenaltyScore extends SubScoreCalculation {
  @override
  SubScoreResult calculateScore(Game game) {
    var count = game.penalty.count;
    var points = count * -5;
    return SubScoreResult(count: count, points: points);
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
}
