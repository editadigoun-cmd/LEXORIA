import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfile {
  static const _nameKey = 'player_name';
  static const _avatarKey = 'player_avatar';
  static const _playedKey = 'player_games_played';
  static const _winsKey = 'player_games_won';
  static const _bestKey = 'player_best_score';

  final String name;
  final int avatarIndex;
  final int gamesPlayed;
  final int wins;
  final int bestScore;

  const PlayerProfile({required this.name, required this.avatarIndex, required this.gamesPlayed, required this.wins, required this.bestScore});

  static Future<PlayerProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PlayerProfile(
      name: prefs.getString(_nameKey) ?? 'Joueur',
      avatarIndex: prefs.getInt(_avatarKey) ?? 0,
      gamesPlayed: prefs.getInt(_playedKey) ?? 0,
      wins: prefs.getInt(_winsKey) ?? 0,
      bestScore: prefs.getInt(_bestKey) ?? 0,
    );
  }

  static Future<void> saveIdentity({required String name, required int avatarIndex}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name.trim().isEmpty ? 'Joueur' : name.trim());
    await prefs.setInt(_avatarKey, avatarIndex);
  }

  static Future<void> recordGame({required bool won, required int score}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_playedKey, (prefs.getInt(_playedKey) ?? 0) + 1);
    if (won) await prefs.setInt(_winsKey, (prefs.getInt(_winsKey) ?? 0) + 1);
    if (score > (prefs.getInt(_bestKey) ?? 0)) await prefs.setInt(_bestKey, score);
  }
}
