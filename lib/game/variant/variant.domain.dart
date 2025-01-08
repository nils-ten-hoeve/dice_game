// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:collection/collection.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/variant/basic_variant.domain.dart';
import 'package:dice_game/game/variant/connected_variant.domain.dart';
import 'package:dice_game/game/variant/double_variant.domain.dart';
import 'package:dice_game/game/variant/mixed_variant.domain.dart';
import 'package:undo/undo.dart';

abstract class GameVariant {
  final String name;
  final Uri explenationUrl;
  final CellRow row1;
  final CellRow row2;
  final CellRow row3;
  final CellRow row4;
  final int nrOfMarkedCellsNeededToLock;
  final List<Change> Function(Game game, Cell cell) createChangesToMarkCell;
  final TotalScoreCalculation scoreCalculation;

  GameVariant({
    required this.name,
    required this.explenationUrl,
    required this.row1,
    required this.row2,
    required this.row3,
    required this.row4,
    required this.nrOfMarkedCellsNeededToLock,
    required this.createChangesToMarkCell,
    required this.scoreCalculation,
  }) {
    validateIfAllUnique();
  }

  void validateIfAllUnique() {
    var allValues = rows.expand((row) => row);
    var uniqueValues = allValues.toSet();
    if (uniqueValues.length != allValues.length) {
      throw Exception("Values must be unique");
    }
  }

  late final List<CellRow> rows = [row1, row2, row3, row4];

  List<Cell> preceidingCells(Cell cell) {
    var row = findRow(cell);
    var index = row.indexOf(cell);
    return row.sublist(0, index);
  }

  CellRow findRow(Cell cell) => rows.firstWhere((row) => row.contains(cell));

  int findRowIndex(Cell cell) => rows.indexOf(findRow(cell));

  bool isLastCell(Cell cell) {
    var row = findRow(cell);
    return row.last == cell;
  }
}

class GameVariants extends DelegatingList<GameVariant> {
  GameVariants()
      : super([
          BasicVariantA(),
          BasicVariantB(),
          MixedVariantA(),
          MixedVariantB(),
          ConnectedVariantA(),
          ConnectedVariantB(),
          DoubleVariantA(),
        ]);
}
