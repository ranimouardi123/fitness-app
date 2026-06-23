import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  SupabaseClient get _db => Supabase.instance.client;

  Future<void> initCoachParDefaut() async {
    final data = await _db.from('utilisateurs').select().eq('role', 'coach').eq('email', 'coach@fitness.app');
    if (data.isEmpty) {
      await _db.from('utilisateurs').insert({
        'nom': 'Coach', 'prenom': 'Admin', 'email': 'coach@fitness.app', 'role': 'coach',
        'mot_de_passe': '777a025f5ca4a20f7bafee940f2820e28e1f4bbcbd9dd774bbce883166ef7c55',
        'date_creation': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int> ajouterAdherent(Map<String, dynamic> data) async {
    final res = await _db.from('utilisateurs').insert(data).select('id').single();
    return res['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getTousAdherents() async {
    final data = await _db.from('utilisateurs').select().eq('role', 'adherent').order('nom', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getAdherentParId(int id) async {
    return await _db.from('utilisateurs').select().eq('id', id).maybeSingle();
  }

  Future<Map<String, dynamic>?> getUtilisateurParCodeAcces(String code) async {
    return await _db.from('utilisateurs').select().eq('code_acces', code.toUpperCase()).maybeSingle();
  }

  Future<Map<String, dynamic>?> getCoachParEmail(String email) async {
    return await _db.from('utilisateurs').select().eq('email', email).eq('role', 'coach').maybeSingle();
  }

  Future<void> modifierAdherent(int id, Map<String, dynamic> data) async {
    await _db.from('utilisateurs').update(data).eq('id', id);
  }

  Future<void> supprimerAdherent(int id) async {
    for (final table in ['prog_alimentaire', 'prog_musculation', 'prog_cardio', 'bilan_corporel', 'bilan_sanguin', 'tracking', 'messages']) {
      await _db.from(table).delete().eq('adherent_id', id);
    }
    await _db.from('utilisateurs').delete().eq('id', id);
  }

  Future<int> ajouterBilanCorporel(Map<String, dynamic> data) async {
    final res = await _db.from('bilan_corporel').insert(data).select('id').single();
    return res['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getBilansCorporels(int adherentId) async {
    final data = await _db.from('bilan_corporel').select().eq('adherent_id', adherentId).order('date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getDernierBilanCorporel(int adherentId) async {
    return await _db.from('bilan_corporel').select().eq('adherent_id', adherentId).order('date', ascending: false).limit(1).maybeSingle();
  }

  Future<Map<String, dynamic>?> getBilanCorporelParId(int id) async {
    return await _db.from('bilan_corporel').select().eq('id', id).maybeSingle();
  }

  Future<void> modifierBilanCorporel(int id, Map<String, dynamic> data) async {
    await _db.from('bilan_corporel').update(data).eq('id', id);
  }

  Future<void> supprimerBilanCorporel(int id) async {
    await _db.from('bilan_corporel').delete().eq('id', id);
  }

  Future<int> ajouterBilanSanguin(Map<String, dynamic> data) async {
    final res = await _db.from('bilan_sanguin').insert(data).select('id').single();
    return res['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getBilansSanguins(int adherentId) async {
    final data = await _db.from('bilan_sanguin').select().eq('adherent_id', adherentId).order('date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getBilanSanguinParId(int id) async {
    return await _db.from('bilan_sanguin').select().eq('id', id).maybeSingle();
  }

  Future<void> modifierBilanSanguin(int id, Map<String, dynamic> data) async {
    await _db.from('bilan_sanguin').update(data).eq('id', id);
  }

  Future<void> supprimerBilanSanguin(int id) async {
    await _db.from('bilan_sanguin').delete().eq('id', id);
  }

  Future<int> ajouterProgAlimentaire(Map<String, dynamic> data) async {
    final res = await _db.from('prog_alimentaire').insert(data).select('id').single();
    return res['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getProgsAlimentaires(int adherentId) async {
    final data = await _db.from('prog_alimentaire').select().eq('adherent_id', adherentId).order('date_creation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getProgAlimentaireActif(int adherentId) async {
    return await _db.from('prog_alimentaire').select().eq('adherent_id', adherentId).eq('actif', true).order('date_creation', ascending: false).limit(1).maybeSingle();
  }

  Future<Map<String, dynamic>?> getProgAlimentaireParId(int id) async {
    return await _db.from('prog_alimentaire').select().eq('id', id).maybeSingle();
  }

  Future<void> modifierProgAlimentaire(int id, Map<String, dynamic> data) async {
    await _db.from('prog_alimentaire').update(data).eq('id', id);
  }

  Future<void> supprimerProgAlimentaire(int id) async {
    await _db.from('prog_alimentaire').delete().eq('id', id);
  }

  Future<int> ajouterProgMusculation(Map<String, dynamic> data) async {
    final res = await _db.from('prog_musculation').insert(data).select('id').single();
    return res['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getProgsMusculation(int adherentId) async {
    final data = await _db.from('prog_musculation').select().eq('adherent_id', adherentId).order('date_creation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getProgMusculationActif(int adherentId) async {
    return await _db.from('prog_musculation').select().eq('adherent_id', adherentId).eq('actif', true).order('date_creation', ascending: false).limit(1).maybeSingle();
  }

  Future<Map<String, dynamic>?> getProgMusculationParId(int id) async {
    return await _db.from('prog_musculation').select().eq('id', id).maybeSingle();
  }

  Future<void> modifierProgMusculation(int id, Map<String, dynamic> data) async {
    await _db.from('prog_musculation').update(data).eq('id', id);
  }

  Future<void> supprimerProgMusculation(int id) async {
    await _db.from('prog_musculation').delete().eq('id', id);
  }

  Future<int> ajouterProgCardio(Map<String, dynamic> data) async {
    final res = await _db.from('prog_cardio').insert(data).select('id').single();
    return res['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getProgsCardio(int adherentId) async {
    final data = await _db.from('prog_cardio').select().eq('adherent_id', adherentId).order('date_creation', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getProgCardioActif(int adherentId) async {
    return await _db.from('prog_cardio').select().eq('adherent_id', adherentId).eq('actif', true).order('date_creation', ascending: false).limit(1).maybeSingle();
  }

  Future<Map<String, dynamic>?> getProgCardioParId(int id) async {
    return await _db.from('prog_cardio').select().eq('id', id).maybeSingle();
  }

  Future<void> modifierProgCardio(int id, Map<String, dynamic> data) async {
    await _db.from('prog_cardio').update(data).eq('id', id);
  }

  Future<void> supprimerProgCardio(int id) async {
    await _db.from('prog_cardio').delete().eq('id', id);
  }

  Future<int> ajouterTracking(Map<String, dynamic> data) async {
    final res = await _db.from('tracking').insert(data).select('id').single();
    return res['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getTrackings(int adherentId) async {
    final data = await _db.from('tracking').select().eq('adherent_id', adherentId).order('date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> modifierTracking(int id, Map<String, dynamic> data) async {
    await _db.from('tracking').update(data).eq('id', id);
  }

  Future<void> supprimerTracking(int id) async {
    await _db.from('tracking').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getSeancesParProgramme(int programmeId) async {
    final prog = await getProgMusculationParId(programmeId);
    if (prog == null) return [];
    final jours = prog['jours'];
    if (jours == null) return [];
    final List<dynamic> liste = jours is List ? jours : [];
    return liste.asMap().entries.map((e) => {
      'id': e.key,
      'titre': (e.value as Map)['titre'] ?? 'Jour ${e.key + 1}',
      'exercices_texte': (e.value as Map)['exercices'] ?? '',
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getExercicesParSeance(int seanceId) async => [];

  Future<int> ajouterProgrammeNutrition(Map<String, dynamic> data) => ajouterProgAlimentaire(data);
  Future<List<Map<String, dynamic>>> getProgrammesNutritionAdherent(int adherentId) => getProgsAlimentaires(adherentId);
  Future<Map<String, dynamic>?> getProgrammeNutritionActif(int adherentId) => getProgAlimentaireActif(adherentId);
  Future<Map<String, dynamic>?> getProgrammeNutritionParId(int id) => getProgAlimentaireParId(id);
  Future<void> modifierProgrammeNutrition(int id, Map<String, dynamic> data) => modifierProgAlimentaire(id, data);
  Future<void> supprimerProgrammeNutrition(int id) => supprimerProgAlimentaire(id);
  Future<int> ajouterProgrammeEntrainement(Map<String, dynamic> data) => ajouterProgMusculation(data);
  Future<List<Map<String, dynamic>>> getProgrammesEntrainementAdherent(int adherentId) => getProgsMusculation(adherentId);
  Future<Map<String, dynamic>?> getProgrammeEntrainementActif(int adherentId) => getProgMusculationActif(adherentId);
  Future<Map<String, dynamic>?> getProgrammeEntrainementParId(int id) => getProgMusculationParId(id);
  Future<void> modifierProgrammeEntrainement(int id, Map<String, dynamic> data) => modifierProgMusculation(id, data);
  Future<void> supprimerProgrammeEntrainement(int id) => supprimerProgMusculation(id);
  Future<int> ajouterRepas(Map<String, dynamic> data) async => 0;
  Future<List<Map<String, dynamic>>> getRepasParProgramme(int programmeId) async => [];
  Future<Map<String, dynamic>?> getRepasParId(int id) async => null;
  Future<void> modifierRepas(int id, Map<String, dynamic> data) async {}
  Future<void> supprimerRepas(int id) async {}
  Future<int> ajouterSeance(Map<String, dynamic> data) async => 0;
  Future<Map<String, dynamic>?> getSeanceParId(int id) async => null;
  Future<void> modifierSeance(int id, Map<String, dynamic> data) async {}
  Future<void> supprimerSeance(int id) async {}
  Future<int> ajouterExercice(Map<String, dynamic> data) async => 0;
  Future<Map<String, dynamic>?> getExerciceParId(int id) async => null;
  Future<void> modifierExercice(int id, Map<String, dynamic> data) async {}
  Future<void> supprimerExercice(int id) async {}
  Future<int> countExercicesParSeance(int seanceId) async => 0;
}
