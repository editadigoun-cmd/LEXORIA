import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexoria/game/puzzle.dart';

void main() {
  group('WordSearchPuzzle', () {
    test('generates a square grid and places every requested word', () {
      final puzzle = WordSearchPuzzle.generate(
        size: 10,
        words: const ['FLUTTER', 'DART', 'LEXORIA'],
        random: Random(7),
      );

      expect(puzzle.letters.length, 10);
      expect(puzzle.letters.every((row) => row.length == 10), isTrue);
      expect(puzzle.placements.keys, containsAll(['FLUTTER', 'DART', 'LEXORIA']));
    });

    test('recognizes a word in forward and reverse selection order', () {
      final puzzle = WordSearchPuzzle.generate(
        size: 8,
        words: const ['DART'],
        random: Random(2),
      );
      final path = puzzle.placements['DART']!;

      expect(puzzle.isValidSelection(path), isTrue);
      expect(puzzle.isValidSelection(path.reversed.toList()), isTrue);
      expect(puzzle.wordForSelection(path), 'DART');
    });

    test('rejects words longer than the grid', () {
      expect(
        () => WordSearchPuzzle.generate(size: 4, words: const ['LEXORIA']),
        throwsArgumentError,
      );
    });

    test('rejects an empty word list', () {
      expect(
        () => WordSearchPuzzle.generate(size: 8, words: const []),
        throwsArgumentError,
      );
    });
  });
}
