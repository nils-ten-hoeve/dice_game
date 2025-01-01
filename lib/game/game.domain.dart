// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.value.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:flutter/material.dart';
import 'package:undo/undo.dart';

class CellRow {
  final CellValue column1;
  final CellValue column2;
  final CellValue column3;
  final CellValue column4;
  final CellValue column5;
  final CellValue column6;
  final CellValue column7;
  final CellValue column8;
  final CellValue column9;
  final CellValue column10;
  final CellValue column11;

  CellRow(
      this.column1,
      this.column2,
      this.column3,
      this.column4,
      this.column5,
      this.column6,
      this.column7,
      this.column8,
      this.column9,
      this.column10,
      this.column11);

  List<CellValue> get values => [
        column1,
        column2,
        column3,
        column4,
        column5,
        column6,
        column7,
        column8,
        column9,
        column10,
        column11
      ];
}

abstract class GameVariant {
  final String name;
  final Uri explenationUrl;
  final CellRow row1;
  final CellRow row2;
  final CellRow row3;
  final CellRow row4;
  final int markedCellsToLock;

  GameVariant({
    required this.name,
    required this.explenationUrl,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
    required this.markedCellsToLock,
  }) {
    validateIfAllUnique();
  }

  void validateIfAllUnique() {
    var uniqueValues = {
      ...row1.values,
      ...row2.values,
      ...row3.values,
      ...row4.values
    };
    if (uniqueValues.length != CellValue.values.length) {
      throw Exception("Values must be unique");
    }
  }

  late final List<CellRow> rows = [row1, row2, row3, row4];

  List<CellValue> preceidingCells(CellValue value) {
    var row = findRow(value);
    var index = row.values.indexOf(value);
    return row.values.sublist(0, index);
  }

  CellRow findRow(CellValue value) =>
      rows.firstWhere((row) => row.values.contains(value));

  int findRowIndex(CellValue value) => rows.indexOf(findRow(value));

  bool isLastCell(CellValue value) {
    var row = findRow(value);
    return row.values.last == value;
  }
}

class BasicVariantA extends GameVariant {
  BasicVariantA()
      : super(
          name: "Basic Variant A",
          explenationUrl: Uri.parse("https://www.qwixx.nl/#basisspel"),
          row1: CellRow(
              CellValue.red2,
              CellValue.red3,
              CellValue.red4,
              CellValue.red5,
              CellValue.red6,
              CellValue.red7,
              CellValue.red8,
              CellValue.red9,
              CellValue.red10,
              CellValue.red11,
              CellValue.red12),
          row2: CellRow(
              CellValue.yellow2,
              CellValue.yellow3,
              CellValue.yellow4,
              CellValue.yellow5,
              CellValue.yellow6,
              CellValue.yellow7,
              CellValue.yellow8,
              CellValue.yellow9,
              CellValue.yellow10,
              CellValue.yellow11,
              CellValue.yellow12),
          row3: CellRow(
              CellValue.green2,
              CellValue.green3,
              CellValue.green4,
              CellValue.green5,
              CellValue.green6,
              CellValue.green7,
              CellValue.green8,
              CellValue.green9,
              CellValue.green10,
              CellValue.green11,
              CellValue.green12),
          row4: CellRow(
              CellValue.blue2,
              CellValue.blue3,
              CellValue.blue4,
              CellValue.blue5,
              CellValue.blue6,
              CellValue.blue7,
              CellValue.blue8,
              CellValue.blue9,
              CellValue.blue10,
              CellValue.blue11,
              CellValue.blue12),
          markedCellsToLock: 5,
        );
}

class BasicVariantB extends GameVariant {
  BasicVariantB()
      : super(
          name: "Basic Variant B",
          explenationUrl: Uri.parse("https://www.qwixx.nl/#basisspel"),
          row1: CellRow(
              CellValue.red2,
              CellValue.red3,
              CellValue.red4,
              CellValue.red5,
              CellValue.red6,
              CellValue.red7,
              CellValue.red8,
              CellValue.red9,
              CellValue.red10,
              CellValue.red11,
              CellValue.red12),
          row2: CellRow(
              CellValue.yellow2,
              CellValue.yellow3,
              CellValue.yellow4,
              CellValue.yellow5,
              CellValue.yellow6,
              CellValue.yellow7,
              CellValue.yellow8,
              CellValue.yellow9,
              CellValue.yellow10,
              CellValue.yellow11,
              CellValue.yellow12),
          row3: CellRow(
              CellValue.green12,
              CellValue.green11,
              CellValue.green10,
              CellValue.green9,
              CellValue.green8,
              CellValue.green7,
              CellValue.green6,
              CellValue.green5,
              CellValue.green4,
              CellValue.green3,
              CellValue.green2),
          row4: CellRow(
              CellValue.blue12,
              CellValue.blue11,
              CellValue.blue10,
              CellValue.blue9,
              CellValue.blue8,
              CellValue.blue7,
              CellValue.blue6,
              CellValue.blue5,
              CellValue.blue4,
              CellValue.blue3,
              CellValue.blue2),
          markedCellsToLock: 5,
        );
}

