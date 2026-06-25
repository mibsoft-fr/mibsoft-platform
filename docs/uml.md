# MIBsoft SSIAP — Diagrammes UML

> Généré depuis le schéma réel de la base (clés étrangères). Les fichiers `.md` Mermaid se
> visualisent directement sur GitHub, dans VS Code (extension Mermaid) ou sur https://mermaid.live.

---

## 1. Diagramme de classes / entités (modèle de données)

```mermaid
erDiagram
    %% ───────── Comptes & licences ─────────
    centers ||--o{ profiles            : "profil auth"
    centers ||--o{ formateurs          : "emploie"
    centers ||--o{ stagiaires          : "inscrit"
    centers ||--o{ avis_retours        : "reçoit"

    %% ───────── Formation ─────────
    centers ||--o{ sessions_formation       : "organise"
    formateurs ||--o{ sessions_formation     : "anime"
    sessions_formation ||--o{ session_participants : "réunit"
    stagiaires ||--o{ session_participants    : "participe"

    %% ───────── Auto-entraînement ─────────
    centers ||--o{ entrainement_sessions      : ""
    stagiaires ||--o{ entrainement_sessions   : "s'entraîne"
    entrainement_sessions ||--o{ entrainement_reponses : "détail"

    %% ───────── Quiz Salle ─────────
    centers ||--o{ quiz_salle_sessions        : ""
    formateurs ||--o{ quiz_salle_sessions     : "lance"
    quiz_salle_sessions ||--o{ quiz_salle_participants : ""
    stagiaires ||--o{ quiz_salle_participants  : ""
    quiz_salle_sessions ||--o{ quiz_salle_reponses     : ""
    quiz_salle_participants ||--o{ quiz_salle_reponses : ""
    questions ||--o{ quiz_salle_reponses       : ""

    %% ───────── Challenge Cup (banque + jeu) ─────────
    cc_modules ||--o{ cc_questions             : "contient"
    cc_questions ||--o{ cc_question_options     : ""
    cc_questions ||--o{ cc_question_items       : ""
    cc_questions ||--o{ cc_question_pairs       : ""
    cc_questions ||--o{ cc_question_categories  : ""
    cc_questions ||--o{ cc_question_category_items : ""
    cc_questions ||--o{ cc_question_decision_steps : ""
    cc_sessions ||--o{ cc_teams                 : "équipes"
    cc_sessions ||--o{ cc_team_answers          : ""
    cc_teams ||--o{ cc_team_answers             : "répond"
    cc_questions ||--o{ cc_team_answers         : ""

    centers {
        uuid id PK
        text email
        text nom
        text plan "demo|apprenant|independant|starter|pro|expert"
        text license_type "centre|independant|apprenant|formateur"
        text license_status "active|suspended|expired"
        date license_expires_at
        text license_key
        text billing_cycle "mensuel|annuel|unique"
        int max_formateurs
        int max_stagiaires
        bool module_auto_entrainement
        bool module_quiz_salle
        bool module_challenge_cup
        bool module_ssi_autoformation
        uuid auth_user_id
        text stripe_customer_id
    }
    profiles {
        uuid user_id PK
        enum role "centre|formateur|stagiaire"
        uuid center_id FK
    }
    formateurs {
        uuid id PK
        uuid center_id FK
        text prenom
        text nom
        text niveau "SSIAP1|2|3"
        date date_dernier_recyclage
        text pin_hash
        text role "responsable|formateur"
        bool actif
    }
    stagiaires {
        uuid id PK
        uuid center_id FK
        text prenom
        text nom
        text niveau
        text pin_hash
        bool actif
    }
    sessions_formation {
        uuid id PK
        uuid center_id FK
        uuid formateur_id FK
        text type_formation "INI|REC|RAN"
        text niveau
        date date_debut
        date date_fin
        text statut
    }
    session_participants {
        uuid id PK
        uuid session_id FK
        uuid stagiaire_id FK
        bool presence
    }
    entrainement_sessions {
        uuid id PK
        uuid stagiaire_id FK
        uuid center_id FK
        text niveau
        int score
        int max_score
        text status
    }
    entrainement_reponses {
        uuid id PK
        uuid session_id FK
        text question_id
        jsonb reponse
        bool est_correcte
    }
    avis_retours {
        uuid id PK
        uuid center_id FK
        text auteur_type "stagiaire|centre"
        text auteur_nom
        int note "1..5"
        text message
        text statut
    }
    cc_questions {
        uuid id PK
        uuid module_id FK
        text type "quiz|true-false|sequence|matching|fill-blank|categories|decision|..."
        text question
        int correct_answer
        jsonb correct_answers
        jsonb correct_order
        jsonb correct_blanks
    }
    cc_team_answers {
        uuid id PK
        uuid session_id FK
        text team_id
        text question_id
        bool is_correct
    }
```

