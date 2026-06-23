// ignore_for_file: constant_identifier_names

class ExerciceData {
  final String nom;
  final String groupe;
  final String equipement;

  const ExerciceData({
    required this.nom,
    required this.groupe,
    required this.equipement,
  });
}

// ═══════════════════════════════════════════════════════════════
//  GROUPES MUSCULAIRES
// ═══════════════════════════════════════════════════════════════

const List<String> groupesMusculaires = [
  'Pectoraux',
  'Épaules',
  'Dos',
  'Biceps',
  'Triceps',
  'Avant-bras',
  'Abdominaux',
  'Lombaires',
  'Fessiers',
  'Quadriceps',
  'Ischio-jambiers',
  'Abducteurs',
  'Adducteurs',
  'Mollets',
  'Étirements',
];

// ═══════════════════════════════════════════════════════════════
//  PECTORAUX
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesPectoraux = [
  'Développé couché barre',
  'Développé couché haltères',
  'Développé incliné barre',
  'Développé incliné haltères',
  'Développé décliné barre',
  'Développé décliné haltères',
  'Développé machine guidée',
  'Chest press machine',
  'Pompes classiques',
  'Pompes inclinées',
  'Pompes déclinées',
  'Pompes diamant',
  'Pompes larges',
  'Dips penché avant',
  'Écarté couché haltères',
  'Écarté incliné haltères',
  'Écarté décliné haltères',
  'Pec deck machine',
  'Butterfly machine',
  'Écarté poulie vis-à-vis',
  'Écarté poulie basse',
  'Écarté poulie haute',
  'Pull-over haltère',
  'Pull-over à la poulie',
  'Landmine press',
  'Svend press',
  'Développé serré',
  'Développé unilatéral haltère',
  'Chest fly machine',
  'Cable press pectoraux',
];

// ═══════════════════════════════════════════════════════════════
//  ÉPAULES
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesEpaules = [
  'Développé militaire barre',
  'Développé épaules haltères',
  'Shoulder press machine',
  'Développé Arnold',
  'Développé nuque',
  'Élévations latérales haltères',
  'Élévations latérales à la poulie',
  'Élévations latérales machine',
  'Élévations frontales haltères',
  'Élévations frontales barre',
  'Élévations frontales à la poulie',
  'Oiseau haltères',
  'Oiseau sur banc incliné',
  'Reverse pec deck',
  'Face pull à la poulie',
  'Tirage menton barre',
  'Tirage menton poulie',
  'Rowing menton haltères',
  'Shrugs barre',
  'Shrugs haltères',
  'Shrugs machine',
  'Cuban press',
  'Landmine press épaules',
  'Pike push-up',
  'Handstand push-up',
  'Y raise',
  'L raise',
  'Rotation externe à la poulie',
  'Rotation externe élastique',
  'Farmer walk épaules/trapèzes',
];

// ═══════════════════════════════════════════════════════════════
//  DOS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesDos = [
  'Traction pronation',
  'Traction supination',
  'Traction prise neutre',
  'Tirage vertical poitrine',
  'Tirage vertical nuque',
  'Tirage vertical prise serrée',
  'Tirage vertical prise large',
  'Rowing barre',
  'Rowing haltère unilatéral',
  'Rowing T-bar',
  'Rowing machine',
  'Rowing poulie basse',
  'Rowing assis prise serrée',
  'Rowing assis prise large',
  'Rowing inversé',
  'Tirage horizontal poulie',
  'Tirage bûcheron',
  'Pull-over poulie haute',
  'Pull-over haltère dos',
  'Straight arm pulldown',
  'Soulevé de terre',
  'Soulevé de terre roumain',
  'Rack pull',
  'Good morning',
  'Hyperextension lombaire',
  'Extension lombaire au banc',
  'Superman',
  'Face pull',
  'Reverse fly',
  'Shrugs trapèzes',
];

