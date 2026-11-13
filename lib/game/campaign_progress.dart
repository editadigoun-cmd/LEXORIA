import 'package:shared_preferences/shared_preferences.dart';

class CampaignProgress {
  static const _completedKey = 'campaign_completed_levels';

  static Future<Set<int>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedKey) ?? <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  static Future<void> complete(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await loadCompleted();
    completed.add(levelId);
    await prefs.setStringList(
      _completedKey,
      completed.toList()..sort(),
    );
  }
}
