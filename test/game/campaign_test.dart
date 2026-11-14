import 'package:flutter_test/flutter_test.dart';
import 'package:lexoria/game/campaign.dart';

void main() {
  group('CampaignCatalog', () {
    test('contains exactly 100 numbered levels', () {
      expect(CampaignCatalog.all, hasLength(100));
      expect(CampaignCatalog.all.map((level) => level.id).toSet(), hasLength(100));
      expect(CampaignCatalog.all.first.id, 1);
      expect(CampaignCatalog.all.last.id, 100);
    });

    test('contains exactly 500 globally unique words', () {
      final allWords = CampaignCatalog.all.expand((level) => level.words).toList();
      expect(allWords, hasLength(500));
      expect(allWords.toSet(), hasLength(500));
    });

    test('every level has five words and every word fits its grid', () {
      for (final level in CampaignCatalog.all) {
        expect(level.words, hasLength(5), reason: 'Level ${level.id}');
        for (final word in level.words) {
          expect(word.length, lessThanOrEqualTo(level.gridSize),
              reason: '${level.title}: $word does not fit a ${level.gridSize} grid');
        }
      }
    });

    test('campaign uses international themes and has no regional Africa category', () {
      final categories = CampaignCatalog.all.map((level) => level.category).toSet();
      expect(categories, hasLength(10));
      expect(categories, isNot(contains('Afrique')));
      expect(categories, contains('Nature'));
      expect(categories, contains('Voyages'));
      expect(categories, contains('Espace'));
    });

    test('difficulty and grid size increase through the campaign', () {
      expect(CampaignCatalog.all[0].gridSize, 8);
      expect(CampaignCatalog.all[20].gridSize, 9);
      expect(CampaignCatalog.all[50].gridSize, 10);
      expect(CampaignCatalog.all[80].gridSize, 12);
      expect(CampaignCatalog.all.last.difficulty, 'Expert');
    });
  });
}
