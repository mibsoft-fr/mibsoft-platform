# Stripe — Checklist de passage en PRODUCTION (mode live)

> État actuel : tout fonctionne en **mode test** (`sk_test_…`, cartes `4242`).
> Cette checklist fait passer le flux en **mode live** pour encaisser de vrais paiements.
> Projet Supabase : `ozfkmlokovxigfnwjeuk` · Domaines : vitrine `mib-prevention.fr`, app `app.mib-prevention.fr`.

---

## 0. Pré-requis — Activer le compte Stripe (obligatoire pour recevoir l'argent)

Dashboard Stripe → **Activer le compte** / *Activate payments* :
- [ ] Infos légales de l'entreprise (SIRET, adresse, représentant)
- [ ] **IBAN** pour recevoir les virements (payouts)
- [ ] Vérification d'identité si demandée

Tant que le compte n'est pas activé, le mode live refuse les paiements.

---

## 1. Récupérer les clés LIVE

Dashboard Stripe → bascule l'interrupteur **« Mode test » → OFF** (en haut à droite) → **Developers → API keys** :
- [ ] Copier la **Secret key** live → `sk_live_…`
  *(la Publishable key `pk_live_` n'est pas utilisée ici — on passe par Checkout côté serveur)*

---

## 2. Mettre à jour les secrets Supabase (Edge Functions)

Supabase Dashboard → **Project Settings → Edge Functions → Secrets** (projet `ozfkmlokovxigfnwjeuk`) :

| Secret | Nouvelle valeur (live) |
|---|---|
| `STRIPE_SECRET_KEY` | `sk_live_…` (étape 1) |
| `STRIPE_WEBHOOK_SECRET` | `whsec_…` **live** (étape 4) |

Inchangés (déjà bons) : `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `MAILGUN_API_KEY`,
`MAILGUN_DOMAIN` (`mib-prevention.fr`), `MAILGUN_HOST` (`api.eu.mailgun.net`),
`APP_URL` (`https://app.mib-prevention.fr`), `VITRINE_URL` (`https://mib-prevention.fr`).

> ⚠️ Vérifier que le **domaine Mailgun est vérifié en production** (SPF/DKIM) sinon les emails de bienvenue partiront en spam ou seront rejetés.

---

## 3. Créer les produits + prix en mode LIVE

⚠️ La table `stripe_prices` contient aujourd'hui des **price IDs de TEST** — invalides en live.
Il faut régénérer les prix live, sinon `stripe-create-checkout` renverra `prix_non_configuré`.

Une fois `STRIPE_SECRET_KEY` passée en `sk_live_` (étape 2), appeler la fonction
`stripe-setup-products` (auth super-admin requise) qui crée produits + prix dans Stripe
**et** met à jour la table `stripe_prices` :

```bash
curl -X POST \
  https://ozfkmlokovxigfnwjeuk.supabase.co/functions/v1/stripe-setup-products \
  -H "Authorization: Bearer <JWT_SUPER_ADMIN>" \
  -H "Content-Type: application/json"
```

- [ ] Vérifier en base que les `stripe_price_id` commencent bien par un prix **live** et `active = true` :

```sql
select plan, cycle, stripe_price_id, amount_cents, active from stripe_prices order by plan, cycle;
```

Tarifs attendus (HT) : Indépendant 69 €/mois · Starter 160 €/1 600 € · Pro 260 €/2 600 € · Expert 360 €/3 600 €.

---

## 4. Créer le Webhook LIVE

Dashboard Stripe (mode **live**) → **Developers → Webhooks → Add endpoint** :

- [ ] **Endpoint URL** :
  `https://ozfkmlokovxigfnwjeuk.supabase.co/functions/v1/stripe-webhook`
- [ ] **Events à écouter** (exactement ceux gérés par la fonction) :
  - `checkout.session.completed`  → crée le centre + envoie l'email
  - `customer.subscription.updated` → met à jour statut/expiration
  - `customer.subscription.deleted` → passe le centre en `expired`
  - `invoice.payment_failed` → suspend le centre + alerte monitoring
- [ ] Copier le **Signing secret** `whsec_…` → le mettre dans `STRIPE_WEBHOOK_SECRET` (étape 2)

---

## 5. Déployer les pages vitrines sur le bon domaine

Les URLs de retour Checkout sont construites à partir de l'origine appelante, donc les pages
doivent exister à la racine du domaine vitrine **`mib-prevention.fr`** :
- [ ] `pricing.html` (depuis `vitrine/pricing.html`)
- [ ] `paiement-succes.html` (depuis `vitrine/paiement-succes.html`) — cible de `success_url`
- [ ] `paiement-annule.html` (depuis `vitrine/paiement-annule.html`) — cible de `cancel_url`

> Le CORS de `stripe-create-checkout` autorise déjà `mib-prevention.fr`, `app.mib-prevention.fr`,
> `localhost` et les préviews Vercel `mib-platform-ssiap*`. Si la vitrine est servie depuis un
> **autre domaine**, il faut l'ajouter à `isOriginAllowed()` dans la fonction.

---

## 6. Test end-to-end en LIVE

- [ ] Ouvrir `https://mib-prevention.fr/pricing.html`
- [ ] Choisir un plan → saisir email + nom → **Continuer**
- [ ] Régler avec une **vraie carte** (le `4242` ne marche qu'en test) — prendre le plan le moins cher (Indépendant 69 €) pour limiter
- [ ] Vérifier la redirection vers `paiement-succes.html`
- [ ] Vérifier la **réception de l'email** de bienvenue (clé licence + lien mot de passe)
- [ ] Vérifier le centre créé `active` dans l'admin
- [ ] **Rembourser** le paiement test depuis Stripe (Payments → Refund)
- [ ] Contrôler la table `stripe_events` : event `done`, `livemode = true`

---

## 7. Points de vigilance

- **TVA** : les prix sont en **HT** mais Checkout facture le montant tel quel (pas de TVA ajoutée
  automatiquement). Si tu dois collecter la TVA → activer **Stripe Tax** ou créer des prix TTC.
- **Plan Entreprise / Démo** : volontairement hors Stripe (devis / essai gratuit) — pas d'action.
- **Idempotence** : déjà gérée via la table `stripe_events` (rejoue sans doublon).
- **Rollback** : pour revenir en test, remettre `sk_test_` + `whsec_` de test et réactiver les
  price IDs de test dans `stripe_prices`.
