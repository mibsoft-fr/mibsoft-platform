# Plan de Reprise d'Activité (PRA) — MIBsoft Platform

Document de référence pour sauvegarder et restaurer la plateforme MIBsoft
(SSIAP / sécurité incendie) en cas d'incident majeur.

Dernière révision : 2026-07-12

---

## 1. Périmètre : qu'est-ce qui doit être protégé ?

| Élément | Où c'est stocké | Risque de perte | Sauvegarde |
|---|---|---|---|
| **Base de données** (données stagiaires, comptes, évaluations, sessions) | Supabase PostgreSQL (prod : `vsddtohdkcwihlybfief`) | 🔴 **Élevé et critique** | **Backblaze B2 quotidien** + PITR Supabase |
| **Fichiers Storage** (documents durables éventuels) | Supabase Storage | 🟠 Moyen (nul si pas de fichiers durables) | Export manuel (voir §6) |
| **Code applicatif** (front, Edge Functions, migrations) | GitHub `mibsoft-fr/mibsoft-platform` | 🟢 Faible | GitHub + clone local + miroir occasionnel |
| **Déploiement web** | Vercel | 🟢 Nul | Rien à sauvegarder : Vercel **reconstruit** depuis GitHub |
| **Variables d'environnement Vercel** (clés, config) | Vercel (hors repo) | 🟠 Moyen | À **noter dans un gestionnaire de mots de passe** |
| **Secrets** (mots de passe DB, clés Backblaze, passphrase de chiffrement) | GitHub Secrets / gestionnaire de mots de passe | 🔴 Critique | Gestionnaire de mots de passe (jamais dans le repo) |

> **Vidéos de débriefing SSI** : éphémères (purgées automatiquement) → **non sauvegardées** volontairement (RGPD).

**En clair : le seul enjeu vital de sauvegarde est la base Supabase.** Le code (GitHub)
et le déploiement (Vercel) ne présentent pas de risque de perte de données.

---

## 2. Objectifs (cibles)

- **RPO** (perte de données maximale acceptable) : **24 h** (sauvegarde quotidienne).
  Avec le PITR Supabase activé en plus, on descend à quelques minutes.
- **RTO** (temps de remise en service visé) : **quelques heures**.

---

## 3. Où sont les sauvegardes

- **Fournisseur** : Backblaze B2 (compatible S3), **bucket en région UE** (RGPD).
- **Chiffrement** : chaque dump est chiffré **AES-256** avant l'envoi
  (passphrase `BACKUP_ENCRYPTION_PASSPHRASE`).
- **Rétention** : 30 jours — à configurer via une **Lifecycle Rule** sur le bucket
  Backblaze (supprime automatiquement les fichiers de plus de 30 jours).

---

## 4. Sauvegarde automatique

Assurée par le workflow **`.github/workflows/backup.yml`** :
- s'exécute **tous les jours à 02:00 UTC** (et manuellement via *Run workflow*),
- fait un `pg_dump` des schémas `public`, `auth`, `storage`,
- chiffre le fichier, puis l'envoie dans `s3://<bucket>/daily/`.

### Secrets à créer une seule fois (Settings → Secrets and variables → Actions)

| Secret | Valeur |
|---|---|
| `SUPABASE_DB_URL` | Chaîne **« Session pooler »** (port 5432) — Supabase → Project Settings → Database → Connection string → *Session pooler*. ⚠️ Pas la connexion directe (IPv4 requis). |
| `BACKUP_ENCRYPTION_PASSPHRASE` | Phrase secrète forte. **À conserver précieusement** : sans elle, aucune sauvegarde n'est lisible. |
| `B2_ACCESS_KEY_ID` | `keyID` de l'Application Key Backblaze. |
| `B2_SECRET_ACCESS_KEY` | `applicationKey` Backblaze. |
| `B2_ENDPOINT` | Ex. `https://s3.eu-central-003.backblazeb2.com` (région UE). |
| `B2_BUCKET` | Ex. `mibsoft-backups`. |

