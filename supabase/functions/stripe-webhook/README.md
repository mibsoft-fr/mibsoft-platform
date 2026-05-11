# Phase 7 — Intégration Stripe + paiements virement

## État au moment de la pause (session 11/05/2026 matin)

### ✅ Phase 7a — Déployé en DB et Supabase

**Migration `phase7a_stripe_foundation`** :
- Table `stripe_prices` (mapping plan/cycle ↔ Stripe Price ID) avec RLS super-admin
- Table `stripe_events` (idempotence webhook + audit)
- Trigger `updated_at` automatique

**Edge Function `stripe-webhook`** (déployée v1, code dans `supabase/functions/stripe-webhook/index.ts`) :
- Signature Stripe vérifiée
- Idempotence via `stripe_events`
- Events traités :
  - `checkout.session.completed` → crée auth.users + centre + envoie email invitation Resend
  - `customer.subscription.updated` → met à jour expiration / statut
  - `customer.subscription.deleted` → statut expired
  - `invoice.payment_failed` → suspend + alerte monitoring

### À faire ce soir

#### 1. Configuration Supabase (secrets Edge Functions)

À ajouter dans Project Settings → Edge Functions → Secrets :
- `STRIPE_SECRET_KEY` = `sk_test_...` (clé secrète Stripe, mode test au début)
- `STRIPE_WEBHOOK_SECRET` = `whsec_...` (à créer dans Stripe Dashboard → Webhooks)
- `RESEND_API_KEY` = `re_...` (déjà demandé pour le monitoring)
- `RESEND_FROM` = `MIB Prévention <onboarding@resend.dev>` ou domaine vérifié
- `APP_URL` = `http://localhost:8000` (dev) ou `https://app.mib-prevention.fr`

#### 2. Configuration Stripe Dashboard

- Créer le webhook endpoint pointant vers `https://ozfkmlokovxigfnwjeuk.supabase.co/functions/v1/stripe-webhook`
- Sélectionner les événements :
  - `checkout.session.completed`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.payment_failed`
- Copier le `whsec_...` dans `STRIPE_WEBHOOK_SECRET`
- Créer un produit + price par plan × cycle (5 plans × 2 cycles = 10 prices)
- Pour chaque price : insérer dans `stripe_prices` via admin MIB

#### 3. Phase 7b — Edge Function create-checkout + snippet site vitrine

- Edge Function `stripe-create-checkout` qui :
  - Reçoit `{plan, cycle, email?, nom_centre?}`
  - Lit le `stripe_price_id` depuis `stripe_prices`
  - Crée une session Stripe Checkout
  - Retourne `{url}` à rediriger
- Snippet HTML/JS pour `mib-prevention.fr` (site vitrine) avec sélecteur de plan
- Page success/cancel à héberger sur le site vitrine

#### 4. Phase 7c — Admin

- Onglet "Tarifs Stripe" dans admin pour gérer `stripe_prices`
- Onglet "Paiements" pour voir les `stripe_events` récents + paiements échoués

#### 5. Paiements par virement (pas de Stripe)

**Décision Michel** : centres qui paient par virement → création manuelle depuis l'admin.

À adapter dans `admin-create-centre` Edge Function :
- Remplacer la création avec mot de passe en clair par un **lien d'invitation magique** (même mécanisme que dans `stripe-webhook`)
- Le centre reçoit un email Resend identique à celui Stripe (mais déclenché par admin)
- Le modal "Nouveau centre" perd le champ "Mot de passe initial" (devient inutile)
- Ajouter un champ "Motif" : `virement_paye` / `essai` / `demo` etc.

#### 6. Tests

- Mode test Stripe : carte `4242 4242 4242 4242` + n'importe quelle date future + CVC quelconque
- Vérifier dans Stripe Dashboard → Events que le webhook reçoit bien
- Vérifier dans `stripe_events` que l'événement est marqué `done`
- Vérifier dans `centers` que le centre a été créé avec les bons paramètres
- Vérifier que l'email d'invitation arrive bien (vérifier les spams)

## Sécurité / dette technique

- ✅ Signature webhook Stripe vérifiée (anti-spoofing)
- ✅ Idempotence (un même `event.id` ne sera pas traité 2x)
- ⚠️ Rate limiting : pas implémenté (Stripe le gère côté leur)
- ⚠️ Le centre créé via Stripe a `password_set: false` — vérifier que le flow `login-centre.html` accepte bien ce cas (avec le lien magique)

## Architecture finale (à termes)

```
mib-prevention.fr (vitrine)              Edge Functions                       Email Resend
─────────────────────────                ──────────────                       ────────────
Page Tarifs → btn "Pro" ──POST──→ stripe-create-checkout
                                          │
                                          └─ retourne URL Stripe Checkout
Browser ──redirige──→ Stripe Checkout (carte) 
                                          │
                                          └─ paiement OK
                                          │
                                    stripe-webhook ← événement Stripe
                                          │
                                          ├─ Crée auth.users + centre + licence
                                          ├─ generateLink type=recovery
                                          ├─ ────────────────────────────── → Email invitation au centre
                                          │
                                  ←─ Centre reçoit email + clic
                                                                              
                                                                              Centre arrive sur login-centre.html
                                                                              avec une session de recovery
                                                                              → définit son mot de passe
                                                                              → connexion sur center.html

Virement bancaire :
Michel reçoit virement → Admin → "Nouveau centre" → admin-create-centre
                                          │ (similaire au flow Stripe mais sans paiement automatique)
                                          ├─ Crée auth.users + centre + licence
                                          ├─ generateLink type=recovery
                                          ├─ ────────────────────────────── → Email invitation au centre
```
