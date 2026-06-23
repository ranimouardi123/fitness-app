import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'exercices_data.dart';
import '../../app_theme.dart';

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════

String _toSlug(String nom) {
  const accents = {
    'à':'a','â':'a','ä':'a','á':'a',
    'è':'e','ê':'e','ë':'e','é':'e',
    'î':'i','ï':'i','í':'i','ì':'i',
    'ô':'o','ö':'o','ó':'o','ò':'o',
    'û':'u','ü':'u','ú':'u','ù':'u',
    'ç':'c','ñ':'n',
    'À':'a','Â':'a','Ä':'a','Á':'a',
    'È':'e','Ê':'e','Ë':'e','É':'e',
    'Î':'i','Ï':'i','Í':'i','Ì':'i',
    'Ô':'o','Ö':'o','Ó':'o','Ò':'o',
    'Û':'u','Ü':'u','Ú':'u','Ù':'u',
    'Ç':'c','Ñ':'n',
  };
  var s = nom.toLowerCase();
  for (final e in accents.entries) {
    s = s.replaceAll(e.key, e.value);
  }
  s = s
    .replaceAll(RegExp(r"[''`]"), '-')
    .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
    .trim()
    .replaceAll(RegExp(r'\s+'), '-')
    .replaceAll(RegExp(r'-+'), '-');
  return s;
}

String? _extractGif(String html) {
  final pattern = RegExp(
    r'https://www[.]docteur-fitness[.]com/wp-content/uploads/[^"<>\s]+[.]gif',
  );
  final match = pattern.firstMatch(html);
  return match?.group(0);
}

