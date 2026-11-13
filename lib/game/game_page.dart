import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import 'puzzle.dart';
import 'campaign.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    this.title = 'Défi libre',
    this.level,
    this.onLevelCompleted,
  });
  final String title;
  final GameLevel? level;
  final Future<void> Function(GameLevel level)? onLevelCompleted;
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> get words => widget.level?.words ??
      const ['AFRIQUE', 'SAVANE', 'LION', 'BAOBAB', 'FLEUVE', 'ZEBRE'];
  int get duration => widget.level?.timeLimitSeconds ?? 180;
  int get gridSize => widget.level?.gridSize ?? 10;
  late WordSearchPuzzle puzzle;
  final Set<String> found = {};
  final Set<GridPoint> foundCells = {};
  List<GridPoint> selection = [];
  GridPoint? start;
  Timer? timer;
  int seconds = duration;
  int score = 0;
  bool finished = false;
  bool completionSaved = false;
  String? hint;

  @override
  void initState() {
    super.initState();
    _reset();
    _runTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _reset() {
    puzzle = WordSearchPuzzle.generate(size: gridSize, words: words);
    found.clear();
    foundCells.clear();
    selection = [];
    start = null;
    seconds = duration;
    score = 0;
    finished = false;
    completionSaved = false;
    hint = null;
  }

  void _runTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || finished) return t.cancel();
      if (seconds <= 1) {
        setState(() => seconds = 0);
        _finish();
      } else {
        setState(() => seconds--);
      }
    });
  }

  GridPoint? _pointAt(Offset p, double size) {
    final cell = size / puzzle.size;
    final row = (p.dy / cell).floor();
    final col = (p.dx / cell).floor();
    if (row < 0 || row >= puzzle.size || col < 0 || col >= puzzle.size) return null;
    return GridPoint(row, col);
  }

  List<GridPoint> _line(GridPoint a, GridPoint b) {
    final dr = b.row - a.row;
    final dc = b.column - a.column;
    if (dr != 0 && dc != 0 && dr.abs() != dc.abs()) return [];
    final steps = dr.abs() > dc.abs() ? dr.abs() : dc.abs();
    if (steps == 0) return [a];
    final sr = dr == 0 ? 0 : dr ~/ steps;
    final sc = dc == 0 ? 0 : dc ~/ steps;
    return List.generate(steps + 1, (i) => GridPoint(a.row + sr * i, a.column + sc * i));
  }

  void _startAt(Offset p, double size) {
    if (finished) return;
    final point = _pointAt(p, size);
    if (point == null) return;
    setState(() {
      start = point;
      selection = [point];
      hint = null;
    });
  }

  void _moveTo(Offset p, double size) {
    if (start == null || finished) return;
    final point = _pointAt(p, size);
    if (point == null) return;
    final line = _line(start!, point);
    if (line.isNotEmpty) setState(() => selection = line);
  }

  void _end() {
    if (selection.isEmpty || finished) return;
    final word = puzzle.wordForSelection(selection);
    setState(() {
      if (word != null && !found.contains(word)) {
        found.add(word);
        foundCells.addAll(selection);
        score += word.length * 10 + seconds ~/ 10;
      }
      selection = [];
      start = null;
    });
    if (found.length == words.length) _finish();
  }

  void _showHint() {
    if (finished) return;
    final remaining = words.where((w) => !found.contains(w)).toList();
    if (remaining.isEmpty) return;
    final word = remaining.first;
    setState(() => hint = '${word[0]} • ${word.length} lettres');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Le prochain mot commence par ${word[0]} et contient ${word.length} lettres.')),
    );
  }

  void _finish() {
    if (finished) return;
    timer?.cancel();
    if (found.length == words.length && widget.level != null && !completionSaved) {
      completionSaved = true;
      final callback = widget.onLevelCompleted;
      if (callback != null) unawaited(callback(widget.level!));
    }
    setState(() => finished = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: LexoriaColors.surface,
          title: Text(found.length == words.length ? 'Grille terminée !' : 'Temps écoulé'),
          content: Text('Mots trouvés : ${found.length}/${words.length}\nScore : $score points.'),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: const Text('Terminer'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(_reset);
                _runTimer();
              },
              child: const Text('Rejouer'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LexoriaColors.background,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: _showHint, icon: const Icon(Icons.lightbulb_outline, color: LexoriaColors.gold)),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final boardSize = constraints.maxWidth - 32;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: _status('SCORE', '$score', Icons.stars_rounded, LexoriaColors.gold)),
                  const SizedBox(width: 10),
                  Expanded(child: _status('TEMPS', '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}', Icons.timer_rounded, seconds <= 30 ? Colors.orangeAccent : LexoriaColors.turquoise)),
                ]),
                const SizedBox(height: 22),
                Row(children: [
                  const Expanded(child: Text('RETROUVE LES MOTS', style: TextStyle(color: LexoriaColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
                  Text('${found.length}/${words.length} trouvés', style: const TextStyle(color: LexoriaColors.turquoise, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onPanStart: (d) => _startAt(Offset(d.localPosition.dx - 7, d.localPosition.dy - 7), boardSize - 14),
                    onPanUpdate: (d) => _moveTo(Offset(d.localPosition.dx - 7, d.localPosition.dy - 7), boardSize - 14),
                    onPanEnd: (_) => _end(),
                    child: Container(
                      width: boardSize,
                      height: boardSize,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: LexoriaColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF293653)),
                      ),
                      child: IgnorePointer(
                        child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: puzzle.size * puzzle.size,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: puzzle.size, mainAxisSpacing: 2, crossAxisSpacing: 2,
                        ),
                        itemBuilder: (context, index) {
                          final row = index ~/ puzzle.size;
                          final col = index % puzzle.size;
                          final point = GridPoint(row, col);
                          final isFound = foundCells.contains(point);
                          final isActive = selection.contains(point);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isFound
                                  ? LexoriaColors.turquoise.withValues(alpha: .24)
                                  : isActive
                                      ? LexoriaColors.violet.withValues(alpha: .5)
                                      : LexoriaColors.surfaceLight,
                              borderRadius: BorderRadius.circular(5),
                              border: isActive ? Border.all(color: LexoriaColors.violetBright) : null,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(puzzle.letters[row][col],
                                style: TextStyle(
                                  color: isFound ? LexoriaColors.turquoise : LexoriaColors.white,
                                  fontSize: boardSize / puzzle.size * .48,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text('MOTS À TROUVER', style: TextStyle(color: LexoriaColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: words.map((word) {
                    final done = found.contains(word);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: done ? LexoriaColors.turquoise.withValues(alpha: .13) : LexoriaColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: done ? LexoriaColors.turquoise : const Color(0xFF293653)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (done) const Icon(Icons.check_circle, color: LexoriaColors.turquoise, size: 14),
                        if (done) const SizedBox(width: 5),
                        Text(word, style: TextStyle(
                          color: done ? LexoriaColors.turquoise : LexoriaColors.white,
                          fontSize: 11, fontWeight: FontWeight.w800,
                          decoration: done ? TextDecoration.lineThrough : null,
                        )),
                      ]),
                    );
                  }).toList(),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 14),
                  Text('Indice : $hint', style: const TextStyle(color: LexoriaColors.gold, fontSize: 12)),
                ],
                const SizedBox(height: 18),
                OutlinedButton.icon(onPressed: _showHint, icon: const Icon(Icons.lightbulb_outline), label: const Text('Obtenir un indice')),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _status(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: LexoriaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF293653)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: LexoriaColors.muted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: LexoriaColors.white, fontSize: 17, fontWeight: FontWeight.w900)),
        ]),
      ]),
    );
  }
}
