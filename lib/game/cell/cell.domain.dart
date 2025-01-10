import 'package:collection/collection.dart';
import 'package:dice_game/game/color/color.domain.dart';
import 'package:dice_game/game/game.domain.dart';
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

enum NumberIdentifier {
  singleNumber,
  topNumber,
  bottomNumber,
}

typedef CellStates = Map<NumberIdentifier, CellState>;

enum CellVariant {
  /// [normal] is used in:
  /// * [BasicVariantA]
  /// * [BasicVariantB]
  /// * [MixedVariantA]
  /// * [MixedVariantB]
  normal(NumbersPerCell.one),

  /// See:
  /// * [ConnectedVariantA]
  /// * https://www.qwixx.nl/varianten/qwixx-connected/
  /// * https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTCWEkfvZGisW9eFdRp7zxANZdbeg-J1fkk-A&s
  linkedStairs(NumbersPerCell.one, hasPurpleCircle: true),

  /// See:
  /// * [ConnectedVariantB]
  /// * https://www.qwixx.nl/varianten/qwixx-connected/
  /// * https://freundderwuerfel.weebly.com/uploads/1/3/0/8/130835601/published/qwixx-connected.jpg?1590921087
  linkedWithCellBelow(NumbersPerCell.one, hasPurpleCircle: true),
  linkedWithCellAbove(NumbersPerCell.one, hasPurpleCircle: true),

  /// See:
  /// * [DoubleVariantA]
  /// * https://www.qwixx.nl/varianten/qwixx-dubbel/
  /// * https://usercontent.one/wp/www.brettspielabend.net/wp-content/uploads/2022/06/20220612_155936-scaled.jpg?media=1728493186
  doubleNumberMarkedOneByOne(NumbersPerCell.two),

  /// See:
  /// * [DoubleVariantB]
  /// * https://www.qwixx.nl/varianten/qwixx-dubbel/
  /// * https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiZSRQn6sw2fRwtgcRx0cVTeiBrEuBRvy8BY2kmbqQ9LlyTMWXkRB7eut6P2NgO6UFsMI&usqp=CAU
  doubleNumberMarkedTogether(NumbersPerCell.two),
  ;

  final bool hasPurpleCircle;

  final NumbersPerCell numbersPerCell;

  const CellVariant(this.numbersPerCell, {this.hasPurpleCircle = false});
}

enum NumbersPerCell {
  one([NumberIdentifier.singleNumber]),
  two([
    NumberIdentifier.topNumber,
    NumberIdentifier.bottomNumber,
  ]),
  ;

  final List<NumberIdentifier> identifiers;
  const NumbersPerCell(this.identifiers);
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

  Cell copyWith({CellColor? color, int? number, CellVariant? variant}) =>
      Cell(color ?? this.color, number ?? this.number, variant ?? this.variant);
}

class CellRow extends DelegatingList<Cell> {
  CellRow.twoTroughTwelve(CellColor color)
      : super(List.generate(11, (index) => Cell(color, index + 2)));

  CellRow.twelveTroughTwo(CellColor color)
      : super(List.generate(11, (index) => Cell(color, 12 - index)));

  CellRow(super.values) {
    validateNumberOfCells();
  }

  void validateNumberOfCells() {
    if (length != maxColumns) {
      throw Exception("Row must have 11 cells");
    }
  }

  static int maxColumns = 11;
}
