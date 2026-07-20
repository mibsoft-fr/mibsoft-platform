# Cahier des charges — Module « Registre de sécurité ERP »

> **Statut** : proposition à valider. **Version 0.4 — 16/07/2026** (intègre le cycle de vie du registre,
> l'accès établissement-only, les 7 rubriques réglementaires, et le tableau de suivi des vérifications).
> **Plateforme** : module MIBsoft, disponible pour les **centres de formation** et les **entreprises**.
> ⚠️ Les affirmations réglementaires doivent être **validées par un préventionniste / juriste**
> avant toute communication commerciale sur la « valeur légale ».

---

## 1. Objet

Tenir un **registre de sécurité incendie dématérialisé** par établissement (ERP/IGH), à jour, traçable,
infalsifiable et présentable en contrôle (commission de sécurité, SDIS, inspection du travail, assureur).

## 2. Cadre réglementaire (à valider)

- Registre obligatoire en ERP : **art. R143-44 CCH** + **arrêté du 25 juin 1980**.
- Dématérialisation admise si **intégrité, infalsifiabilité, traçabilité** et présentation en contrôle.
- Signature : cadre **eIDAS**. Phase 1 = **socle de preuve maison** (empreinte + horodatage + journal
  inaltérable) ; **Yousign** (avancée/qualifiée) pour le permis de feu (Phase 2).

## 3. Cycle de vie du registre  *(nouveau — décision exploitant)*

- Il existe **un registre par établissement** (période courante).
- L'**exploitant OUVRE** le registre (date d'ouverture, identité) → statut **Ouvert**.
- Pendant qu'il est **Ouvert** : saisie des entrées, dépôt de rapports, visas.
- L'**exploitant CLÔTURE** le registre → statut **Clôturé** : le registre est **scellé** (empreinte
  globale figée), il devient **lecture seule** ; on ouvre alors un nouveau registre pour la période suivante.
- Un registre clôturé reste **consultable et exportable** (archive à valeur probante).

## 4. Acteurs & accès  *(décisions exploitant)*

**Accès : établissement uniquement.** Pas de lecteur externe (commission/assureur) en Phase 1 — la
présentation en contrôle se fait via **export PDF scellé**. (Lien de consultation externe = évolution future.)

**L'établissement (exploitant) définit lui-même qui a l'accès en écriture** au registre : il gère une
**liste de membres** avec des droits (écriture, visa). L'ouverture/clôture reste réservée à l'exploitant.

