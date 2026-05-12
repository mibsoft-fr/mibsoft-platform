---
name: mib-design-system
description: Apply the MIB "Vigil" design system to any HTML/CSS/JS project. Use when building UI for MIB Prévention apps (SSIAP, sécurité incendie) or any spin-off app of MIB. Provides design tokens (colors, typography, spacing) and component classes (.mib-btn, .mib-card, .mib-inp, .mib-modal, .mib-badge, etc.) with a green-blue gradient brand identity (vert sauvetage + bleu pompier). Always use the .mib-* classes instead of inventing new styles. Triggers when: user asks to style a new page, create a form, add a button, build a dashboard, or refactor an existing page to match brand.
---

# MIB Design System — "Vigil"

## Quand utiliser ce skill

Ce skill s'applique automatiquement quand :
- L'utilisateur travaille sur une app MIB Prévention ou un spin-off MIB
- L'utilisateur demande de styler un nouveau composant ou une nouvelle page
- L'utilisateur demande de "rendre responsive" ou "améliorer le design" d'une page
- L'utilisateur demande de créer un formulaire, un dashboard, une modal, une table

## Identité visuelle (Vigil — palette G)

**Métier** : sécurité incendie SSIAP en France. Le ton est **professionnel, rassurant, institutionnel moderne** — entre le service public (préfecture, sapeurs-pompiers) et le SaaS premium (Linear, Stripe).

**Palette** (référence : `design-tokens.css`)
- **Primary** : gradient vert→bleu `linear-gradient(135deg, #10B981 → #059669 → #2563EB)` — boutons d'action, logo, CTA principaux
- **Vert solide** `#059669` (`--vigil-600`) — fallback, success, badges
- **Bleu marine** `#1E3A8A` (`--marine-900`) — sidebar, accent secondaire
- **Warning orange** `#D97706` (`--warning-600`) — bouton "Alerter", recyclage à venir
- **Danger rouge** `#DC2626` (`--danger-600`) — supprimer, expiré, erreur critique
- **Background page** `#F8FAFC` (`--neutral-50`)
- **Texte titre** `#0F172A` (`--text-1`)

**Typographie**
- Titres : `Plus Jakarta Sans` (700-800) avec `letter-spacing: -0.02em`
- Texte : `Inter` (400-600)
- Mono : `JetBrains Mono`

## Comment l'utiliser

### 1. Inclure les CSS dans toute nouvelle page HTML

```html
<head>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="design-tokens.css">
  <link rel="stylesheet" href="mib-design.css">
</head>
```

### 2. Utiliser les classes `.mib-*` (préfixées pour éviter conflits)

**Boutons**
- `.mib-btn .mib-btn-primary` — action principale (gradient vert→bleu)
- `.mib-btn .mib-btn-secondary` — action neutre (navy)
- `.mib-btn .mib-btn-warning` — "Alerter", "Avertir"
- `.mib-btn .mib-btn-danger` — "Supprimer", action irréversible
- `.mib-btn .mib-btn-ghost` — "Annuler", action mineure
- `.mib-btn .mib-btn-outline` — action secondaire de marque
- Tailles : ajouter `.mib-btn-sm` ou `.mib-btn-lg`. **Sur mobile, utiliser `.mib-btn-lg` (hit-target 48px)**.
- Bloc plein largeur : `.mib-btn-block`

**Inputs**
- `.mib-label` (avant input)
- `.mib-inp` (text/email/password/search/etc.)
- `.mib-select` (avec chevron auto)
- `.mib-textarea`
- État erreur : ajouter `.is-error` sur l'input + `.mib-help.is-error` pour le message
- Helper : `.mib-help`

**Cards**
- `.mib-card` (défaut, avec ombre légère)
- `.mib-card-elevated` (ombre forte)
- `.mib-card-bordered` (bordure, sans ombre)
- `.mib-card-interactive` (hover lift, pour cards cliquables)
- Titre interne : `.mib-card-title`

