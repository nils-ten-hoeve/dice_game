import 'package:collection/collection.dart';
import 'package:dice_game/game/category/basic.domain.dart';
import 'package:dice_game/game/category/connected.domain.dart';
import 'package:dice_game/game/category/double.domain.dart';
import 'package:dice_game/game/category/mixed.domain.dart';
import 'package:dice_game/game/category/variant.domain.dart';

abstract class Category {
  String get dutchName;
  Uri get dutchExplenationUrl;
  List<Variant> get variants;
}

class Categories extends UnmodifiableListView<Category> {
  Categories()
      : super([
          BasicCategory(),
          MixedCategory(),
          ConnectedCategory(),
          DoubleCategory(),
        ]);
}