const Map<String, String> slugOverrides = {
  // Épaules
  'Shoulder press machine':            'developpe-epaules-a-la-machine',
  'Développé nuque':                   'developpe-nuque-barre-guidee',
  'Oiseau haltères':                   'oiseau-assis-sur-un-banc',
  'Oiseau sur banc incliné':           'oiseau-assis-sur-un-banc',
  'Élévations latérales haltères':     'elevations-laterales',
  'Élévations latérales à la poulie':  'elevations-laterales-a-la-poulie',
  'Élévations latérales machine':      'elevations-laterales-a-la-machine',
  'Élévations frontales haltères':     'elevations-frontales',
  'Élévations frontales barre':        'elevations-frontales',
  'Élévations frontales à la poulie':  'elevations-frontales-a-la-poulie-basse',
  'Développé militaire barre':         'developpe-militaire',
  'Développé épaules haltères':        'developpe-epaules-assis',
  'Développé Arnold':                  'developpe-arnold',
  'Tirage menton barre':               'tirage-menton',
  'Tirage menton poulie':              'tirage-menton-barre-guidee',
  'Rowing menton haltères':            'tirage-menton',
  'Face pull à la poulie':             'face-pull',
  'Reverse pec deck':                  'pec-deck-inverse',
  'Shrugs barre':                      'shrug-barre',
  'Shrugs haltères':                   'shrugs-avec-halteres',
  'Shrugs machine':                    'shrug-a-la-poulie',
  'Cuban press':                       'rotations-cubaines',
  'Landmine press épaules':            'developpe-militaire',
  'Pike push-up':                      'pompes-piquees',
  'Handstand push-up':                 'handstand-push-up',
  'Y raise':                           'elevation-en-y-a-la-poulie',
  'L raise':                           'rotation-externe-de-lepaule-a-la-poulie',
  'Farmer walk épaules/trapèzes':      'shrug-barre',
  'Rotation externe à la poulie':      'rotation-externe-de-lepaule-a-la-poulie',
  'Rotation externe élastique':        'rotations-externes-de-lepaule-avec-elastique',
  // Pectoraux
  'Développé couché barre':            'developpe-couche',
  'Développé couché haltères':         'developpe-couche-halteres',
  'Développé incliné barre':           'developpe-incline-a-la-barre',
  'Développé incliné haltères':        'developpe-incline-avec-halteres',
  'Développé décliné barre':           'developpe-decline-a-la-barre',
  'Développé décliné haltères':        'developpe-decline-avec-haltere',
  'Développé machine guidée':          'developpe-machine-assis-pour-les-pectoraux',
  'Chest press machine':               'developpe-machine-assis-pour-les-pectoraux',
  'Pompes classiques':                 'pourquoi-devrait-on-faire-des-pompes-plus-souvent',
  'Pompes inclinées':                  'pompes-inclinees',
  'Pompes déclinées':                  'pompes-declinees',
  'Pompes diamant':                    'pompes-diamant',
  'Pompes larges':                     'pompes-larges',
  'Dips penché avant':                 'dips',
  'Écarté couché haltères':            'ecartes-couche-avec-halteres',
  'Écarté incliné haltères':           'ecartes-incline-avec-halteres',
  'Écarté décliné haltères':           'ecartes-decline-avec-halteres',
  'Pec deck machine':                  'pec-deck',
  'Butterfly machine':                 'pec-deck',
  'Écarté poulie vis-à-vis':           'ecartes-a-la-poulie-vis-a-vis-pour-les-pectoraux',
  'Écarté poulie basse':               'ecartes-a-la-poulie-vis-a-vis-pour-les-pectoraux',
  'Écarté poulie haute':               'ecartes-a-la-poulie-haute',
  'Pull-over haltère':                 'pullover-avec-haltere',
  'Pull-over à la poulie':             'pull-over-avec-barre',
  'Landmine press':                    'developpe-a-la-landmine-pour-les-pectoraux',
  'Svend press':                       'svend-press',
  'Développé serré':                   'developpe-couche-serre-avec-halteres',
  'Développé unilatéral haltère':      'developpe-couche-halteres',
  'Chest fly machine':                 'pec-deck',
  'Cable press pectoraux':             'developpe-incline-a-la-poulie',
  // Dos
  'Traction pronation':                'traction-pronation',
  'Traction supination':               'traction-supination',
  'Traction prise neutre':             'traction-prise-neutre',
  'Tirage vertical poitrine':          'tirage-vertical-poitrine',
  'Tirage vertical nuque':             'tirage-vertical-nuque',
  'Tirage vertical prise serrée':      'tirage-vertical-prise-serree',
  'Tirage vertical prise large':       'tirage-vertical-poitrine',
  'Rowing barre':                      'rowing-barre',
  'Rowing haltère unilatéral':         'rowing-haltere',
  'Rowing T-bar':                      'rowing-t-bar',
  'Rowing machine':                    'rowing-en-pronation-assis-a-la-machine-technogym',
  'Rowing poulie basse':               'tirage-horizontal-a-la-poulie',
  'Rowing assis prise serrée':         'tirage-vertical-prise-serree',
  'Rowing assis prise large':          'tirage-horizontal-prise-large',
  'Rowing inversé':                    'tractions-australiennes',
  'Tirage horizontal poulie':          'tirage-horizontal-a-la-poulie',
  'Tirage bûcheron':                   'bent-over-row-avec-halteres',
  'Pull-over poulie haute':            'pull-over-a-la-poulie',
  'Pull-over haltère dos':             'pullover-avec-haltere',
  'Straight arm pulldown':             'pull-over-a-la-poulie',
  'Reverse fly':                       'pec-deck-inverse',
  'Shrugs trapèzes':                   'shrug-barre',
  'Soulevé de terre':                  'souleve-de-terre',
  'Soulevé de terre roumain':          'souleve-de-terre-roumain',
  'Hyperextension lombaire':           'hyperextension',
  // Lombaires
  'Extension lombaire au banc 45°':    'extension-lombaire-au-banc-a-45',
  'Extension lombaire au sol':         'extension-lombaire-au-banc-a-45',
  'Back extension machine':            'extension-lombaire-a-la-machine',
  'Reverse hyperextension':            'reverse-hyperextension',
  'Bird dog':                          'hyperextension',
  'Dead bug lombaires':                'planche',
  'Gainage superman':                  'hyperextension',
  'Pont fessier / Glute bridge':       'glute-bridge',
  'Rowing barre buste penché':         'rowing-barre',
  'T-bar row':                         'rowing-t-bar',
  'Planche avec extension jambe':      'planche',
  'Extension lombaire avec disque':    'extension-lombaire-au-banc-a-45',
  'Extension lombaire avec élastique': 'extension-lombaire-au-banc-a-45',
  'Good morning Smith machine':        'good-morning',
  // Avant-bras
  'Curl poignets barre':               'curl-inverse-a-la-barre',
  'Curl poignets haltères':            'curl-zottman',
  'Curl poignets à la poulie':         'curl-inverse-a-la-barre',
  'Curl poignets inversé barre':       'curl-inverse-a-la-barre',
  'Curl poignets inversé haltères':    'curl-zottman',
  'Reverse curl barre':                'curl-inverse-a-la-barre',
  'Reverse curl barre EZ':             'curl-inverse-a-la-barre',
  'Reverse curl haltères':             'curl-zottman',
  'Curl marteau avant-bras':           'curl-haltere-prise-neutre',
  'Curl marteau corde':                'curl-haltere-prise-neutre',
  'Farmer walk':                       'shrug-barre',
  'Zottman curl':                      'curl-zottman',
  'Fat grip curl':                     'curl-a-la-barre',
  'Suitcase carry':                    'shrug-barre',
  // Biceps
  'Curl barre droite':                 'curl-a-la-barre',
  'Curl barre EZ':                     'curl-pupitre-barre-ez',
  'Curl haltères alterné':             'curl-biceps-avec-halteres-alterne',
  'Curl haltères simultané':           'curl-biceps-avec-halteres-alterne',
  'Curl marteau':                      'curl-haltere-prise-neutre',
  'Curl marteau à la corde':           'curl-haltere-prise-neutre',
  'Curl incliné haltères':             'curl-haltere-incline',
  'Curl pupitre barre EZ':             'curl-pupitre-barre-ez',
  'Curl pupitre haltère':              'curl-haltere-prise-marteau-au-pupitre',
  'Curl concentration':                'curl-concentration',
  'Curl spider':                       'curl-spider',
  'Curl à la poulie basse':            'curl-biceps-a-la-poulie-basse',
  'Curl poulie corde':                 'curl-biceps-a-la-poulie-basse',
  'Curl poulie unilatéral':            'curl-biceps-a-la-poulie-basse',
  'Curl câble vis-à-vis':              'curl-biceps-a-la-poulie-basse',
  'Curl machine':                      'curl-biceps-a-la-poulie-basse',
  'Curl assis haltères':               'curl-biceps-avec-halteres-alterne',
  'Curl debout haltères':              'curl-biceps-avec-halteres-alterne',
  'Curl inversé barre':                'curl-inverse-a-la-barre',
  'Curl inversé EZ':                   'curl-inverse-a-la-barre',
  'Curl prise serrée':                 'curl-a-la-barre',
  'Curl prise large':                  'curl-a-la-barre',
  'Curl Zottman':                      'curl-haltere-prise-neutre',
  'Curl 21':                           'curl-a-la-barre',
  'Curl élastique':                    'curl-biceps-a-la-poulie-basse',
  'Curl preacher machine':             'curl-pupitre-barre-ez',
  'Curl drag':                         'curl-a-la-barre',
  'Curl isométrique':                  'curl-a-la-barre',
  // Triceps
  'Extension triceps à la poulie haute':             'extensions-verticales-a-la-poulie-haute',
  'Pushdown barre droite':                           'extensions-verticales-a-la-poulie-haute',
  'Pushdown corde':                                  'extensions-des-triceps-a-la-poulie-haute-a-la-corde',
  'Pushdown barre V':                                'extensions-verticales-a-la-poulie-haute',
  'Extension triceps unilatérale à la poulie':       'extension-verticale-a-la-poulie-basse',
  'Extension triceps au-dessus de la tête à la corde': 'extensions-des-triceps-a-la-poulie-haute-a-la-corde',
  'Extension nuque haltère':                         'extensions-des-triceps-assis-avec-haltere',
  'Extension nuque barre EZ':                        'extensions-des-triceps-couche-avec-halteres',
  'Extension nuque à la poulie':                     'extension-verticale-a-la-poulie-basse',
  'Skull crusher barre EZ':                          'extensions-des-triceps-couche-avec-halteres',
  'Barre au front':                                  'extensions-des-triceps-couche-avec-halteres',
  'Développé couché prise serrée':                   'developpe-couche-prise-serree',
  'Dips entre deux bancs':                           'dips-sur-banc',
  'Dips aux barres parallèles':                      'dips',
  'Pompes prise serrée':                             'pompes-diamant',
  'Kickback haltère':                                'kickback',
  'Kickback à la poulie':                            'kickback-debout-avec-halteres',
  'JM press':                                        'extensions-des-triceps-couche-avec-halteres',
  'Extension triceps machine':                       'extensions-verticales-a-la-poulie-haute',
  'Triceps press machine':                           'extensions-verticales-a-la-poulie-haute',
  'French press barre EZ':                           'extensions-des-triceps-couche-avec-halteres',
  'Extension triceps allongé haltères':              'extensions-des-triceps-couche-avec-halteres',
  'Extension triceps assis haltère':                 'extensions-des-triceps-assis-avec-haltere',
  'Extension triceps debout haltère':                'extensions-verticales-dun-bras-avec-haltere',
  'Extension triceps élastique':                     'extension-verticale-des-triceps-avec-elastique',
  'Bench dips':                                      'dips-sur-banc',
  'Cable overhead triceps extension':                'extensions-des-triceps-a-la-poulie-haute-a-la-corde',
  // Abdominaux
  'Crunch au sol':                     'crunch-au-sol',
  'Crunch machine':                    'crunch-a-la-machine',
  'Crunch à la poulie haute':          'crunch-a-la-poulie',
  'Crunch inversé':                    'crunch-decline',
  'Crunch oblique':                    'crunch-a-la-poulie-pour-les-obliques',
  'Relevé de jambes au sol':           'crunch-avec-jambes-verticales',
  'Relevé de jambes suspendu':         'releve-de-genoux-suspendu',
  'Relevé de genoux suspendu':         'releve-de-genoux-suspendu',
  'Relevé de jambes sur chaise romaine': 'releve-de-jambes-a-la-chaise-romaine',
  'Gainage classique':                 'planche',
  'Gainage latéral':                   'planche',
  'Gainage dynamique':                 'planche',
  'Planche avec rotation':             'planche',
  'Mountain climber':                  'mountain-climber',
  'Bicycle crunch':                    'crunch-bicyclette',
  'Russian twist':                     'russian-twist',
  'Ab wheel rollout':                  'roulette-a-abdominaux',
  'Cable woodchopper':                 'crunch-a-la-poulie-pour-les-obliques',
  'Pallof press':                      'crunch-a-la-poulie',
  'Flutter kicks':                     'crunch-avec-jambes-verticales',
  'Scissor kicks':                     'crunch-avec-jambes-verticales',
  'Planche shoulder tap':              'planche',
  'Planche commando':                  'planche',
  'Reverse plank':                     'planche',
  'Oblique side bend haltère':         'crunch-a-la-poulie-pour-les-obliques',
  // Fessiers
  'Hip thrust':                        'hip-thrust',
  'Hip thrust barre':                  'hip-thrust',
  'Hip thrust machine':                'hip-thrust-a-la-machine',
  'Hip thrust unilatéral':             'hip-thrust',
  'Glute bridge':                      'glute-bridge',
  'Glute bridge barre':                'glute-bridge',
  'Glute bridge unilatéral':           'glute-bridge',
  'Squat sumo fessiers':               'squat-sumo',
  'Squat barre fessiers':              'squat',
  'Bulgarian split squat':             'squat-bulgare-avec-halteres',
  'Fentes arrière':                    'fentes',
  'Fentes latérales':                  'fentes',
  'Step-up banc':                      'montees-sur-banc',
  'Presse à cuisses pieds hauts':      'presse-a-cuisses',
  'Soulevé de terre sumo':             'souleve-de-terre-sumo',
  'Kickback machine':                  'kickback',
  'Donkey kick':                       'kickback',
  'Fire hydrant':                      'abduction-hanche-machine',
  'Abduction machine':                 'abduction-hanche-machine',
  'Abduction élastique':               'abduction-hanche-machine',
  'Abduction à la poulie':             'abduction-hanche-machine',
  'Monster walk':                      'abduction-hanche-machine',
  'Lateral band walk':                 'abduction-hanche-machine',
  'Cable pull-through':                'pull-through-avec-elastique',
  'Frog pump':                         'glute-bridge',
  // Quadriceps
  'Squat barre':                       'squat',
  'Front squat':                       'front-squat',
  'Goblet squat':                      'goblet-squat',
  'Hack squat':                        'hack-squat',
  'Smith machine squat':               'squat-a-la-smith-machine',
  'Presse à cuisses':                  'presse-a-cuisses',
  'Presse inclinée pieds bas':         'presse-a-cuisses',
  'Leg extension':                     'leg-extension',
  'Leg extension unilatéral':          'leg-extension',
  'Leg press unilatérale':             'presse-a-cuisses',
  'Fentes avant':                      'fentes',
  'Fentes marchées':                   'fentes-marchees',
  'Walking lunges':                    'fentes-marchees',
  'Split squat':                       'split-squat-a-la-smith-machine',
  'Wall sit':                          'squat-sur-banc',
  'Box squat':                         'squat-sur-banc',
  'Squat talons surélevés':            'squat',
  'Squat sumo':                        'squat-sumo',
  'Squat jump':                        'squat-saute',
  'Pistol squat':                      'squat-saute',
  'Squat machine guidée':              'squat-a-la-smith-machine',
  'Landmine squat':                    'squat',
  'Zercher squat':                     'squat',
  'Belt squat':                        'squat',
  'Cyclist squat':                     'squat',
  'Sissy squat':                       'squat',
  'Reverse Nordic curl':               'nordic-curl',
  // Ischio-jambiers
  'Leg curl couché':                   'leg-curl',
  'Leg curl assis':                    'leg-curl-assis',
  'Leg curl debout':                   'leg-curl-unilateral-debout-a-la-machine',
  'Leg curl unilatéral':               'leg-curl-unilateral-debout-a-la-machine',
  'Nordic hamstring curl':             'nordic-hamstring-curl-avec-elastique',
  'Good morning':                      'good-morning',
  'Romanian deadlift haltères':        'souleve-de-terre-roumain',
  'Romanian deadlift barre':           'souleve-de-terre-roumain',
  'Single leg Romanian deadlift':      'souleve-de-terre-roumain-a-la-landmine',
  'Deadlift sumo':                     'souleve-de-terre-sumo',
  'Deadlift classique':                'souleve-de-terre',
  'Back extension focus ischios':      'extension-lombaire-au-banc-a-45',
  'Hyperextension banc 45°':           'extension-lombaire-au-banc-a-45',
  'Swiss ball leg curl':               'leg-curl-au-ballon-de-gym',
  'Slider leg curl':                   'leg-curl-au-ballon-de-gym',
  'TRX hamstring curl':                'leg-curl-au-ballon-de-gym',
  'Cable leg curl':                    'leg-curl',
  'Machine hip extension':             'extension-de-la-hanche-a-la-poulie-basse',
  'Bulgarian split squat focus ischios': 'squat-bulgare-avec-halteres',
  'Step-up haut':                      'montees-sur-banc',
  'Donkey kick machine':               'kickback',
  // Abducteurs
  'Abduction avec élastique':          'abduction-hanche-machine',
  'Side lying leg raise':              'abduction-hanche-machine',
  'Clamshell':                         'abduction-hanche-machine',
  'Hip abduction debout':              'abduction-hanche-machine',
  'Hip abduction allongé':             'abduction-hanche-machine',
  'Side plank abduction':              'planche',
  'Kickback latéral à la poulie':      'extension-de-la-hanche-a-la-poulie-basse',
  'Cable hip abduction':               'extension-de-la-hanche-a-la-poulie-basse',
  'Lateral step-up':                   'montees-sur-banc',
  'Skater squat':                      'squat-bulgare-avec-halteres',
  // Adducteurs
  'Adduction machine':                 'abduction-hanche-machine',
  'Adduction à la poulie':             'extension-de-la-hanche-a-la-poulie-basse',
  'Adduction avec élastique':          'abduction-hanche-machine',
  'Side lying adduction':              'abduction-hanche-machine',
  'Sumo squat':                        'squat-sumo-avec-haltere',
  'Squat large':                       'squat-sumo-avec-haltere',
  'Leg press pieds larges':            'presse-a-cuisses',
  'Adductor squeeze avec ballon':      'glute-bridge',
  'Cable hip adduction':               'extension-de-la-hanche-a-la-poulie-basse',
  'Adduction debout':                  'extension-de-la-hanche-a-la-poulie-basse',
  'Glute bridge avec ballon entre genoux': 'glute-bridge',
  'Copenhagen plank':                  'planche',
  'Cossack squat':                     'squat-bulgare-avec-halteres',
  'Fente latérale':                    'fentes',
  'Sliding lateral lunge':             'fentes',
  // Mollets
  'Mollets debout machine':            'extensions-des-mollets-debout-a-la-machine',
  'Mollets assis machine':             'extension-des-mollets-assis-a-la-machine',
  'Mollets à la presse':               'extension-des-mollets-a-la-presse',
  'Mollets debout haltères':           'mollets-debout-machine',
  'Mollets debout barre':              'extension-des-mollets-a-la-barre-debout',
  'Mollets unilatéral debout':         'extensions-des-mollets-debout-a-la-machine',
  'Mollets unilatéral avec haltère':   'mollets-debout-machine',
  'Mollets à la Smith machine':        'extensions-des-mollets-debout-a-la-smith-machine',
  'Mollets à la hack squat':           'extensions-des-mollets-au-hack-squat',
  'Donkey calf raise':                 'elevations-des-mollets-au-donkey',
  'Standing calf raise':               'extensions-des-mollets-debout-a-la-machine',
  'Seated calf raise':                 'extension-a-la-presse-a-mollets-assis',
  'Leg press calf raise':              'extension-des-mollets-a-la-presse',
  'Calf raise sur step':               'mollets-debout-machine',
  'Calf raise au poids du corps':      'mollets-debout-machine',
  'Calf raise explosif':               'squat-saute',
  'Calf raise tempo lent':             'extensions-des-mollets-debout-a-la-machine',
  'Calf raise pause en haut':          'extensions-des-mollets-debout-a-la-machine',
  'Calf raise pause en bas':           'extensions-des-mollets-debout-a-la-machine',
  'Mollets genoux fléchis':            'extension-des-mollets-assis-a-la-machine',
  'Mollets genoux tendus':             'extensions-des-mollets-debout-a-la-machine',
  'Mollets avec élastique':            'mollets-debout-machine',
  'Jump rope / corde à sauter':        'box-jump',
  'Box jump':                          'box-jump',
  'Pogo jumps':                        'squat-saute',
  'Farmer walk sur pointes':           'shrug-barre',
  'Marche sur pointes':                'mollets-debout-machine',
  'Sled push sur pointes':             'mollets-debout-machine',
};


