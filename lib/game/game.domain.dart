// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/dice/dice.domain.dart';
import 'package:dice_game/game/variant/variant.domain.dart';
import 'package:flutter/material.dart';
import 'package:undo/undo.dart';

class Game extends ChangeNotifier {
  final GameVariant variant;
  Game({required this.variant});

  late Map<Cell, CellState> cellStates = {
    for (var cell in variant.rows.expand((row) => row)) cell: CellState.none
  };

  late List<RowState> rowStates = [
    for (var rowIndex = 0; rowIndex < variant.rows.length; rowIndex++)
      RowState.none
  ];

  late List<CellColor> rowLockColors = [
    for (var rowIndex = 0; rowIndex < variant.rows.length; rowIndex++)
      variant.rows[rowIndex].last.color
  ];

  bool get finished => twoRowsClosed || penalty.isMax;

  bool get twoRowsClosed =>
      rowStates.whereNot((RowState e) => e == RowState.none).length >= 2;

  int markedCount(CellColor cellColor) =>
      _markedCellCount(cellColor) + _markedLockCount(cellColor);

  int _markedCellCount(CellColor cellColor) => cellStates.entries
      .where((MapEntry e) =>
          e.key.color == cellColor && e.value == CellState.marked)
      .length;

  int _markedLockCount(CellColor cellColor) {
    var rowLockIndex = rowLockColors.indexOf(cellColor);
    return rowStates[rowLockIndex] == RowState.lockedByMe ? 1 : 0;
  }

  Panalty penalty = Panalty.none;

  late GameChangeStack changes = GameChangeStack(this);

  /// This is a message to be displayed to the user.
  /// It is null when it is read or when there are no messages
  String? dutchMessage;

  bool _showDice = false;

  late final Dice dice = Dice(this);

  bool get showDice => _showDice;
  set showDice(bool visible) {
    _showDice = visible;
    if (visible) {
      dice.roll();
    }
    notifyListeners();
  }

  void markOrUnMarkCell(Cell cell) {
    changes.add(MarkCell(this, cell));
  }

  void lockRowByOtherPlayer(int rowIndex) {
    changes.add(LockRowByOtherPlayer(this, rowIndex));
  }

  void addPenalty() {
    changes.add(AddPenalty(this));
  }

  void undo() {
    changes.undo();
  }

  void redo() {
    changes.redo();
  }

  bool canLock(CellColor color) =>
      markedCount(color) >= variant.markedCellsToLock;

  bool isClosed(CellColor color) =>
      rowStates[rowLockColors.indexOf(color)] != RowState.none;
}

enum CellState {
  none(' '),
  marked('X'),
  skipped('–');

  final String text;
  const CellState(this.text);
}

enum RowState {
  none(CellState.none),
  lockedByMe(CellState.marked),
  lockedByOtherPlayer(CellState.skipped);

  final CellState asCellState;
  const RowState(this.asCellState);
}

class LockRowByOtherPlayer extends Change<RowState> {
  LockRowByOtherPlayer(Game game, int rowIndex)
      : super(
          game.rowStates[rowIndex],
          () => _lockRowByOtherPlayer(game, rowIndex),
          (oldRowState) => _unlockRow(game, rowIndex),
        );

  static void _lockRowByOtherPlayer(Game game, int rowIndex) {
    var currentState = game.rowStates[rowIndex];
    if (currentState == RowState.none) {
      var row = game.variant.rows[rowIndex];
      for (var cell in row.reversed) {
        if (game.cellStates[cell] == CellState.marked) {
          break;
        }
        if (game.cellStates[cell] == CellState.none) {
          game.cellStates[cell] = CellState.skipped;
        }
      }
      game.rowStates[rowIndex] = RowState.lockedByOtherPlayer;
    }
  }

  static void _unlockRow(Game game, int rowIndex) {
    var currentState = game.rowStates[rowIndex];
    if (currentState == RowState.lockedByOtherPlayer) {
      var row = game.variant.rows[rowIndex];
      for (var cell in row.reversed) {
        if (game.cellStates[cell] == CellState.marked) {
          break;
        }
        if (game.cellStates[cell] == CellState.skipped) {
          game.cellStates[cell] = CellState.none;
        }
      }
      game.rowStates[rowIndex] = RowState.none;
    }
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

abstract class WithDutchMessage {
  String get dutchMessage;
}

class MarkCell extends Change<Cell> {
  MarkCell(Game game, Cell cell)
      : super(
          cell,
          () => _markCell(game, cell),
          (oldCellValue) => _unMarkCell(game, oldCellValue),
        );

  static void _markCell(Game game, Cell cell) {
    var currentState = game.cellStates[cell];
    if (currentState != CellState.none) {
      /// cell is marked or skipped: do nothing
      return;
    }
    if (game.variant.isLastCell(cell) && !game.canLock(cell.color)) {
      game.dutchMessage = "Bij deze variant kun je alleen een kleur sluiten "
          "wanneer je ${game.variant.markedCellsToLock} of meer "
          "${cell.color.dutchName} cellen hebt gemarkeert.";
      return;
    }
    var preceidingCells = game.variant.preceidingCells(cell);
    for (var preceidingCell in preceidingCells) {
      if (game.cellStates[preceidingCell] == CellState.none) {
        game.cellStates[preceidingCell] = CellState.skipped;
      }
    }
    game.cellStates[cell] = CellState.marked;
    if (game.variant.isLastCell(cell) && game.canLock(cell.color)) {
      lockRow(game, cell);
      if (!game.finished) {
        game.dutchMessage = "Gefeliciteerd! Je hebt ${cell.color.dutchName} "
            "gesloten! Vertel het de overige spelers.";
      }
    }
  }

  static void lockRow(Game game, Cell cell) {
    var rowIndex = game.variant.findRowIndex(cell);
    game.rowStates[rowIndex] = RowState.lockedByMe;
  }

  static void _unMarkCell(Game game, Cell cell) {
    var preceidingCells = game.variant.preceidingCells(cell);
    var currentState = game.cellStates[cell];
    if (currentState == CellState.marked) {
      for (var preceidingCell in preceidingCells.reversed) {
        if (game.cellStates[preceidingCell] == CellState.marked) {
          break;
        }
        if (game.cellStates[preceidingCell] == CellState.skipped) {
          game.cellStates[preceidingCell] = CellState.none;
        }
      }
      game.cellStates[cell] = CellState.none;
      var rowIndex = game.variant.findRowIndex(cell);
      if (game.variant.isLastCell(cell) &&
          game.rowStates[rowIndex] == RowState.lockedByMe) {
        _unLockRow(game, rowIndex);
      }
    }
  }

  static void _unLockRow(Game game, int rowIndex) {
    game.rowStates[rowIndex] = RowState.none;
  }
}

enum Panalty {
  none(0),
  one(1),
  two(2),
  three(3),
  four(4);

  final int count;

  const Panalty(this.count);

  bool get isMax => count == 4;
}
