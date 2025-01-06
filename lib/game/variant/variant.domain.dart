// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:math';

import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
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
  final int nrOfMarkedCellsNeededToLock;
  final MultipleChanges Function(Game game, Cell cell) createChangesToMarkCell;
  final TotalScoreCalculation scoreCalculation;

  GameVariant({
    required this.name,
    required this.explenationUrl,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
    required this.nrOfMarkedCellsNeededToLock,
    required this.createChangesToMarkCell,
    required this.scoreCalculation,
  }) {
    validateIfAllUnique();
  }

  void validateIfAllUnique() {
    var allValues = rows.expand((row) => row);
    var uniqueValues = allValues.toSet();
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
          nrOfMarkedCellsNeededToLock: 5,
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCell(game, cell),
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
          nrOfMarkedCellsNeededToLock: 5,
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCell(game, cell),
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
          nrOfMarkedCellsNeededToLock:
              6, //Note: this is different from others, see rules
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCell(game, cell),
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
          nrOfMarkedCellsNeededToLock: 5,
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCell(game, cell),
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
  ConnectedVariantA._internal({
    required super.name,
    required super.explenationUrl,
    required super.row1,
    required super.row2,
    required super.row3,
    required super.row4,
    required super.nrOfMarkedCellsNeededToLock,
    required super.createChangesToMarkCell,
    required super.scoreCalculation,
  });

  factory ConnectedVariantA() {
    var baseRows = BasicVariantA().rows;
    Map<(int rowNr, int columnNr), Cell> cells = {};
    var columnLength = baseRows.first.length;
    for (var rowNr = 0; rowNr < baseRows.length; rowNr++) {
      for (var columnNr = 0; columnNr < columnLength; columnNr++) {
        cells[(rowNr, columnNr)] = baseRows[rowNr][columnNr];
      }
    }
    var random = Random();
    var firstRowNr = 0;
    var lastRowNr = baseRows.length - 1;
    var rowNr = random.nextInt(baseRows.length);
    var goingUp = rowNr == lastRowNr
        ? true
        : rowNr == firstRowNr
            ? false
            : random.nextBool();
    for (var columnNr = 0; columnNr < columnLength; columnNr++) {
      cells[(rowNr, columnNr)] =
          cells[(rowNr, columnNr)]!.copyWith(variant: CellVariant.stairs);
      rowNr = goingUp ? rowNr - 1 : rowNr + 1;
      goingUp = rowNr == lastRowNr
          ? true
          : rowNr == firstRowNr
              ? false
              : goingUp;
    }

    return ConnectedVariantA._internal(
      name: "Connected Variant A (Treden)",
      explenationUrl:
          Uri.parse("https://www.qwixx.nl/varianten/qwixx-connected/"),
      row1: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(0, columnNr)]!,
      ]),
      row2: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(1, columnNr)]!
      ]),
      row3: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(2, columnNr)]!
      ]),
      row4: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(3, columnNr)]!
      ]),
      nrOfMarkedCellsNeededToLock: 5,
      createChangesToMarkCell: (Game game, Cell cell) => MarkCell(game, cell),
      scoreCalculation: TotalScoreCalculation([
        for (var color in CellColor.values) ColorScore(color),
        PurpleScore(),
        PenaltyScore()
      ]),
    );
  }
}

class ConnectedVariantB extends GameVariant {
  ConnectedVariantB._internal({
    required super.name,
    required super.explenationUrl,
    required super.row1,
    required super.row2,
    required super.row3,
    required super.row4,
    required super.nrOfMarkedCellsNeededToLock,
    required super.createChangesToMarkCell,
    required super.scoreCalculation,
  });

  factory ConnectedVariantB() {
    var baseRows = BasicVariantA().rows;
    Map<(int rowNr, int columnNr), Cell> cells = {};
    var columnLength = baseRows.first.length;
    for (var rowNr = 0; rowNr < baseRows.length; rowNr++) {
      for (var columnNr = 0; columnNr < columnLength; columnNr++) {
        cells[(rowNr, columnNr)] = baseRows[rowNr][columnNr];
      }
    }
    var random = Random();
    var firstRowNr = 0;
    var lastRowNr = baseRows.length - 2;
    var rowNr = random.nextInt(baseRows.length - 1);
    var goingUp = rowNr == lastRowNr
        ? true
        : rowNr == firstRowNr
            ? false
            : random.nextBool();
    var columnsToSkip = [
      0,
      random.nextBool() ? 2 : 3,
      5,
      random.nextBool() ? 7 : 8,
      10
    ];
    for (var columnNr = 0; columnNr < columnLength; columnNr++) {
      if (!columnsToSkip.contains(columnNr)) {
        cells[(rowNr, columnNr)] = cells[(rowNr, columnNr)]!
            .copyWith(variant: CellVariant.linkedWithCellBelow);
        cells[(rowNr + 1, columnNr)] = cells[(rowNr + 1, columnNr)]!
            .copyWith(variant: CellVariant.linkedWithCellAbove);
        rowNr = goingUp ? rowNr - 1 : rowNr + 1;
        if (rowNr < firstRowNr) {
          rowNr = lastRowNr;
        }
        if (rowNr > lastRowNr) {
          rowNr = firstRowNr;
        }
      }
    }

    return ConnectedVariantB._internal(
      name: "Connected Variant B (Paaren)",
      explenationUrl:
          Uri.parse("https://www.qwixx.nl/varianten/qwixx-connected/"),
      row1: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(0, columnNr)]!,
      ]),
      row2: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(1, columnNr)]!
      ]),
      row3: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(2, columnNr)]!
      ]),
      row4: CellRow([
        for (var columnNr = 0; columnNr < columnLength; columnNr++)
          cells[(3, columnNr)]!
      ]),
      nrOfMarkedCellsNeededToLock: 5,
      createChangesToMarkCell: (Game game, Cell cell) {
        var changes = MarkCell(game, cell).changes;
        if (changes.isNotEmpty &&
                cell.variant == CellVariant.linkedWithCellAbove ||
            cell.variant == CellVariant.linkedWithCellBelow) {
          var rowIndex = game.variant.findRowIndex(cell);
          var cellIndex = game.variant.rows[rowIndex].indexOf(cell);
          var linkedRowIndex = cell.variant == CellVariant.linkedWithCellAbove
              ? rowIndex - 1
              : rowIndex + 1;
          var linkedCell =
              game.variant.rows[linkedRowIndex].elementAt(cellIndex);
          changes.add(ChangeCellState(game, linkedCell, CellState.marked));
        }
        return MultipleChanges(changes);
      },
      scoreCalculation: TotalScoreCalculation([
        for (var color in CellColor.values) ColorScore(color),
        PenaltyScore()
      ]),
    );
  }
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