class MixedVariantA extends GameVariant {
  MixedVariantA()
      : super(
          name: "Mixed Variant A (kleuren)",
          explenationUrl: Uri.parse(
              "https://www.qwixx.nl/varianten/qwixx-mixx-uitbreiding/"),
          row1: CellRow(
              CellValue.yellow2,
              CellValue.yellow3,
              CellValue.yellow4,
              CellValue.blue5,
              CellValue.blue6,
              CellValue.blue7,
              CellValue.green8,
              CellValue.green9,
              CellValue.green10,
              CellValue.red11,
              CellValue.red12),
          row2: CellRow(
              CellValue.red2,
              CellValue.red3,
              CellValue.green4,
              CellValue.green5,
              CellValue.green6,
              CellValue.green7,
              CellValue.blue8,
              CellValue.blue9,
              CellValue.yellow10,
              CellValue.yellow11,
              CellValue.yellow12),
          row3: CellRow(
              CellValue.blue12,
              CellValue.blue11,
              CellValue.blue10,
              CellValue.yellow9,
              CellValue.yellow8,
              CellValue.yellow7,
              CellValue.red6,
              CellValue.red5,
              CellValue.red4,
              CellValue.green3,
              CellValue.green2),
          row4: CellRow(
              CellValue.green12,
              CellValue.green11,
              CellValue.red10,
              CellValue.red9,
              CellValue.red8,
              CellValue.red7,
              CellValue.yellow6,
              CellValue.yellow5,
              CellValue.blue4,
              CellValue.blue3,
              CellValue.blue2),
          markedCellsToLock: 6, //Note: this is different from others, see rules
        );
}

class MixedVariantB extends GameVariant {
  MixedVariantB()
      : super(
          name: "Mixed Variant B (nummers)",
          explenationUrl: Uri.parse(
              "https://www.qwixx.nl/varianten/qwixx-mixx-uitbreiding/"),
          row1: CellRow(
            CellValue.red10,
            CellValue.red6,
            CellValue.red2,
            CellValue.red8,
            CellValue.red3,
            CellValue.red4,
            CellValue.red12,
            CellValue.red5,
            CellValue.red9,
            CellValue.red7,
            CellValue.red11,
          ),
          row2: CellRow(
            CellValue.yellow9,
            CellValue.yellow12,
            CellValue.yellow4,
            CellValue.yellow6,
            CellValue.yellow7,
            CellValue.yellow2,
            CellValue.yellow5,
            CellValue.yellow8,
            CellValue.yellow11,
            CellValue.yellow3,
            CellValue.yellow10,
          ),
          row3: CellRow(
            CellValue.green8,
            CellValue.green2,
            CellValue.green10,
            CellValue.green12,
            CellValue.green6,
            CellValue.green9,
            CellValue.green7,
            CellValue.green4,
            CellValue.green5,
            CellValue.green11,
            CellValue.green3,
          ),
          row4: CellRow(
            CellValue.blue5,
            CellValue.blue7,
            CellValue.blue11,
            CellValue.blue9,
            CellValue.blue12,
            CellValue.blue3,
            CellValue.blue8,
            CellValue.blue10,
            CellValue.blue2,
            CellValue.blue6,
            CellValue.blue4,
          ),
          markedCellsToLock: 5,
        );
}

class GameVariants {
  final GameVariant basicVariantA = BasicVariantA();
  final GameVariant basicVariantB = BasicVariantB();
  final GameVariant mixedVariantA = MixedVariantA();
  final GameVariant mixedVariantB = MixedVariantB();
  late final List<GameVariant> all = [
    basicVariantA,
    basicVariantB,
    mixedVariantA,
    mixedVariantB,
  ];
}

class Game extends ChangeNotifier {
  final GameVariant variant;
  Game({required this.variant});

  late Map<CellValue, CellState> cellStates = {
    for (var cell in CellValue.values) cell: CellState.none
  };

  late List<RowState> rowStates = [
    for (var rowIndex = 0; rowIndex < variant.rows.length; rowIndex++)
      RowState.none
  ];