// ═══════════════════════════════════════════════════════════════
//  BICEPS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesBiceps = [
  'Curl barre droite',
  'Curl barre EZ',
  'Curl haltères alterné',
  'Curl haltères simultané',
  'Curl marteau',
  'Curl marteau à la corde',
  'Curl incliné haltères',
  'Curl pupitre barre EZ',
  'Curl pupitre haltère',
  'Curl concentration',
  'Curl spider',
  'Curl à la poulie basse',
  'Curl poulie corde',
  'Curl poulie unilatéral',
  'Curl câble vis-à-vis',
  'Curl machine',
  'Curl assis haltères',
  'Curl debout haltères',
  'Curl inversé barre',
  'Curl inversé EZ',
  'Curl prise serrée',
  'Curl prise large',
  'Curl Zottman',
  'Curl 21',
  'Traction supination',
  'Traction prise serrée supination',
  'Curl élastique',
  'Curl preacher machine',
  'Curl drag',
  'Curl isométrique',
];

// ═══════════════════════════════════════════════════════════════
//  TRICEPS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesTriceps = [
  'Extension triceps à la poulie haute',
  'Pushdown barre droite',
  'Pushdown corde',
  'Pushdown barre V',
  'Extension triceps unilatérale à la poulie',
  'Extension triceps au-dessus de la tête à la corde',
  'Extension nuque haltère',
  'Extension nuque barre EZ',
  'Extension nuque à la poulie',
  'Skull crusher barre EZ',
  'Barre au front',
  'Développé couché prise serrée',
  'Dips entre deux bancs',
  'Dips aux barres parallèles',
  'Pompes prise serrée',
  'Pompes diamant',
  'Kickback haltère',
  'Kickback à la poulie',
  'Tate press',
  'JM press',
  'Extension triceps machine',
  'Triceps press machine',
  'French press barre EZ',
  'Extension triceps allongé haltères',
  'Extension triceps assis haltère',
  'Extension triceps debout haltère',
  'Extension triceps élastique',
  'Bench dips',
  'Cable overhead triceps extension',
];

// ═══════════════════════════════════════════════════════════════
//  AVANT-BRAS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesAvantBras = [
  'Curl poignets barre',
  'Curl poignets haltères',
  'Curl poignets à la poulie',
  'Curl poignets inversé barre',
  'Curl poignets inversé haltères',
  'Reverse curl barre',
  'Reverse curl barre EZ',
  'Reverse curl haltères',
  'Curl marteau avant-bras',
  'Curl marteau corde',
  'Farmer walk',
  'Dead hang',
  'Towel hang',
  'Plate pinch',
  'Wrist roller',
  'Rotation poignets avec haltère',
  'Pronation haltère',
  'Supination haltère',
  'Grip squeeze',
  'Hand gripper',
  'Pinch grip hold',
  'Barbell hold',
  'Dumbbell hold',
  'Rope climb',
  'Traction serviette',
  'Wrist extension élastique',
  'Wrist flexion élastique',
  'Zottman curl',
  'Fat grip curl',
  'Suitcase carry',
];

// ═══════════════════════════════════════════════════════════════
//  ABDOMINAUX
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesAbdominaux = [
  'Crunch au sol',
  'Crunch machine',
  'Crunch à la poulie haute',
  'Crunch inversé',
  'Crunch oblique',
  'Sit-up',
  'Relevé de jambes au sol',
  'Relevé de jambes suspendu',
  'Relevé de genoux suspendu',
  'Relevé de jambes sur chaise romaine',
  'Gainage classique',
  'Gainage latéral',
  'Gainage dynamique',
  'Planche avec rotation',
  'Mountain climber',
  'Bicycle crunch',
  'Russian twist',
  'Dead bug',
  'Hollow hold',
  'Hollow rock',
  'Toe touch',
  'V-up',
  'Jackknife',
  'Ab wheel rollout',
  'Cable woodchopper',
  'Pallof press',
  'Dragon flag',
  'Flutter kicks',
  'Scissor kicks',
  'Vacuum abdominal',
  'Planche shoulder tap',
  'Planche commando',
  'Reverse plank',
  'Oblique side bend haltère',
  'Medicine ball slam',
];

// ═══════════════════════════════════════════════════════════════
//  LOMBAIRES
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesLombaires = [
  'Hyperextension lombaire',
  'Extension lombaire au banc 45°',
  'Extension lombaire au sol',
  'Superman',
  'Good morning',
  'Soulevé de terre classique',
  'Soulevé de terre roumain',
  'Rack pull',
  'Back extension machine',
  'Reverse hyperextension',
  'Bird dog',
  'Dead bug lombaires',
  'Gainage classique',
  'Gainage latéral',
  'Gainage superman',
  'Pont fessier / Glute bridge',
  'Hip thrust',
  'Kettlebell swing',
  'Pull-through à la poulie',
  'Rowing barre buste penché',
  'T-bar row',
  'Farmer walk',
  'Suitcase carry',
  'Planche avec extension jambe',
  'Cobra stretch dynamique',
  'Extension lombaire avec disque',
  'Extension lombaire avec élastique',
  'Good morning Smith machine',
  'Jefferson curl léger',
  'McGill curl-up',
];

