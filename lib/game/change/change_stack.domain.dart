// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member


import 'package:dice_game/game/game.domain.dart';
import 'package:undo/undo.dart';

/// This is a wrapper class to ensure that the
/// [game] listeners are automatically notified of new changes

class GameChangeStack extends ChangeStack {
  final Game game;

  GameChangeStack(this.game, {super.limit});

  @override
  void add<T>(Change<T> change) {
    super.add(change);
    game.notifyListeners();
  }

  @override
  void addGroup<T>(List<Change<T>> changes) {
    super.addGroup(changes);
    game.notifyListeners();
  }

  @override
  void clearHistory() {
    super.clearHistory();
    game.notifyListeners();
  }

  @override
  void undo() {
    super.undo();
    game.notifyListeners();
  }

  @override
  void redo() {
    super.redo();
    game.notifyListeners();
  }
}
