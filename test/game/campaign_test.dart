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

    test('every word fits its level grid', () {
      for (final level in CampaignCatalog.all) {
        expect(level.words, isNotEmpty, reason: 'Level ${level.id}');
        for (final word in level.words) {
          expect(word.length, lessThanOrEqualTo(level.gridSize),
              reason: '${level.title}: $word does not fit a ${level.gridSize} grid');
        }
      }
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