---

## 2. Diagramme de composants (espaces & flux)

```mermaid
flowchart TD
    Stripe[["💳 Stripe Checkout"]] -->|webhook| WH{{"edge: stripe-webhook"}}
    WH -->|crée| C[("centers\n(centre / indépendant / apprenant)")]
    Vitrine["🌐 Vitrine — pricing.html"] -->|edge: stripe-create-checkout| Stripe

    C --> ADM["🛠️ Admin — admin.html\n(synthèse, licences, monitoring)"]

    subgraph Espaces["Espaces utilisateurs"]
      CE["🏫 Centre — center.html"]
      IN["🧑‍🏫 Indépendant — center.html (mode)\nlogin-independant.html"]
      AP["🎓 Apprenant — apprenant.html\nlogin-apprenant.html"]
      FO["👨‍🏫 Formateur — formateur.html (PIN)"]
      ST["👨‍🎓 Stagiaire — stagiaire.html (PIN/QR)"]
    end

    C --> CE
    C --> IN
    C --> AP
    CE --> FO
    CE --> ST
    IN --> ST

    subgraph Modules["Modules d'entraînement"]
      AE["🎯 Auto-entraînement\n(QCM + Multi-jeux)"]
      QS["📡 Quiz Salle"]
      CC["🏆 Challenge Cup\n(challenge-cup-ssiap)"]
    end

    AP --> AE
    ST --> AE
    ST --> QS
    IN -->|lance| CC
    FO -->|lance| QS
    FO -->|lance| CC

    AE -->|résultats| DB[("Supabase\nentrainement_* / cc_* / quiz_salle_*")]
    QS --> DB
    CC --> DB
    DB -->|stats + erreurs| IN
    ST -->|avis| AV[("avis_retours")]
    AV --> IN
    AV --> ADM
```

---

## 3. Cycle de vie d'une licence (états)

```mermaid
stateDiagram-v2
    [*] --> active : paiement validé (webhook)
    active --> active : prolonger / renouveler
    active --> suspended : paiement échoué (invoice.payment_failed)
    suspended --> active : régularisation
    active --> expired : date dépassée / abonnement supprimé
    suspended --> expired
    expired --> active : rachat / nouvelle licence
    expired --> [*]
```

---

## 4. Diagramme de séquence — Achat & activation (Stripe)

```mermaid
sequenceDiagram
    actor U as Acheteur
    participant V as Vitrine (pricing.html)
    participant CK as edge: stripe-create-checkout
    participant S as Stripe
    participant WH as edge: stripe-webhook
    participant DB as Supabase
    participant MG as Mailgun

    U->>V: Choisit un plan (apprenant / indépendant / centre)
    V->>CK: POST {plan, email, nom}
    CK->>DB: lit stripe_prices (price_id)
    CK->>S: crée Checkout Session (subscription | payment)
    S-->>U: page de paiement
    U->>S: paie (carte)
    S->>WH: webhook checkout.session.completed
    WH->>DB: crée centers (+ quotas, modules, license_key)
    WH->>DB: crée auth user + profile
    WH->>S: (génère le lien de récupération)
    WH->>MG: email de bienvenue (+ lien « définir mot de passe »)
    MG-->>U: email reçu
    U->>U: définit son mot de passe → accède à son espace
```

---

## 5. Diagramme de séquence — Déroulé d'un Challenge Cup

```mermaid
sequenceDiagram
    actor F as Indépendant / Formateur
    participant CE as center.html / formateur.html
    participant CC as challenge-cup-ssiap
    participant DB as Supabase (cc_*)
    actor S as Stagiaires

    F->>CE: « Lancer Challenge salle » (groupe | individuel)
    CE->>CC: ouvre + dépose mib_cc_auth {session, formateur, stagiaires?}
    CC->>DB: crée cc_session (+ équipes nominatives si invitation)
    CC-->>S: QR / invitation pour rejoindre
    S->>CC: rejoignent (cc_teams)
    loop Pour chaque question
        F->>CC: lance la question
        S->>CC: répondent
        CC->>DB: enregistre cc_team_answers (is_correct)
        CC-->>F: « X/Y équipes ont répondu » + correction
    end
    CC->>DB: podium + RPC cc_bridge_to_entrainement
    DB->>DB: réplique les erreurs → entrainement_sessions / reponses
    F->>CE: « Résultats & questions échouées » (stats par session)
    F->>CE: « Reprendre les erreurs » → relance un Challenge de remédiation
```

