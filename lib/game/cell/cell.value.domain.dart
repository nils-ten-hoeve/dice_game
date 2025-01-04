import 'package:collection/collection.dart';
import 'package:dice_game/game/color/color.domain.dart';
import 'package:flutter/material.dart';

enum CellColor {
  red(Colors.red, 'rood'),
  yellow(

      /// See [Colors.yellow.shade700]
      Color(0xFFFBC02D),
      'geel'),
  green(Colors.green, 'groen'),
  blue(Colors.blue, 'blauw');

  final Color dark;
  final String dutchName;
  const CellColor(this.dark, this.dutchName);

  Color get middle => lightenColor(dark, 0.15);

  Color get light => lightenColor(dark, 0.4);
}

enum CellVariant {
  /// [normal] is used in:
  /// * [BasicVariantA]
  /// * [BasicVariantB]
  /// * [MixedVariantA]
  /// * [MixedVariantB]
  normal,

  /// See:
  /// * [ConnectedVariantA]
  /// * https://www.qwixx.nl/varianten/qwixx-connected/
  /// * https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCWEkfvZGisW9eFdRp7zxANZdbeg-J1fkk-A&s
  stairs,

  /// See:
  /// * [ConnectedVariantB]
  /// * https://www.qwixx.nl/varianten/qwixx-connected/
  /// * https://freundderwuerfel.weebly.com/uploads/1/3/0/8/130835601/published/qwixx-connected.jpg?1590921087
  linkedWithCellBelow,
}

class Cell {
  final CellColor color;
  final int number;
  final CellVariant variant;

  Cell(this.color, this.number, [this.variant = CellVariant.normal]) {
    validateNumber();
  }

  void validateNumber() {
    if (number < 2) {
      throw Exception("Number must be at least 2");
    }
    if (number > 12) {
      throw Exception("Number must be at most 12");
    }
  }
}

class CellRow extends DelegatingList<Cell> {
  CellRow(super.values) {
    validateNumberOfCells();
  }

  void validateNumberOfCells() {
    if (length != 11) {
      throw Exception("Row must have 11 cells");
    }
  }
}
