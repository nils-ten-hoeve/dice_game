// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/variant/variant.domain.dart';

const List<int> twoTroughTwelve = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
const List<int> twelveTroughTwo = [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];

class BasicVariantA extends GameVariant {
  BasicVariantA()
      : super(
          name: "Basic Variant A",
          explenationUrl: Uri.parse("https://www.qwixx.nl/#basisspel"),
          row1: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.red, number),
          ]),
          row2: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.yellow, number),
          ]),
          row3: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.green, number),
          ]),
          row4: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.blue, number),
          ]),
          nrOfMarkedCellsNeededToLock: 5,
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCellChanges(game, cell),
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}

class BasicVariantB extends GameVariant {
  BasicVariantB()
      : super(
          name: "Basic Variant B",
          explenationUrl: Uri.parse("https://www.qwixx.nl/#basisspel"),
          row1: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.red, number),
          ]),
          row2: CellRow([
            for (var number in twoTroughTwelve) Cell(CellColor.yellow, number),
          ]),
          row3: CellRow([
            for (var number in twelveTroughTwo) Cell(CellColor.green, number),
          ]),
          row4: CellRow([
            for (var number in twelveTroughTwo) Cell(CellColor.blue, number),
          ]),
          nrOfMarkedCellsNeededToLock: 5,
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCellChanges(game, cell),
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}
