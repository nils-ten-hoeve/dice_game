import 'package:dice_game/game/cell/cell.value.domain.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:flutter/material.dart';

class GameRow extends StatelessWidget {
  final Game? game;
  final CellRow cellRow;
  const GameRow({
    super.key,
    this.game,
    required this.cellRow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var cellSize = _cellSize(constraints);
      return SizedBox(
        width: constraints.maxWidth,
        child: Row(
          children: [
            for (var value in cellRow.values)
              GameRowCell(
                size: cellSize,
                color: value.color.dark,
                child: CellNumberAndState(
                  cellValue: value,
                  game: game,
                ),
              ),
            GameRowCell(
                size: cellSize,
                color: cellRow.values.last.color.dark,
                child: LockAndState(
                  cellRow.values.last,
                  game: game,
                )),
          ],
        ),
      );
    });
  }

  static const double cellHeightFactor = 1.15;
  static const double cellsPerRow = 12;

  _cellSize(BoxConstraints constraints) => Size(
      constraints.maxWidth / cellsPerRow,
      constraints.maxWidth / cellsPerRow * cellHeightFactor);
}

class GameRowCell extends StatelessWidget {
  final Size size;
  final Color color;
  final Widget child;

  const GameRowCell(
      {super.key,
      required this.size,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) => Container(
      width: size.width,
      height: size.height,
      color: color,
      child: Center(child: child));
}

class CellNumberAndState extends StatelessWidget {
  final CellValue cellValue;
  final Game? game;

  const CellNumberAndState({
    super.key,
    required this.cellValue,
    this.game,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var cellSize = constraints.maxWidth * 0.9;
      var borderRadius = constraints.maxWidth * 0.1;
      var widget = Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
            color: game != null && game!.cellStates[cellValue] != CellState.none
                ? cellValue.color.middle
                : cellValue.color.light,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        child: Stack(children: [
          CellNumberWidget(cellValue),
          if (game != null) CellStateWidget(game!.cellStates[cellValue]!),
        ]),
      );
      if (game != null) {
        return InkWell(
          onTap: () {
            game!.markOrUnMarkCell(cellValue);
          },
          child: widget,
        );
      } else {
        return widget;
      }
    });
  }
}

class CellNumberWidget extends StatelessWidget {
  final CellValue value;

  const CellNumberWidget(
    this.value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Transform.scale(
          scale: 0.8,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(value.number.toString(),
                style: TextStyle(
                  color: value.color.dark,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      );
}

class CellStateWidget extends StatelessWidget {
  final CellState state;

  const CellStateWidget(
    this.state, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Transform.scale(
            scale: 1.1,
            child: FittedBox(
                fit: BoxFit.contain,
                child: Text(state.text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    )))),
      );
}

class LockAndState extends StatelessWidget {
  final CellValue lastCellValue;
  final Game? game;
  const LockAndState(this.lastCellValue, {super.key, this.game});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        var fieldSize = constraints.maxWidth * 0.75;

        var cellColor = lastCellValue.color;
        var surfaceColor = game != null && rowState(game!) != RowState.none
            ? cellColor.middle
            : cellColor.light;

        var widget = Container(
          width: fieldSize,
          height: fieldSize,
          decoration:
              BoxDecoration(color: surfaceColor, shape: BoxShape.circle),
          child: Stack(children: [
            LockWidget(cellColor: cellColor),
            if (game != null) CellStateWidget(rowState(game!).asCellState),
          ]),
        );
        if (game != null) {
          return InkWell(
            onTap: () {
              game!.lockRowByOtherPlayer(rowIndex(game!));
            },
            child: widget,
          );
        } else {
          return widget;
        }
      });

  RowState rowState(Game game) => game.rowStates[rowIndex(game)];

  int rowIndex(Game game) => game.variant.findRowIndex(lastCellValue);
}

class LockWidget extends StatelessWidget {
  const LockWidget({
    super.key,
    required this.cellColor,
  });

  final CellColor cellColor;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Transform.scale(
            scale: 0.6,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(
                Icons.lock_open_rounded,
                color: cellColor.dark,
              ),
            )));
  }
}