/// Fallback ExerciseDB slugs pour exercices absents sur docteur-fitness
const Map<String, String> _exerciseDbIds = {
  // Avant-bras sans page docteur-fitness
  'Dead hang':                   'dead-hang',
  'Towel hang':                  'dead-hang',
  'Plate pinch':                 'plate-pinch',
  'Wrist roller':                'wrist-roller',
  'Rotation poignets avec haltère': 'wrist-rotation-with-dumbbell',
  'Pronation haltère':           'wrist-pronation',
  'Supination haltère':          'wrist-supination',
  'Grip squeeze':                'hand-grip-strengthener',
  'Hand gripper':                'hand-grip-strengthener',
  'Pinch grip hold':             'plate-pinch',
  'Barbell hold':                'farmers-walk',
  'Dumbbell hold':               'farmers-walk',
  'Rope climb':                  'rope-climb',
  'Traction serviette':          'towel-pull-up',
  'Wrist extension élastique':   'wrist-extension',
  'Wrist flexion élastique':     'wrist-flexion',
  'Pompes déclinées':        'decline-push-up',
  'Pompes diamant':          'diamond-push-up',
  'Pompes larges':           'wide-push-up',
  'Pompes classiques':       'push-up',
  'Pompes inclinées':        'incline-push-up',
  'Écarté poulie basse':     'cable-crossover',
  'Pull-over à la poulie':   'cable-pullover',
  'Landmine press':          'landmine-chest-press',
  'Développé unilatéral haltère': 'single-arm-dumbbell-bench-press',
};

