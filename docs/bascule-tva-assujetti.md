# Bascule TVA — franchise → assujetti

**État actuel** : société en cours de création, **pas encore de numéro de TVA**. MIBsoft est donc
en **franchise en base de TVA** (art. 293 B du CGI) : aucune TVA n'est facturée ni collectée.
`pricing.html` et `legal/cgv.html` (Article 5) reflètent ce régime.

> ⚠️ Tant que le numéro de TVA intracommunautaire n'est pas actif, **ne pas** activer la collecte
> de TVA dans Stripe : facturer de la TVA sans être assujetti est irrégulier.

## À faire le jour où le numéro de TVA est reçu

### 1. Textes (repo)
- **`pricing.html`** (footer) : remplacer
  `Prix en euros nets de taxes. TVA non applicable, article 293 B du CGI …`
  par `Prix indiqués en euros hors taxes (HT). TVA en sus au taux en vigueur (20 %).`
- **`legal/cgv.html`** (Article 5) : remplacer la clause franchise par la clause assujetti
  (prix HT ; la TVA au taux en vigueur s'ajoute ; auto-liquidation intra-UE art. 196 directive TVA).
- **Mentions légales** (`legal/mentions-legales.html`) : ajouter le **numéro de TVA intracommunautaire**
  (et le n° SIREN/RCS de la société une fois immatriculée).

### 2. Stripe — faire réellement collecter les 20 %
Sans ça, on afficherait « HT » mais on encaisserait le montant sans TVA => TVA à reverser de sa poche.
Deux approches (choisir) :

- **Option A — Stripe Tax (recommandé)** : activer Stripe Tax, renseigner l'immatriculation TVA FR,
  définir le *tax code* des produits, mettre les prix en `tax_behavior = exclusive` (HT), puis
  activer `automatic_tax: { enabled: true }` dans `stripe-create-checkout` + collecte de l'adresse
  client. Gère l'auto-liquidation intra-UE automatiquement (cohérent avec la CGV).
- **Option B — taux manuel 20 %** : créer un tax rate 20 % dans Stripe et l'attacher aux lignes du
  Checkout dans `stripe-create-checkout`. Plus simple, mais ne gère pas l'auto-liquidation intra-UE.

> Vérifier si les `price_id` LIVE existants sont bien des montants **HT** ; sinon recréer les prix.

### 3. Vérification
- Achat de test (mode live, petit montant ou coupon) → la TVA 20 % apparaît bien au checkout et sur la facture.
- Facture Stripe : mentionne le numéro de TVA et le taux appliqué.
