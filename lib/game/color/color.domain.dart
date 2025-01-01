import 'package:flutter/material.dart';

Color lightenColor(Color color, [double amount = 0.1]) {
  assert(amount >= 0 && amount <= 1, 'The amount should be between 0 and 1.');
  final hsl = HSLColor.fromColor(color);
  final lighterHSL =
      hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
  return lighterHSL.toColor();
}
