# Passation projet — TERANGA CIVIL (Mobile Flutter)

> Document de référence unique pour reprendre le projet dans une nouvelle discussion avec **Claude Code**.
> Rédigé à partir de l'ensemble du travail déjà réalisé. À lire **en entier** avant toute modification.

---

## 0. Résumé express (à lire en premier)

- **Projet** : TERANGA CIVIL — application civique sénégalaise de demande de certificats d'état civil (naissance, mariage, décès, résidence).
- **Monorepo Git** : `https://github.com/Alioune205/Teranga-Civil.git`, branche de travail **`DevAliouneSene`**. Il contient 3 sous-projets : `backend/` (Django/DRF), `frontend/` (React web), `mobile/` (Flutter).
- **Rôle de l'utilisatrice (Fatou)** : équipe **front-end mobile uniquement**. ⚠️ **Elle ne doit PAS modifier le backend ni le React.** Le mobile doit *s'adapter* à ce que fournit le backend.
- **Le projet mobile actif** se trouve dans `D:\DBE\Flutter\front-mobile-terranga_civil` (et non dans le dossier `mobile/` du repo — voir §3).
- **Le backend + web** se trouvent dans `D:\DBE\Flutter\Teranga-Civil`.
- **État** : le mobile est largement fonctionnel (auth + OTP, demandes d'actes, suivi de dossiers, notifications, chat IA Ndiogoye, paiement). Le backend tourne en local sur SQLite.

---

## 1. Contexte du projet

### 1.1 Description
TERANGA CIVIL (« L'administration proche de vous ») est une plateforme de **dématérialisation de l'état civil sénégalais**. Elle permet à un citoyen de demander en ligne ses actes (naissance, mariage, décès) et certificats (résidence), de suivre l'avancement de ses dossiers, de payer les frais, puis de télécharger le document officiel généré.

La plateforme comporte trois faces :
- **Mobile (Flutter)** — face **citoyen** : faire des demandes, suivre, payer, télécharger.
- **Web (React)** — face **agents / mairie** : réception, vérification, validation, génération des actes, statistiques.
- **Backend (Django/DRF)** — cœur métier commun : authentification, workflow des dossiers, registre civil simulé, paiements, notifications, OCR/IA.

### 1.2 Objectifs métier
- Réduire les déplacements et files d'attente en mairie.
- Sécuriser et tracer les demandes d'actes d'état civil.
- Vérifier l'authenticité d'une demande contre le **registre civil de la commune** avant traitement.
- Permettre le paiement des frais et la délivrance d'un document PDF officiel (avec QR de vérification).

### 1.3 Problème résolu
Aujourd'hui, obtenir un acte impose un déplacement physique, des délais et peu de traçabilité. L'app numérise tout le parcours : demande → vérification registre → paiement → traitement agent → délivrance PDF, avec notifications à chaque étape.

### 1.4 Utilisateurs concernés
- **Citoyens** (app mobile) : rôle `citizen`.
- **Agents de réception** : rôle `reception_agent`.
- **Agents de vérification** : rôle `verification_agent`.
- **Administrateurs de commune (maire)** : rôle `civil_admin`.
- **Super administrateur** : rôle `super_admin`.

### 1.5 Vision globale
Un guichet d'état civil 100 % numérique, multi-communes, où le citoyen pilote ses démarches depuis son téléphone et où la mairie traite/valide depuis le web, le tout adossé à un registre civil de référence.

---

## 2. État actuel du développement (côté MOBILE)

### 2.1 Terminé et fonctionnel
- **Authentification** : connexion (téléphone **ou** email + mot de passe), inscription multi-étapes, **validation OTP obligatoire** après inscription, refresh token, déconnexion forcée à chaque (re)démarrage de l'app.
- **Accueil** : en-tête dégradé navy (avatar → profil, salutation FR/Wolof animée, commune réelle), message civique animé, carte « Que souhaitez-vous faire ? », **démarches rapides** (Naissance, Mariage & famille, Décès, Logement) via *bottom sheets* de catégories, **Ndiogoye Proactif** (carrousel, visible si ≥ 1 dossier), **activité récente** branchée sur les dossiers réels, **Vos rendez-vous** (état vide, pas d'endpoint), **Ma mairie la plus proche** (statique + actualités civiques), **feuille de notifications** (onglets Tous / Non lus).
- **Demande d'acte de naissance** (pour soi / pour un tiers) : formulaire multi-étapes, **vérification contre le RegistreCivil** (`/dossiers/verify-registry/`), upload optionnel d'extrait avec OCR, upload CNI pour demande tierce.
- **Demande de mariage, décès, résidence** : formulaires multi-étapes, création + soumission immédiate du dossier.
- **Suivi des dossiers** : liste + détail, statuts traduits, rafraîchissement après soumission/paiement.
- **Documents** : catalogue des démarches par famille + « vos démarches fréquentes » (basé sur l'historique).
- **Profil** : bannière immersive, nom complet réel, initiales calculées depuis le nom complet, feuilles d'édition (profil, mot de passe, langue).
- **Chat IA « Ndiogoye »** : design dédié (avatar animé, suggestions, bulles dégradées, indicateur de saisie), branché sur `/ai/ndiogoye/chat/`.
- **Paiement** : écran de paiement (bouton de confirmation déplacé en `bottomNavigationBar` pour éviter l'overflow), écran de succès qui **invalide la liste des dossiers**.
- **Navigation** : `ShellRoute` go_router avec **barre flottante 5 items** (Accueil, Dossiers, bouton IA central Ndiogoye, Documents, Profil).
- **Thème** : tokens centralisés (`AppColors`, `AppTextStyles`, `AppTheme`), palette pro navy (`#0B285D`).

### 2.2 Partiellement développé
- **Ndiogoye Chat** : fonctionnel mais dépend de `GROQ_API_KEY` côté backend (sinon réponses dégradées/erreur).
- **OCR extrait de naissance** : pré-remplit le formulaire ; qualité dépendante du moteur OCR backend.
- **Rendez-vous** : UI présente mais **aucun endpoint backend** → état vide permanent.
- **« Ma mairie la plus proche »** et **actualités civiques** : **statiques / mockées** (pas branchées sur le backend).
- **Familles de documents** : plusieurs sous-démarches affichées en « Bientôt » (non implémentées).

### 2.3 Non commencé (mobile)
- Géolocalisation réelle de la mairie / itinéraire.
- Prise de rendez-vous réelle.
- Notifications push (device tokens existent côté backend mais non câblées en push réel mobile).
- Actualités civiques dynamiques.
- Mode hors-ligne / cache avancé.

> **Backend & Web** : développés par les autres équipes. Considérés comme la **source de vérité**. Voir §7 pour les endpoints réellement exposés.

---

## 3. Architecture actuelle

### 3.1 Emplacements sur le disque (IMPORTANT)
- `D:\DBE\Flutter\Teranga-Civil` → **monorepo** cloné : `backend/`, `frontend/` (React), etc.
- `D:\DBE\Flutter\front-mobile-terranga_civil` → **le projet mobile Flutter actif** de Fatou (c'est ICI qu'on développe le mobile).
- ⚠️ Un dossier `D:\DBE\Flutter\Diouma\front-mobile-terranga_civil` (copie d'une coéquipière sur laquelle on avait porté le design) **a été perdu** lors d'une manipulation Git/copie ; il n'est plus accessible. Ne pas compter dessus.
- Le repo contient un dossier `mobile/` : **à ignorer** par convention de l'équipe (le mobile vit dans le dépôt mais Fatou travaille sur sa copie).

### 3.2 Structure du projet mobile (`lib/`)
Architecture **feature-first + clean-ish** (data / domain / presentation par feature) :

```
lib/
  core/
    constants/        (assets_constants.dart, …)
    errors/           (failures.dart)
    network/          (dio_client.dart — client Dio + intercepteurs JWT)
    router/           (app_router.dart — go_router, AppRoutes)
    theme/            (app_colors.dart, app_text_styles.dart, app_theme.dart)
    utils/            (validators.dart, picked_files.dart — cache fichiers web)
    providers/        (profile_state_provider.dart, …)
  features/
    auth/             (login, register_step1..4, otp_verification, splash, welcome)
    home/             (home_screen)
    documents/        (documents_screen)   ← section "Brouillons" supprimée
    dossiers/         (liste + détail ; data: remote_datasource, models/dossier_model)
    certificates/
      naissance/      (beneficiary_choice, recap_self, other_person, recap_other)
      mariage/        (mariage_form, mariage_recap)
      deces/          (deces_form, deces_recap)
      residence/      (residence_form)
    profile/          (profile_screen)
    assistant/        (agent_chat_screen — Ndiogoye, assistant_sheet)
    notifications/    (barrel notifications.dart + providers/datasource)
    payment/          (payment_screen, payment_success_screen)
  shared/
    layout/           (main_scaffold.dart — barre nav flottante 5 items)
    widgets/          (primary_button, app_text_field, upload_document_card,
                       backend_commune_select, certificate_step_indicator, …)
    models/           (commune_model.dart, …)
  main.dart           (logout au démarrage + route initiale login)
```

### 3.3 Technologies (mobile)
- **Flutter** (SDK Dart `>=3.2 <4.0`), **Material**.
- **State management** : `flutter_riverpod` (^2.5) + `riverpod_annotation` / `riverpod_generator` (build_runner).
- **Navigation** : `go_router` (^13) — `ShellRoute` pour la barre d'onglets.
- **HTTP** : `dio` (^5.4) via `core/network/dio_client.dart` (injection du JWT, refresh).
- **Stockage sécurisé** : `flutter_secure_storage` (tokens).
- **Préférences** : `shared_preferences`.
- **Divers** : `pin_code_fields` (OTP), `image_picker` (scan CNI/extrait), `lottie`, `google_fonts`, police **Poppins** intégrée, `intl`, `flutter_svg`, `cached_network_image`, `connectivity_plus`, `path_provider` (download PDF), `url_launcher`.

### 3.4 Technologies (backend — pour info, NE PAS MODIFIER)
- **Django + Django REST Framework**, **SimpleJWT** (auth par tokens).
- **drf-spectacular** : schéma OpenAPI + Swagger UI sur `/api/docs/` (et `/api/redoc/`).
- **Celery** (mode *eager* en dev ; `CELERY_TASK_STORE_EAGER_RESULT = False` pour éviter un crash Redis).
- **SQLite** en développement (pas de Postgres requis localement).
- OCR + IA (Ndiogoye) via module `ai` (nécessite `GROQ_API_KEY`).

### 3.5 Architecture logicielle
- **Mobile** : feature-first. Chaque feature expose `data` (datasources Dio + models), `presentation` (screens + providers Riverpod). Les écrans consomment des `Provider`/`FutureProvider`/`StateNotifierProvider`.
- **Backend** : apps Django par domaine (voir §4/§7), ViewSets DRF + actions custom, sérialiseurs, permissions par rôle.

### 3.6 Flux de données type (demande d'acte de naissance pour soi)
1. L'utilisateur saisit n° de registre + année + date de naissance + commune (sélecteur branché backend) → écran récap.
2. Mobile appelle `POST /api/dossiers/verify-registry/` `{numero_registre, annee_registre, commune (code), type_acte:'birth_certificate', is_for_third_party:false}`.
3. Backend cherche dans `RegistreCivil` (n° + année + commune.code + type) **et** vérifie que `nom_complet_personne` correspond au nom du compte connecté.
4. Si OK → `POST /api/dossiers/` crée le dossier (brouillon) puis il est **soumis** ; le backend **enrichit `metadata`** depuis le registre (le client ne fournit jamais `metadata`).
5. Paiement → traitement agent (web) → statut `completed` → **PDF** disponible via `GET /api/dossiers/{id}/download-pdf/`.
6. Notifications créées à chaque transition ; le mobile rafraîchit via `invalidate(dossiersListProvider)` et `notificationsProvider`.

---

## 4. Base de données

> Dialecte : **SQLite** en dev. Les modèles sont en `apps/<app>/models.py`. Beaucoup héritent de `TimeStampedModel` (`apps/shared/models.py` : champs `created_at`, `updated_at`, généralement PK UUID).

### 4.1 Tables / modèles existants (par app)
- **users** :
  - `User` (modèle utilisateur custom, `Role` ∈ `super_admin | civil_admin | verification_agent | reception_agent | citizen`, `commune` FK, `is_verified`, propriété `full_name = "{first_name} {last_name}"`).
  - `CitizenProfile` (1-1 avec User : `cni_number`, `address`, …).
  - `OTPCode` (codes OTP citoyens).
  - `LoginHistory` (historique de connexion).
- **authentication** : `OTPToken` (OTP pour super-admin / flux dédiés).
- **communes** : `Commune` (`name`, `region`, `department`, **`code`** unique — ⚠️ clé d'API, voir §10).
- **dossiers** :
  - `Dossier` (`reference`, `type` ∈ `birth_certificate | marriage_certificate | death_certificate | residence_certificate | other`, `status` ∈ `draft | submitted | in_review | approved | rejected | completed`, `citizen` FK, `commune` FK, `assigned_agent`, `metadata` JSON, timestamps de workflow).
  - `DossierComment` (commentaires/historique sur un dossier).
  - `RegistreCivil` (**registre civil simulé = base de vérité de la mairie** : `numero_registre`, `annee_registre`, `type_acte`, `nom_complet_personne`, `date_naissance_personne`, `conjoint_nom_complet`, `commune` FK, + enrichissement : `nom_pere`, `nom_mere`, `sexe`, `lieu_naissance`, `profession_pere`, `profession_mere`). Unicité : `(numero_registre, annee_registre, commune, type_acte)`).
- **documents** : `Document` (pièces jointes liées à un dossier), `TimbreFiscal`, `GeneratedCertificate` (PDF généré).
- **payments** : `PaymentTransaction`, `TreasuryTransfer`, enums `PaymentType`, `PaymentStatus`.
- **notifications** : `Notification` (titre, corps, lu/non lu, dossier lié), `DeviceToken` (push).
- **ai** : `NdiogoyeChatLog` (journal des conversations IA).
- **audit_logs** : `AuditLog`.
- **services** : `Transaction`, `Report`, `Survey`, `SurveyOption`, `SurveyVote` (fonctions web/agent).

### 4.2 Relations clés
- `User (citizen) 1—N Dossier`, `Commune 1—N Dossier`, `Dossier 1—N Document`, `Dossier 1—N DossierComment`, `Dossier 1—1 GeneratedCertificate`, `Dossier 1—N Notification`, `Commune 1—N RegistreCivil`, `User 1—1 CitizenProfile`.

### 4.3 Migrations
- Migrations Django **présentes et appliquées** (ex. `dossiers/0013_...` ajoute les champs d'enrichissement du RegistreCivil). Lancer `python manage.py migrate` après tout pull.

### 4.4 Données de test
- `python manage.py seed_data` → communes (dont **Dakar Plateau `DK-PLT`**), comptes de démo (tous mot de passe **`password123`**), quelques dossiers.
  - Citoyens : `citoyen1@gmail.com` (Moussa Diop), `citoyen2@gmail.com` (Awa Fall).
  - Agents/Admin : `reception.plateau@…`, `verifier.plateau@…`, `admin.plateau@sunucivil.sn`, `superadmin@sunucivil.sn`.
- **`seed_registres.py`** (à la racine `backend/`, créé pendant cette session) → ajoute des actes de test dans `RegistreCivil` correspondant aux citoyens (ex. naissance `0001/1995` pour Moussa Diop). Lancer : `python seed_registres.py` (venv actif). Indispensable pour que `verify-registry` réussisse.

### 4.5 Restant à implémenter (BDD)
- Table/endpoint **rendez-vous** (inexistant).
- **Actualités civiques** dynamiques.
- Géodonnées des mairies (coordonnées, horaires) si on veut sortir du statique.

---

## 5. Fonctionnalités développées (détail)

### 5.1 Authentification + OTP
- **Description** : login téléphone/email + mot de passe ; inscription 4 étapes ; OTP obligatoire avant entrée.
- **État** : fonctionnel.
- **Points importants** : `RegisterView` renvoie `{needs_otp: true, identifier}` → `register_step1` pousse vers `AppRoutes.otpVerification`. **Code OTP de dev : `123456`** fonctionne toujours. `main.dart` fait `storage.deleteAll()` au démarrage → l'utilisateur est **toujours déconnecté** au lancement (décision validée).
- **Améliorations** : « se souvenir de moi », renvoi d'OTP avec compte à rebours, gestion fine des erreurs réseau.

### 5.2 Accueil
- **Description** : voir §2.1.
- **État** : fonctionnel ; sections RDV/mairie/actualités **statiques**.
- **Points importants** : tri des cartes = Naissance / Mariage & famille / Décès / Logement. « Ndiogoye Proactif » visible **uniquement si ≥ 1 dossier**. La commune affichée vient de `user.communeNom` (défaut « Non renseignée »).
- **Améliorations** : brancher RDV/mairie/actualités sur de vrais endpoints quand ils existeront.

### 5.3 Demandes d'actes (naissance / mariage / décès / résidence)
- **Description** : formulaires multi-étapes + upload + soumission.
- **État** : fonctionnel. **Seule la naissance** appelle `verify-registry` (les autres créent directement le dossier).
- **Points importants** :
  - `commune_id` envoyé = **code commune** (`Commune.code`, ex. `DK-PLT`), pas un UUID.
  - Le client **n'envoie jamais `metadata`** : le backend le remplit depuis `RegistreCivil`.
  - Validations : année de registre ≤ année courante ; date de décès ≤ 1 an (règle backend) ; n° de registre ≤ 12 caractères.
  - Upload **cross-platform** : sur le web, `MultipartFile.fromFile(path)` échoue → on passe par **bytes** (`PickedFiles` cache + `MultipartFile.fromBytes`).
- **Améliorations** : factoriser les 4 formulaires (beaucoup de duplication), mutualiser le widget d'upload.

### 5.4 Suivi des dossiers
- **État** : fonctionnel (liste + détail, statuts traduits FR).
- **Points importants** : après soumission/paiement, **`ref.invalidate(dossiersListProvider)`** pour rafraîchir. Téléchargement PDF via `/dossiers/{id}/download-pdf/` quand `completed`.

### 5.5 Notifications
- **État** : fonctionnel (liste, badge non-lus, « tout marquer comme lu »).
- **Points importants** : barrel `features/notifications/notifications.dart` expose `notificationsProvider`, `unreadNotificationsCountProvider`, `notificationsDatasourceProvider`.

### 5.6 Chat IA Ndiogoye
- **État** : fonctionnel si `GROQ_API_KEY` configurée côté backend.
- **Points importants** : endpoint `/api/ai/ndiogoye/chat/`. Avatar = `assets/images/ndiogoye.png` (vérifier la présence de l'asset).

### 5.7 Paiement
- **État** : fonctionnel (initiation + succès).
- **Points importants** : bouton de confirmation en `bottomNavigationBar` (anti-overflow). Endpoints `/api/payments/initiate/`, reçu PDF `/api/payments/transactions/{id}/receipt/`.

### 5.8 Profil
- **État** : fonctionnel. Nom complet + initiales depuis `user.nomComplet`. ⚠️ **La carte « configuration CNI » a été retirée** (décision). Les feuilles utilisent `useRootNavigator: true` + poignée + bouton ✕.

---

## 6. Fonctionnalités restantes

| Fonctionnalité | Objectif | Priorité | Dépendances | Reco d'implémentation |
|---|---|---|---|---|
| Prise de rendez-vous | Réserver un créneau en mairie | Moyenne | Endpoint backend RDV (à créer par l'équipe back) | Garder l'UI actuelle (état vide), brancher dès l'endpoint dispo |
| Mairie / géoloc / itinéraire | Localiser la mairie, itinéraire | Basse | Géodonnées communes + permission localisation | `geolocator` + `url_launcher` (maps) |
| Actualités civiques | Infos officielles dynamiques | Basse | Endpoint backend actualités | Liste paginée + cache image |
| Notifications push | Alerter hors-app | Moyenne | `DeviceToken` backend + FCM | Câbler `register-device/` + FCM |
| Sous-démarches « Bientôt » | Compléter le catalogue | Basse | Endpoints/registre par type | Réutiliser le pattern des formulaires existants |
| Mode hors-ligne | Consulter sans réseau | Basse | Stratégie cache | `sqflite`/cache Dio |

---

## 7. API

> Base : `http://127.0.0.1:8000`. Préfixes montés dans `config/urls.py`. **Swagger : `/api/docs/`** (source de vérité des contrats).

### 7.1 Endpoints existants (consommés ou utiles au mobile)
**Auth** (`/api/auth/`)
- `POST /login/` · `POST /register/` (→ `needs_otp`) · `POST /refresh/` · `POST /logout/`
- `POST /otp/send/` · `POST /otp/verify/` · `GET /login-history/`
- (Super-admin : `/api/v1/auth/super-admin/otp-request|otp-verify|reset-password`)

**Communes** (`/api/communes/`) : ViewSet REST (liste/détail). Clé = `code`.

**Dossiers** (`/api/dossiers/`) — ViewSet + actions :
- CRUD : `GET /`, `POST /`, `GET /{id}/`, `PATCH /{id}/`
- `POST /verify-registry/` (vérif RegistreCivil)
- `POST /{id}/submit/` · `POST /{id}/assign/` · `POST /{id}/review/` · `POST /{id}/approve/` · `POST /{id}/reject/` · `POST /{id}/complete/`
- `GET /{id}/download-pdf/`

**Documents** (`/api/documents/`) : `POST /upload/`, `GET /{id}/download/`, CRUD.

**Notifications** (`/api/notifications/`) : ViewSet + `POST /register-device/`.

**IA** (`/api/ai/`) : `POST /ocr/extract/`, `POST /ocr/camera/`, `POST /ocr/confirm/`, `POST /faq/`, `POST /ndiogoye/chat/`, `GET /ndiogoye/logs/`.

**Paiements** (`/api/`) : `POST /initiate/`, `POST /guichet/register/`, `GET /transactions/{id}/receipt/`, (+ stats admin).

**Autres apps** (surtout web/agent, NE PAS toucher côté mobile) : `users`, `roles`, `audit-logs`, `qr`, `dashboard`, `system`, `services`, `etat_civil` (attribution / citoyen).

### 7.2 Endpoints manquants (à demander à l'équipe back)
- Rendez-vous, actualités civiques, géodonnées mairie, push réel.

### 7.3 Contrats définis (à respecter strictement côté mobile)
- `verify-registry` : `{numero_registre:str, annee_registre:int, commune:<code>, type_acte:<enum back>, is_for_third_party:bool}`.
- Création dossier : `type` UI FR (`naissance|mariage|deces|residence`) + `commune_id` = **code**, **sans `metadata`**.
- Types backend : `birth_certificate | marriage_certificate | death_certificate | residence_certificate`.

### 7.4 Points de vigilance Front/Back/Mobile
- **Le mobile s'adapte au backend**, jamais l'inverse (Fatou ne modifie pas le back).
- Le **code commune** (et non l'UUID/nom) est la clé partagée.
- Les statuts backend (`draft/submitted/in_review/approved/rejected/completed`) doivent être traduits côté mobile sans en inventer.
- Upload : toujours prévoir le **chemin web (bytes)** en plus du mobile (fichier).

---

## 8. Sécurité

### 8.1 Déjà en place
- **JWT (SimpleJWT)** : access + refresh ; stockage mobile en `flutter_secure_storage`.
- **OTP obligatoire** à l'inscription (et flux super-admin dédié).
- **Permissions par rôle** côté backend (`IsCitizen`, etc.) ; `verify-registry` réservé aux citoyens.
- **Déconnexion forcée au démarrage** de l'app (pas de session persistante silencieuse).
- Vérification d'identité demande/registre (nom du compte vs `nom_complet_personne`).

### 8.2 À mettre en place / vérifier
- Rotation/expiration fine des tokens et gestion du refresh en cas d'expiration en cours d'action.
- Durcir la validation des uploads (type/taille) côté mobile.
- Ne jamais logguer de données personnelles (CNI, etc.).
- En prod : HTTPS, secrets hors code (`GROQ_API_KEY`, clés JWT), CORS strict.

### 8.3 Recommandations
- Centraliser la gestion d'erreurs API et le refresh dans `dio_client.dart`.
- Vérifier les permissions à chaque action sensible côté backend (déjà fait, à conserver).

---

## 9. Décisions techniques prises (ne pas contredire)

1. **Mobile = équipe front uniquement** : ne **jamais** modifier `backend/` ni `frontend/` (React). S'adapter aux contrats.
2. **Le projet mobile actif est `D:\DBE\Flutter\front-mobile-terranga_civil`** (pas le dossier `mobile/` du repo).
3. **Thème centralisé** : toute couleur/typo passe par `AppColors` / `AppTextStyles` / `AppTheme`. Palette navy `#0B285D` (dégradé `#0B285D → #1B4A9C`).
4. **Routes via `AppRoutes`** (constantes) — jamais de chaînes en dur ; navigation par `go_router`.
5. **Navigation = barre flottante 5 items** (Accueil, Dossiers, bouton IA central, Documents, Profil) via `ShellRoute` ; index de shell : Accueil=0, Dossiers=1, (centre=2), Documents=3, Profil=4.
6. **OTP obligatoire** à l'inscription ; **logout à chaque démarrage** ; **code OTP dev = 123456**.
7. **Commune par `code`** dans les appels API (SlugRelatedField côté back).
8. **Le client n'envoie jamais `metadata`** : enrichi par le backend depuis `RegistreCivil`.
9. **Upload cross-platform** via `PickedFiles` + `MultipartFile.fromBytes` (obligatoire pour le web).
10. **Paiement** : bouton de validation en `bottomNavigationBar` (anti-overflow) ; succès → `invalidate(dossiersListProvider)`.
11. **Validations** : année de naissance ≤ année courante ; date de décès ≤ 1 an ; n° registre ≤ 12 caractères.
12. **Carte « Mariage » nommée « Mariage & famille »** (accueil + documents).
13. **Fonctionnalité « Brouillons » entièrement supprimée** (écran, route `/drafts`, provider, bouton Documents) **et** l'auto-save des formulaires (`_saveDraft/_loadDraft/_clearDraft` + message « Brouillon restauré »). ⚠️ Ne **pas** confondre avec le **statut `draft`** d'un dossier côté backend, qui lui est **conservé** (un dossier est créé en brouillon puis soumis).
14. **Carte « configuration CNI » retirée** du profil/accueil.
15. **Backend dev** : SQLite, Celery eager + `CELERY_TASK_STORE_EAGER_RESULT = False`, OTP dev 123456, `GROQ_API_KEY` nécessaire pour Ndiogoye. (Ces réglages dev existent ; ne pas les « corriger ».)
16. **Pages connexion/inscription** : fond **blanc pur**, logo **sans cadre** (il se fond dans le blanc) — choix esthétique validé.
17. **Sections accueil** « Vos rendez-vous », « Ma mairie la plus proche », « Ndiogoye Proactif » : **présentes** dans le projet de Fatou (réintégrées). (Elles avaient été retirées d'une copie tierce désormais perdue.)

---

## 10. Dette technique

### 10.1 Bugs / limitations connus
- **Sections statiques** : RDV, mairie, actualités → données mockées (pas d'API).
- **Ndiogoye** dépend de `GROQ_API_KEY` (sinon erreur/réponse dégradée).
- **Fichiers orphelins** : `documents/presentation/screens/drafts_screen.dart` et `…/providers/drafts_provider.dart` ont été **vidés** (commentaire seulement) faute de pouvoir les supprimer dans l'environnement — **les supprimer physiquement** est recommandé.
- **`other_services_screen.dart`** : écran supprimé du routeur (n'était plus utilisé) suite à une copie incomplète après re-clone.
- **Duplication** importante entre les 4 formulaires de certificats.

### 10.2 Environnement (historique, non bloquant pour le code)
- Le bac à sable Linux/outil a parfois échoué (« disque plein / EXDEV »). Sans impact sur le code, mais privilégier les outils fichiers directs ; `flutter analyze`/`flutter run` se lancent côté machine de l'utilisatrice.

### 10.3 Refactoring recommandé
- **Factoriser les formulaires de certificats** (étapes, validations, upload) dans des widgets/mixins partagés.
- Centraliser la **gestion d'erreurs API** et le **refresh token** dans `dio_client.dart`.
- Extraire les libellés/statuts dans un mapping unique réutilisable.

### 10.4 Optimisations futures
- Mise en cache des listes (dossiers, communes), pagination.
- Lazy-loading des images, compression des uploads.
- Tests (widget + golden + intégration) — actuellement minimaux.

---

## 11. Roadmap (ordre logique conseillé)

1. **Stabiliser le build** : `flutter pub get`, `flutter analyze`, `flutter run` ; corriger les éventuels fichiers manquants après le re-clone (vérifier que tous les imports de `app_router.dart` résolvent).
2. **Supprimer proprement** les fichiers orphelins `drafts_*` et vérifier qu'aucune référence ne subsiste.
3. **Fiabiliser le parcours principal** (naissance) de bout en bout avec `seed_data` + `seed_registres.py` : demande → vérif → paiement → validation agent (web) → download PDF.
4. **Brancher les demandes mariage/décès/résidence** sur des registres de test équivalents (étendre `seed_registres.py`).
5. **Refactor des formulaires** de certificats (réduire la duplication).
6. **Robustesse réseau** : refresh token + gestion d'erreurs centralisée.
7. **Notifications push** (FCM + `register-device/`).
8. **RDV / mairie / actualités** dès que les endpoints backend existent (sinon laisser l'UI statique).
9. **Tests** et **CI**.
10. **Préparation prod** : config réseau (baseUrl), secrets, build release.

---

## 12. Contexte complet pour Claude Code

### 12.1 Ce qu'il doit savoir avant de commencer
- C'est une app **citoyen mobile Flutter** d'un monorepo TERANGA CIVIL (back Django + web React). **Le mobile actif est `D:\DBE\Flutter\front-mobile-terranga_civil`**.
- Le **backend tourne en local** : depuis `D:\DBE\Flutter\Teranga-Civil\backend`, venv activé → `python manage.py migrate` puis `python manage.py runserver 127.0.0.1:8000`. Données : `python manage.py seed_data` **puis** `python seed_registres.py`. Comptes : mot de passe `password123`, OTP dev `123456`.
- Pour tester la **naissance pour soi** : `citoyen1@gmail.com` / commune **Dakar Plateau** / n° `0001` / année `1995` (ou `citoyen2@gmail.com` / `0002` / `1998`).
- Le **téléchargement du PDF** exige qu'un agent (web : `verifier.plateau@…` ou `admin.plateau@sunucivil.sn`) ait passé le dossier en `completed`.
- Contrats API : **`/api/docs/`** (Swagger) fait foi.

### 12.2 Ce qu'il ne doit PAS modifier
- ❌ **Le backend** (`D:\DBE\Flutter\Teranga-Civil\backend`) — sauf, à la rigueur, **données de seed** (`seed_registres.py`) ; jamais la logique métier.
- ❌ **Le frontend React** (`frontend/`).
- ❌ Le **statut `draft`** des dossiers (workflow backend) — ce n'est PAS la feature « Brouillons » (supprimée).
- ❌ Les **décisions du §9** (les respecter).
- ❌ Réintroduire la feature « Brouillons », la carte « config CNI », l'auto-save des formulaires.

### 12.3 Conventions du projet
- **Architecture feature-first** : `features/<feature>/{data,presentation}`. Les providers Riverpod vivent dans `presentation/providers`.
- **Routes** : ajouter une route = nouvelle constante dans `AppRoutes` + `GoRoute` dans `app_router.dart`. Jamais d'URL en dur.
- **Thème** : couleurs via `AppColors`, textes via `AppTextStyles`, jamais de couleurs « magiques » hors palette (le code existant utilise parfois des hex directs `#0B285D` — rester cohérent avec la palette).
- **HTTP** : passer par `dio_client.dart` (JWT injecté). Datasources par feature.
- **Uploads** : toujours gérer **web (bytes via `PickedFiles`)** + mobile (fichier).
- **Commune** : utiliser le **code**.
- **Nommage** : fichiers `snake_case.dart`, classes `PascalCase`, providers suffixés `Provider`.
- **i18n** : libellés FR (+ touches Wolof sur l'accueil). Police **Poppins**.

### 12.4 Prochaines tâches prioritaires
1. **Vérifier que le projet compile** (`flutter analyze` / `flutter run` web ou Android) et corriger tout fichier manquant suite au re-clone (vérifier les imports de `app_router.dart`).
2. **Supprimer physiquement** les fichiers `drafts_screen.dart` et `drafts_provider.dart` (vidés, non référencés).
3. **Valider le parcours naissance complet** avec les données de test (jusqu'au download PDF).
4. **Étendre `seed_registres.py`** pour mariage/décès/résidence et fiabiliser ces parcours.
5. **Refactor des formulaires** de certificats (réduction de la duplication).

### 12.5 Bonnes pratiques pour rester cohérent
- **Avant de coder** : lire `app_router.dart`, `core/theme/*`, `core/network/dio_client.dart`, et le datasource de la feature concernée.
- **Réutiliser** les widgets partagés (`primary_button`, `app_text_field`, `upload_document_card`, `backend_commune_select`, `certificate_step_indicator`).
- **Ne pas casser les contrats API** ; en cas de besoin d'un nouvel endpoint, le **documenter et le demander à l'équipe backend** plutôt que de modifier le back.
- **Tester** le rendu **web ET mobile** (l'app cible les deux ; pièges connus sur l'upload web).
- **Petits commits atomiques** sur la branche `DevAliouneSene` ; messages clairs.
- **Toujours rafraîchir l'état** après une mutation (`ref.invalidate(...)`).
- En cas d'erreur backend rencontrée, **la remonter** (message exact) à l'équipe back plutôt que de contourner côté mobile.

---

### Annexe — Comptes & commandes utiles
```
# Backend (dossier D:\DBE\Flutter\Teranga-Civil\backend)
venv\Scripts\activate.bat
python manage.py migrate
python manage.py seed_data
python seed_registres.py
python manage.py runserver 127.0.0.1:8000
# Swagger : http://127.0.0.1:8000/api/docs/

# Mobile (dossier D:\DBE\Flutter\front-mobile-terranga_civil)
flutter pub get
flutter analyze
flutter run        # choisir Chrome / appareil

# Comptes (mot de passe : password123 ; OTP dev : 123456)
citoyen1@gmail.com  (Moussa Diop)  — naissance test : DK-PLT / 0001 / 1995
citoyen2@gmail.com  (Awa Fall)     — naissance test : DK-PLT / 0002 / 1998
verifier.plateau@sunucivil.sn / admin.plateau@sunucivil.sn (web, validation)
```

> Fin du document de passation. Ce fichier doit rester la **référence unique** ; le mettre à jour à chaque décision structurante.
