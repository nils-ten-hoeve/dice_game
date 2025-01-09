// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:undo/undo.dart';

/// This is a wrapper class to ensure that the
/// [game] listeners are automatically notified of new changes

class GameChangeStack extends ChangeStack {
  final Game game;

  GameChangeStack(this.game, {super.limit});

  @override
  void add<T>(Change<T> change) {
    super.add(change);
    game.notifyListeners();
  }

  @override
  void addGroup<T>(List<Change<T>> changes) {
    if (changes.isNotEmpty) {
      super.addGroup(changes);
      game.notifyListeners();
    }
  }

  @override
  void clearHistory() {
    super.clearHistory();
    game.notifyListeners();
  }

  @override
  void undo() {
    super.undo();
    game.notifyListeners();
  }

  @override
  void redo() {
    super.redo();
    game.notifyListeners();
  }
}

class ChangeCellState extends Change<CellState> {
  ChangeCellState(Game game, Cell cell, NumberIdentifier numberIdentifier,
      CellState newState)
      : super(
          game.cellStates[cell]![numberIdentifier]!,
          () => game.cellStates[cell]![numberIdentifier] = newState,
          (oldState) => game.cellStates[cell]![numberIdentifier] = oldState,
        );
}

class ChangeRowState extends Change<RowState> {
  ChangeRowState(Game game, int rowIndex, RowState newState)
      : super(
          game.rowStates[rowIndex],
          () => game.rowStates[rowIndex] = newState,
          (oldState) => game.rowStates[rowIndex] = oldState,
        );
}

class LockRowByOtherPlayerChanges extends UnmodifiableListView<Change> {
  LockRowByOtherPlayerChanges._internal(super.changes);

  factory LockRowByOtherPlayerChanges(Game game, int rowIndex) {
    var changes = <Change>[];
    if (game.rowStates[rowIndex] == RowState.none) {
      changes.addAll(skipPreceidingCellsChanges(game, rowIndex));
      changes.add(ChangeRowState(game, rowIndex, RowState.lockedByOtherPlayer));
    }
    return LockRowByOtherPlayerChanges._internal(changes);
  }

  static List<Change> skipPreceidingCellsChanges(Game game, int rowIndex) {
    var changes = <Change>[];
    var row = game.variant.rows[rowIndex];
    for (var cell in row.reversed) {
      for (var numberIdentifier
          in cell.variant.numbersPerCell.identifiers.reversed) {
        if (game.cellStates[cell]![numberIdentifier] == CellState.marked) {
          return changes;
        }
        if (game.cellStates[cell]![numberIdentifier] == CellState.none) {
          changes.add(
              ChangeCellState(game, cell, numberIdentifier, CellState.skipped));
        }
      }
    }
    return changes;
  }
}

class AddPenalty extends Change<Panalty> {
  AddPenalty(Game game)
      : super(
          game.penalty,
          () => _addPenalty(game),
          (oldValue) => game.penalty = oldValue,
        );

  static void _addPenalty(Game game) {
    if (game.penalty.count < 4) {
      game.penalty = Panalty.values[game.penalty.count + 1];
    }
  }
}

class MarkCellChanges extends UnmodifiableListView<Change> {
  MarkCellChanges._internal(super.changes);

  factory MarkCellChanges(Game game, Cell cell) {
    var changes = <Change>[];
    var currentStates = game.cellStates[cell]!;

    if (canNotMarkCell(currentStates)) {
      return MarkCellChanges._internal([]);
    }

    if (canNotLockRow(game, cell)) {
      game.dutchMessage = "Bij deze variant kun je alleen een kleur sluiten "
          "wanneer je ${game.variant.nrOfMarkedCellsNeededToLock} of meer "
          "${cell.color.dutchName} cellen hebt gemarkeert.";
      return MarkCellChanges._internal([]);
    }

    changes.addAll(skipPreceidingCellChanges(game, cell));
    changes.add(ChangeCellState(
      game,
      cell,
      NumberIdentifier.singleNumber,
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
    return MarkCellChanges._internal(changes);
  }

  static List<Change> skipPreceidingCellChanges(Game game, Cell cell) {
    var changes = <Change>[];
    var preceidingCells = game.variant.preceidingCells(cell);
    for (var preceidingCell in preceidingCells) {
      if (game.cellStates[preceidingCell]![NumberIdentifier.singleNumber] ==
          CellState.none) {
        changes.add(ChangeCellState(
          game,
          preceidingCell,
          NumberIdentifier.singleNumber,
          CellState.skipped,
        ));
      }
    }
    return changes;
  }

  static bool canLockRow(Game game, Cell cell) =>
      game.variant.isLastCell(cell) && game.canLock(cell.color);

  static bool canNotLockRow(Game game, Cell cell) =>
      game.variant.isLastCell(cell) && !game.canLock(cell.color);

  static bool canNotMarkCell(CellStates currentStates) =>
      currentStates[NumberIdentifier.singleNumber] != CellState.none;
}
