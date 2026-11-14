import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProfile {
  static const _nameKey = 'player_name';
  static const _avatarKey = 'player_avatar';
  static const _playedKey = 'player_games_played';
  static const _winsKey = 'player_games_won';
  static const _bestKey = 'player_best_score';
  static const _remoteIdKey = 'player_remote_id';
  static const _apiUrl = 'https://lexoria-api.vercel.app/api/lexoria';

  final String name;
  final int avatarIndex;
  final int gamesPlayed;
  final int wins;
  final int bestScore;
  final String? remoteId;

  const PlayerProfile({
    required this.name,
    required this.avatarIndex,
    required this.gamesPlayed,
    required this.wins,
    required this.bestScore,
    this.remoteId,
  });

  static Future<PlayerProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? 'Joueur';
    final avatar = prefs.getInt(_avatarKey) ?? 0;
    var remoteId = prefs.getString(_remoteIdKey);
    if (remoteId == null) {
      remoteId = await _syncProfile(name: name, avatarIndex: avatar);
      if (remoteId != null) await prefs.setString(_remoteIdKey, remoteId);
    }
    return PlayerProfile(
      name: name,
      avatarIndex: avatar,
      gamesPlayed: prefs.getInt(_playedKey) ?? 0,
      wins: prefs.getInt(_winsKey) ?? 0,
      bestScore: prefs.getInt(_bestKey) ?? 0,
      remoteId: remoteId,
    );
  }

  static Future<String?> _syncProfile({
    required String name,
    required int avatarIndex,
    String? playerId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_apiUrl?action=profile'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim().isEmpty ? 'Joueur' : name.trim(),
              'avatarKey': 'avatar_$avatarIndex',
              if (playerId != null) 'playerId': playerId,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['profile'] as Map<String, dynamic>)['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveIdentity({
    required String name,
    required int avatarIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanName = name.trim().isEmpty ? 'Joueur' : name.trim();
    await prefs.setString(_nameKey, cleanName);
    await prefs.setInt(_avatarKey, avatarIndex);
    final remoteId = await _syncProfile(
      name: cleanName,
      avatarIndex: avatarIndex,
      playerId: prefs.getString(_remoteIdKey),
    );
    if (remoteId != null) await prefs.setString(_remoteIdKey, remoteId);
  }

  static Future<void> recordGame({
    required bool won,
    required int score,
    int wordsFound = 0,
    int wordsTotal = 0,
    int durationSeconds = 0,
    String mode = 'solo',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_playedKey, (prefs.getInt(_playedKey) ?? 0) + 1);
    if (won) await prefs.setInt(_winsKey, (prefs.getInt(_winsKey) ?? 0) + 1);
    if (score > (prefs.getInt(_bestKey) ?? 0)) {
      await prefs.setInt(_bestKey, score);
    }

    var playerId = prefs.getString(_remoteIdKey);
    if (playerId == null) {
      playerId = await _syncProfile(
        name: prefs.getString(_nameKey) ?? 'Joueur',
        avatarIndex: prefs.getInt(_avatarKey) ?? 0,
      );
      if (playerId != null) await prefs.setString(_remoteIdKey, playerId);
    }
    if (playerId == null) return;
    try {
      await http
          .post(
            Uri.parse('$_apiUrl?action=result'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'playerId': playerId,
              'mode': mode,
              'score': score,
              'wordsFound': wordsFound,
              'wordsTotal': wordsTotal,
              'completed': won,
              'durationSeconds': durationSeconds,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Keep the local game experience available when the player is offline.
    }
  }
}
