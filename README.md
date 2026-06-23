# Fitness Coach App — Flutter + SQLite

Application de coaching fitness avec gestion des programmes nutrition et entraînement.

## Stack technique
- **Flutter** (Dart)
- **sqflite** — base de données SQLite locale
- **shared_preferences** — session utilisateur
- **go_router** — navigation
- **crypto** — hash mot de passe (SHA-256)
- **uuid** — génération codes d'accès

## Installation

### 1. Prérequis
- Flutter SDK installé (flutter.dev)
- VS Code + extension Flutter/Dart
- Android Studio (pour l'émulateur) ou un appareil physique

### 2. Créer le projet et copier les fichiers
```bash
flutter create fitness_app
cd fitness_app
# Remplacer les fichiers par ceux fournis
```

### 3. Installer les dépendances
```bash
flutter pub get
```

### 4. Lancer l'app
```bash
flutter run
```

---

## Connexion par défaut

**Coach (admin)**
- Email : `coach@fitness.app`
- Mot de passe : `coach123`

**Adhérent**
- Code d'accès généré automatiquement lors de la création de l'adhérent
- Format : `ADH-XXXXXXXX`

---

## Structure du projet

```
lib/
├── main.dart                          # Point d'entrée
├── app_router.dart                    # Navigation (go_router)
├── app_theme.dart                     # Couleurs et styles
├── services/
│   ├── database_helper.dart           # SQLite — toutes les tables et CRUD
│   └── auth_service.dart              # Auth locale (session + codes)
└── screens/
    ├── auth/
    │   ├── login_screen.dart           # Connexion coach
    │   └── code_acces_screen.dart      # Connexion adhérent
    ├── coach/
    │   ├── coach_dashboard_screen.dart
    │   ├── adherents_screen.dart
    │   ├── ajouter_adherent_screen.dart
    │   ├── programmes_nutrition_screen.dart
    │   ├── form_programme_nutrition_screen.dart
    │   ├── form_repas_screen.dart
    │   ├── programmes_entrainement_screen.dart
    │   ├── form_programme_entrainement_screen.dart
    │   ├── form_seance_screen.dart
    │   └── form_exercice_screen.dart
    └── adherent/
        ├── adherent_home_screen.dart
        ├── adherent_nutrition_screen.dart
        └── adherent_entrainement_screen.dart
```

---

## Accéder à la base de données

Le fichier `fitness.db` se trouve sur l'appareil Android :
```
/data/data/com.example.fitness_app/databases/fitness.db
```

### Avec Android Studio
1. **View → Tool Windows → Device Explorer**
2. Naviguer vers `/data/data/com.example.fitness_app/databases/`
3. Clic droit sur `fitness.db` → **Save As**
4. Ouvrir avec **DB Browser for SQLite**

### Avec adb (terminal)
```bash
adb shell run-as com.example.fitness_app cp /data/data/com.example.fitness_app/databases/fitness.db /sdcard/
adb pull /sdcard/fitness.db ./fitness.db
```

---

## Tables SQLite

| Table | Description |
|-------|-------------|
| `utilisateurs` | Coach + adhérents (role: 'coach' ou 'adherent') |
| `programmes_nutrition` | Plans nutritionnels par adhérent |
| `repas` | Repas liés à un programme nutrition |
| `programmes_entrainement` | Programmes d'entraînement par adhérent |
| `seances` | Séances liées à un programme |
| `exercices` | Exercices liés à une séance |

---

## Fonctionnalités

### Coach
- ✅ Tableau de bord avec liste adhérents
- ✅ Créer / modifier / supprimer un adhérent
- ✅ Génération automatique du code d'accès unique
- ✅ Créer des programmes nutrition avec repas détaillés
- ✅ Créer des programmes entraînement avec séances et exercices
- ✅ Activer/désactiver un programme

### Adhérent
- ✅ Connexion par code d'accès
- ✅ Voir son programme nutrition actif (repas, calories, macros)
- ✅ Voir son programme entraînement actif (séances, exercices)
- ✅ Lecture seule — aucune modification possible

---

## Modifications futures

Pour demander une modification, précisez :
- Le fichier concerné
- Ce que vous voulez changer