/// URLs GIFs directs — priorité absolue sur docteur-fitness et ExerciseDB
const Map<String, String> _directGifUrls = {
  // Biceps
  'Curl haltères alterné':       'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
  'Curl haltères simultané':     'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
  'Curl assis haltères':         'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
  'Curl debout haltères':        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Curl.gif',
  'Traction prise serrée supination': 'https://fitnessprogramer.com/wp-content/uploads/2021/04/Close-Grip-Chin-Up.gif',
  // Dos
  'Traction pronation':          'https://fitnessprogramer.com/wp-content/uploads/2022/08/how-to-do-pull-up.gif',
  'Tirage bûcheron':             'https://www.docteur-fitness.com/wp-content/uploads/2022/10/bent-over-row-avec-halteres.gif',
  'Rowing haltère unilatéral':   'https://www.docteur-fitness.com/wp-content/uploads/2022/10/bent-over-row-avec-halteres.gif',
  'Soulevé de terre':            'https://www.docteur-fitness.com/wp-content/uploads/2021/12/souleve-de-terre.gif',
  'Soulevé de terre classique':  'https://www.docteur-fitness.com/wp-content/uploads/2021/12/souleve-de-terre.gif',
  // Avant-bras
  'Rope climb':                  'https://fitnessprogramer.com/wp-content/uploads/2022/02/Rope-Climb.gif',
  'Traction serviette':          'https://fitnessprogramer.com/wp-content/uploads/2022/02/Rope-Climb.gif',
  // Lombaires
  'Jefferson curl léger':        'https://fitnessprogramer.com/wp-content/uploads/2025/08/Dumbbell-jefferson-curl.gif',
  'Cobra stretch dynamique':     'https://fitnessprogramer.com/wp-content/uploads/2021/06/abdominal-stretch.gif',
  // Abdominaux
  'Toe touch':                   'https://fitnessprogramer.com/wp-content/uploads/2021/05/Standing-Toe-Touch.gif',
  // Biceps
  'Curl concentration':      'https://fitnessprogramer.com/wp-content/uploads/2021/02/Concentration-Curl.gif',
  // Dos
  'Traction supination':     'https://www.docteur-fitness.com/wp-content/uploads/2021/08/chin-up-traction-supination.gif',
  'Rowing barre':            'https://www.docteur-fitness.com/wp-content/uploads/2021/09/rowing-barre.gif',
  'Traction prise neutre':   'https://www.docteur-fitness.com/wp-content/uploads/2022/10/traction-prise-neutre.gif',
  'Tirage vertical nuque':   'https://www.docteur-fitness.com/wp-content/uploads/2024/06/traction-barre-derriere-rear-oull-up.gif',
  'Tirage vertical prise large': 'https://www.docteur-fitness.com/wp-content/uploads/2024/06/rocky-pull-up.gif',
  'Rowing inversé':          'https://www.docteur-fitness.com/wp-content/uploads/2025/11/tractions-aux-anneaux.gif',
  // Pectoraux
  'Développé machine guidée':'https://www.docteur-fitness.com/wp-content/uploads/2022/11/developpe-machine-assis-pectoraux.gif',
  'Chest press machine':     'https://www.docteur-fitness.com/wp-content/uploads/2022/11/developpe-machine-assis-pectoraux.gif',
  'Pompes classiques':       'https://www.docteur-fitness.com/wp-content/uploads/2020/10/pompe-musculation.gif',
  'Pompes inclinées':        'https://www.docteur-fitness.com/wp-content/uploads/2020/10/pompe-musculation.gif',
  'Landmine press':          'https://www.docteur-fitness.com/wp-content/uploads/2022/11/developpe-landmine-pectoraux.gif',
  // Abdominaux
  'Gainage classique':       'https://www.docteur-fitness.com/wp-content/uploads/2022/05/planche-abdos.gif',
  'Gainage latéral':         'https://www.docteur-fitness.com/wp-content/uploads/2022/05/planche-abdos.gif',
  'Gainage dynamique':       'https://www.docteur-fitness.com/wp-content/uploads/2022/05/planche-abdos.gif',
  'Planche avec rotation':   'https://www.docteur-fitness.com/wp-content/uploads/2022/05/planche-abdos.gif',
  'Planche shoulder tap':    'https://www.docteur-fitness.com/wp-content/uploads/2022/05/planche-abdos.gif',
  'Planche commando':        'https://www.docteur-fitness.com/wp-content/uploads/2022/05/planche-abdos.gif',
  'Vacuum abdominal':        'https://www.docteur-fitness.com/wp-content/uploads/2023/06/stomach-vacuum-exercice-abdos.gif',
  'Medicine ball slam':      'https://www.docteur-fitness.com/wp-content/uploads/2025/11/sit-up-avec-medecine-ball.gif',
  // Fessiers
  'Hip thrust':              'https://www.docteur-fitness.com/wp-content/uploads/2021/12/hips-thrust.gif',
  'Hip thrust machine':      'https://www.docteur-fitness.com/wp-content/uploads/2022/08/hip-thrust-a-la-machine.gif',
  'Hip thrust barre':        'https://www.docteur-fitness.com/wp-content/uploads/2022/08/hip-thrust-a-la-smith-machine.gif',
  'Hip thrust unilatéral':   'https://fitnessprogramer.com/wp-content/uploads/2021/06/Single-Leg-Bridge.gif',
  'Glute bridge unilatéral': 'https://fitnessprogramer.com/wp-content/uploads/2021/06/Single-Leg-Bridge.gif',
  'Frog pump':               'https://fitnessprogramer.com/wp-content/uploads/2022/10/Frog-Pump.gif',
  'Monster walk':            'https://www.docteur-fitness.com/wp-content/uploads/2022/08/marche-avec-elastique.gif',
  'Lateral band walk':       'https://www.docteur-fitness.com/wp-content/uploads/2022/08/marche-avec-elastique.gif',
  'Abduction élastique':     'https://www.docteur-fitness.com/wp-content/uploads/2022/04/fire-hydratant.gif',
  'Fire hydrant':            'https://www.docteur-fitness.com/wp-content/uploads/2022/04/fire-hydratant.gif',
  'Cable pull-through':      'https://www.docteur-fitness.com/wp-content/uploads/2022/05/extension-hanche-poulie-basse.gif',
  'Kickback à la poulie':    'https://www.docteur-fitness.com/wp-content/uploads/2022/05/extension-hanche-poulie-basse.gif',
  'Machine hip extension':   'https://www.docteur-fitness.com/wp-content/uploads/2025/11/extension-hanche-machine.gif',
  'Donkey kick':             'https://www.docteur-fitness.com/wp-content/uploads/2025/11/extension-hanche-machine.gif',
  'Kickback machine':        'https://www.docteur-fitness.com/wp-content/uploads/2025/11/extension-hanche-machine.gif',
  'Reverse hyperextension':  'https://www.docteur-fitness.com/wp-content/uploads/2022/02/reverse-hyperextension.gif',
  // Quadriceps
  'Presse à cuisses':        'https://www.docteur-fitness.com/wp-content/uploads/2022/08/presse-a-cuisses-verticale.gif',
  'Presse inclinée pieds bas':'https://www.docteur-fitness.com/wp-content/uploads/2022/08/presse-a-cuisses-verticale.gif',
  'Presse à cuisses pieds hauts':'https://www.docteur-fitness.com/wp-content/uploads/2023/08/presse-a-cuisse-sur-le-cote.gif',
  'Leg press pieds larges':  'https://www.docteur-fitness.com/wp-content/uploads/2000/06/presse-a-cuisse-exercice-musculation.gif',
  'Leg press unilatérale':   'https://www.docteur-fitness.com/wp-content/uploads/2023/08/hack-squat-assis.gif',
  'Hack squat':              'https://www.docteur-fitness.com/wp-content/uploads/2022/01/hack-squat.gif',
  'Cyclist squat':           'https://www.docteur-fitness.com/wp-content/uploads/2022/02/hack-squat-inverse.gif',
  'Sissy squat':             'https://www.docteur-fitness.com/wp-content/uploads/2022/02/hack-squat-inverse.gif',
  'Leg extension':           'https://www.docteur-fitness.com/wp-content/uploads/2021/12/extension-de-jambe-unilateral-machine-dips-assistes.gif',
  'Leg extension unilatéral':'https://www.docteur-fitness.com/wp-content/uploads/2021/12/extension-de-jambe-unilateral-machine-dips-assistes.gif',
  // Ischio-jambiers
  'Nordic hamstring curl':   'https://www.docteur-fitness.com/wp-content/uploads/2022/10/glute-ham-developer-ghd.gif',
  'Back extension focus ischios':'https://www.docteur-fitness.com/wp-content/uploads/2022/10/glute-ham-developer-ghd.gif',
  'Deadlift classique':      'https://www.docteur-fitness.com/wp-content/uploads/2021/12/souleve-de-terre.gif',
  'Rack pull':               'https://www.docteur-fitness.com/wp-content/uploads/2022/11/souleve-de-terre-avec-machine.gif',
  // Lombaires
  'Extension lombaire au banc 45°':'https://www.docteur-fitness.com/wp-content/uploads/2021/08/extension-lombaire-au-banc-45.gif',
  'Extension lombaire au sol':'https://www.docteur-fitness.com/wp-content/uploads/2021/08/extension-lombaire-au-banc-45.gif',
  'Back extension machine':  'https://www.docteur-fitness.com/wp-content/uploads/2021/08/extension-lombaire-au-banc-45.gif',
  // Abducteurs/Adducteurs
  'Hip abduction debout':        'https://fitnessprogramer.com/wp-content/uploads/2021/05/Standing-Hip-Abduction-1.gif',
  'Abduction à la poulie':       'https://fitnessprogramer.com/wp-content/uploads/2021/05/Standing-Hip-Abduction-1.gif',
  'Cable hip abduction':         'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Hip-Abduction.gif',
  'Kickback latéral à la poulie':'https://www.docteur-fitness.com/wp-content/uploads/2022/05/extension-hanche-poulie-basse.gif',
  'Abduction machine':           'https://fitnessprogramer.com/wp-content/uploads/2022/04/Lever-Side-Hip-Abduction.gif',
  'Side lying leg raise':        'https://fitnessprogramer.com/wp-content/uploads/2022/04/Lever-Side-Hip-Abduction.gif',
  'Hip abduction allongé':       'https://fitnessprogramer.com/wp-content/uploads/2022/04/Lever-Side-Hip-Abduction.gif',
  'Clamshell':                   'https://fitnessprogramer.com/wp-content/uploads/2022/04/Lever-Side-Hip-Abduction.gif',
  // Adducteurs
  'Adduction machine':           'https://fitnessprogramer.com/wp-content/uploads/2021/02/HIP-ADDUCTION-MACHINE.gif',
  'Adduction à la poulie':       'https://fitnessprogramer.com/wp-content/uploads/2021/02/HIP-ADDUCTION-MACHINE.gif',
  'Adduction debout':            'https://fitnessprogramer.com/wp-content/uploads/2021/02/HIP-ADDUCTION-MACHINE.gif',
  'Cable hip adduction':         'https://fitnessprogramer.com/wp-content/uploads/2021/02/HIP-ADDUCTION-MACHINE.gif',
  'Side lying adduction':        'https://fitnessprogramer.com/wp-content/uploads/2022/06/Side-Lying-Hip-Adduction.gif',
  'Adduction avec élastique':    'https://fitnessprogramer.com/wp-content/uploads/2022/06/Side-Lying-Hip-Adduction.gif',
  // Fessiers
  'Glute bridge':                'https://fitnessprogramer.com/wp-content/uploads/2021/02/Glute-Bridge-.gif',
  'Glute bridge barre':          'https://fitnessprogramer.com/wp-content/uploads/2021/02/Glute-Bridge-.gif',
  'Pont fessier / Glute bridge': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Glute-Bridge-.gif',
  'Glute bridge avec ballon entre genoux': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Glute-Bridge-.gif',
  'Adductor squeeze avec ballon':'https://fitnessprogramer.com/wp-content/uploads/2021/02/Glute-Bridge-.gif',
  // Mollets
  'Tibialis raise':              'https://fitnessprogramer.com/wp-content/uploads/2021/08/Toe-Extensor-Stretch.gif',
  'Toe raise contre mur':        'https://fitnessprogramer.com/wp-content/uploads/2021/08/Toe-Extensor-Stretch.gif',
  'Sled push sur pointes':       'https://fitnessprogramer.com/wp-content/uploads/2025/07/plate-push.gif',
  // Étirements
  'Étirement pectoral bras levés':            'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-pectoral-bras-leves.gif',
  'Étirement épaule bras croisé':             'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-epaule-bras-croise.gif',
  'Étirement avant-bras coude tendu':         'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-avant-bras-coude-tendu.gif',
  'Étirement adducteurs allongé sur le dos':  'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-des-adducteurs-allonge-sur-le-dos.gif',
  'Étirement quadriceps à quatre pattes':     'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-du-quadriceps-a-quatre-pattes.gif',
  'Étirement épaule bras fléchi':             'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-epaule-bras-flechi.gif',
  'Étirement vertical des bras':              'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-vertical-des-bras.gif',
  'Étirement du dos à la barre fixe':         'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-du-dos-a-la-barre-fixe.gif',
  'Cercles de hanches':                       'https://www.docteur-fitness.com/wp-content/uploads/2025/11/cercles-de-hanches.gif',
  'Rotation du buste allongé':                'https://www.docteur-fitness.com/wp-content/uploads/2025/11/rotation-du-buste-allonge.gif',
  'Rotation dynamique des hanches 90-90':     'https://www.docteur-fitness.com/wp-content/uploads/2025/11/rotation-dynamique-des-hanches-90-90.gif',
  'Flexion et extension de la colonne':       'https://www.docteur-fitness.com/wp-content/uploads/2025/11/flexion-et-extension-de-la-colonne.gif',
  'Étirement du psoas':                       'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-du-psoas.gif',
  'Fente profonde avec étirement des ischios':'https://www.docteur-fitness.com/wp-content/uploads/2025/11/fente-profonde-avec-etirement-des-ischios.gif',
  'Étirement de la hanche 90-90':             'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-de-la-hanche-90-90.gif',
  'Étirement des pectoraux à genoux':         'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-des-pectoraux-a-genoux.gif',
  'Étirement fléchisseurs de hanche à genoux':'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-des-flechisseurs-de-hanche-a-genoux.gif',
  'Étirement rotation dos genoux':            'https://www.docteur-fitness.com/wp-content/uploads/2024/09/etirement-rotation-dos-genoux-posture-flexibilite-mobilite-tensions-musculaires.gif',
  'Étirement adducteurs en fente latérale':   'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-des-adducteurs-en-fente-laterale.gif',
  'Étirement quadriceps en fente à genoux':   'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-quadriceps-en-fente-a-genoux.gif',
  'Étirement jambe tendue surélevée':         'https://www.docteur-fitness.com/wp-content/uploads/2025/11/etirement-jambe-tendue-surelevee.gif',
  // Mollets
  'Calf raise sur step':         'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-sur-marche.gif',
  'Calf raise au poids du corps':'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-sur-marche.gif',
  'Marche sur pointes':          'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-sur-marche.gif',
  'Mollets debout barre':        'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-barre-debout.gif',
  'Mollets debout haltères':     'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-barre-debout.gif',
  'Standing calf raise':         'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-barre-debout.gif',
  'Mollets unilatéral debout':   'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-barre-debout.gif',
  'Mollets unilatéral avec haltère':'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-barre-debout.gif',
  'Mollets assis machine':       'https://www.docteur-fitness.com/wp-content/uploads/2022/02/extension-mollets-assis-barre.gif',
  'Seated calf raise':           'https://www.docteur-fitness.com/wp-content/uploads/2022/02/extension-mollets-assis-barre.gif',
  'Mollets genoux fléchis':      'https://www.docteur-fitness.com/wp-content/uploads/2022/02/extension-mollets-assis-barre.gif',
  'Mollets genoux tendus':       'https://www.docteur-fitness.com/wp-content/uploads/2021/10/extension-mollets-barre-debout.gif',
  // Avant-bras
  'Wrist roller':                   'https://fitnessprogramer.com/wp-content/uploads/2021/08/wrist-roller.gif',
  'Towel hang':                     'https://www.docteur-fitness.com/wp-content/uploads/2025/11/dead-hang-suspension-passive.gif',
  'Dead hang':                      'https://www.docteur-fitness.com/wp-content/uploads/2025/11/dead-hang-suspension-passive.gif',
  'Hand gripper':                   'https://fitnessprogramer.com/wp-content/uploads/2022/01/Hand-Gripper.gif',
  'Farmer walk':                    'https://fitnessprogramer.com/wp-content/uploads/2022/02/Farmers-walk_Cardio.gif',
  'Barbell hold':                   'https://fitnessprogramer.com/wp-content/uploads/2022/02/Farmers-walk_Cardio.gif',
  'Dumbbell hold':                  'https://fitnessprogramer.com/wp-content/uploads/2022/02/Farmers-walk_Cardio.gif',
  'Suitcase carry':                 'https://fitnessprogramer.com/wp-content/uploads/2022/02/Farmers-walk_Cardio.gif',
  'Farmer walk sur pointes':        'https://fitnessprogramer.com/wp-content/uploads/2022/02/Farmers-walk_Cardio.gif',
  'Rotation poignets avec haltère': 'https://fitnessprogramer.com/wp-content/uploads/2021/04/Dumbbell-Wrist-Rotation.gif',
  'Pronation haltère':              'https://fitnessprogramer.com/wp-content/uploads/2021/04/Dumbbell-Pronation.gif',
  'Supination haltère':             'https://fitnessprogramer.com/wp-content/uploads/2021/04/Dumbbell-Supination.gif',
  'Wrist extension élastique':      'https://fitnessprogramer.com/wp-content/uploads/2021/04/Wrist-Extension.gif',
  'Wrist flexion élastique':        'https://fitnessprogramer.com/wp-content/uploads/2021/04/Wrist-Flexion.gif',
  'Pompes déclinées':   'https://fitnessprogramer.com/wp-content/uploads/2015/07/Decline-Push-Up.gif',
  'Pompes diamant':     'https://fitnessprogramer.com/wp-content/uploads/2021/02/Diamond-Push-up.gif',
  'Pompes larges':      'https://fitnessprogramer.com/wp-content/uploads/2021/02/Push-Up.gif',
  'Pompes prise serrée':    'https://fitnessprogramer.com/wp-content/uploads/2021/02/Diamond-Push-up.gif',
  'Développé serré':        'https://fitnessprogramer.com/wp-content/uploads/2021/02/Close-Grip-Bench-Press.gif',
  'Développé couché prise serrée': 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Close-Grip-Bench-Press.gif',
};

