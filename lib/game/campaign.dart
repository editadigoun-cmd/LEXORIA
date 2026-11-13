class GameLevel {
  const GameLevel({
    required this.id,
    required this.title,
    required this.category,
    required this.gridSize,
    required this.words,
    required this.timeLimitSeconds,
    required this.difficulty,
  });

  final int id;
  final String title;
  final String category;
  final int gridSize;
  final List<String> words;
  final int timeLimitSeconds;
  final String difficulty;
}

class CampaignCatalog {
  static const _themes = <String, List<String>>{
    'Afrique': ['AFRIQUE','SAVANE','LION','BAOBAB','FLEUVE','ZEBRE','GORILLE','SAHARA','DJEMBE','KORA','NIL','ACACIA','COBRA','GAZELLE','MANGUE','TAMTAM','OASIS','DELTA'],
    'Nature': ['FORET','RIVIERE','MONTAGNE','OCEAN','NUAGE','SOLEIL','PLUIE','ROCHER','PRAIRIE','VOLCAN','GLACIER','CASCADE','ETOILE','PLANETE','FLEUR','RACINE','BRANCHE','HERBE'],
    'Animaux': ['ELEPHANT','GIRAFE','PANTHERE','CHEVAL','DAUPHIN','TORTUE','RENARD','AIGLE','PANDA','CHAMEAU','LAPIN','SERPENT','BALEINE','SINGE','HIBOU','REQUIN','LOUP','TIGRE'],
    'Voyage': ['VOYAGE','VALISE','BILLET','AVION','TRAIN','BATEAU','PLAGE','HOTEL','CARTE','PASSEPORT','TICKET','ROUTE','CAMPING','BAGAGE','ESCALE','GUIDE','VISA','PORT'],
    'Cuisine': ['CUISINE','MANGUE','PIMENT','BANANE','PAPAYE','CITRON','TOMATE','OIGNON','CAROTTE','POISSON','POULET','RIZ','PAIN','MIEL','GINGEMBRE','COCO','ANANAS','EPICE'],
    'Sciences': ['SCIENCE','ATOME','CELLULE','ENERGIE','FUSION','LASER','ORBIT','SATELLITE','ROBOT','MICROBE','GENOME','NEURONE','METAL','OXYGENE','FOSSILE','QUANTUM','FORMULE','LABO'],
    'Culture': ['MUSIQUE','DANSE','CINEMA','THEATRE','LIVRE','POESIE','PEINTURE','SCULPTURE','ROMAN','CHANT','MASQUE','TAMBOUR','ARTISTE','MUSEE','CULTURE','CONTE','RHYTHME','DESSIN'],
    'Sports': ['FOOTBALL','TENNIS','RUGBY','BOXE','NATATION','CYCLISME','BASKET','COURSE','JUDO','KARATE','VOLLEY','HANDBALL','GOLF','SURF','ESCRIME','SKI','MARATHON','PLONGEE'],
    'Technologie': ['CLAVIER','ECRAN','SOURIS','RESEAU','DONNEE','CLOUD','PIXEL','MODEM','ROBOT','CAPTEUR','LOGICIEL','SERVEUR','TABLETTE','MOBILE','CODE','WIFI','CASQUE','CAMERA'],
    'Espace': ['GALAXIE','NEBULEUSE','COMETE','ASTEROIDE','MERCURE','VENUS','MARS','JUPITER','SATURNE','URANUS','NEPTUNE','LUNAIRE','FUSEE','ETOILE','COSMOS','ORBITAL','METEORE','SOLEIL'],
  };

  static final List<GameLevel> all = _build();

  static List<GameLevel> _build() {
    final levels = <GameLevel>[];
    var id = 1;
    for (final entry in _themes.entries) {
      final words = entry.value;
      for (var stage = 0; stage < 10; stage++) {
        final size = id <= 20 ? 8 : id <= 50 ? 9 : id <= 80 ? 10 : 12;
        final count = id <= 20 ? 5 : id <= 60 ? 6 : 7;
        // Space consecutive levels across the theme vocabulary instead of taking
        // near-identical overlapping slices. This reduces back-to-back repeats.
        final start = (stage * 8) % words.length;
        final selected = List.generate(count, (i) => words[(start + i) % words.length]);
        levels.add(GameLevel(
          id: id,
          title: 'Niveau $id',
          category: entry.key,
          gridSize: size,
          words: List.unmodifiable(selected),
          timeLimitSeconds: id <= 20 ? 150 : id <= 60 ? 180 : 210,
          difficulty: id <= 20 ? 'Facile' : id <= 60 ? 'Intermédiaire' : 'Expert',
        ));
        id++;
      }
    }
    return List.unmodifiable(levels);
  }
}
