// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

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
    super.addGroup(changes);
    game.notifyListeners();
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

/// a chinge changes that contins a group of changes
/// that can be undone in one go
class MultipleChanges extends Change {
  final List<Change> changes;

  MultipleChanges(this.changes)
      : super(
          null,
          () {
            for (var change in changes) {
              change.execute();
            }
          },
          (_) {
            for (var change in changes.reversed) {
              change.undo();
            }
          },
        );
}

class ChangeCellState extends Change<CellState> {
  ChangeCellState(Game game, Cell cell, CellState newState)
      : super(
          game.cellStates[cell]!,
          () => game.cellStates[cell] = newState,
          (oldState) => game.cellStates[cell] = oldState,
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

class LockRowByOtherPlayer extends MultipleChanges {
  LockRowByOtherPlayer._internal(super.changes);

  factory LockRowByOtherPlayer(Game game, int rowIndex) {
    var currentState = game.rowStates[rowIndex];
    var changes = <Change>[];
    if (currentState == RowState.none) {
      var row = game.variant.rows[rowIndex];
      for (var cell in row.reversed) {
        if (game.cellStates[cell] == CellState.marked) {
          break;
        }
        if (game.cellStates[cell] == CellState.none) {
          changes.add(ChangeCellState(game, cell, CellState.skipped));
        }
      }
      changes.add(ChangeRowState(game, rowIndex, RowState.lockedByOtherPlayer));
    }
    return LockRowByOtherPlayer._internal(changes);
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

class MarkCell extends MultipleChanges {
  MarkCell._internal(super.changes);

  factory MarkCell(Game game, Cell cell) {
    var changes = <Change>[];
    var currentState = game.cellStates[cell];
    if (currentState != CellState.none) {
      /// cell is marked or skipped: do nothing
      return MarkCell._internal([]);
    }
    if (game.variant.isLastCell(cell) && !game.canLock(cell.color)) {
      game.dutchMessage = "Bij deze variant kun je alleen een kleur sluiten "
          "wanneer je ${game.variant.nrOfMarkedCellsNeededToLock} of meer "
          "${cell.color.dutchName} cellen hebt gemarkeert.";
      return MarkCell._internal([]);
    }
    var preceidingCells = game.variant.preceidingCells(cell);
    for (var preceidingCell in preceidingCells) {
      if (game.cellStates[preceidingCell] == CellState.none) {
        changes.add(ChangeCellState(game, preceidingCell, CellState.skipped));
      }
    }
    changes.add(ChangeCellState(game, cell, CellState.marked));
    if (game.variant.isLastCell(cell) && game.canLock(cell.color)) {
      var rowIndex = game.variant.findRowIndex(cell);
      changes.add(ChangeRowState(game, rowIndex, RowState.lockedByMe));
      if (!game.finished) {
        game.dutchMessage = "Gefeliciteerd! Je hebt ${cell.color.dutchName} "
            "gesloten! Vertel het de overige spelers.";
      }
    }
    return MarkCell._internal(changes);
  }
}