final Map<String, String?> gifCache = {};

const String _apiKey  = 'bb620c84a6msh7707d719937d10bp16033cjsn01d7b45b7d84';
const String _apiHost = 'exercisedb.p.rapidapi.com';

Future<String?> fetchGif(String nom) async {
  if (gifCache.containsKey(nom)) return gifCache[nom];

  // 0. URLs directes — priorité absolue
  if (_directGifUrls.containsKey(nom)) {
    gifCache[nom] = _directGifUrls[nom];
    return _directGifUrls[nom];
  }

  // 1. Essayer docteur-fitness
  try {
    final slug = slugOverrides[nom] ?? _toSlug(nom);
    final url = 'https://www.docteur-fitness.com/$slug';
    final res = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'Mozilla/5.0 (compatible; FitnessApp/1.0)'},
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final gifUrl = _extractGif(res.body);
      if (gifUrl != null) {
        gifCache[nom] = gifUrl;
        return gifUrl;
      }
    }
  } catch (_) {}

  // 2. Fallback ExerciseDB si docteur-fitness n'a pas de GIF
  final dbQuery = _exerciseDbIds[nom];
  if (dbQuery != null) {
    try {
      final url = Uri.parse(
        'https://$_apiHost/exercises/name/${Uri.encodeComponent(dbQuery)}?limit=1&offset=0',
      );
      final res = await http.get(url, headers: {
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': _apiHost,
      }).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        if (data.isNotEmpty) {
          final gifUrl = data[0]['gifUrl'] as String?;
          if (gifUrl != null && gifUrl.isNotEmpty) {
            gifCache[nom] = gifUrl;
            return gifUrl;
          }
        }
      }
    } catch (_) {}
  }

  gifCache[nom] = null;
  return null;
}

