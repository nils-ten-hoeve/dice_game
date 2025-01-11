// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/category/category.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/category/variant.domain.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BasicCategory extends Category {
  @override
  final dutchName = "Basis";

  @override
  final icon = FontAwesomeIcons.diceOne;

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
        CellRow.twoTroughTwelve(CellColor.red),
        CellRow.twoTroughTwelve(CellColor.yellow),
        CellRow.twoTroughTwelve(CellColor.green),
        CellRow.twoTroughTwelve(CellColor.blue),
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
      CellRow.twoTroughTwelve(CellColor.red),
      CellRow.twoTroughTwelve(CellColor.yellow),
      CellRow.twelveTroughTwo(CellColor.green),
      CellRow.twelveTroughTwo(CellColor.blue),
    ];
  }
}
