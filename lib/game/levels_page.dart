import 'package:flutter/material.dart';

import '../main.dart';
import 'campaign.dart';
import 'campaign_progress.dart';
import 'game_page.dart';

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  Set<int> completed = <int>{};
  bool loading = true;

  int get unlockedThrough {
    if (completed.isEmpty) return 1;
    return (completed.reduce((a, b) => a > b ? a : b) + 1).clamp(1, 100);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await CampaignProgress.loadCompleted();
    if (!mounted) return;
    setState(() {
      completed = saved;
      loading = false;
    });
  }

  Future<void> _openLevel(GameLevel level) async {
    if (level.id > unlockedThrough) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GamePage(
        title: level.title,
        level: level,
        onLevelCompleted: (finishedLevel) async {
          await CampaignProgress.complete(finishedLevel.id);
          if (!mounted) return;
          setState(() => completed.add(finishedLevel.id));
        },
      ),
    ));
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final categories = CampaignCatalog.all.map((level) => level.category).toSet();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LexoriaColors.background,
        title: const Text('Campagne', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _progressHeader(),
                const SizedBox(height: 24),
                for (final category in categories) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(category.toUpperCase(),
                              style: const TextStyle(color: LexoriaColors.muted, fontSize: 11,
                                  fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                        ),
                        Text('${CampaignCatalog.all.where((l) => l.category == category && completed.contains(l.id)).length}/10',
                            style: const TextStyle(color: LexoriaColors.turquoise, fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: CampaignCatalog.all
                        .where((level) => level.category == category)
                        .map(_levelTile)
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
    );
  }

  Widget _progressHeader() {
    final percent = completed.length / 100;
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF49358C), Color(0xFF1B2946)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0x667F69D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TON PARCOURS', style: TextStyle(color: Color(0xFFE4D9FF),
              fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
          const SizedBox(height: 9),
          Text('${completed.length} / 100 niveaux terminés',
              style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: const Color(0x554B4D77),
              valueColor: const AlwaysStoppedAnimation<Color>(LexoriaColors.turquoise),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(percent * 100).round()} % de la campagne accomplie',
              style: const TextStyle(color: Color(0xFFD0C9EC), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _levelTile(GameLevel level) {
    final done = completed.contains(level.id);
    final unlocked = level.id <= unlockedThrough;
    final color = done ? LexoriaColors.turquoise : unlocked ? LexoriaColors.violet : const Color(0xFF536078);
    return SizedBox(
      width: 58,
      height: 62,
      child: Material(
        color: unlocked ? LexoriaColors.surface : const Color(0xFF0D1422),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: unlocked ? () => _openLevel(level) : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: .55)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(done ? Icons.check_circle_rounded : unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                    color: color, size: 19),
                const SizedBox(height: 3),
                Text('${level.id}', style: TextStyle(color: unlocked ? LexoriaColors.white : LexoriaColors.muted,
                    fontSize: 12, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
