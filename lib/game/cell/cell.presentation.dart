import 'package:dice_game/game/cell/cell.domain.dart';
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
            for (var cell in cellRow)
              GameRowCell(
                size: cellSize,
                color: cell.color.dark,
                child: CellWidget(
                  cell: cell,
                  game: game,
                ),
              ),
            GameRowCell(
                size: cellSize,
                color: cellRow.last.color.dark,
                child: LockAndState(
                  cellRow.last,
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

class CellWidget extends StatelessWidget {
  final Cell cell;
  final Game? game;

  const CellWidget({
    super.key,
    required this.cell,
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
            color: hasDarkBackground() ? cell.color.middle : cell.color.light,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        child: Stack(children: [
          if (cell.variant.hasPurpleCircle) PurpleCircle(),
          if (cell.variant.numbersPerCell == NumbersPerCell.one)
            Positioned.fill(
                child: CellNumberAndState(
                    game, cell, CellStateIdentifier.singleNumber)),
          if (cell.variant.numbersPerCell == NumbersPerCell.two)
            Positioned(
                left: 0,
                top: 0,
                width: constraints.maxWidth * 0.55,
                height: constraints.maxWidth * 0.55,
                child: CellNumberAndState(
                    game, cell, CellStateIdentifier.topNumber)),
          if (cell.variant.numbersPerCell == NumbersPerCell.two)
            Positioned(
                right: 0,
                bottom: 0,
                width: constraints.maxWidth * 0.55,
                height: constraints.maxWidth * 0.55,
                child: CellNumberAndState(
                    game, cell, CellStateIdentifier.bottomNumber)),
        ]),
      );
      if (game != null) {
        return InkWell(
          onTap: () {
            game!.markOrUnMarkCell(cell);
          },
          child: widget,
        );
      } else {
        return widget;
      }
    });
  }

  bool hasDarkBackground() =>
      game != null &&
      game!.cellStates[cell]!.values.any((state) => state != CellState.none);
}

class CellNumberAndState extends StatelessWidget {
  final Game? game;
  final Cell cell;
  final CellStateIdentifier numberIdentifier;
  const CellNumberAndState(this.game, this.cell, this.numberIdentifier,
      {super.key});

  @override
  Widget build(BuildContext context) => Stack(children: [
        CellNumberWidget(cell),
        if (game != null)
          CellStateWidget(game!.cellStates[cell]![numberIdentifier]!),
      ]);
}

class CellNumberWidget extends StatelessWidget {
  final Cell cell;

  const CellNumberWidget(
    this.cell, {
    super.key,
  });

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Transform.scale(
          scale: 0.8,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(cell.number.toString(),
                style: TextStyle(
                  color: cell.color.dark,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      );
}

class PurpleCircle extends StatelessWidget {
  const PurpleCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Positioned.fill(
      child: Transform.scale(
          scale: 0.9,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.purple,
                    width: MediaQuery.of(context).size.width * 0.005)),
          )));
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    )))),
      );
}

class LockAndState extends StatelessWidget {
  final Cell lastCell;
  final Game? game;
  const LockAndState(this.lastCell, {super.key, this.game});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        var fieldSize = constraints.maxWidth * 0.75;

        var cellColor = lastCell.color;
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

  int rowIndex(Game game) => game.variant.findRowIndex(lastCell);
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
