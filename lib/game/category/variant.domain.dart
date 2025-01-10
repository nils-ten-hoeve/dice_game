// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dice_game/game/category/category.domain.dart';
import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:undo/undo.dart';

enum VariantLetter { a, b }

abstract class Variant {
  final Category category;
  final VariantLetter variantLetter;
  int? variantNumber;
  final List<CellRow> rows;
  final int nrOfMarkedCellsNeededToLock;
  final List<Change> Function(Game game, Cell cell) createChangesToMarkCell;
  final TotalScoreCalculation scoreCalculation;

  Variant({
    required this.category,
    required this.variantLetter,
    this.variantNumber,
    required this.rows,
    required this.nrOfMarkedCellsNeededToLock,
    required this.createChangesToMarkCell,
    required this.scoreCalculation,
  }) {
    validateIfAllUnique();
  }

  late final name = '${variantLetter.name.toUpperCase()}'
      '${variantNumber == null ? "" : variantNumber! + 1}';

  void validateIfAllUnique() {
    var allValues = rows.expand((row) => row);
    var uniqueValues = allValues.toSet();
    if (uniqueValues.length != allValues.length) {
      throw Exception("Values must be unique");
    }
  }

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