// ═══════════════════════════════════════════════════════════════
//  COULEURS & EMOJIS
// ═══════════════════════════════════════════════════════════════

const Map<String, Color> _couleurs = {
  'Pectoraux':        Color(0xFFBF360C),
  'Épaules':          Color(0xFF1565C0),
  'Dos':              Color(0xFF4E342E),
  'Biceps':           Color(0xFF2E7D32),
  'Triceps':          Color(0xFF6A1B9A),
  'Avant-bras':       Color(0xFF00838F),
  'Abdominaux':       Color(0xFF00695C),
  'Lombaires':        Color(0xFF5D4037),
  'Fessiers':         Color(0xFFE65100),
  'Quadriceps':       Color(0xFF1976D2),
  'Ischio-jambiers':  Color(0xFF558B2F),
  'Abducteurs':       Color(0xFF6D4C41),
  'Adducteurs':       Color(0xFF7B1FA2),
  'Mollets':          Color(0xFF37474F),
  'Étirements':       Color(0xFF00897B),
};

const Map<String, String> _emojis = {
  'Pectoraux':        '🫀',
  'Épaules':          '🏋️',
  'Dos':              '🔙',
  'Biceps':           '💪',
  'Triceps':          '🦾',
  'Avant-bras':       '🤝',
  'Abdominaux':       '🎯',
  'Lombaires':        '🦴',
  'Fessiers':         '🍑',
  'Quadriceps':       '🦵',
  'Ischio-jambiers':  '🦿',
  'Abducteurs':       '↔️',
  'Adducteurs':       '↕️',
  'Mollets':          '🦶',
  'Étirements':       '🧘',
};

