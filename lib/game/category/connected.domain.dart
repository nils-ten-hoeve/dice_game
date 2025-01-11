// ignore_for_file: invalid_use_of_protected_member, dead_code
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dice_game/game/category/category.domain.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/category/basic.domain.dart';
import 'package:dice_game/game/category/variant.domain.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:undo/undo.dart';

class ConnectedCategory extends Category {
  @override
  final dutchName = "Verbonden";

  @override
  final icon = FontAwesomeIcons.link;

  @override
  final dutchExplenationUrl =
      Uri.parse("https://www.qwixx.nl/varianten/qwixx-connected/");

  @override
  late final variants = [
    for (int i = 0; i < 6; i++) ConnectedVariantA(this, i),
    for (int i = 0; i < 6; i++) ConnectedVariantB(this, i),
  ];
}

class ConnectedVariantA extends Variant {
  ConnectedVariantA._internal({
    required super.category,
    required super.variantNumber,
    required super.rows,
    required super.nrOfMarkedCellsNeededToLock,
    required super.createChangesToMarkCell,
    required super.scoreCalculation,
  }) : super(variantLetter: VariantLetter.a);

  factory ConnectedVariantA(ConnectedCategory category, int variantNr) {
    assert(variantNr >= 0 && variantNr <= 5);

    return ConnectedVariantA._internal(
      category: category,
      variantNumber: variantNr,
      rows: _createRows(variantNr),
      nrOfMarkedCellsNeededToLock: 5,
      createChangesToMarkCell: _createChangesToMarkCell,
      scoreCalculation: _scoreCalculation(),
    );
  }

  static TotalScoreCalculation _scoreCalculation() {
    return TotalScoreCalculation([
      for (var color in CellColor.values) ColorScore(color),
      PurpleScore(),
      PenaltyScore()
    ]);
  }

  static List<Change<dynamic>> _createChangesToMarkCell(Game game, Cell cell) =>
      MarkCellChanges(game, cell);

  static List<CellRow> _createRows(int variantNr) {
    var rows = BasicVariantB.createRows();
    var firstRowNr = 0;
    var lastRowNr = 3;
    var rowNr = _rowNr(variantNr);
    var goingUp = variantNr % 2 != 0;
    for (var columnNr = 0; columnNr < CellRow.maxColumns; columnNr++) {
      rows[rowNr][columnNr] =
          rows[rowNr][columnNr].copyWith(variant: CellVariant.linkedStairs);
      rowNr = goingUp ? rowNr - 1 : rowNr + 1;
      goingUp = rowNr == lastRowNr
          ? true
          : rowNr == firstRowNr
              ? false
              : goingUp;
    }
    return rows;
  }

  static int _rowNr(int variantNr) {
    if (variantNr == 0) {
      return 0;
    }
    if (variantNr == 1 || variantNr == 2) {
      return 1;
    }
    if (variantNr == 3 || variantNr == 4) {
      return 2;
    }
    return 3;
  }
}

class ConnectedVariantB extends Variant {
  ConnectedVariantB._internal({
    required super.category,
    required super.variantNumber,
    required super.rows,
    required super.nrOfMarkedCellsNeededToLock,
    required super.createChangesToMarkCell,
    required super.scoreCalculation,
  }) : super(variantLetter: VariantLetter.b);

  factory ConnectedVariantB(ConnectedCategory category, int variantNr) {
    assert(variantNr >= 0 && variantNr <= 5);
    return ConnectedVariantB._internal(
      category: category,
      variantNumber: variantNr,
      rows: _createRows(variantNr),
      nrOfMarkedCellsNeededToLock: 5,
      createChangesToMarkCell: _createChangesToMarkCell,
      scoreCalculation: _createScoreCalculation(),
    );
  }

  static TotalScoreCalculation _createScoreCalculation() {
    return TotalScoreCalculation([
      for (var color in CellColor.values) ColorScore(color),
      PenaltyScore()
    ]);
  }

  static List<Change<dynamic>> _createChangesToMarkCell(Game game, Cell cell) {
    var changes = <Change>[];
    changes.addAll(MarkCellChanges(game, cell));
    if (changes.isNotEmpty && cell.variant == CellVariant.linkedWithCellAbove ||
        cell.variant == CellVariant.linkedWithCellBelow) {
      var rowIndex = game.variant.findRowIndex(cell);
      var cellIndex = game.variant.rows[rowIndex].indexOf(cell);
      var linkedRowIndex = cell.variant == CellVariant.linkedWithCellAbove
          ? rowIndex - 1
          : rowIndex + 1;
      var linkedCell = game.variant.rows[linkedRowIndex].elementAt(cellIndex);
      changes.add(ChangeCellState(
          game, linkedCell, NumberIdentifier.singleNumber, CellState.marked));
    }
    return changes;
  }

  static List<CellRow> _createRows(int variantNr) {
    var rows = BasicVariantB.createRows();
    var firstRowNr = 0;
    var lastRowNr = rows.length - 2;
    var rowNr = variantNr ~/ 2;
    var goingUp = variantNr % 2 != 0;
    var skipSecondColumn = variantNr % 2 != 0;
    var columnsToSkip = [
      0,
      skipSecondColumn ? 2 : 3,
      5,
      skipSecondColumn ? 7 : 8,
      10
    ];
    for (var columnNr = 0; columnNr < CellRow.maxColumns; columnNr++) {
      if (!columnsToSkip.contains(columnNr)) {
        rows[rowNr][columnNr] = rows[rowNr][columnNr]
            .copyWith(variant: CellVariant.linkedWithCellBelow);
        rows[rowNr + 1][columnNr] = rows[rowNr + 1][columnNr]
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

    return rows;
  }
}

class PurpleScore extends SubScoreCalculation {
  @override
  SubScoreResult calculateScore(Game game) {
    var allCells = game.variant.rows.expand((row) => row);
    var cellsOfColor = allCells
        .where((cell) => cell.variant == CellVariant.linkedStairs)
        .toList();
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
