// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:collection/collection.dart';
import 'package:dice_game/game/category/category.domain.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/category/basic.domain.dart';
import 'package:dice_game/game/category/variant.domain.dart';
import 'package:undo/undo.dart';

class DoubleCategory extends Category {
  @override
  final dutchName = "Dubbel";

  @override
  final dutchExplenationUrl =
      Uri.parse("https://www.qwixx.nl/varianten/qwixx-dubbel/");

  @override
  late final variants = [
    DoubleVariantA(this),
    for (int i = 0; i < 2; i++) DoubleVariantB(this, i),
  ];
}

class DoubleVariantA extends Variant {
  DoubleVariantA._internal({
    required super.category,
    required super.rows,
    required super.nrOfMarkedCellsNeededToLock,
    required super.createChangesToMarkCell,
    required super.scoreCalculation,
  }) : super(variantLetter: VariantLetter.a);

  factory DoubleVariantA(DoubleCategory cagategory) {
    return DoubleVariantA._internal(
      category: cagategory,
      rows: _createRows(),
      nrOfMarkedCellsNeededToLock: 7,
      createChangesToMarkCell: _createChangesToMarkCell,
      scoreCalculation: _scoreCalculation(),
    );
  }

  static TotalScoreCalculation _scoreCalculation() {
    return TotalScoreCalculation([
      for (var color in CellColor.values) ColorScore(color),
      PenaltyScore()
    ]);
  }

  static List<Change<dynamic>> _createChangesToMarkCell(Game game, Cell cell) =>
      _MarkCellFactory(
        game,
        cell,
        markBothNumbers: false,
      ).createChanges();

  static List<CellRow> _createRows() {
    var rows = BasicVariantB.createRows();

    for (var rowNr = 0; rowNr < rows.length; rowNr++) {
      for (var columnNr = 0; columnNr < CellRow.maxColumns; columnNr++) {
        if (columnNr != CellRow.maxColumns - 1) {
          rows[rowNr][columnNr] = rows[rowNr][columnNr]
              .copyWith(variant: CellVariant.doubleNumberMarkedOneByOne);
        }
      }
    }
    return rows;
  }
}

class DoubleVariantB extends Variant {
  DoubleVariantB._internal({
    required super.category,
    required super.variantNumber,
    required super.rows,
    required super.nrOfMarkedCellsNeededToLock,
    required super.createChangesToMarkCell,
    required super.scoreCalculation,
  }) : super(variantLetter: VariantLetter.b);

  factory DoubleVariantB(DoubleCategory category, int variantNr) {
    assert(variantNr >= 0 && variantNr <= 1);

    return DoubleVariantB._internal(
      category: category,
      variantNumber: variantNr,
      rows: _createRows(variantNr),
      nrOfMarkedCellsNeededToLock: 7,
      createChangesToMarkCell: _createChangesToMarkCell,
      scoreCalculation: _scoreCalculation(),
    );
  }

  static List<CellRow> _createRows(int variantNr) {
    var rows = BasicVariantB.createRows();

    final cellsToSkip1 = [0, 2, 4, 5, 6, 8, 10];
    final cellsToSkip2 = [0, 1, 3, 5, 7, 9, 10, 11];
    var rowsWithCellsToSkip = variantNr == 0
        ? [cellsToSkip1, cellsToSkip1, cellsToSkip2, cellsToSkip2]
        : [cellsToSkip2, cellsToSkip2, cellsToSkip1, cellsToSkip1];
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      var cellsToSkip = rowsWithCellsToSkip[rowIndex];
      for (var columnIndex = 0;
          columnIndex < CellRow.maxColumns;
          columnIndex++) {
        if (!cellsToSkip.contains(columnIndex)) {
          rows[rowIndex][columnIndex] = rows[rowIndex][columnIndex]
              .copyWith(variant: CellVariant.doubleNumberMarkedOneByOne);
        }
      }
    }
    return rows;
  }

  static TotalScoreCalculation _scoreCalculation() {
    return TotalScoreCalculation([
      for (var color in CellColor.values) ColorScore(color),
      PenaltyScore()
    ]);
  }

  static List<Change<dynamic>> _createChangesToMarkCell(Game game, Cell cell) =>
      _MarkCellFactory(
        game,
        cell,
        markBothNumbers: true,
      ).createChanges();
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

  List<NumberIdentifier> get identifiersToMark {
    var identifiers = cell.variant.numbersPerCell.identifiers;
    if (identifiers.length == 1) {
      return [identifiers.first];
    }
    if (markBothNumbers) {
      return cell.variant.numbersPerCell.identifiers;
    }
    return markTopCell
        ? [NumberIdentifier.topNumber]
        : [NumberIdentifier.bottomNumber];
  }

  bool get markTopCell =>
      game.cellStates[cell]![NumberIdentifier.topNumber] == CellState.none;

  bool get canNotMarkCell =>
      game.cellStates[cell]!.values.none((state) => state == CellState.none);
}
