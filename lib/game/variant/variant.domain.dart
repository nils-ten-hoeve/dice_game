// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dice_game/game/cell/cell.value.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:flutter/material.dart';

abstract class GameVariant {
  final String name;
  final Uri explenationUrl;
  final CellRow row1;
  final CellRow row2;
  final CellRow row3;
  final CellRow row4;
  final int markedCellsToLock;
  final TotalScoreCalculation scoreCalculation;

  GameVariant({
    required this.name,
    required this.explenationUrl,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
    required this.markedCellsToLock,
    required this.scoreCalculation,
  }) {
    validateIfAllUnique();
  }

  void validateIfAllUnique() {
    var allValues = [...row1, ...row2, ...row3, ...row4];
    var uniqueValues = {...row1, ...row2, ...row3, ...row4};
    if (uniqueValues.length != allValues.length) {
      throw Exception("Values must be unique");
    }
  }

  late final List<CellRow> rows = [row1, row2, row3, row4];

  List<Cell> preceidingCells(Cell cell) {
    var row = findRow(cell);
    var index = row.indexOf(cell);
    return row.sublist(0, index);
  }

  CellRow findRow(Cell cell) => rows.firstWhere((row) => row.contains(cell));

  int findRowIndex(Cell cell) => rows.indexOf(findRow(cell));

  bool isLastCell(Cell cell) {
    var row = findRow(cell);
    return row.last == cell;
  }
}

const List<int> twoTroughTwelve = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
const List<int> twelveTroughTwo = [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];

class BasicVariantA extends GameVariant {
  BasicVariantA()
      : super(
          name: "Basic Variant A",
          explenationUrl: Uri.parse("https://www.qwixx.nl/#basisspel"),
          row1: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.red, number),
          ]),
          row2: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.yellow, number),
          ]),
          row3: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.green, number),
          ]),
          row4: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.blue, number),
          ]),
          markedCellsToLock: 5,
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}

class BasicVariantB extends GameVariant {
  BasicVariantB()
      : super(
          name: "Basic Variant B",
          explenationUrl: Uri.parse("https://www.qwixx.nl/#basisspel"),
          row1: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.red, number),
          ]),
          row2: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.yellow, number),
          ]),
          row3: CellRow([
            for (var number in twelveTroughTwo) Cell(CellColor.green, number),
          ]),
          row4: CellRow([
            for (var number in twelveTroughTwo) Cell(CellColor.blue, number),
          ]),
          markedCellsToLock: 5,
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}

