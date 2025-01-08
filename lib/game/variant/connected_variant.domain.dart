// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:math';

import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/variant/basic_variant.domain.dart';
import 'package:dice_game/game/variant/variant.domain.dart';
import 'package:flutter/material.dart';
import 'package:undo/undo.dart';

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
    var baseRows = BasicVariantB().rows;
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
      createChangesToMarkCell: (Game game, Cell cell) =>
          MarkCellChanges(game, cell),
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
    var baseRows = BasicVariantB().rows;
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
    var skipSecondColumn = random.nextBool();
    var columnsToSkip = [
      0,
      skipSecondColumn ? 2 : 3,
      5,
      skipSecondColumn ? 7 : 8,
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
        var changes = <Change>[];
        changes.addAll(MarkCellChanges(game, cell));
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
          changes.add(ChangeCellState(game, linkedCell,
              CellStateIdentifier.singleNumber, CellState.marked));
        }
        return changes;
      },
      scoreCalculation: TotalScoreCalculation([
        for (var color in CellColor.values) ColorScore(color),
        PenaltyScore()
      ]),
    );
  }
}

class PurpleScore extends SubScoreCalculation {
  @override
  SubScoreResult calculateScore(Game game) {
    var allCells = game.variant.rows.expand((row) => row);
    var cellsOfColor =
        allCells.where((cell) => cell.variant == CellVariant.stairs).toList();
    var cellStates = game.cellStates.entries
        .where((entry) => cellsOfColor.contains(entry.key))
        .expand((entry) => entry.value.values);
    var markedCells = cellStates
        .where((cellStatus) => cellStatus == CellState.marked)
        .toList();
    var count = markedCells.length;
    var points = scoreConversion.countToPoints(count);
    var dutchMessage = '$count keer paars is $points punten.\n$scoreConversion';
    return SubScoreResult(
      count: count,
      points: points,
      dutchMessage: dutchMessage,
      color: Colors.purple,
    );
  }

  final ScoreConversion scoreConversion = ScoreConversion();
}
