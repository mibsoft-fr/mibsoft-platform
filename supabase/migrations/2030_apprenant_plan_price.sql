-- ============================================================
-- Plan « Apprenant » — licence individuelle, PAIEMENT UNIQUE (1 mois d'accès)
-- ============================================================
-- Le checkout (stripe-create-checkout) cherche le prix dans stripe_prices
-- avec (plan='apprenant', cycle='unique', active=true), puis crée une
-- session Stripe en mode 'payment' (et non 'subscription').
--
-- ⚠️ ÉTAPE MANUELLE REQUISE avant activation :
--   1. Créer dans le Dashboard Stripe un PRIX UNIQUE (one-time) de 10,00 €
--      (produit « MIB SSIAP — Accès Apprenant »).
--   2. Copier l'identifiant du prix (price_xxx) ci-dessous.
--   3. Repasser active=true (UPDATE en bas).
--
-- Tant que active=false, le plan répond proprement « prix_non_configuré »
-- côté checkout et n'est donc pas vendable par erreur.

insert into public.stripe_prices (plan, cycle, amount_cents, active, stripe_price_id)
select 'apprenant', 'unique', 1000, false, 'price_REMPLACER_PAR_LE_PRIX_STRIPE'
where not exists (
  select 1 from public.stripe_prices where plan = 'apprenant' and cycle = 'unique'
);

-- Une fois le vrai price_id Stripe créé, exécuter :
-- update public.stripe_prices
--   set stripe_price_id = 'price_xxxxx', amount_cents = 1000, active = true
--   where plan = 'apprenant' and cycle = 'unique';