class MixedVariantA extends GameVariant {
  MixedVariantA()
      : super(
          name: "Mixed Variant A (kleuren)",
          explenationUrl: Uri.parse(
              "https://www.qwixx.nl/varianten/qwixx-mixx-uitbreiding/"),
          row1: CellRow([
            Cell(CellColor.yellow, 2),
            Cell(CellColor.yellow, 3),
            Cell(CellColor.yellow, 4),
            Cell(CellColor.blue, 5),
            Cell(CellColor.blue, 6),
            Cell(CellColor.blue, 7),
            Cell(CellColor.green, 8),
            Cell(CellColor.green, 9),
            Cell(CellColor.green, 10),
            Cell(CellColor.red, 11),
            Cell(CellColor.red, 12)
          ]),
          row2: CellRow([
            Cell(CellColor.red, 2),
            Cell(CellColor.red, 3),
            Cell(CellColor.green, 4),
            Cell(CellColor.green, 5),
            Cell(CellColor.green, 6),
            Cell(CellColor.green, 7),
            Cell(CellColor.blue, 8),
            Cell(CellColor.blue, 9),
            Cell(CellColor.yellow, 10),
            Cell(CellColor.yellow, 11),
            Cell(CellColor.yellow, 12)
          ]),
          row3: CellRow([
            Cell(CellColor.blue, 12),
            Cell(CellColor.blue, 11),
            Cell(CellColor.blue, 10),
            Cell(CellColor.yellow, 9),
            Cell(CellColor.yellow, 8),
            Cell(CellColor.yellow, 7),
            Cell(CellColor.red, 6),
            Cell(CellColor.red, 5),
            Cell(CellColor.red, 4),
            Cell(CellColor.green, 3),
            Cell(CellColor.green, 2)
          ]),
          row4: CellRow([
            Cell(CellColor.green, 12),
            Cell(CellColor.green, 11),
            Cell(CellColor.red, 10),
            Cell(CellColor.red, 9),
            Cell(CellColor.red, 8),
            Cell(CellColor.red, 7),
            Cell(CellColor.yellow, 6),
            Cell(CellColor.yellow, 5),
            Cell(CellColor.blue, 4),
            Cell(CellColor.blue, 3),
            Cell(CellColor.blue, 2)
          ]),
          markedCellsToLock: 6, //Note: this is different from others, see rules
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}

class MixedVariantB extends GameVariant {
  MixedVariantB()
      : super(
          name: "Mixed Variant B (nummers)",
          explenationUrl: Uri.parse(
              "https://www.qwixx.nl/varianten/qwixx-mixx-uitbreiding/"),
          row1: CellRow([
            Cell(CellColor.red, 10),
            Cell(CellColor.red, 6),
            Cell(CellColor.red, 2),
            Cell(CellColor.red, 8),
            Cell(CellColor.red, 3),
            Cell(CellColor.red, 4),
            Cell(CellColor.red, 12),
            Cell(CellColor.red, 5),
            Cell(CellColor.red, 9),
            Cell(CellColor.red, 7),
            Cell(CellColor.red, 11),
          ]),
          row2: CellRow([
            Cell(CellColor.yellow, 9),
            Cell(CellColor.yellow, 12),
            Cell(CellColor.yellow, 4),
            Cell(CellColor.yellow, 6),
            Cell(CellColor.yellow, 7),
            Cell(CellColor.yellow, 2),
            Cell(CellColor.yellow, 5),
            Cell(CellColor.yellow, 8),
            Cell(CellColor.yellow, 11),
            Cell(CellColor.yellow, 3),
            Cell(CellColor.yellow, 10),
          ]),
          row3: CellRow([
            Cell(CellColor.green, 8),
            Cell(CellColor.green, 2),
            Cell(CellColor.green, 10),
            Cell(CellColor.green, 12),
            Cell(CellColor.green, 6),
            Cell(CellColor.green, 9),
            Cell(CellColor.green, 7),
            Cell(CellColor.green, 4),
            Cell(CellColor.green, 5),
            Cell(CellColor.green, 11),
            Cell(CellColor.green, 3),
          ]),
          row4: CellRow([
            Cell(CellColor.blue, 5),
            Cell(CellColor.blue, 7),
            Cell(CellColor.blue, 11),
            Cell(CellColor.blue, 9),
            Cell(CellColor.blue, 12),
            Cell(CellColor.blue, 3),
            Cell(CellColor.blue, 8),
            Cell(CellColor.blue, 10),
            Cell(CellColor.blue, 2),
            Cell(CellColor.blue, 6),
            Cell(
              CellColor.blue,
              4,
            )
          ]),
          markedCellsToLock: 5,
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}

class PurpleScore extends SubScoreCalculation {
  @override
  SubScoreResult calculateScore(Game game) {
    var allCells = game.variant.rows.expand((row) => row);
    var cellsOfColor =
        allCells.where((cell) => cell.variant == CellVariant.stairs).toList();
    var cellStates = game.cellStates.entries
        .where((entry) => cellsOfColor.contains(entry.key))
        .toList();
    var markedCells =
        cellStates.where((entry) => entry.value == CellState.marked).toList();
    var count = markedCells.length;
    var points = scoreConversion.countToPoints(count);
    var dutchMessage = '$count keer paars is $points punten.\n$scoreConversion';
    return SubScoreResult(
      points: points,
      dutchMessage: dutchMessage,
      color: Colors.purple,
    );
  }