---

## 5. Procédure de RESTAURATION de la base (« break glass »)

À exécuter depuis une machine avec le client PostgreSQL 17 installé.

### Étape 1 — Récupérer et déchiffrer la dernière sauvegarde
```bash
# Lister les sauvegardes disponibles
aws s3 ls s3://mibsoft-backups/daily/ --endpoint-url https://s3.eu-central-003.backblazeb2.com

# Télécharger la plus récente
aws s3 cp s3://mibsoft-backups/daily/mibsoft_prod_AAAA-MM-JJ_HHMM.dump.gpg . \
  --endpoint-url https://s3.eu-central-003.backblazeb2.com

# Déchiffrer (demande la passphrase BACKUP_ENCRYPTION_PASSPHRASE)
gpg --batch --yes --passphrase "MA_PASSPHRASE" \
  -o restore.dump -d mibsoft_prod_AAAA-MM-JJ_HHMM.dump.gpg
```

### Étape 2 — Préparer la cible
- Soit un **nouveau projet Supabase** (région UE), soit une base PostgreSQL neuve.
- Récupérer sa chaîne de connexion (« Session pooler », port 5432).

### Étape 3 — Restaurer
```bash
# Données applicatives (schéma public) : restauration principale
pg_restore --no-owner --no-privileges --schema public \
  --dbname "postgresql://postgres.[REF]:[MDP]@aws-0-[region].pooler.supabase.com:5432/postgres" \
  restore.dump

# Comptes utilisateurs (schéma auth) : données uniquement
pg_restore --no-owner --data-only --schema auth \
  --dbname "postgresql://postgres.[REF]:[MDP]@aws-0-[region].pooler.supabase.com:5432/postgres" \
  restore.dump
```
> Des messages « already exists » sur des objets système sont **normaux** (le projet
> Supabase neuf possède déjà les schémas `auth`/`storage`) → on ne restaure que les
> **données** de `auth`, pas sa structure.

### Étape 4 — Repointer l'application
Dans `supabase.js`, mettre à jour `url` et `anon` du projet PROD par ceux du nouveau
projet, commiter → Vercel redéploie automatiquement.

### Étape 5 — Vérifier
- Connexion d'un compte formateur et d'un compte stagiaire.
- Présence des sessions / évaluations récentes.
- Une session SSI de test fonctionne de bout en bout.

---

## 6. Fichiers Storage (si applicable)
Si des fichiers durables sont stockés dans Supabase Storage, les télécharger
séparément (le dump ne contient que leurs métadonnées) via l'endpoint S3 du Storage
ou le dashboard, et les ré-uploader après restauration.

---

## 7. Test trimestriel (OBLIGATOIRE)
> Une sauvegarde jamais restaurée n'est pas une sauvegarde.

Tous les 3 mois, exécuter §5 sur un **projet Supabase jetable** et cocher :

- [ ] Le dernier `.dump.gpg` se télécharge depuis Backblaze.
- [ ] Le déchiffrement fonctionne (passphrase correcte et connue).
- [ ] `pg_restore` du schéma `public` se termine sans erreur bloquante.
- [ ] Les comptes (`auth`) sont restaurés et un login fonctionne.
- [ ] L'application tourne sur la base restaurée.
- [ ] Date du test + résultat notés ci-dessous.

| Date du test | Résultat | Par |
|---|---|---|
|  |  |  |

---

## 8. En cas d'incident : réflexes
1. **Ne pas paniquer, ne rien supprimer.** D'abord identifier l'ampleur.
2. Perte partielle / erreur récente → **PITR Supabase** (le plus rapide).
3. Perte totale de Supabase → restauration Backblaze (§5) sur un nouveau projet.
4. Panne Vercel → redéployer depuis GitHub (aucune donnée en jeu).
5. Documenter l'incident et la reprise.
