// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dice_game/game/cell/cell.domain.dart';
import 'package:dice_game/game/change/change_stack.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/score/score.domain.dart';
import 'package:dice_game/game/variant/variant.domain.dart';

class MixedVariantA extends GameVariant {
  MixedVariantA()
      : super(
          name: "Mixed Variant A (kleuren)",
          explenationUrl: Uri.parse(
              "https://www.qwixx.nl/varianten/qwixx-mixx-uitbreiding/"),
          row1: CellRow([
            Cell(CellColor.yellow, 2),
            Cell(CellColor.yellow, 3),
            Cell(CellColor.yellow, 4),
            Cell(CellColor.blue, 5),
            Cell(CellColor.blue, 6),
            Cell(CellColor.blue, 7),
            Cell(CellColor.green, 8),
            Cell(CellColor.green, 9),
            Cell(CellColor.green, 10),
            Cell(CellColor.red, 11),
            Cell(CellColor.red, 12)
          ]),
          row2: CellRow([
            Cell(CellColor.red, 2),
            Cell(CellColor.red, 3),
            Cell(CellColor.green, 4),
            Cell(CellColor.green, 5),
            Cell(CellColor.green, 6),
            Cell(CellColor.green, 7),
            Cell(CellColor.blue, 8),
            Cell(CellColor.blue, 9),
            Cell(CellColor.yellow, 10),
            Cell(CellColor.yellow, 11),
            Cell(CellColor.yellow, 12)
          ]),
          row3: CellRow([
            Cell(CellColor.blue, 12),
            Cell(CellColor.blue, 11),
            Cell(CellColor.blue, 10),
            Cell(CellColor.yellow, 9),
            Cell(CellColor.yellow, 8),
            Cell(CellColor.yellow, 7),
            Cell(CellColor.red, 6),
            Cell(CellColor.red, 5),
            Cell(CellColor.red, 4),
            Cell(CellColor.green, 3),
            Cell(CellColor.green, 2)
          ]),
          row4: CellRow([
            Cell(CellColor.green, 12),
            Cell(CellColor.green, 11),
            Cell(CellColor.red, 10),
            Cell(CellColor.red, 9),
            Cell(CellColor.red, 8),
            Cell(CellColor.red, 7),
            Cell(CellColor.yellow, 6),
            Cell(CellColor.yellow, 5),
            Cell(CellColor.blue, 4),
            Cell(CellColor.blue, 3),
            Cell(CellColor.blue, 2)
          ]),
          nrOfMarkedCellsNeededToLock:
              6, //Note: this is different from others, see rules
          createChangesToMarkCell: (Game game, Cell cell) =>
              MarkCellChanges(game, cell),
          scoreCalculation: TotalScoreCalculation([
            for (var color in CellColor.values) ColorScore(color),
            PenaltyScore()
          ]),
        );
}

class MixedVariantB extends GameVariant {
  MixedVariantB()
      : super(
          name: "Mixed Variant B (nummers)",
          explenationUrl: Uri.parse(
              "https://www.qwixx.nl/varianten/qwixx-mixx-uitbreiding/"),
          row1: CellRow([
            Cell(CellColor.red, 10),
            Cell(CellColor.red, 6),
            Cell(CellColor.red, 2),
            Cell(CellColor.red, 8),
            Cell(CellColor.red, 3),
            Cell(CellColor.red, 4),
            Cell(CellColor.red, 12),
            Cell(CellColor.red, 5),
            Cell(CellColor.red, 9),
            Cell(CellColor.red, 7),
            Cell(CellColor.red, 11),
          ]),
          row2: CellRow([
            Cell(CellColor.yellow, 9),
            Cell(CellColor.yellow, 12),
            Cell(CellColor.yellow, 4),
            Cell(CellColor.yellow, 6),
            Cell(CellColor.yellow, 7),
            Cell(CellColor.yellow, 2),
            Cell(CellColor.yellow, 5),
            Cell(CellColor.yellow, 8),
            Cell(CellColor.yellow, 11),
            Cell(CellColor.yellow, 3),
            Cell(CellColor.yellow, 10),
          ]),
          row3: CellRow([
            Cell(CellColor.green, 8),
            Cell(CellColor.green, 2),
            Cell(CellColor.green, 10),
            Cell(CellColor.green, 12),
            Cell(CellColor.green, 6),
            Cell(CellColor.green, 9),
            Cell(CellColor.green, 7),
            Cell(CellColor.green, 4),
            Cell(CellColor.green, 5),
            Cell(CellColor.green, 11),
            Cell(CellColor.green, 3),
          ]),
          row4: CellRow([
            Cell(CellColor.blue, 5),
            Cell(CellColor.blue, 7),
            Cell(CellColor.blue, 11),
            Cell(CellColor.blue, 9),
            Cell(CellColor.blue, 12),
            Cell(CellColor.blue, 3),
            Cell(CellColor.blue, 8),
            Cell(CellColor.blue, 10),
            Cell(CellColor.blue, 2),
            Cell(CellColor.blue, 6),
            Cell(
              CellColor.blue,
              4,
            )
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
