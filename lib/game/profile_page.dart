import 'package:material_ui/material_ui.dart';
import '../main.dart';
import 'player_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _avatars = <IconData>[
    Icons.person_rounded, Icons.face_rounded, Icons.psychology_rounded,
    Icons.emoji_events_rounded, Icons.bolt_rounded, Icons.auto_awesome_rounded,
  ];
  final _nameController = TextEditingController();
  PlayerProfile? profile;
  int selectedAvatar = 0;
  bool loading = true;
  bool saving = false;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  Future<void> _load() async {
    final saved = await PlayerProfile.load();
    if (!mounted) return;
    setState(() {
      profile = saved;
      _nameController.text = saved.name;
      selectedAvatar = saved.avatarIndex.clamp(0, _avatars.length - 1);
      loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => saving = true);
    await PlayerProfile.saveIdentity(name: _nameController.text, avatarIndex: selectedAvatar);
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil enregistré sur cet appareil.')));
  }

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Scaffold(
      appBar: AppBar(backgroundColor: LexoriaColors.background, title: const Text('Mon profil', style: TextStyle(fontWeight: FontWeight.w900))),
      body: loading || p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(22),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(colors: [Color(0xFF49358C), Color(0xFF1B2946)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    border: Border.all(color: const Color(0x667F69D8)),
                  ),
                  child: Column(children: [
                    CircleAvatar(radius: 39, backgroundColor: const Color(0x447F69D8), child: Icon(_avatars[selectedAvatar], size: 42, color: LexoriaColors.violetBright)),
                    const SizedBox(height: 12),
                    Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('JOUEUR LEXORIA', style: TextStyle(color: Color(0xFFD0C9EC), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                  ]),
                ),
                const SizedBox(height: 25),
                const Text('PERSONNALISER', style: TextStyle(color: LexoriaColors.muted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                TextField(controller: _nameController, maxLength: 20, decoration: const InputDecoration(labelText: 'Ton pseudo', hintText: 'Entre ton pseudo', filled: true, border: OutlineInputBorder())),
                const SizedBox(height: 8),
                const Text('Choisis ton avatar', style: TextStyle(color: LexoriaColors.muted, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(spacing: 12, runSpacing: 12, children: List.generate(_avatars.length, (index) => InkWell(
                  onTap: () => setState(() => selectedAvatar = index),
                  borderRadius: BorderRadius.circular(30),
                  child: CircleAvatar(radius: 25, backgroundColor: selectedAvatar == index ? LexoriaColors.violet : LexoriaColors.surfaceLight, child: Icon(_avatars[index], color: Colors.white)),
                ))),
                const SizedBox(height: 18),
                FilledButton(onPressed: saving ? null : _save, child: Text(saving ? 'Enregistrement…' : 'Enregistrer le profil')),
                const SizedBox(height: 28),
                const Text('MES STATISTIQUES', style: TextStyle(color: LexoriaColors.muted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _stat('PARTIES', '${p.gamesPlayed}', Icons.grid_view_rounded)),
                  const SizedBox(width: 9),
                  Expanded(child: _stat('VICTOIRES', '${p.wins}', Icons.emoji_events_rounded)),
                  const SizedBox(width: 9),
                  Expanded(child: _stat('RECORD', '${p.bestScore}', Icons.stars_rounded)),
                ]),
                const SizedBox(height: 12),
                Text('Taux de victoire : ${p.gamesPlayed == 0 ? 0 : (p.wins * 100 / p.gamesPlayed).round()} %', textAlign: TextAlign.center, style: const TextStyle(color: LexoriaColors.turquoise, fontWeight: FontWeight.w800)),
              ],
            ),
    );
  }

  Widget _stat(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
    decoration: BoxDecoration(color: LexoriaColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF293653))),
    child: Column(children: [
      Icon(icon, color: LexoriaColors.violetBright, size: 20),
      const SizedBox(height: 7),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: LexoriaColors.muted, fontSize: 8, fontWeight: FontWeight.w800)),
    ]),
  );
}