// ═══════════════════════════════════════════════════════════════
//  FESSIERS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesFessiers = [
  'Hip thrust',
  'Hip thrust barre',
  'Hip thrust machine',
  'Hip thrust unilatéral',
  'Glute bridge',
  'Glute bridge barre',
  'Glute bridge unilatéral',
  'Squat sumo fessiers',
  'Squat barre fessiers',
  'Goblet squat',
  'Bulgarian split squat',
  'Fentes arrière',
  'Fentes marchées',
  'Fentes latérales',
  'Step-up banc',
  'Presse à cuisses pieds hauts',
  'Soulevé de terre roumain',
  'Soulevé de terre sumo',
  'Kickback à la poulie',
  'Kickback machine',
  'Donkey kick',
  'Fire hydrant',
  'Abduction machine',
  'Abduction élastique',
  'Abduction à la poulie',
  'Monster walk',
  'Lateral band walk',
  'Cable pull-through',
  'Reverse hyperextension',
  'Frog pump',
];

// ═══════════════════════════════════════════════════════════════
//  QUADRICEPS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesQuadriceps = [
  'Squat barre',
  'Front squat',
  'Goblet squat',
  'Hack squat',
  'Smith machine squat',
  'Presse à cuisses',
  'Presse inclinée pieds bas',
  'Leg extension',
  'Fentes avant',
  'Fentes marchées',
  'Bulgarian split squat',
  'Split squat',
  'Step-up banc',
  'Sissy squat',
  'Wall sit',
  'Box squat',
  'Squat talons surélevés',
  'Squat sumo',
  'Squat jump',
  'Pistol squat',
  'Leg press unilatérale',
  'Leg extension unilatéral',
  'Fentes latérales',
  'Reverse Nordic curl',
  'Cyclist squat',
  'Belt squat',
  'Landmine squat',
  'Zercher squat',
  'Squat machine guidée',
  'Walking lunges',
];

// ═══════════════════════════════════════════════════════════════
//  ISCHIO-JAMBIERS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesIschioJambiers = [
  'Soulevé de terre roumain',
  'Soulevé de terre jambes tendues',
  'Leg curl couché',
  'Leg curl assis',
  'Leg curl debout',
  'Leg curl unilatéral',
  'Nordic hamstring curl',
  'Good morning',
  'Hip thrust',
  'Glute bridge',
  'Pull-through à la poulie',
  'Kettlebell swing',
  'Romanian deadlift haltères',
  'Romanian deadlift barre',
  'Single leg Romanian deadlift',
  'Deadlift sumo',
  'Deadlift classique',
  'Back extension focus ischios',
  'Hyperextension banc 45°',
  'Swiss ball leg curl',
  'Slider leg curl',
  'TRX hamstring curl',
  'Cable leg curl',
  'Machine hip extension',
  'Fentes arrière',
  'Bulgarian split squat focus ischios',
  'Step-up haut',
  'Good morning Smith machine',
  'Reverse hyperextension',
  'Donkey kick machine',
];

// ═══════════════════════════════════════════════════════════════
//  ABDUCTEURS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesAbducteurs = [
  'Abduction machine',
  'Abduction à la poulie',
  'Abduction avec élastique',
  'Side lying leg raise',
  'Monster walk',
  'Lateral band walk',
  'Clamshell',
  'Fire hydrant',
  'Hip abduction debout',
  'Hip abduction allongé',
  'Side plank abduction',
  'Kickback latéral à la poulie',
  'Cable hip abduction',
  'Lateral step-up',
  'Skater squat',
];

// ═══════════════════════════════════════════════════════════════
//  ADDUCTEURS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesAdducteurs = [
  'Adduction machine',
  'Adduction à la poulie',
  'Adduction avec élastique',
  'Copenhagen plank',
  'Side lying adduction',
  'Sumo squat',
  'Squat large',
  'Fente latérale',
  'Cossack squat',
  'Leg press pieds larges',
  'Adductor squeeze avec ballon',
  'Cable hip adduction',
  'Adduction debout',
  'Glute bridge avec ballon entre genoux',
  'Sliding lateral lunge',
];

