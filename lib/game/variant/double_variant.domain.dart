// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

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
      name: "Dubbel Variant A (Treden)",
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
      createChangesToMarkCell: (Game game, Cell cell) =>
          MarkCellChangesForDoubleVariantA(game, cell),
      scoreCalculation: TotalScoreCalculation([
        for (var color in CellColor.values) ColorScore(color),
        PenaltyScore()
      ]),
    );
  }
}

class MarkCellChangesForDoubleVariantA extends UnmodifiableListView<Change> {
  MarkCellChangesForDoubleVariantA._internal(super.changes);

  factory MarkCellChangesForDoubleVariantA(Game game, Cell cell) {
    var changes = <Change>[];
    var currentStates = game.cellStates[cell]!;
    if (canNotMarkCell(currentStates)) {
      return MarkCellChangesForDoubleVariantA._internal([]);
    }

    if (canNotLockRow(game, cell)) {
      game.dutchMessage = "Bij deze variant kun je alleen een kleur sluiten "
          "wanneer je ${game.variant.nrOfMarkedCellsNeededToLock} of meer "
          "${cell.color.dutchName} cellen hebt gemarkeert.";
      return MarkCellChangesForDoubleVariantA._internal([]);
    }

    changes.addAll(skipPreceidingCellsChanges(game, cell));

    changes.add(ChangeCellState(
      game,
      cell,
      identifierToMark(game, cell),
      CellState.marked,
    ));

    if (canLockRow(game, cell)) {
      var rowIndex = game.variant.findRowIndex(cell);
      changes.add(ChangeRowState(game, rowIndex, RowState.lockedByMe));
      if (!game.finished) {
        game.dutchMessage = "Gefeliciteerd! Je hebt ${cell.color.dutchName} "
            "gesloten! Vertel het de overige spelers.";
      }
    }
    return MarkCellChangesForDoubleVariantA._internal(changes);
  }

  static List<Change> skipPreceidingCellsChanges(Game game, Cell cell) {
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

  static bool canNotLockRow(Game game, Cell cell) =>
      game.variant.isLastCell(cell) && !game.canLock(cell.color);

  static bool canLockRow(Game game, Cell cell) =>
      game.variant.isLastCell(cell) && game.canLock(cell.color);

  static CellStateIdentifier identifierToMark(Game game, Cell cell) {
    var identifiers = cell.variant.numbersPerCell.identifiers;
    if (identifiers.length == 1) {
      return identifiers.first;
    }
    return markTopCell(game, cell)
        ? CellStateIdentifier.topNumber
        : CellStateIdentifier.bottomNumber;
  }

  static bool markTopCell(Game game, Cell cell) =>
      game.cellStates[cell]![CellStateIdentifier.topNumber] == CellState.none;

  static bool canNotMarkCell(CellStates currentStates) =>
      currentStates.values.none((state) => state == CellState.none);
}
