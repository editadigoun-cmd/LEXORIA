import 'package:material_ui/material_ui.dart';

import 'game/game_page.dart';
import 'game/levels_page.dart';
import 'game/profile_page.dart';
import 'game/player_profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LexoriaApp());
}

abstract final class LexoriaColors {
  static const background = Color(0xFF090E1C);
  static const surface = Color(0xFF121B30);
  static const surfaceLight = Color(0xFF1A2742);
  static const violet = Color(0xFF9670FF);
  static const violetBright = Color(0xFFB49AFF);
  static const turquoise = Color(0xFF36D9C5);
  static const gold = Color(0xFFF3C66A);
  static const muted = Color(0xFF8D9AB5);
  static const white = Color(0xFFF5F7FF);
}

class LexoriaApp extends StatelessWidget {
  const LexoriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LEXORIA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: LexoriaColors.background,
        colorScheme: const ColorScheme.dark(
          primary: LexoriaColors.violet,
          secondary: LexoriaColors.turquoise,
          surface: LexoriaColors.surface,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF151632), LexoriaColors.background, Color(0xFF080D19)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopBar(),
                const SizedBox(height: 34),
                const Text(
                  'LE PLAISIR DES MOTS,\nLE DÉFI DE L’ESPRIT.',
                  style: TextStyle(
                    color: LexoriaColors.white,
                    fontSize: 27,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Chaque grille cache une nouvelle victoire.',
                  style: TextStyle(color: LexoriaColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 26),
                const _DailyCard(),
                const SizedBox(height: 26),
                const Text(
                  'CHOISIS TON AVENTURE',
                  style: TextStyle(
                    color: LexoriaColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 13),
                _ModeCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Mode Solo',
                  subtitle: 'Progresse à ton rythme, niveau après niveau.',
                  tag: 'CAMPAGNE',
                  accent: LexoriaColors.violet,
                  onTap: () => _openMode(context, 'Mode Solo'),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  icon: Icons.bolt_rounded,
                  title: 'Duel en direct',
                  subtitle: 'Affronte un joueur sur la même grille.',
                  tag: '1 CONTRE 1',
                  accent: LexoriaColors.turquoise,
                  onTap: () => _openMode(context, 'Duel en direct'),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  icon: Icons.send_rounded,
                  title: 'Défis entre amis',
                  subtitle: 'Envoie un défi et comparez vos scores.',
                  tag: 'À DISTANCE',
                  accent: LexoriaColors.gold,
                  onTap: () => _openMode(context, 'Défis entre amis'),
                ),
                const SizedBox(height: 26),
                const _StatsRow(),
                const SizedBox(height: 22),
                const Center(
                  child: Text(
                    'LEXORIA  •  TROUVE LES MOTS. DÉPASSE-TOI.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64718C),
                      fontSize: 9,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMode(BuildContext context, String mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => mode == 'Mode Solo' ? const LevelsPage() : ModePreviewPage(mode: mode)),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [LexoriaColors.violet, Color(0xFF5943C8)],
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x449670FF), blurRadius: 20, offset: Offset(0, 5)),
            ],
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 12),
        const Text(
          'LEXORIA',
          style: TextStyle(
            color: LexoriaColors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: LexoriaColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF293653)),
          ),
          child: const Row(
            children: [
              Icon(Icons.monetization_on_rounded, color: LexoriaColors.gold, size: 17),
              SizedBox(width: 6),
              Text('250', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 9),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LexoriaColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF394666)),
            ),
            child: const Icon(Icons.person_rounded, color: LexoriaColors.violetBright),
          ),
        ),
      ],
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF49358C), Color(0xFF24234F), Color(0xFF18213A)],
        ),
        border: Border.all(color: const Color(0x667F69D8)),
        boxShadow: const [
          BoxShadow(color: Color(0x332D236C), blurRadius: 28, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: LexoriaColors.gold, size: 15),
              const SizedBox(width: 8),
              const Text(
                'DÉFI QUOTIDIEN',
                style: TextStyle(
                  color: Color(0xFFE4D9FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('NOUVEAU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Prêt à relever\nle défi du jour ?',
            style: TextStyle(color: Colors.white, fontSize: 23, height: 1.15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Une grille spéciale. Des récompenses exclusives.',
            style: TextStyle(color: Color(0xFFD0C9EC), fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 45,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: LexoriaColors.white,
                foregroundColor: const Color(0xFF30245E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GamePage(title: 'Défi quotidien'),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('JOUER MAINTENANT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LexoriaColors.surface,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFF26334E)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: LexoriaColors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: LexoriaColors.muted, fontSize: 11, height: 1.3)),
                    const SizedBox(height: 5),
                    Text(tag, style: TextStyle(color: accent, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: accent, size: 23),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerProfile>(
      future: PlayerProfile.load(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF10182A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF202D46)),
          ),
          child: Row(
            children: [
              Expanded(child: _StatItem(value: '${profile?.gamesPlayed ?? 0}', label: 'PARTIES')),
              const _StatDivider(),
              Expanded(child: _StatItem(value: '${profile?.wins ?? 0}', label: 'VICTOIRES')),
              const _StatDivider(),
              Expanded(child: _StatItem(value: '${profile?.bestScore ?? 0}', label: 'RECORD')),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: LexoriaColors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: LexoriaColors.muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 30, color: const Color(0xFF2B3852));
}

class ModePreviewPage extends StatelessWidget {
  const ModePreviewPage({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: LexoriaColors.background,
        title: Text(mode, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, color: LexoriaColors.violetBright, size: 54),
              const SizedBox(height: 18),
              Text(mode, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              const SizedBox(height: 9),
              const Text(
                'Ce mode sera activé dans la prochaine étape du développement.',
                textAlign: TextAlign.center,
                style: TextStyle(color: LexoriaColors.muted, height: 1.5),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Retour à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
