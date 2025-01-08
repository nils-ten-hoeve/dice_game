// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/dice/dice.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/variant/variant.domain.dart';
import 'package:flutter/material.dart';

class Game extends ChangeNotifier {
  final GameVariant variant;
  Game({required this.variant});

  late Map<Cell, CellStates> cellStates = {
    for (var cell in variant.rows.expand((row) => row))
      cell: {
        for (var numberIdentifier in cell.variant.numbersPerCell.identifiers)
          numberIdentifier: CellState.none
      }
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

  Panalty penalty = Panalty.none;

  late GameChangeStack changes = GameChangeStack(this);

  /// This is a message to be displayed to the user.
  /// It is null when it is read or when there are no messages
  String? _dutchMessage;

  String? get dutchMessage => _dutchMessage;

  set dutchMessage(String? newDutchMessage) {
    _dutchMessage = newDutchMessage;
    if (newDutchMessage != null) {
      notifyListeners();
    }
  }

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
    changes.addGroup(variant.createChangesToMarkCell(this, cell));
  }

  void lockRowByOtherPlayer(int rowIndex) {
    changes.addGroup(LockRowByOtherPlayerChanges(this, rowIndex));
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

  bool isClosed(CellColor color) =>
      rowStates[rowLockColors.indexOf(color)] != RowState.none;

  bool canLock(CellColor color) {
    var markedCells = ColorScore(color).calculateScore(this).count;
    return markedCells >= variant.nrOfMarkedCellsNeededToLock;
  }
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

abstract class WithDutchMessage {
  String get dutchMessage;
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