// ═══════════════════════════════════════════════════════════════
//  MOLLETS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesMollets = [
  'Mollets debout machine',
  'Mollets assis machine',
  'Mollets à la presse',
  'Mollets debout haltères',
  'Mollets debout barre',
  'Mollets unilatéral debout',
  'Mollets unilatéral avec haltère',
  'Mollets à la Smith machine',
  'Mollets à la hack squat',
  'Donkey calf raise',
  'Standing calf raise',
  'Seated calf raise',
  'Leg press calf raise',
  'Calf raise sur step',
  'Calf raise au poids du corps',
  'Calf raise explosif',
  'Jump rope / corde à sauter',
  'Box jump',
  'Pogo jumps',
  'Farmer walk sur pointes',
  'Marche sur pointes',
  'Tibialis raise',
  'Toe raise contre mur',
  'Mollets genoux fléchis',
  'Mollets genoux tendus',
  'Mollets avec élastique',
  'Calf raise tempo lent',
  'Calf raise pause en haut',
  'Calf raise pause en bas',
  'Sled push sur pointes',
];

// ═══════════════════════════════════════════════════════════════
//  ÉTIREMENTS
// ═══════════════════════════════════════════════════════════════

const List<String> exercicesEtirements = [
  'Étirement pectoral bras levés',
  'Étirement épaule bras croisé',
  'Étirement avant-bras coude tendu',
  'Étirement adducteurs allongé sur le dos',
  'Étirement quadriceps à quatre pattes',
  'Étirement épaule bras fléchi',
  'Étirement vertical des bras',
  'Étirement du dos à la barre fixe',
  'Cercles de hanches',
  'Rotation du buste allongé',
  'Rotation dynamique des hanches 90-90',
  'Flexion et extension de la colonne',
  'Étirement du psoas',
  'Fente profonde avec étirement des ischios',
  'Étirement de la hanche 90-90',
  'Étirement des pectoraux à genoux',
  'Étirement fléchisseurs de hanche à genoux',
  'Étirement rotation dos genoux',
  'Étirement adducteurs en fente latérale',
  'Étirement quadriceps en fente à genoux',
  'Étirement jambe tendue surélevée',
];

// ═══════════════════════════════════════════════════════════════
//  MAP COMPLÈTE : groupe → liste d'exercices
// ═══════════════════════════════════════════════════════════════

const Map<String, List<String>> exercicesParGroupe = {
  'Pectoraux': exercicesPectoraux,
  'Épaules': exercicesEpaules,
  'Dos': exercicesDos,
  'Biceps': exercicesBiceps,
  'Triceps': exercicesTriceps,
  'Avant-bras': exercicesAvantBras,
  'Abdominaux': exercicesAbdominaux,
  'Lombaires': exercicesLombaires,
  'Fessiers': exercicesFessiers,
  'Quadriceps': exercicesQuadriceps,
  'Ischio-jambiers': exercicesIschioJambiers,
  'Abducteurs': exercicesAbducteurs,
  'Adducteurs': exercicesAdducteurs,
  'Mollets': exercicesMollets,
  'Étirements': exercicesEtirements,
};

// ═══════════════════════════════════════════════════════════════
//  HELPER : chercher un exercice dans tous les groupes
// ═══════════════════════════════════════════════════════════════

List<String> rechercherExercices(String query) {
  final q = query.toLowerCase();
  final results = <String>[];
  for (final liste in exercicesParGroupe.values) {
    for (final ex in liste) {
      if (ex.toLowerCase().contains(q)) results.add(ex);
    }
  }
  return results;
}

// ═══════════════════════════════════════════════════════════════
//  STATS
// ═══════════════════════════════════════════════════════════════
//
//  Pectoraux        : 30
//  Épaules          : 30
//  Dos              : 30
//  Biceps           : 30
//  Triceps          : 29
//  Avant-bras       : 30
//  Abdominaux       : 35
//  Lombaires        : 30
//  Fessiers         : 30
//  Quadriceps       : 30
//  Ischio-jambiers  : 30
//  Abducteurs       : 15
//  Adducteurs       : 15
//  Mollets          : 30
//  ─────────────────────
//  TOTAL            : 424 exercices
//
