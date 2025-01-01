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

Color lightenColor(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1, 'The amount should be between 0 and 1.');
  final hsl = HSLColor.fromColor(color);
  final lighterHSL =
      hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return lighterHSL.toColor();
}

enum CellValue {
  red2(CellColor.red, 2),
  red3(CellColor.red, 3),
  red4(CellColor.red, 4),
  red5(CellColor.red, 5),
  red6(CellColor.red, 6),
  red7(CellColor.red, 7),
  red8(CellColor.red, 8),
  red9(CellColor.red, 9),
  red10(CellColor.red, 10),
  red11(CellColor.red, 11),
  red12(CellColor.red, 12),

  yellow2(CellColor.yellow, 2),
  yellow3(CellColor.yellow, 3),
  yellow4(CellColor.yellow, 4),
  yellow5(CellColor.yellow, 5),
  yellow6(CellColor.yellow, 6),
  yellow7(CellColor.yellow, 7),
  yellow8(CellColor.yellow, 8),
  yellow9(CellColor.yellow, 9),
  yellow10(CellColor.yellow, 10),
  yellow11(CellColor.yellow, 11),
  yellow12(CellColor.yellow, 12),

  green2(CellColor.green, 2),
  green3(CellColor.green, 3),
  green4(CellColor.green, 4),
  green5(CellColor.green, 5),
  green6(CellColor.green, 6),
  green7(CellColor.green, 7),
  green8(CellColor.green, 8),
  green9(CellColor.green, 9),
  green10(CellColor.green, 10),
  green11(CellColor.green, 11),
  green12(CellColor.green, 12),

  blue2(CellColor.blue, 2),
  blue3(CellColor.blue, 3),
  blue4(CellColor.blue, 4),
  blue5(CellColor.blue, 5),
  blue6(CellColor.blue, 6),
  blue7(CellColor.blue, 7),
  blue8(CellColor.blue, 8),
  blue9(CellColor.blue, 9),
  blue10(CellColor.blue, 10),
  blue11(CellColor.blue, 11),
  blue12(CellColor.blue, 12),
  ;

  final CellColor color;
  final int number;
  const CellValue(this.color, this.number);
}
