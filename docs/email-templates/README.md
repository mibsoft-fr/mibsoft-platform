# Templates d'emails d'authentification — MIBsoft

Gabarits HTML **brandés MIBsoft (français)** pour les emails envoyés par **Supabase Auth**
(réinitialisation de mot de passe, confirmation, etc.). Ils remplacent les templates par défaut
de Supabase (anglais, non brandés), qui partaient facilement en spam.

> ⚠️ Ces templates se configurent dans le **dashboard Supabase**, pas dans le code. Les fichiers
> ici servent de **référence versionnée** : on les copie-colle dans Supabase, et on garde la trace
> dans le repo.

## Où les coller

**Supabase → Authentication → Emails → Templates** — un onglet par type d'email.
À faire sur **PROD** (`vsddtohdkcwihlybfief`) et, si besoin de tester, sur **DEV** (`ozfkmlokovxigfnwjeuk`).

| Fichier | Onglet Supabase | Objet (Subject) recommandé |
|---|---|---|
| `reset-password.html` | **Reset Password** (Recovery) | Réinitialisation de votre mot de passe MIBsoft |
| `confirm-signup.html` | **Confirm signup** | Confirmez votre adresse email — MIBsoft |
| `magic-link.html` | **Magic Link** | Votre lien de connexion MIBsoft |
| `invite.html` | **Invite user** | Vous êtes invité(e) sur MIBsoft |
| `email-change.html` | **Change Email Address** | Confirmez votre nouvelle adresse email — MIBsoft |
| `reauthentication.html` | **Reauthentication** | Code de vérification MIBsoft |

Pour chaque template : colle le HTML dans le champ **Message body**, et renseigne le **Subject** ci-dessus.

## Variables Supabase utilisées

- `{{ .ConfirmationURL }}` — lien d'action (présent dans tous les templates).
- `{{ .Email }}` / `{{ .NewEmail }}` — utilisées uniquement dans `email-change.html`.

Ne pas modifier ces variables : Supabase les remplace à l'envoi.

## Notes anti-spam

- **Contenu brandé + français** : réduit fortement le score spam par rapport au template par défaut.
- **Réputation du domaine** : `mibsoft.fr` étant récent, les tout premiers envois peuvent partir en
  spam puis s'améliorer. Marquer les emails « Non spam » aide à entraîner les filtres.
- **Authentification** : SPF + DKIM (sélecteur `mta`) + DMARC (géré par IONOS) sont alignés sur
  `mibsoft.fr` — l'authentification n'est pas la cause du spam, c'était bien le contenu.
- **Logo** : chargé depuis `https://mibsoft.fr/logo/logo-web-transparent.png` (même image que les
  emails transactionnels des Edge Functions, pour une identité cohérente).