**Badges**
- `.mib-badge .mib-badge-success` (vert)
- `.mib-badge .mib-badge-warning` (orange)
- `.mib-badge .mib-badge-danger` (rouge)
- `.mib-badge .mib-badge-info` (bleu)
- `.mib-badge .mib-badge-neutral` (gris)
- `.mib-badge .mib-badge-brand` (vert clair, marque)

**Alertes**
- `.mib-alert .mib-alert-success` / `-warning` / `-danger` / `-info`

**Modals**
- Wrapper : `.mib-modal-backdrop`
- Contenu : `.mib-modal` (devient bottom-sheet sur mobile auto)

**KPI**
- `.mib-kpi` (carte) avec `.mib-kpi-label`, `.mib-kpi-value`, `.mib-kpi-delta.is-positive` ou `.is-negative`

**Tables**
- `.mib-table` (stylée avec header sticky-friendly)
- En responsive < md, transformer en cards stackées (à coder par page)

**Logo**
- `.mib-logo` (texte avec dégradé brand)

**Spinner**
- `.mib-spinner` (cercle 20px, anim 0.8s)

### 3. Utilities responsive

- Hide/show : `.mib-hide-mobile`, `.mib-only-mobile`, `.mib-hide-tablet`, `.mib-only-tablet`
- Safe areas iOS : `.mib-safe-top`, `.mib-safe-bottom`

### 4. Variables CSS à utiliser dans les styles spécifiques

Ne jamais hard-coder de couleur ou taille. Toujours utiliser les variables :
- Couleurs : `var(--vigil-600)`, `var(--text-1)`, `var(--bg-page)`, etc.
- Espaces : `var(--space-4)` (16px), `var(--space-6)` (24px), etc.
- Radius : `var(--radius-md)` (10px), `var(--radius-lg)` (14px)
- Shadows : `var(--shadow-sm)`, `var(--shadow-md)`, `var(--shadow-lg)`, `var(--shadow-brand)`
- Fonts : `var(--font-display)`, `var(--font-body)`
- Tailles : `var(--text-base)`, `var(--text-xl)`, etc.

### 5. Responsive (mobile-first)

Breakpoints : `sm 640`, `md 768`, `lg 1024`, `xl 1280`.

**Adapter par profil utilisateur** :
- **Stagiaire** = mobile-first (smartphone), bottom-nav, 1 colonne, gros CTA `.mib-btn-lg`
- **Formateur** = touch-first (tablette + smartphone terrain), hit-targets 48px+, contrastes forts
- **Centre admin** = desktop+tablette, sidebar fixe desktop / drawer mobile
- **Super-admin** = desktop, densité haute, sidebar fixe

### 6. Iconographie

Préférer **Lucide Icons** (https://lucide.dev) en SVG inline. Éviter les emoji dans une app métier réglementée.
Les emoji existants peuvent être conservés transitoirement le temps de la migration.

## Règles à respecter

1. **Toujours** inclure `design-tokens.css` AVANT `mib-design.css`.
2. **Toujours** préfixer les classes du DS par `.mib-*` (pour cohabiter avec l'ancien CSS pendant la migration).
3. **Ne jamais** hard-coder de couleur — utiliser les variables CSS.
4. **Ne jamais** utiliser `outline: none` sans alternative `:focus-visible` (accessibilité WCAG).
5. **Toujours** tester en mobile (375px) + tablette (768px) + desktop (1280px).
6. Gradient brand = uniquement pour CTA principaux et logo. Ne pas surutiliser sinon perd son impact.
7. Orange = warning, jamais branding. Rouge = danger uniquement, jamais décoratif.

## Pour démarrer un nouveau projet MIB

1. Copier `design-tokens.css` + `mib-design.css` à la racine du projet
2. Copier ce dossier `.claude/skills/mib-design-system/` dans le nouveau projet
3. Charger les fonts dans le `<head>` de chaque page
4. Inclure les 2 CSS dans chaque page
5. Utiliser exclusivement les classes `.mib-*`

## Inspirations du design

- Linear (densité+élégance) · Stripe Dashboard (data) · Vercel (ombres premium) · Doctolib Pro (cible métier proche)
