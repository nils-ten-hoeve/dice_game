import 'package:dice_game/game/game.domain.dart';
import 'package:flutter/material.dart';
import 'package:dice_game/game/variant/variant.domain.dart';

class GameService extends ChangeNotifier {
  static final GameService _singleton = GameService._internal();

  factory GameService() => _singleton;

  GameService._internal();

  final GameVariants gameVariants = GameVariants();

  late Game _currentGame = Game(variant: gameVariants.basicVariantA);

  Game get currentGame => _currentGame;

  void newGame(GameVariant variant) {
    _currentGame = Game(variant: variant);
    notifyListeners();
  }
}
