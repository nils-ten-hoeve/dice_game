// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/variant/basic_variant.domain.dart';
import 'package:dice_game/game/variant/variant.domain.dart';
import 'package:undo/undo.dart';

class DoubleVariantA extends GameVariant {
  DoubleVariantA._internal({
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

  factory DoubleVariantA() {
    var baseRows = BasicVariantB().rows;
    Map<(int rowNr, int columnNr), Cell> cells = {};
    var columnLength = baseRows.first.length;
    for (var rowNr = 0; rowNr < baseRows.length; rowNr++) {
      for (var columnNr = 0; columnNr < columnLength; columnNr++) {
        cells[(rowNr, columnNr)] = baseRows[rowNr][columnNr];
      }
    }

    for (var rowNr = 0; rowNr < baseRows.length; rowNr++) {
      for (var columnNr = 0; columnNr < columnLength; columnNr++) {
        if (columnNr != columnLength - 1) {
          cells[(rowNr, columnNr)] = cells[(rowNr, columnNr)]!
              .copyWith(variant: CellVariant.doubleNumberMarkedOneByOne);
        }
      }
    }

    return DoubleVariantA._internal(
      name: "Dubbel Variant A",
      explenationUrl: Uri.parse("https://www.qwixx.nl/varianten/qwixx-dubbel/"),
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
      nrOfMarkedCellsNeededToLock: 7,
      createChangesToMarkCell: (Game game, Cell cell) => _MarkCellFactory(
        game,
        cell,
        markBothNumbers: false,
      ).createChanges(),
      scoreCalculation: TotalScoreCalculation([
        for (var color in CellColor.values) ColorScore(color),
        PenaltyScore()
      ]),
    );
  }
}

class DoubleVariantB extends GameVariant {
  DoubleVariantB._internal({
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

  factory DoubleVariantB() {
    var baseRows = BasicVariantB().rows;
    Map<(int rowNr, int columnNr), Cell> cells = {};
    var columnLength = baseRows.first.length;
    for (var rowNr = 0; rowNr < baseRows.length; rowNr++) {
      for (var columnNr = 0; columnNr < columnLength; columnNr++) {
        cells[(rowNr, columnNr)] = baseRows[rowNr][columnNr];
      }
    }

    final cellsToSkip1 = [0, 2, 4, 5, 6, 8, 10];
    final cellsToSkip2 = [0, 1, 3, 5, 7, 9, 10, 11];
    final variantB = Random().nextBool();
    var rowsWithCellsToSkip = variantB
        ? [cellsToSkip1, cellsToSkip1, cellsToSkip2, cellsToSkip2]
        : [cellsToSkip2, cellsToSkip2, cellsToSkip1, cellsToSkip1];
    for (int rowIndex = 0; rowIndex < baseRows.length; rowIndex++) {
      var cellsToSkip = rowsWithCellsToSkip[rowIndex];
      for (var columnIndex = 0; columnIndex < columnLength; columnIndex++) {
        if (!cellsToSkip.contains(columnIndex)) {
          cells[(rowIndex, columnIndex)] = cells[(rowIndex, columnIndex)]!
              .copyWith(variant: CellVariant.doubleNumberMarkedOneByOne);
        }
      }
    }

    return DoubleVariantB._internal(
      name: "Dubbel Variant B",
      explenationUrl: Uri.parse("https://www.qwixx.nl/varianten/qwixx-dubbel/"),
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
      nrOfMarkedCellsNeededToLock: 7,
      createChangesToMarkCell: (Game game, Cell cell) => _MarkCellFactory(
        game,
        cell,
        markBothNumbers: true,
      ).createChanges(),
      scoreCalculation: TotalScoreCalculation([
        for (var color in CellColor.values) ColorScore(color),
        PenaltyScore()
      ]),
    );
  }
}

class _MarkCellFactory {
  final Game game;
  final Cell cell;
  final bool markBothNumbers;

  _MarkCellFactory(this.game, this.cell, {required this.markBothNumbers});

  List<Change> createChanges() {
    var changes = <Change>[];
    if (canNotMarkCell) {
      return [];
    }

    if (canNotLockRow) {
      game.dutchMessage = "Bij deze variant kun je alleen een kleur sluiten "
          "wanneer je ${game.variant.nrOfMarkedCellsNeededToLock} of meer "
          "${cell.color.dutchName} cellen hebt gemarkeert.";
      return [];
    }

    changes.addAll(skipPreceidingCellsChanges);

    for (var identifierToMark in identifiersToMark) {
      changes.add(ChangeCellState(
        game,
        cell,
        identifierToMark,
        CellState.marked,
      ));
    }

    if (canLockRow) {
      var rowIndex = game.variant.findRowIndex(cell);
      changes.add(ChangeRowState(game, rowIndex, RowState.lockedByMe));
      if (!game.finished) {
        game.dutchMessage = "Gefeliciteerd! Je hebt ${cell.color.dutchName} "
            "gesloten! Vertel het de overige spelers.";
      }
    }
    return changes;
  }

  List<Change> get skipPreceidingCellsChanges {
    var changes = <Change>[];
    var preceidingCells = game.variant.preceidingCells(cell);
    for (var preceidingCell in preceidingCells) {
      for (var numberIdentifier
          in preceidingCell.variant.numbersPerCell.identifiers) {
        if (game.cellStates[preceidingCell]![numberIdentifier] ==
            CellState.none) {
          changes.add(ChangeCellState(
            game,
            preceidingCell,
            numberIdentifier,
            CellState.skipped,
          ));
        }
      }
    }
    return changes;
  }

  bool get canNotLockRow =>
      game.variant.isLastCell(cell) && !game.canLock(cell.color);

  bool get canLockRow =>
      game.variant.isLastCell(cell) && game.canLock(cell.color);

  List<CellStateIdentifier> get identifiersToMark {
    var identifiers = cell.variant.numbersPerCell.identifiers;
    if (identifiers.length == 1) {
      return [identifiers.first];
    }
    if (markBothNumbers) {
      return cell.variant.numbersPerCell.identifiers;
    }
    return markTopCell
        ? [CellStateIdentifier.topNumber]
        : [CellStateIdentifier.bottomNumber];
  }

  bool get markTopCell =>
      game.cellStates[cell]![CellStateIdentifier.topNumber] == CellState.none;

  bool get canNotMarkCell =>
      game.cellStates[cell]!.values.none((state) => state == CellState.none);
}
