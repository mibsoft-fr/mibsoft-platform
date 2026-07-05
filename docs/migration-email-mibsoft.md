# Migration email → domaine `mibsoft.fr` (Mailgun)

> Trace de la bascule des emails de la plateforme SSIAP de l'ancien domaine d'envoi
> (`mib-prevention.fr`) vers **`mibsoft.fr`**, dans le cadre du rebrand **MIB Prévention → MIBsoft**.
> Réalisée en juillet 2026.

## Contexte

- Deux applications distinctes utilisent Mailgun :
  - **gestion-ets** → reste sur le compte Mailgun **« Mib-Prevention »** avec le domaine `mib-prevention.fr` (inchangé).
  - **Plateforme SSIAP (ce repo)** → nouveau compte Mailgun **« MIBSOFT »**, domaine d'envoi **`mibsoft.fr`**.
- Deux comptes Mailgun séparés = deux clés API, deux facturations. Le plan **Free** ne permet
  plus d'envoyer depuis un domaine custom : le compte MIBSOFT doit être en **Basic 10k (14 €/mois)**
  au minimum (10 000 emails/mois, 1 domaine — suffisant).
- Région Mailgun : **EU** (comme les Edge Functions, qui appellent `api.eu.mailgun.net`).

## Configuration DNS (IONOS, zone `mibsoft.fr`)

Les enregistrements ci-dessous sont **ajoutés** à la zone existante (le site est déjà servi par
Vercel via `A @ → 216.198.79.1`, et la messagerie `contact@mibsoft.fr` reste sur IONOS).

| Type | Hôte (IONOS) | Valeur | But |
|---|---|---|---|
| `TXT` | `@` | `v=spf1 include:_spf-eu.ionos.com include:mailgun.org ~all` | **SPF fusionné** : autorise à la fois la messagerie IONOS et Mailgun. Une seule ligne SPF autorisée. |
| `TXT` | `mta._domainkey` | `k=rsa; p=…` (clé publique fournie par Mailgun) | **DKIM** Mailgun (sélecteur `mta`, distinct des sélecteurs IONOS `s1-ionos` / `s2-ionos`). |
| `CNAME` | `email` | `eu.mailgun.org` | **Tracking** ouvertures/clics + liens de désabonnement (optionnel mais recommandé). |

### ⚠️ Ce qu'on n'ajoute PAS
- **Les MX Mailgun** (`mxa.eu.mailgun.org` / `mxb.eu.mailgun.org`) : ils feraient **recevoir** le
  courrier de `@mibsoft.fr` par Mailgun et **casseraient la réception de `contact@mibsoft.fr`**
  (boîte IONOS). On garde donc les MX IONOS existants (`mx00.ionos.fr` / `mx01.ionos.fr`).
- Le DMARC via Red Sift (proposé par Mailgun) : optionnel, non activé pour l'instant.

### Statut Mailgun attendu après propagation
- `TXT (SPF)` → **Verified** ✅
- `TXT (DKIM)` → **Active** ✅
- `CNAME (tracking)` → **Verified** ✅
- `MX` → **Unverified** (normal et voulu — non installés).

## Secrets à basculer (Supabase → Edge Functions → Secrets)

À faire sur **DEV** (`ozfkmlokovxigfnwjeuk`) **et PROD** (`vsddtohdkcwihlybfief`).

| Secret | Nouvelle valeur |
|---|---|
| `MAILGUN_API_KEY` | Sending API key du compte **MIBSOFT** (≠ clé du compte Mib-Prevention) |
| `MAILGUN_DOMAIN` | `mibsoft.fr` |
| `MAILGUN_FROM` | `MIBsoft <no-reply@mibsoft.fr>` |
| `MAILGUN_HOST` | `api.eu.mailgun.net` (bien vérifier la région EU) |

> Les emails transactionnels (bienvenue, rappels PIN, alertes) partent des Edge Functions via
> l'**API Mailgun** ; ils utilisent ces secrets. Aucun changement de code n'est nécessaire, seuls
> les secrets changent.

## Custom SMTP Supabase (emails d'authentification)

Concerne uniquement les emails envoyés par **Supabase Auth** (réinitialisation de mot de passe,
confirmation) — distincts des emails transactionnels ci-dessus.

`Authentication → Emails → SMTP Settings → Enable Custom SMTP` :

| Champ | Valeur |
|---|---|
| Host | `smtp.eu.mailgun.org` |
| Port | `587` |
| Username | SMTP login du domaine (Mailgun → domaine → SMTP credentials, type `postmaster@mibsoft.fr`) |
| Password | mot de passe SMTP associé (réinitialisable dans Mailgun) |
| Sender email | `noreply@mibsoft.fr` |
| Sender name | `MIBsoft` |

> Identifiant SMTP créé dans Mailgun (Domain settings → SMTP Credentials → *Add new SMTP user*) :
> `noreply@mibsoft.fr`. Le custom SMTP a été activé et testé (email de reset reçu depuis
> `noreply@mibsoft.fr`).

### Templates d'emails d'authentification
Les templates Supabase par défaut (anglais, non brandés) sont remplacés par des gabarits brandés
MIBsoft (français), versionnés dans **`docs/email-templates/`** (voir le README du dossier pour le
mapping onglet Supabase ↔ fichier + objets recommandés). À coller dans
`Authentication → Emails → Templates`.

## Ordre de bascule (pour ne jamais couper les emails)

1. Créer + **vérifier** `mibsoft.fr` sur le compte MIBSOFT (DNS ci-dessus) → **fait**.
2. **Upgrade Basic 10k** sur le compte MIBSOFT (obligatoire pour envoyer depuis le domaine custom).
3. Récupérer la **nouvelle clé API** (compte MIBSOFT).
4. **Test d'envoi réel** vers une adresse externe (hors compte).
5. Basculer les **secrets** (`MAILGUN_*`) sur **DEV puis PROD**.
6. Configurer le **custom SMTP** Supabase (DEV puis PROD).
7. Vérifier de bout en bout : achat de test → email de bienvenue reçu ; reset mot de passe → email reçu.

## Rappels

- `mib-prevention.fr` **reste en service** pour gestion-ets — ne pas le supprimer.
- Une seule ligne `SPF` par domaine : toujours **fusionner**, ne jamais dupliquer.
- Si l'include SPF IONOS diffère (`_spf-eu.ionos.com` peut varier selon l'offre), reprendre la valeur
  exacte recommandée par IONOS et la placer avant `include:mailgun.org`.
