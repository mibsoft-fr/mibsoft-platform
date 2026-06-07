# Phase 7 — Intégration Stripe complète ✅

## État final (12/05/2026)

Tout est en production sur Supabase. Le flow bout-en-bout fonctionne :
**vitrine → checkout Stripe → webhook → centre créé en DB → email Mailgun → activation par lien magique → connexion sur l'app**.

## Edge Functions déployées

| Function | Auth | Rôle |
|---|---|---|
| `stripe-webhook` v4 | aucune (signature Stripe) | Reçoit events Stripe → provisionne centre + envoie email |
| `stripe-create-checkout` v5 | aucune (CORS strict) | Appelée depuis vitrine/app → crée session Checkout Stripe |
| `stripe-setup-products` v3 | JWT super-admin | Crée/met à jour les produits + prices Stripe d'un coup |
| `mailgun-test` v1 | aucune | Diagnostic config Mailgun (envoi test + détail erreur) |
| `resend-welcome` v1 | JWT super-admin | Renvoie un email de bienvenue à un centre existant (cas perte du mail initial) |

## Tables DB

- `stripe_prices` (plan, cycle, stripe_price_id, amount_cents) — RLS super-admin
- `stripe_events` (id, event_type, status, error_message) — idempotence webhook

## Secrets Supabase Edge Functions (configurés)

- `STRIPE_SECRET_KEY` (mode test sk_test_...)
- `STRIPE_WEBHOOK_SECRET` (whsec_...)
- `MAILGUN_API_KEY` (Private API Key)
- `MAILGUN_DOMAIN` = `mibsoft.fr`
- `MAILGUN_HOST` = `api.eu.mailgun.net` (compte Mailgun EU)
- `APP_URL`, `VITRINE_URL` selon environnement

## Prix configurés (mode test)

| Plan | Mensuel | Annuel | Quotas formateurs/stagiaires |
|---|---|---|---|
| Indépendant | 69 € HT | — | 1 / 30 (license_type=formateur) |
| Starter | 160 € HT | 1 600 € HT | 3 / 30 |
| Pro | 260 € HT | 2 600 € HT | 10 / 100 |
| Expert | 360 € HT | 3 600 € HT | 20 / 200 |
| Entreprise | sur devis (pas de Stripe) | — | illimité |
| Demo | gratuit 14j (pas de Stripe) | — | 1 / 5 |

## Pages HTML

Dans le repo (app Vercel) :
- `pricing.html` — page tarifs avec toggle Mensuel/Annuel, 5 plans, modal email+nom, appel `stripe-create-checkout`
- `paiement-succes.html` — page de retour post-paiement (instructions email)
- `paiement-annule.html` — page de retour si abandon

Versions standalone (`vitrine/`) pour copier-coller sur `mibsoft.fr` :
- `vitrine/pricing.html` (inline les constantes Supabase, sans dépendance supabase.js)
- `vitrine/paiement-succes.html`
- `vitrine/paiement-annule.html`

## Test end-to-end validé

1. ✅ pricing.html chargée sur preview Vercel
2. ✅ Choix plan Indépendant → modal → continuer
3. ✅ Redirection Stripe Checkout
4. ✅ Carte test 4242 acceptée
5. ✅ Retour sur paiement-succes.html
6. ✅ Webhook reçu (event_type=checkout.session.completed, status=done)
7. ✅ Centre créé en DB (license_status=active, password_set=false)
8. ✅ Profile JWT créé (role=formateur pour indépendant)
9. ✅ Email Mailgun envoyé avec lien magique
10. ✅ Lien magique → définition mot de passe → connexion

## À faire encore (suite Phase 7)

1. **Adapter `admin-create-centre`** pour le flow virement bancaire :
   - Remplacer le mot de passe en clair par un lien d'invitation magique (même mécanisme que Stripe)
   - Le centre reçoit l'email Mailgun avec lien magique au lieu d'un mot de passe initial
   - Plus sécurisé et cohérent

2. **Bascule mode LIVE** quand prêt :
   - Récupérer `sk_live_...` et nouveau `whsec_...` mode live
   - Remplacer `STRIPE_SECRET_KEY` et `STRIPE_WEBHOOK_SECRET`
   - Recréer les produits Stripe en mode live (re-run `stripe-setup-products`)
   - Vérifier `mibsoft.fr` configuré dans Mailgun avec SPF/DKIM corrects

3. **Déploiement vitrine** : copier `vitrine/pricing.html`, `vitrine/paiement-succes.html`, `vitrine/paiement-annule.html` sur `mibsoft.fr`

4. **Admin UI Phase 7c** (optionnel) : onglet "Tarifs Stripe" pour modifier les prix sans console + onglet "Paiements" pour voir les events Stripe récents

## Diagnostic / debug

- Logs webhook : table `stripe_events` (status `done` / `error` / `ignored`)
- Logs Mailgun : Mailgun Dashboard → Sending → Logs
- Logs Edge Functions : Supabase Dashboard → Edge Functions → Logs
- Renvoyer un email perdu : appeler `resend-welcome` depuis admin console

## Cartes de test Stripe utiles

| Scénario | Numéro |
|---|---|
| Succès | 4242 4242 4242 4242 |
| 3D Secure requis | 4000 0027 6000 3184 |
| Refus générique | 4000 0000 0000 0002 |
| Fonds insuffisants | 4000 0000 0000 9995 |
| Carte expirée | 4000 0000 0000 0069 |

Date d'expiration : n'importe quelle date future. CVC : n'importe quel nombre à 3 chiffres.