  final ScoreConversion scoreConversion = ScoreConversion();
}

class ConnectedVariantA extends GameVariant {
  ConnectedVariantA()
      : super(
          name: "Connected Variant A (Treden)",
          explenationUrl:
              Uri.parse("https://www.qwixx.nl/varianten/qwixx-connected/"),
          row1: CellRow([
            Cell(CellColor.red, 2),
            Cell(CellColor.red, 3),
            Cell(CellColor.red, 4),
            Cell(CellColor.red, 5),
            Cell(CellColor.red, 6),
            Cell(CellColor.red, 7),
            Cell(CellColor.red, 8),
            Cell(CellColor.red, 9),
            Cell(CellColor.red, 10),
            Cell(CellColor.red, 11),
            Cell(CellColor.red, 12),
          ]),
          row2: CellRow([
            Cell(CellColor.yellow, 2),
            Cell(CellColor.yellow, 3),
            Cell(CellColor.yellow, 4),
            Cell(CellColor.yellow, 5),
            Cell(CellColor.yellow, 6),
            Cell(CellColor.yellow, 7),
            Cell(CellColor.yellow, 8),
            Cell(CellColor.yellow, 9),
            Cell(CellColor.yellow, 10),
            Cell(CellColor.yellow, 11),
            Cell(CellColor.yellow, 12),
          ]),
          row3: CellRow([
            Cell(CellColor.green, 12),
            Cell(CellColor.green, 11),
            Cell(CellColor.green, 10),
            Cell(CellColor.green, 9),
            Cell(CellColor.green, 8),
            Cell(CellColor.green, 7),
            Cell(CellColor.green, 6),
            Cell(CellColor.green, 5),
            Cell(CellColor.green, 4),
            Cell(CellColor.green, 3),
            Cell(CellColor.green, 2),
          ]),
          row4: CellRow([
            Cell(CellColor.blue, 12),
            Cell(CellColor.blue, 11),
            Cell(CellColor.blue, 10),
            Cell(CellColor.blue, 9),
            Cell(CellColor.blue, 8),
            Cell(CellColor.blue, 7),
            Cell(CellColor.blue, 6),
            Cell(CellColor.blue, 5),
            Cell(CellColor.blue, 4),
            Cell(CellColor.blue, 3),
            Cell(CellColor.blue, 2)
          ]),
          markedCellsToLock: 5,
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PurpleScore(),
            PenaltyScore()
          ]),
        );
}

class ConnectedVariantB extends GameVariant {
  ConnectedVariantB()
      : super(
          name: "Connected Variant B (Verbonden)",
          explenationUrl:
              Uri.parse("https://www.qwixx.nl/varianten/qwixx-connected/"),
          row1: CellRow([
            Cell(CellColor.red, 2),
            Cell(CellColor.red, 3),
            Cell(CellColor.red, 4),
            Cell(CellColor.red, 5),
            Cell(CellColor.red, 6),
            Cell(CellColor.red, 7),
            Cell(CellColor.red, 8),
            Cell(CellColor.red, 9),
            Cell(CellColor.red, 10),
            Cell(CellColor.red, 11),
            Cell(CellColor.red, 12),
          ]),
          row2: CellRow([
            Cell(CellColor.yellow, 2),
            Cell(CellColor.yellow, 3),
            Cell(CellColor.yellow, 4),
            Cell(CellColor.yellow, 5),
            Cell(CellColor.yellow, 6),
            Cell(CellColor.yellow, 7),
            Cell(CellColor.yellow, 8),
            Cell(CellColor.yellow, 9),
            Cell(CellColor.yellow, 10),
            Cell(CellColor.yellow, 11),
            Cell(CellColor.yellow, 12),
          ]),
          row3: CellRow([
            Cell(CellColor.green, 12),
            Cell(CellColor.green, 11),
            Cell(CellColor.green, 10),
            Cell(CellColor.green, 9),
            Cell(CellColor.green, 8),
            Cell(CellColor.green, 7),
            Cell(CellColor.green, 6),
            Cell(CellColor.green, 5),
            Cell(CellColor.green, 4),
            Cell(CellColor.green, 3),
            Cell(CellColor.green, 2),
          ]),
          row4: CellRow([
            Cell(CellColor.blue, 12),
            Cell(CellColor.blue, 11),
            Cell(CellColor.blue, 10),
            Cell(CellColor.blue, 9),
            Cell(CellColor.blue, 8),
            Cell(CellColor.blue, 7),
            Cell(CellColor.blue, 6),
            Cell(CellColor.blue, 5),
            Cell(CellColor.blue, 4),
            Cell(CellColor.blue, 3),
            Cell(CellColor.blue, 2)
          ]),
          markedCellsToLock: 5,
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}

class GameVariants {
  final GameVariant basicVariantA = BasicVariantA();
  final GameVariant basicVariantB = BasicVariantB();
  final GameVariant mixedVariantA = MixedVariantA();
  final GameVariant mixedVariantB = MixedVariantB();
  final GameVariant connectedVariantA = ConnectedVariantA();
  final GameVariant connectedVariantB = ConnectedVariantB();

  late final List<GameVariant> all = [
    basicVariantA,
    basicVariantB,
    mixedVariantA,
    mixedVariantB,
    connectedVariantA,
    connectedVariantB,
  ];
}
