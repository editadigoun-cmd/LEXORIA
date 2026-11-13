import 'dart:math';

class GridPoint {
  const GridPoint(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) =>
      other is GridPoint && other.row == row && other.column == column;

  @override
  int get hashCode => Object.hash(row, column);
}

class WordSearchPuzzle {
  WordSearchPuzzle._({
    required this.size,
    required this.letters,
    required this.placements,
  });

  final int size;
  final List<List<String>> letters;
  final Map<String, List<GridPoint>> placements;

  static const _directions = <GridPoint>[
    GridPoint(0, 1),
    GridPoint(1, 0),
    GridPoint(1, 1),
    GridPoint(1, -1),
    GridPoint(0, -1),
    GridPoint(-1, 0),
    GridPoint(-1, -1),
    GridPoint(-1, 1),
  ];

  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static WordSearchPuzzle generate({
    required int size,
    required List<String> words,
    Random? random,
    int maxAttemptsPerWord = 300,
  }) {
    if (size < 4) {
      throw ArgumentError.value(size, 'size', 'Grid size must be at least 4.');
    }
    if (words.isEmpty) {
      throw ArgumentError.value(words, 'words', 'At least one word is required.');
    }

    final rng = random ?? Random();
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final placements = <String, List<GridPoint>>{};
    final normalizedWords = words
        .map((word) => word.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ''))
        .where((word) => word.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    if (normalizedWords.isEmpty) {
      throw ArgumentError.value(words, 'words', 'Words cannot all be empty.');
    }
    if (normalizedWords.any((word) => word.length > size)) {
      throw ArgumentError('Every word must fit inside the grid.');
    }

    for (final word in normalizedWords) {
      var placed = false;
      for (var attempt = 0; attempt < maxAttemptsPerWord && !placed; attempt++) {
        final direction = _directions[rng.nextInt(_directions.length)];
        final start = GridPoint(rng.nextInt(size), rng.nextInt(size));
        final path = List.generate(
          word.length,
          (index) => GridPoint(
            start.row + direction.row * index,
            start.column + direction.column * index,
          ),
        );

        final fits = path.every((point) =>
            point.row >= 0 &&
            point.row < size &&
            point.column >= 0 &&
            point.column < size);
        if (!fits) continue;

        final compatible = path.asMap().entries.every((entry) {
          final existing = grid[entry.value.row][entry.value.column];
          return existing == null || existing == word[entry.key];
        });
        if (!compatible) continue;

        for (var index = 0; index < word.length; index++) {
          final point = path[index];
          grid[point.row][point.column] = word[index];
        }
        placements[word] = path;
        placed = true;
      }

      if (!placed) {
        throw StateError('Unable to place "$word" in a ${size}x$size grid. Try a larger grid.');
      }
    }

    final completedGrid = grid
        .map((row) => row
            .map((letter) => letter ?? _alphabet[rng.nextInt(_alphabet.length)])
            .toList(growable: false))
        .toList(growable: false);

    return WordSearchPuzzle._(
      size: size,
      letters: completedGrid,
      placements: Map.unmodifiable(placements),
    );
  }

  bool isValidSelection(List<GridPoint> selection) {
    if (selection.isEmpty) return false;

    for (final path in placements.values) {
      if (_samePath(selection, path) || _samePath(selection, path.reversed.toList())) {
        return true;
      }
    }
    return false;
  }

  String? wordForSelection(List<GridPoint> selection) {
    if (selection.isEmpty) return null;

    for (final entry in placements.entries) {
      if (_samePath(selection, entry.value) ||
          _samePath(selection, entry.value.reversed.toList())) {
        return entry.key;
      }
    }
    return null;
  }

  bool _samePath(List<GridPoint> first, List<GridPoint> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