  late List<CellColor> rowLockColors = [
    for (var rowIndex = 0; rowIndex < variant.rows.length; rowIndex++)
      variant.rows[rowIndex].values.last.color
  ];

  bool get finished => twoRowsClosed || penalty.isMax;

  bool get twoRowsClosed =>
      rowStates.whereNot((RowState e) => e == RowState.none).length >= 2;

  final scoresConversion = ScoreConversion();

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

  int get redScore => scoresConversion.of(markedCount(CellColor.red));

  int get yellowScore => scoresConversion.of(markedCount(CellColor.yellow));

  int get greenScore => scoresConversion.of(markedCount(CellColor.green));

  int get blueScore => scoresConversion.of(markedCount(CellColor.blue));

  int get penaltyScore => penalty.count * -5;

  Panalty penalty = Panalty.none;

  int get totalScore =>
      redScore + yellowScore + greenScore + blueScore + penaltyScore;

  late GameChangeStack changes = GameChangeStack(this);

  /// This is a message to be displayed to the user.
  /// It is cleared when it is read
  String? dutchMessage;

  void markOrUnMarkCell(CellValue cellValue) {
    changes.add(MarkCell(this, cellValue));
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
      for (var cellValue in row.values.reversed) {
        if (game.cellStates[cellValue] == CellState.marked) {
          break;
        }
        if (game.cellStates[cellValue] == CellState.none) {
          game.cellStates[cellValue] = CellState.skipped;
        }
      }
      game.rowStates[rowIndex] = RowState.lockedByOtherPlayer;
    }
  }

  static void _unlockRow(Game game, int rowIndex) {
    var currentState = game.rowStates[rowIndex];
    if (currentState == RowState.lockedByOtherPlayer) {
      var row = game.variant.rows[rowIndex];
      for (var cellValue in row.values.reversed) {
        if (game.cellStates[cellValue] == CellState.marked) {
          break;
        }
        if (game.cellStates[cellValue] == CellState.skipped) {
          game.cellStates[cellValue] = CellState.none;
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

class MarkCell extends Change<CellValue> {
  MarkCell(Game game, CellValue cellValue)
      : super(
          cellValue,
          () => _markCell(game, cellValue),
          (oldCellValue) => _unMarkCell(game, oldCellValue),
        );

  static void _markCell(Game game, CellValue value) {
    var currentState = game.cellStates[value];
    if (currentState != CellState.none) {
      /// cell is marked or skipped: do nothing
      return;
    }
    if (game.variant.isLastCell(value) && !game.canLock(value.color)) {
      game.dutchMessage = "Bij deze variant kun je alleen een kleur sluiten "
          "wanneer je ${game.variant.markedCellsToLock} of meer "
          "${value.color.dutchName} cellen hebt gemarkeert.";
      return;
    }
    var preceidingCells = game.variant.preceidingCells(value);
    for (var preceidingCell in preceidingCells) {
      if (game.cellStates[preceidingCell] == CellState.none) {
        game.cellStates[preceidingCell] = CellState.skipped;
      }
    }
    game.cellStates[value] = CellState.marked;
    if (game.variant.isLastCell(value) && game.canLock(value.color)) {
      lockRow(game, value);
      if (!game.finished) {
        game.dutchMessage = "Gefeliciteerd! Je hebt ${value.color.dutchName} "
            "gesloten! Vertel het de overige spelers.";
      }
    }
  }

  static void lockRow(Game game, CellValue value) {
    var rowIndex = game.variant.findRowIndex(value);
    game.rowStates[rowIndex] = RowState.lockedByMe;
  }

  static void _unMarkCell(Game game, CellValue value) {
    var preceidingCells = game.variant.preceidingCells(value);
    var currentState = game.cellStates[value];
    if (currentState == CellState.marked) {
      for (var preceidingCell in preceidingCells.reversed) {
        if (game.cellStates[preceidingCell] == CellState.marked) {
          break;
        }
        if (game.cellStates[preceidingCell] == CellState.skipped) {
          game.cellStates[preceidingCell] = CellState.none;
        }
      }
      game.cellStates[value] = CellState.none;
      var rowIndex = game.variant.findRowIndex(value);
      if (game.variant.isLastCell(value) &&
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

class ScoreConversion extends DelegatingMap<int, int> {
  ScoreConversion()
      : super({
          0: 0,
          1: 1,
          2: 3,
          3: 6,
          4: 10,
          5: 15,
          6: 21,
          7: 28,
          8: 36,
          9: 45,
          10: 55,
          11: 66,
          12: 78
        });

  int of(int count) => this[count]!;
}
