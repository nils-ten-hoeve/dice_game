// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/category/category.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/category/variant.domain.dart';

const List<int> twoTroughTwelve = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
const List<int> twelveTroughTwo = [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];

class BasicCategory extends Category {
  @override
  final dutchName = "Basic";

  @override
  final dutchExplenationUrl = Uri.parse("https://www.qwixx.nl/#basisspel");

  @override
  late final variants = [
    BasicVariantA(this),
    BasicVariantB(this),
  ];
}

class BasicVariantA extends Variant {
  BasicVariantA(BasicCategory basicCategory)
      : super(
          category: basicCategory,
          variantLetter: VariantLetter.a,
          rows: createRows(),
          nrOfMarkedCellsNeededToLock: 5,
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCellChanges(game, cell),
          scoreCalculation: _createScoreCalculation(),
        );

  static TotalScoreCalculation _createScoreCalculation() =>
      TotalScoreCalculation([
        for (var color in CellColor.values) ColorScore(color),
        PenaltyScore()
      ]);

  static List<CellRow> createRows() => [
        CellRow([
          for (var number in twoTroughTwelve) Cell(CellColor.red, number),
        ]),
        CellRow([
          for (var number in twoTroughTwelve) Cell(CellColor.yellow, number),
        ]),
        CellRow([
          for (var number in twoTroughTwelve) Cell(CellColor.green, number),
        ]),
        CellRow([
          for (var number in twoTroughTwelve) Cell(CellColor.blue, number),
        ]),
      ];
}

class BasicVariantB extends Variant {
  BasicVariantB(BasicCategory basicCategory)
      : super(
          category: basicCategory,
          variantLetter: VariantLetter.b,
          rows: createRows(),
          nrOfMarkedCellsNeededToLock: 5,
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCellChanges(game, cell),
          scoreCalculation: _createTotalScore(),
        );

  static TotalScoreCalculation _createTotalScore() {
    return TotalScoreCalculation([
      for (var color in CellColor.values) ColorScore(color),
      PenaltyScore()
    ]);
  }

  static List<CellRow> createRows() {
    return [
      CellRow([
        for (var number in twoTroughTwelve) Cell(CellColor.red, number),
      ]),
      CellRow([
        for (var number in twoTroughTwelve) Cell(CellColor.yellow, number),
      ]),
      CellRow([
        for (var number in twelveTroughTwo) Cell(CellColor.green, number),
      ]),
      CellRow([
        for (var number in twelveTroughTwo) Cell(CellColor.blue, number),
      ]),
    ];
  }
}
