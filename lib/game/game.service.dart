import 'package:dice_game/game/category/category.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:flutter/material.dart';
import 'package:dice_game/game/category/variant.domain.dart';

class GameService extends ChangeNotifier {
  static final GameService _singleton = GameService._internal();

  factory GameService() => _singleton;

  GameService._internal();

  final Categories categories = Categories();

  Game _currentGame = Game(variant: Categories().first.variants.first);

  Game get currentGame => _currentGame;

  void newGame(Variant variant) {
    _currentGame = Game(variant: variant);
    notifyListeners();
  }
}
