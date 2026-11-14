import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  static const _url = 'https://lexoria-api.vercel.app/api/lexoria?action=leaderboard';
  late Future<List<_LeaderboardEntry>> _request;

  @override
  void initState() {
    super.initState();
    _request = _load();
  }

  Future<List<_LeaderboardEntry>> _load() async {
    final response = await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Le classement est momentanément indisponible.');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final rows = payload['leaderboard'] as List<dynamic>? ?? const [];
    return rows.map((row) {
      final item = row as Map<String, dynamic>;
      return _LeaderboardEntry(
        name: (item['name'] ?? 'Joueur').toString(),
        score: (item['best_score'] as num?)?.toInt() ?? 0,
        games: (item['games_played'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() => _request = _load());
    await _request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LexoriaColors.background,
        title: const Text('Classement mondial', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => setState(() => _request = _load()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<_LeaderboardEntry>>(
        future: _request,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _message(
              icon: Icons.cloud_off_rounded,
              title: 'Connexion indisponible',
              message: 'Impossible de charger le classement pour le moment. Vérifie ta connexion puis réessaie.',
              action: true,
            );
          }
          final entries = snapshot.data ?? const <_LeaderboardEntry>[];
          if (entries.isEmpty) {
            return _message(
              icon: Icons.emoji_events_outlined,
              title: 'Le classement commence ici',
              message: 'Joue une partie et enregistre ton score pour apparaître parmi les joueurs.',
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              itemCount: entries.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                if (index == 0) return _intro(entries.length);
                final entry = entries[index - 1];
                final rank = index;
                final color = rank == 1
                    ? LexoriaColors.gold
                    : rank == 2
                        ? const Color(0xFFB7C5D8)
                        : rank == 3
                            ? const Color(0xFFCD956D)
                            : LexoriaColors.muted;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: LexoriaColors.surface,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: rank <= 3 ? color.withValues(alpha: .45) : const Color(0xFF293653)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text('#$rank', textAlign: TextAlign.center,
                            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
                      ),
                      const SizedBox(width: 11),
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: color.withValues(alpha: .14),
                        child: Icon(rank == 1 ? Icons.emoji_events_rounded : Icons.person_rounded, color: color, size: 19),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: LexoriaColors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text('${entry.games} partie${entry.games > 1 ? 's' : ''}',
                              style: const TextStyle(color: LexoriaColors.muted, fontSize: 10)),
                        ]),
                      ),
                      Text(entry.score.toString(),
                          style: const TextStyle(color: LexoriaColors.turquoise, fontWeight: FontWeight.w900, fontSize: 17)),
                      const SizedBox(width: 4),
                      const Text('pts', style: TextStyle(color: LexoriaColors.muted, fontSize: 9)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _intro(int count) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF49358C), Color(0xFF1B2946)]),
          border: Border.all(color: const Color(0x667F69D8)),
        ),
        child: Row(children: [
          const Icon(Icons.public_rounded, color: LexoriaColors.violetBright, size: 34),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LES MEILLEURS JOUEURS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11)),
            const SizedBox(height: 4),
            Text('$count joueurs classés • Meilleur score',
                style: const TextStyle(color: Color(0xFFD0C9EC), fontSize: 11)),
          ])),
        ]),
      );

  Widget _message({required IconData icon, required String title, required String message, bool action = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: LexoriaColors.violetBright, size: 52),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(color: LexoriaColors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center,
              style: const TextStyle(color: LexoriaColors.muted, height: 1.5)),
          if (action) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => setState(() => _request = _load()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ]),
      ),
    );
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({required this.name, required this.score, required this.games});
  final String name;
  final int score;
  final int games;
}