| Rôle | Droits |
|---|---|
| **Exploitant / responsable sécurité** | **Ouvre/clôture** le registre, gère les droits, saisit, vise, exporte |
| **Membre en écriture** (agent SSIAP / opérateur, désigné par l'exploitant) | Saisit les entrées, dépose les rapports ; visa **si** droit accordé ; **pas** de clôture |
| **Super-admin MIB** | Supervision / support (lecture) |

Cloisonnement : chaque établissement rattaché à un `center_id` (centre **ou** entreprise), filtré par **RLS**.

## 5. Structure du registre — les 7 rubriques réglementaires

Le registre est organisé en **7 rubriques** (source : exploitant) :

| # | Rubrique | Contenu | Phase |
|---|---|---|---|
| **1** | **Renseignements généraux** (fiche d'identité) | Établissement (nom, adresse, type, catégorie/classe, effectif public+personnel) ; propriétaire, exploitant, responsable sécurité, personnel désigné ; organismes de contrôle & mainteneurs ; secours (n° urgence, centre de secours) | **1** |
| **2** | **Personnel de sécurité & consignes** | Composition du service (SSIAP 1/2/3, EPI/ESI) ; consignes générales & particulières (évacuation, intervention, appel secours, accueil pompiers, PMR) | 1b |
| **3** | **Formations & exercices d'évacuation** | Formations (dates, formateurs/organismes, programmes, personnels formés) ; exercices d'évacuation (≥ tous les 6 mois : date, scénario, temps, observations) | 1b |
| **4** | **Vérifications techniques & maintenances** *(le cœur)* | SSI (ECS/CMSI, DM, DA) ; moyens d'extinction (extincteurs, RIA, colonnes, sprinklers/gaz) ; éclairage de sécurité (BAES évac/ambiance) ; désenfumage (volets, DENFC, ventilateurs) ; électricité & gaz ; portes coupe-feu & issues (ferme-portes, barres antipanique) ; alerte & alarme. Pour chaque : date, intervenant, constats, travaux réalisés, **échéance** | **1** |
| **5** | **Travaux, aménagements & transformations** | Nature des travaux ; matériaux (PV de réaction au feu / classement M0-M2, Euroclasses) ; visites de chantier & réception (avis chargé sécurité / bureau de contrôle) | 1b |
| **6** | **Visites des autorités & commission de sécurité** | Passages commission (dates, avis favorable/défavorable, rapports) ; **prescriptions** + état de mise en conformité ; visites inspection du travail / assureur | 1b |
| **7** | **Consignes en cas de dysfonctionnement** | Mesures compensatoires temporaires (ex. ronde de surveillance humaine si SSI ou désenfumage HS) | 1b |

**Phase 1 (MVP)** = rubrique **1** (fiche d'identité) + rubrique **4** (cœur : vérifications & maintenances,
échéancier, rapports, visa). Les rubriques 2-3-5-6-7 arrivent en **Phase 1b**.

## 6. Lien avec un module « Entretien / Vérifications »  *(idée exploitant)*

La rubrique 4 est un **suivi d'entretien/maintenance** à part entière. On la conçoit comme un socle
réutilisable : un **catalogue d'équipements + périodicités** alimente à la fois le registre de sécurité
et un éventuel **module Entretien** transversal (planning, GMAO légère). On garde donc la table des
équipements/vérifications **découplée** pour pouvoir la brancher ailleurs plus tard.

## 7. Fonctionnalités — Phase 1

1. **Établissements** (rubrique 1) : fiche d'identité complète + acteurs + organismes + secours.
2. **Ouverture / clôture du registre** par l'exploitant (avec scellement à la clôture).
3. **Catalogue des vérifications** (rubrique 4) préchargé, périodicités **paramétrables**.
4. **Échéancier** : prochaine échéance + **statut** (À jour · À venir · En retard) par équipement.
5. **Rappels automatiques** (email, brique d'alertes existante) à J-30 / J-7 / dépassement.
6. **Dépôt de rapport** (PDF) avec **empreinte SHA-256**.
7. **Visa / signature (socle de preuve)** sur une entrée.
8. **Export PDF** du registre (rubrique ou complet), horodaté et scellé.
9. **Journal d'audit** append-only **chaîné** (altération détectable).

## 8. Modèle de données (proposé)

- `etablissements` — `id, center_id (FK), nom, type_erp, categorie, classe_igh, adresse, effectif_public, effectif_personnel, created_at`
- `etablissement_acteurs` — `id, etablissement_id (FK), role ('proprietaire'|'exploitant'|'resp_securite'|'personnel_designe'|'organisme_controle'|'mainteneur'|'secours'), nom, coordonnees`
- `registre_acces` *(droits définis par l'exploitant)* — `id, etablissement_id (FK), user_id, peut_ecrire (bool), peut_viser (bool), ajoute_par, ajoute_le`
- `registres` — `id, etablissement_id (FK), statut ('ouvert'|'cloture'), ouvert_par, ouvert_le, cloture_par, cloture_le, hash_scelle` — **contrainte : un seul registre `ouvert` par établissement** (index unique partiel) ; **clôture → ouverture automatique** du suivant
- `equipements` *(découplé — réutilisable par un module Entretien)* — `id, etablissement_id (FK), type_verification_id (FK), libelle, localisation, periodicite_mois, organisme_requis`
- `verification_types` — catalogue de référence : `id, code, libelle, rubrique (=4), periodicite_mois_defaut, organisme_requis`
- `registre_entrees` — `id, registre_id (FK), rubrique (1..7), type, equipement_id (FK, nullable), date_realisation, prochaine_echeance, statut, intervenant, constats, travaux, description, created_by`
- `registre_documents` — `id, entree_id (FK), storage_path, nom_fichier, hash_sha256, taille, uploaded_by, uploaded_at`
- `signatures` — `id, entree_id (FK, nullable), registre_id (FK, nullable), signataire_nom, signataire_user_id, role, methode ('socle'|'yousign'), hash_signe, horodatage, ip, user_agent`
- `registre_audit` — **append-only** : `id, etablissement_id, registre_id, action, entree_id, acteur, ts, hash_prec, hash_courant`

RLS : tout filtré par `center_id` via `etablissements` ; `signatures`, `registre_audit` et un registre
**clôturé** sont **inaltérables** (pas d'UPDATE/DELETE) ; super-admin en lecture globale.

## 9. Socle de preuve (détail)

À chaque visa **et** à la clôture du registre :
1. Sérialisation **canonique** (JSON déterministe) de l'objet visé (entrée ou registre entier).
2. Empreinte **SHA-256**.
3. Ligne `signatures` (identité du compte + horodatage serveur + IP + user-agent).
4. Ligne `registre_audit` chaînée : `hash_courant = SHA256(hash_prec + payload)`.
5. Export PDF portant l'empreinte + pied « document scellé — toute modification invalide l'empreinte ».

> Signature **simple à forte valeur probante** (art. 1366-1367 C. civ.), pas *avancée* eIDAS. Yousign en Phase 2.

## 10. RGPD

- Collecté au visa : **nom, identifiant compte, IP, user-agent, horodatage**. **Pas de géolocalisation.**
- Base légale : obligation réglementaire + preuve (intérêt légitime). Mention d'info + durée de conservation
  alignée sur l'obligation de conservation du registre. Hébergement UE (Supabase).

## 11. Intégration MIBsoft

- Drapeau `module_registre_securite` sur `centers` → visible univers **Centre** et **Entreprise**.
- Réutilise : Auth + hook JWT, RLS `center_id`, Storage (rapports), brique d'alertes (rappels), DS « Vigil ».

## 12. Écrans (voir `maquette-registre-securite.html`)

Mes établissements · Registre d'un établissement (échéancier rubrique 4) · Détail vérification · Preuve/visa ·
Export PDF. *(À enrichir : bandeau d'état du registre Ouvert/Clôturé + navigation par les 7 rubriques.)*

## 13. Périodicités par défaut (rubrique 4 — source : arrêté du 25 juin 1980)

> Les périodicités par défaut du catalogue sont issues du **règlement de sécurité incendie du
> 25 juin 1980** (dispositions générales ERP). Elles restent **paramétrables** car certaines valeurs
> dépendent du **type et de la catégorie** d'ERP.

| Vérification | Périodicité type | Organisme agréé |
|---|---|---|
| SSI (ECS/CMSI, DM, DA) | Annuelle (+ triennale selon cas) | Selon cas |
| Extincteurs / RIA | Annuelle | Maintenance qualifiée |
| Sprinklers / extinction auto | Selon installation | Selon cas |
| Éclairage de sécurité (BAES) | Semestrielle / annuelle | Non |
| Désenfumage (volets, DENFC, ventilateurs) | Annuelle | Selon cas |
| Installations électriques | Annuelle | Oui |
| Installations gaz / chauffage | Annuelle | Oui |
| Portes / clapets coupe-feu, issues | Annuelle | Selon cas |
| Alerte & alarme | Périodique | Selon cas |

> Les périodicités **exactes dépendent du type et de la catégorie d'ERP** → catalogue **paramétrable**.

## 14. Phasage

| Phase | Contenu |
|---|---|
| **1 (MVP)** | Établissements (rubrique 1) + cycle ouverture/clôture + **vérifications & maintenances** (rubrique 4 : échéancier, rappels, rapports, visa socle, audit, export) |
| **1b** | Rubriques 2 (personnel/consignes), 3 (formations/exercices), 5 (travaux/matériaux), 6 (commission/prescriptions), 7 (mesures compensatoires) |
| **2** | **Permis de feu** (Yousign) |
| **3** | **Plan de prévention** (entreprises extérieures) |
| **Transverse** | Module **Entretien / Vérifications** réutilisant le catalogue d'équipements |

## 15. Décisions actées (15/07/2026)

1. ✅ **Un seul registre actif (`ouvert`) par établissement** (index unique partiel).
2. ✅ À la **clôture**, le registre suivant est **ouvert automatiquement**.
3. ✅ **L'exploitant définit l'accès en écriture** (table `registre_acces` : écriture / visa par membre).
4. ✅ **Périodicités = arrêté du 25 juin 1980** (par défaut, paramétrables).

**Reste à faire valider (juridique)** : le niveau de preuve « socle » avant toute promesse commerciale
de valeur légale.

## 16. Tableau de suivi des vérifications (16/07/2026)

- ✅ **Vue « Tableau de suivi »** (bascule depuis l'échéancier, rubrique 4) présentant le **respect des délais**
  par équipement : `À jour` / `J-60` / `J-30` / `En retard` (calcul jours avant `prochaine_echeance`).
- ✅ Trois champs de traitement par ligne (table `registre_suivi`, upsert par équipement) :
  **Anomalie** (libre), **Mesure prise** (libre), **Remis en conformité** (Oui/Non).
- ✅ **Impression** dédiée du tableau de suivi — destinée à être **présentée à la commission de sécurité**.

### Backlog — alertes e-mail J-60 / J-30 (usage entreprise, différé)

> **Décision (16/07/2026)** : en **formation**, pas d'envoi d'e-mail (le tableau montre déjà l'imminence
> visuellement). À **activer pour l'usage entreprise réel.**

- Infra déjà en place : fonction edge **`send-email`** (Mailgun EU) + modèle de veille planifiée
  **`formateurs-recyclage-watch`** (cron).
- Implémentation prévue : fonction **`registre-echeances-watch`** calquée sur `formateurs-recyclage-watch`,
  déclenchée quotidiennement, qui repère les échéances à **60 j** puis **30 j** et envoie l'alerte via `send-email`.
- À trancher au moment de l'activation entreprise : **destinataire** (exploitant / centre / adresse fixe)
  et **anti-doublon** (ne pas renvoyer le même palier plusieurs fois → journaliser l'envoi).

## 17. Signature de l'intervenant (17/07/2026)

- ✅ **Signature manuscrite tactile** sur la fiche de vérification : l'intervenant signe à l'écran
  (doigt/stylet), l'image PNG est stockée dans le bucket `documents` et **scellée par une empreinte
  SHA-256** (`registre_entrees.signature_path` / `signature_hash`, migration 2052).
- ✅ L'empreinte de signature entre dans le **payload scellé au visa** (intégrité).

### Signature déportée sur téléphone — QR (17/07/2026)

- ✅ Problème terrain : le registre tourne sur un **PC non tactile**, signer à la souris est pénible.
- ✅ Solution : bouton **📱** sur la ligne de vérification → **QR code** affiché sur le PC ; l'intervenant
  le scanne, ouvre `?sign=<token>`, **signe au doigt** sur son téléphone, la signature (PNG + SHA-256)
  revient automatiquement sur l'entrée (le PC détecte par polling). Table `signature_requests` (migration 2056).
- Gratuit, sans SMS ni matériel. QR généré côté client (qrcodejs) avec repli image si indisponible.
- **Évolution (17/07/2026)** : le **pavé de signature sur PC est retiré** (PC souvent non tactile). La signature
  se fait **uniquement sur téléphone**. Le **nom de l'intervenant est saisi sur le téléphone** (dictée vocale
  possible) et revient **automatiquement** dans le champ « Nom de l'intervenant » de la fiche, qui est en
  **lecture seule** côté PC. Objectif : faire remplir/signer par l'intervenant lui-même, simple et cohérent.
- **Fiche complète sur téléphone (17/07/2026)** : sur la vérification, l'intervenant remplit **sur son téléphone**
  nom, société, **avis de conformité**, **compte rendu** et **signature** (tout dictable à la voix). Bouton
  **« Copier le lien »** pour l'**envoyer à distance** si l'intervenant est déjà reparti.
- **Généralisé aux rubriques 3/5/6/7** : plus de pavé PC ; bouton **📱** sur chaque ligne → le signataire
  renseigne nom + société et signe sur son téléphone (QR ou lien). Rubrique 2 (personnel/consignes) : non concernée.

### Backlog — sauvegarde / archivage du registre (usage entreprise)

> **Idée (17/07/2026, M. Boyer)** : prévoir une **sauvegarde du registre de sécurité** et, plus largement,
> un système d'**archivage des documents importants vers le support documentaire de l'entreprise** (PDF).
> Objectif : **rassurer** les entreprises. À concevoir côté entreprise.

- **Déjà en place (infra)** : sauvegarde nocturne de la base Supabase (workflow `backup.yml` → Backblaze B2, chiffrée).
- À concevoir (fonctionnel entreprise) :
  - **Export PDF complet du registre** (par période / par rubrique) déposé automatiquement dans un
    **coffre documentaire** de l'entreprise ou envoyé par e-mail (Mailgun).
  - **Archivage à la clôture** : à chaque clôture de registre, générer et déposer le **PDF scellé** de l'archive.
  - Éventuel **horodatage/qualif** (Yousign) pour renforcer la valeur probante.

### Backlog — signature par code SMS (différé)

> **Décision (17/07/2026)** : signature tactile en présentiel maintenant ; **code SMS à ajouter** pour
> les intervenants **à distance** / usage entreprise.

- Nécessite un **prestataire SMS** (Twilio/Vonage — Mailgun ne fait pas de SMS), avec **coût par envoi**
  et un **champ téléphone** de l'intervenant.
- Principe : OTP envoyé au téléphone → saisie du code = signature (à horodater + journaliser).
- Pour une **valeur juridique** forte : passer par **Yousign** (déjà prévu au phasage).

## 18. Clôture du registre (17/07/2026)

- ✅ **Clôture par l'exploitant** depuis la rubrique 1 (Général), avec **identification** (nom + fonction + code).
- ✅ **Scellement global** : empreinte SHA-256 calculée sur **toutes les entrées** du registre
  (`registres.hash_scelle`) + entrée `cloture` dans le **journal d'audit chaîné**.
- ✅ **Ouverture automatique du registre suivant** (un seul registre `ouvert` par établissement).
- ✅ Le registre clôturé affiche statut, date, clôturant et empreinte.
- ✅ **Consultation des registres archivés** (17/07/2026) : liste des registres clôturés en rubrique 1,
  ouverture en **lecture seule** (bandeau « Registre archivé » + retour au registre actif), rubrique 4
  filtrée sur les entrées du registre archivé, actions de saisie/visa masquées.

## 19. Rubriques 2/3/5/6/7 + historisation du suivi (17/07/2026)

- ✅ **Rubriques 2, 3, 5, 6, 7** : module **journal chronologique générique** (registre_entrees, rubrique n) —
  ajout d'entrée (date, objet/type, personne, détails **libre + voix**, **pièce PDF**, **signature tactile**),
  liste chronologique, consultation. Bloqué en ajout si le registre est clôturé. Repris dans l'Impression.
- ✅ **Historisation du tableau de suivi** : chaque « Enregistrer » **ajoute** une ligne (plus d'écrasement).
  L'écran affiche la **dernière** mise à jour ; bouton **🕘 Historique** pour voir toutes les versions.
  Contrainte d'unicité retirée + index (migration 2054).
- ✅ Modale du tableau de suivi élargie pour tout voir en largeur.

## 21. Contrôle d'accès en saisie — lecture seule + autorisations (17/07/2026)

- ✅ Le registre s'ouvre **en lecture seule**. Bandeau « 🔒 Lecture seule » + **« 🔓 Passer en mode saisie »**.
- ✅ **Autorisations par établissement** (table `registre_autorisations` : nom, fonction, PIN optionnel — migration 2057),
  gérées en **Rubrique 1 → 🔑 Autorisations de saisie** (ajout/retrait de personnes).
- ✅ **Paramétrable** : case « Exiger un code PIN » par établissement (`etablissements.saisie_pin_requise`).
  Défaut formation = **nom seul** ; entreprise = **nom + PIN**.
- ✅ En mode saisie, toutes les actions d'écriture apparaissent (ajout, ✏️, 📱, visa, clôture, suivi) ;
  en lecture seule elles sont masquées / désactivées. La personne choisie devient l'opérateur (visas).
- ⚠️ Sécurité « souple » (modèle Patrol par nom) : la **gestion des autorisations reste accessible** pour
  amorçage. La sécurité forte (comptes/rôles) relèvera du volet entreprise.

## 20. Rubrique 2 — Personnel / Consignes séparés (17/07/2026)

- ✅ Rubrique 2 scindée en deux vues (bascule) : **👥 Personnel** et **📋 Consignes**
  (colonne `registre_entrees.sous_type` = 'personnel' | 'consigne', migration 2055).
- ✅ **Personnel** : saisie **multi-personnes** (Nom, Fonction/qualification, Organisme/employeur, observations).
- ✅ **Consignes** : type prédéfini (**Consigne incendie**, **Consigne de prise en charge des personnes en
  situation de handicap**, Autre), contenu libre + voix, document PDF.
- ✅ Les entrées **Nom + Organisme** sont saisies dans deux champs séparés partout (rubriques 3,5,6,7).

## 22. Modules Permis de feu & Plan de prévention (20/07/2026)

Deux modules autonomes construits sur la même architecture que le registre
(fichier unique, accès **modèle Patrol** par `?center=&op=&niveau=&role=`,
**socle de preuve** signatures + SHA-256 chaîné, design MIB).

### 22.1 Permis de feu (`permisfeu.html`)
- Document réglementaire pour **travaux par point chaud** (soudage, meulage, chalumeau…).
- Identification (n°, établissement, lieu, dates de validité), **intervenants multiples**
  (entreprise + opérateur + e-mail), nature des travaux, **mesures de prévention avant/pendant/après**,
  moyens d'extinction, **surveillance après travaux** avec rondes horodatées.
- **3 signatures** : donneur d'ordre, entreprise(s) exécutante(s) — plusieurs possibles —, chargé de surveillance.
- Cycle **brouillon → validé → clôturé / annulé** avec scellement d'empreinte.
- Migrations : **2060** (`permis_feu` + `permis_feu_signatures` + `permis_feu_rondes` + routage QR),
  **2061** (colonnes `permis_id`/`permis_role` sur `signature_requests`), **2062** (e-mails de partage),
  **2063** (`intervenants` jsonb).

### 22.2 Plan de prévention (`plan-prevention.html`)
- Document réglementaire pour **interventions d'entreprises extérieures** (Code du travail R.4512-6 et s.).
- Identification de l'opération, **entreprise utilisatrice** + **entreprises extérieures multiples**,
  **inspection commune préalable** (date + **participants multiples**), **travaux dangereux** (checklist),
  **analyse des risques d'interférence** (risque → mesure → responsable EU/EE/Commun),
  mesures de prévention, consignes, **réunions de suivi / réexamen** horodatées.
- **Signatures** : entreprise utilisatrice (1) + entreprises extérieures (plusieurs).
- Cycle brouillon → validé → clôturé / annulé.
- Migrations : **2064** (`plan_prevention` + signatures + reunions + routage QR),
  **2066** (`inspection_participants_list` jsonb).

### 22.3 Fonctions transverses aux deux modules
- ✅ **Pièces jointes** (photos, vidéos, documents) génériques (table `pieces_jointes`, migrations
  **2065** + **2067** commentaire) : vignettes, **commentaire/légende par fichier**, téléchargement, suppression.
- ✅ **Partage e-mail** : ouvre le client de messagerie pré-rempli (destinataires = e-mails des intervenants,
  récapitulatif du document, **lien de signature** optionnel). *(Envoi automatisé PDF + suivi = volet entreprise.)*
- ✅ **Mode visite terrain** (`&mode=terrain`) : bouton **📱 Mobile / tablette** affichant un **QR code** à scanner
  avec l'appareil emporté en visite. En terrain : créer, remplir, joindre photos, **signer directement** (pad
  en place, pas de QR), valider. Une fois **validé**, la modification / clôture / annulation se fait **en repassant
  par Patrol**.
- ✅ **Accès** : liens dans la nav de patrol-admin (🔥 Permis de feu, 🛡️ Plan de prévention) + tuiles dans
  « Mes modules » du centre (inclus avec le Registre de sécurité).

## 23. Feuille de route « Phase entreprise » — durcissement (à développer)

> **Contexte (20/07/2026)** : la suite (registre, permis de feu, plan de prévention) est aboutie
> **pour l'usage formation**. Pour un **usage réel en entreprise**, tout est à re-durcir, en priorité
> sur les **validations et les signatures**.

### Sécurité des accès
- **Authentification nominative par utilisateur** (fin de l'ouverture anonyme « Patrol » : comptes + rôles réels).
- **RLS Supabase par utilisateur / centre** (les policies sont aujourd'hui ouvertes `anon` pour la fluidité formation).
- **Stockage privé** : URLs signées à durée limitée au lieu d'URLs publiques (pièces jointes, signatures, documents).

### Signatures & validations à valeur probante
- **Signature électronique eIDAS (Yousign)** — avancée / qualifiée, multi-signataires externes — pour
  permis de feu, plan de prévention et visas du registre.
- **Horodatage qualifié** (autorité de temps) au lieu de l'horloge du navigateur.
- **Audit append-only garanti côté serveur** (le chaînage SHA-256 est aujourd'hui calculé côté client).
- **Signatures obligatoires avant validation** (bloquer, pas seulement prévenir).

### Autour
- **E-mail transactionnel réel** (Mailgun/Resend + edge function) avec PDF joint et suivi des ouvertures
  — même chantier que les alertes J-60 / J-30 du registre.
- **Export PDF signé + archivage à valeur légale** (coffre-fort numérique / horodatage).
- **Sécurité des pièces jointes** : limite de taille (vidéos), contrôle d'accès, éventuel anti-virus.