// ═══════════════════════════════════════════════════════════════
//  WIDGET GIF
// ═══════════════════════════════════════════════════════════════

class _GifCard extends StatefulWidget {
  final String nom;
  final Color couleur;
  final double height;
  final double width;
  const _GifCard({
    required this.nom,
    required this.couleur,
    required this.height,
    required this.width,
  });
  @override
  State<_GifCard> createState() => _GifCardState();
}

class _GifCardState extends State<_GifCard> {
  String? _gifUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final url = await fetchGif(widget.nom);
    if (mounted) setState(() { _gifUrl = url; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: widget.width, height: widget.height,
        color: widget.couleur.withOpacity(0.08),
        child: Center(child: SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: widget.couleur))),
      );
    }
    if (_gifUrl == null) {
      return Container(
        width: widget.width, height: widget.height,
        color: widget.couleur.withOpacity(0.08),
        child: Center(child: Icon(Icons.fitness_center, size: 36,
            color: widget.couleur.withOpacity(0.35))),
      );
    }
    return Image.network(
      _gifUrl!,
      width: widget.width, height: widget.height,
      fit: BoxFit.cover,
      headers: const {'User-Agent': 'Mozilla/5.0'},
      loadingBuilder: (_, child, prog) => prog == null ? child
          : Container(
              width: widget.width, height: widget.height,
              color: widget.couleur.withOpacity(0.08),
              child: Center(child: SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: widget.couleur)))),
      errorBuilder: (_, __, ___) => Container(
        width: widget.width, height: widget.height,
        color: widget.couleur.withOpacity(0.08),
        child: Center(child: Icon(Icons.fitness_center, size: 36,
            color: widget.couleur.withOpacity(0.35))),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHEET PRINCIPALE
// ═══════════════════════════════════════════════════════════════

class ExerciceSelectorSheet extends StatefulWidget {
  final List<String> selection;
  const ExerciceSelectorSheet({super.key, required this.selection});
  @override
  State<ExerciceSelectorSheet> createState() => _ExerciceSelectorSheetState();
}

class _ExerciceSelectorSheetState extends State<ExerciceSelectorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final Set<String> _sel = {};
  String _search = '';
  final _sc = TextEditingController();
  final List<String> _groupes = exercicesParGroupe.keys.toList();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _groupes.length, vsync: this);
    _sel.addAll(widget.selection);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _sc.dispose();
    super.dispose();
  }

  List<String> _list(String groupe) {
    final all = exercicesParGroupe[groupe] ?? [];
    if (_search.isEmpty) return all;
    return all.where((e) => e.toLowerCase().contains(_search.toLowerCase())).toList();
  }

  void _toggle(String nom) =>
      setState(() => _sel.contains(nom) ? _sel.remove(nom) : _sel.add(nom));

  int _countSel(String groupe) =>
      (exercicesParGroupe[groupe] ?? []).where((e) => _sel.contains(e)).length;

  void _detail(String nom, Color couleur) => showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: _GifCard(nom: nom, couleur: couleur, height: 260, width: double.infinity),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Text(nom,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () { _toggle(nom); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(
              backgroundColor: _sel.contains(nom) ? AppTheme.danger : AppTheme.orange,
              minimumSize: const Size(double.infinity, 42)),
            child: Text(_sel.contains(nom) ? '✕ Retirer' : '✓ Ajouter au programme'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer')),
        ])),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.95,
      child: Column(children: [

        const SizedBox(height: 10),
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppTheme.grisClair, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 10),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bibliothèque d\'exercices',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Tap = GIF animé  •  ☑ = sélectionner',
                  style: TextStyle(fontSize: 10, color: AppTheme.grisTexte)),
            ]),
            const Spacer(),
            if (_sel.isNotEmpty) Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_sel.length} sél.',
                  style: const TextStyle(
                      color: AppTheme.orange, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _sel.toList()),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 34), backgroundColor: AppTheme.orange),
              child: const Text('Confirmer'),
            ),
          ]),
        ),
        const SizedBox(height: 8),

        // Recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: _sc,
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un exercice...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () { _sc.clear(); setState(() => _search = ''); })
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Tabs
        TabBar(
          controller: _tabs, isScrollable: true,
          labelColor: AppTheme.orange, unselectedLabelColor: AppTheme.grisTexte,
          indicatorColor: AppTheme.orange, tabAlignment: TabAlignment.start,
          tabs: _groupes.map((g) {
            final cnt = _countSel(g);
            final c = _couleurs[g] ?? AppTheme.orange;
            return Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${_emojis[g] ?? ''} $g', style: const TextStyle(fontSize: 11)),
              if (cnt > 0) ...[
                const SizedBox(width: 4),
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  child: Center(child: Text('$cnt',
                      style: const TextStyle(
                          color: AppTheme.blanc, fontSize: 9,
                          fontWeight: FontWeight.bold)))),
              ],
            ]));
          }).toList(),
        ),

        // Grid
        Expanded(child: TabBarView(
          controller: _tabs,
          children: _groupes.map((g) {
            final list = _list(g);
            final couleur = _couleurs[g] ?? AppTheme.orange;

            if (list.isEmpty) return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off, size: 40, color: couleur.withOpacity(0.3)),
                const SizedBox(height: 8),
                const Text('Aucun exercice trouvé',
                    style: TextStyle(color: AppTheme.grisTexte)),
              ]));

            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 8,
                  mainAxisSpacing: 8, childAspectRatio: 0.75),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final nom = list[i];
                final sel = _sel.contains(nom);
                return GestureDetector(
                  onTap: () => _detail(nom, couleur),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sel ? couleur.withOpacity(0.06) : AppTheme.blanc,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? couleur : const Color(0xFFEEEEEE),
                          width: sel ? 2 : 1),
                    ),
                    child: Column(children: [
                      Expanded(child: Stack(children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: _GifCard(
                              nom: nom, couleur: couleur,
                              height: double.infinity, width: double.infinity),
                        ),
                        // Cache watermark logo haut
                        Positioned(top: 0, left: 0, right: 0,
                          child: Container(
                            height: 26,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                          )),
                        // Cache watermark logo bas
                        Positioned(bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 22,
                            color: Colors.white,
                          )),
                        Positioned(top: 6, right: 6,
                          child: GestureDetector(
                            onTap: () => _toggle(nom),
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: sel ? couleur : Colors.white.withOpacity(0.92),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: sel ? couleur : Colors.grey.shade300,
                                    width: 1.5),
                                boxShadow: [BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4)],
                              ),
                              child: sel ? const Icon(Icons.check,
                                  size: 14, color: AppTheme.blanc) : null,
                            ),
                          )),
                      ])),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7, 5, 7, 8),
                        child: Text(nom,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 11,
                              color: sel ? couleur : AppTheme.noir),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center),
                      ),
                    ]),
                  ),
                );
              },
            );
          }).toList(),
        )),

        // Bouton bas
        if (_sel.isNotEmpty) Padding(
          padding: EdgeInsets.fromLTRB(
              14, 6, 14, MediaQuery.of(context).viewInsets.bottom + 12),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, _sel.toList()),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                backgroundColor: AppTheme.orange),
            child: Text('Ajouter ${_sel.length} exercice(s) au programme',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          )),
      ]),
    );
  }
}
