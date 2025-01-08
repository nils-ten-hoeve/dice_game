import 'package:dice_game/game/cell/cell.presentation.dart';
import 'package:dice_game/game/score/score.presentation.dart';
import 'package:dice_game/game/game.domain.dart';
import 'package:dice_game/game/game.service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ScoreAndActionBar extends StatelessWidget {
  const ScoreAndActionBar({super.key});

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        var cellSize = _cellSize(constraints);
        var game = GameService().currentGame;
        return SizedBox(
          width: constraints.maxWidth,
          child: Row(
            children: [
              SizedBox(
                  width: cellSize.width * 5,
                  height: cellSize.height,
                  child: ScoreWidget()),
              SizedBox(
                  width: cellSize.width,
                  height: cellSize.height,
                  child: DiceButton(game)),
              SizedBox(
                  width: cellSize.width,
                  height: cellSize.height,
                  child: InfoButton()),
              SizedBox(
                  width: cellSize.width,
                  height: cellSize.height,
                  child: UnDoReDoRestartButton()),
              for (var i = 1; i <= 4; i++)
                SizedBox(
                    width: cellSize.width,
                    height: cellSize.height,
                    child: PenaltyButton(game, i)),
            ],
          ),
        );
      });

  static const double cellsPerRow = 12;

  _cellSize(BoxConstraints constraints) => Size(
      constraints.maxWidth / cellsPerRow, constraints.maxWidth / cellsPerRow);
}

class PenaltyButton extends MyIconButton {
  final int index;
  PenaltyButton(Game game, this.index, {super.key})
      : super(
            icon: const Icon(FontAwesomeIcons.xmark),
            onPressed: (_) => game.addPenalty(),
            surfaceColorFunction: (context) =>
                buttonSurfaceColor(context, game.penalty.count >= index));
}

Color buttonSurfaceColor(BuildContext context, bool selected) => selected
    ? Theme.of(context).colorScheme.outline
    : Theme.of(context).colorScheme.surface;

class UnDoReDoRestartButton extends MyIconButton {
  UnDoReDoRestartButton({super.key})
      : super(
          icon: const Icon(Icons.undo_outlined),
          onPressed: (context) => {showUnDoReDoRestartDialog(context)},
        );
}

void showMessageDialog(BuildContext context, String dutchMessage) {
  var game = GameService().currentGame;
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(child: Text(dutchMessage)),
            actions: [
              ElevatedButton.icon(
                label: Text('Ga verder'),
                onPressed: () {
                  closeDialog(context);
                  game.dutchMessage = null;
                },
              ),
            ],
          ));
}

void showUnDoReDoRestartDialog(BuildContext context) {
  var game = GameService().currentGame;
  showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            title: Text('Wat wilt u doen?'),
            children: [
              if (game.changes.canUndo)
                SimpleDialogOption(
                  child: ListTile(
                      leading: Icon(FontAwesomeIcons.arrowRotateLeft),
                      title: Text('Laatste zet ongedaan maken')),
                  onPressed: () {
                    closeDialog(context);
                    game.undo();
                  },
                ),
              if (game.changes.canRedo)
                SimpleDialogOption(
                  child: ListTile(
                      leading: Icon(FontAwesomeIcons.arrowRotateRight),
                      title: Text('Laatste zet opnieuw doen')),
                  onPressed: () {
                    closeDialog(context);
                    game.redo();
                  },
                ),
              SimpleDialogOption(
                child: ListTile(
                    leading: Icon(FontAwesomeIcons.arrowsRotate),
                    title: Text('Nieuw spel starten')),
                onPressed: () {
                  closeDialog(context);
                  showNewGameDialog(context);
                },
              ),
            ],
          ));
}

void closeDialog(BuildContext context) => Navigator.pop(context);

class InfoButton extends MyIconButton {
  InfoButton({super.key})
      : super(
          icon: const Icon(FontAwesomeIcons.info),
          onPressed: (context) => showInfoDialog(context),
        );
}

void showInfoDialog(BuildContext context) {
  Game game = GameService().currentGame;
  showDialog(
      context: context,
      builder: (context) =>
          SimpleDialog(title: Text('Welke spelregels wilt u zien?'), children: [
            SimpleDialogOption(
              child: Text('Basis Regels'),
              onPressed: () async {
                closeDialog(context);
                final Uri url = Uri.parse('https://www.qwixx.nl/');
                await launchUrl(url);
              },
            ),
            SimpleDialogOption(
              child: Text('Regels van variant: ${game.variant.name}'),
              onPressed: () async {
                closeDialog(context);
                await launchUrl(game.variant.explenationUrl);
              },
            ),
          ]));
}

class DiceButton extends MyIconButton {
  DiceButton(Game game, {super.key})
      : super(
          icon: const Icon(FontAwesomeIcons.dice),
          surfaceColorFunction: (context) =>
              buttonSurfaceColor(context, game.showDice),
          onPressed: (_) => game.showDice = !game.showDice,
        );
}

abstract class MyIconButton extends StatefulWidget {
  final Icon icon;
  final Color Function(BuildContext)? surfaceColorFunction;

  final void Function(BuildContext) onPressed;
  const MyIconButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      this.surfaceColorFunction});

  @override
  State<MyIconButton> createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton> {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => Container(
            margin: EdgeInsets.all(constraints.maxWidth * 0.1),
            decoration: BoxDecoration(
                color: widget.surfaceColorFunction == null
                    ? Theme.of(context).colorScheme.surface
                    : widget.surfaceColorFunction!(context),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: constraints.maxWidth * 0.03)),
            child: IconButton(
              onPressed: () {
                widget.onPressed(context);
              },
              icon: widget.icon,
              color: Theme.of(context).colorScheme.onSurface,
              iconSize: constraints.maxWidth * 0.4,
            ),
          ));
}

void showNewGameDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) =>
          SimpleDialog(title: Text('Kies een nieuw spel'), children: [
            for (var variant in GameService().gameVariants)
              SimpleDialogOption(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Column(children: [
                    Text(variant.name),
                    for (var row in variant.rows) GameRow(cellRow: row),
                  ]),
                ),
                onPressed: () {
                  closeDialog(context);
                  GameService().newGame(variant);
                },
              ),
          ]));
}

void showFinishedDialog(BuildContext context) {
  var game = GameService().currentGame;
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Het spel is afgelopen'),
            content: SingleChildScrollView(
                child: Column(children: [
              Text(game.twoRowsClosed
                  ? 'Er zijn twee rijen gesloten!'
                  : 'U had 4 misworpen!'),
              Text('Uw score:'),
              ScoreWidget()
            ])),
            actions: [
              ElevatedButton.icon(
                label: Text('Laatste zet ongedaan maken'),
                icon: Icon(FontAwesomeIcons.arrowRotateLeft),
                onPressed: () {
                  closeDialog(context);
                  game.undo();
                },
              ),
              ElevatedButton.icon(
                label: Text('Nieuw spel starten'),
                icon: const Icon(FontAwesomeIcons.arrowsRotate),
                onPressed: () {
                  closeDialog(context);
                  showNewGameDialog(context);
                },
              ),
            ],
          ));
}
