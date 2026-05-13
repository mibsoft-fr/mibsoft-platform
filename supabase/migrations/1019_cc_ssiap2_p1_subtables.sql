-- SSIAP 2 — Partie 1 « Approfondissement — Le feu »
-- Sub-tables (options / items / pairs / categories / decision steps)
-- for the 26 hand-crafted challenge cc_questions ssiap2-hc-p1-q1..q26.
-- Aligned with the existing cc_questions.explanation and correct_* values.
begin;

insert into public.cc_question_options (question_id, option_index, option_text) values
-- q1 quiz : facteur de propagation (correct=1 → charge calorifique)
('ssiap2-hc-p1-q1', 0, 'La couleur des murs'),
('ssiap2-hc-p1-q1', 1, 'La charge calorifique (quantité et nature des combustibles)'),
('ssiap2-hc-p1-q1', 2, 'La marque des extincteurs'),
('ssiap2-hc-p1-q1', 3, 'L''orientation du bâtiment'),
-- q2 quiz : PCI bois sec (correct=1 → ~17 MJ/kg)
('ssiap2-hc-p1-q2', 0, '~5 MJ/kg'),
('ssiap2-hc-p1-q2', 1, '~17 MJ/kg'),
('ssiap2-hc-p1-q2', 2, '~46 MJ/kg'),
('ssiap2-hc-p1-q2', 3, '~120 MJ/kg'),
-- q3 quiz : mélange explosif (correct=1 → entre LIE et LSE)
('ssiap2-hc-p1-q3', 0, 'En dessous de la LIE'),
('ssiap2-hc-p1-q3', 1, 'Entre la LIE et la LSE'),
('ssiap2-hc-p1-q3', 2, 'Au-dessus de la LSE'),
('ssiap2-hc-p1-q3', 3, 'Sous pression élevée uniquement'),
-- q4 quiz : BLEVE (correct=1)
('ssiap2-hc-p1-q4', 0, 'Une technique d''extinction par mousse'),
('ssiap2-hc-p1-q4', 1, 'L''explosion d''un récipient sous pression contenant un gaz liquéfié chauffé au-delà de son ébullition'),
('ssiap2-hc-p1-q4', 2, 'Un type de désenfumage naturel'),
('ssiap2-hc-p1-q4', 3, 'Une norme NF de classement au feu'),
-- q5 true-false : backdraft à la naissance (correct=1 Faux)
('ssiap2-hc-p1-q5', 0, 'Vrai'),
('ssiap2-hc-p1-q5', 1, 'Faux'),
-- q6 true-false : roll-over prélude au flashover (correct=0 Vrai)
('ssiap2-hc-p1-q6', 0, 'Vrai'),
('ssiap2-hc-p1-q6', 1, 'Faux'),
-- q7 true-false : inertage azote en salle serveur (correct=0 Vrai)
('ssiap2-hc-p1-q7', 0, 'Vrai'),
('ssiap2-hc-p1-q7', 1, 'Faux'),
-- q8 multi-select : phénomènes en local fermé (correct=[0,1,2,3])
('ssiap2-hc-p1-q8', 0, 'Roll-over (vague de flammes au plafond)'),
('ssiap2-hc-p1-q8', 1, 'Flashover (embrasement généralisé)'),
('ssiap2-hc-p1-q8', 2, 'Backdraft (explosion de fumées)'),
('ssiap2-hc-p1-q8', 3, 'Boilover (huile chaude + eau)'),
('ssiap2-hc-p1-q8', 4, 'Sublimation'),
-- q9 multi-select : effets toxiques fumées (correct=[0,1,2,3])
('ssiap2-hc-p1-q9', 0, 'Asphyxie par CO et HCN'),
('ssiap2-hc-p1-q9', 1, 'Irritation respiratoire (HCl, SO2)'),
('ssiap2-hc-p1-q9', 2, 'Opacité — perte de visibilité'),
('ssiap2-hc-p1-q9', 3, 'Hyperthermie par inhalation des gaz chauds'),
('ssiap2-hc-p1-q9', 4, 'Risque de chute de hauteur'),
-- q10 multi-select : modes d'extinction (correct=[0,1,2,3])
('ssiap2-hc-p1-q10', 0, 'Étouffement (privation d''oxygène)'),
('ssiap2-hc-p1-q10', 1, 'Refroidissement (eau)'),
('ssiap2-hc-p1-q10', 2, 'Inhibition (rupture de la réaction en chaîne — poudre ABC)'),
('ssiap2-hc-p1-q10', 3, 'Isolement du combustible (couper le gaz)'),
('ssiap2-hc-p1-q10', 4, 'Sublimation'),
-- q11 find-intruder : pas un phénomène thermique (correct=2 → Sublimation)
('ssiap2-hc-p1-q11', 0, 'Flashover'),
('ssiap2-hc-p1-q11', 1, 'Backdraft'),
('ssiap2-hc-p1-q11', 2, 'Sublimation'),
('ssiap2-hc-p1-q11', 3, 'Roll-over'),
-- q12 find-intruder : pas un combustible classe B (correct=2 → Bois)
('ssiap2-hc-p1-q12', 0, 'Essence'),
('ssiap2-hc-p1-q12', 1, 'Acétone'),
('ssiap2-hc-p1-q12', 2, 'Bois sec'),
('ssiap2-hc-p1-q12', 3, 'Peinture / solvant'),
-- q13 scenario : inhalation fumée stagiaire (correct=1)
('ssiap2-hc-p1-q13', 0, 'Le faire boire et le renvoyer terminer l''exercice'),
('ssiap2-hc-p1-q13', 1, 'Évacuer à l''air libre, oxygénothérapie si disponible, alerter le SAMU 15, surveillance prolongée'),
('ssiap2-hc-p1-q13', 2, 'Lui faire fumer une cigarette pour « ouvrir les bronches »'),
('ssiap2-hc-p1-q13', 3, 'Attendre la fin de l''exercice avant d''agir'),
-- q14 scenario : bouteille gaz au feu BLEVE (correct=1)
('ssiap2-hc-p1-q14', 0, 'S''approcher pour fermer la vanne manuellement'),
('ssiap2-hc-p1-q14', 1, 'Établir une zone d''exclusion 100 m, refroidir à distance à l''eau pulvérisée, alerter les pompiers'),
('ssiap2-hc-p1-q14', 2, 'Couvrir la bouteille d''une couverture humide'),
('ssiap2-hc-p1-q14', 3, 'Attendre que la soupape se calme d''elle-même'),
-- q15 image-identify : risque électrique W012 (correct=1)
('ssiap2-hc-p1-q15', 0, 'Un risque biologique'),
('ssiap2-hc-p1-q15', 1, 'Un risque électrique (W012)'),
('ssiap2-hc-p1-q15', 2, 'Un risque chimique'),
('ssiap2-hc-p1-q15', 3, 'Un risque de chute de plain-pied'),
-- q16 image-identify : extincteur F001 (correct=1)
('ssiap2-hc-p1-q16', 0, 'Un local fermé à clé'),
('ssiap2-hc-p1-q16', 1, 'L''emplacement d''un extincteur portatif (F001)'),
('ssiap2-hc-p1-q16', 2, 'Le poste de sécurité incendie'),
('ssiap2-hc-p1-q16', 3, 'Une zone à risque chimique');

insert into public.cc_question_items (question_id, item_index, item_text) values
-- q17 sequence : phases incendie complet (order [0,1,2,3,4])
('ssiap2-hc-p1-q17', 0, 'Naissance / éclosion'),
('ssiap2-hc-p1-q17', 1, 'Développement (montée en puissance)'),
('ssiap2-hc-p1-q17', 2, 'Phase ventilation-limitante (étouffée)'),
('ssiap2-hc-p1-q17', 3, 'Flashover — embrasement généralisé'),
('ssiap2-hc-p1-q17', 4, 'Décrescence — épuisement du combustible'),
-- q18 sequence : réaction matériau (order [0,1,2,3,4])
('ssiap2-hc-p1-q18', 0, 'Échauffement progressif'),
('ssiap2-hc-p1-q18', 1, 'Pyrolyse — émission de gaz combustibles'),
('ssiap2-hc-p1-q18', 2, 'Inflammation des gaz'),
('ssiap2-hc-p1-q18', 3, 'Combustion vive avec flamme'),
('ssiap2-hc-p1-q18', 4, 'Carbonisation et résidu'),
-- q19 ranking : pouvoir calorifique (order [0,1,3,2] : H2 > Propane > Bois > Charbon humide)
('ssiap2-hc-p1-q19', 0, 'Hydrogène (~120 MJ/kg)'),
('ssiap2-hc-p1-q19', 1, 'Propane (~46 MJ/kg)'),
('ssiap2-hc-p1-q19', 2, 'Charbon de bois humide (~15 MJ/kg pratique)'),
('ssiap2-hc-p1-q19', 3, 'Bois sec (~17 MJ/kg)'),
-- q20 ranking : toxicité gaz combustion (order [0,1,2,3])
('ssiap2-hc-p1-q20', 0, 'HCN — acide cyanhydrique'),
('ssiap2-hc-p1-q20', 1, 'CO — monoxyde de carbone'),
('ssiap2-hc-p1-q20', 2, 'CO2 — dioxyde de carbone'),
('ssiap2-hc-p1-q20', 3, 'Vapeur d''eau');

insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values
-- q21 matching : phénomène ↔ description
('ssiap2-hc-p1-q21', 0, 'Flashover', 'Embrasement généralisé instantané (~500 °C)'),
('ssiap2-hc-p1-q21', 1, 'Backdraft', 'Explosion par apport d''air dans un local sous-ventilé'),
('ssiap2-hc-p1-q21', 2, 'Roll-over', 'Vague de flammes courant au plafond'),
('ssiap2-hc-p1-q21', 3, 'BLEVE', 'Explosion d''une bouteille de gaz liquéfié chauffée'),
-- q22 matching : mode d'extinction ↔ exemple
('ssiap2-hc-p1-q22', 0, 'Étouffement', 'Mousse AFFF sur hydrocarbure'),
('ssiap2-hc-p1-q22', 1, 'Refroidissement', 'Eau pulvérisée sur un feu de bois'),
('ssiap2-hc-p1-q22', 2, 'Inhibition', 'Poudre ABC (rupture de la réaction en chaîne)'),
('ssiap2-hc-p1-q22', 3, 'Isolement', 'Sable autour d''une flaque enflammée');

-- q25 categories : effet fumée vs chaleur
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values
('ssiap2-hc-p1-q25', 0, 'fumees', '💨 Fumées'),
('ssiap2-hc-p1-q25', 1, 'chaleur', '🔥 Chaleur');

insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values
('ssiap2-hc-p1-q25', 0, 'Asphyxie par CO', 'fumees'),
('ssiap2-hc-p1-q25', 1, 'Brûlure cutanée du 2e degré', 'chaleur'),
('ssiap2-hc-p1-q25', 2, 'Intoxication par HCN', 'fumees'),
('ssiap2-hc-p1-q25', 3, 'Hyperthermie / coup de chaleur', 'chaleur'),
('ssiap2-hc-p1-q25', 4, 'Opacité — perte de visibilité', 'fumees'),
('ssiap2-hc-p1-q25', 5, 'Effondrement structurel', 'chaleur');

-- q26 decision : risque BLEVE imminent (bouteille propane, public à 30 m)
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values
('ssiap2-hc-p1-q26', 0,
 'ÉTAPE 1 — Bouteille de propane qui chauffe, soupape qui crache, public à 30 m. Première priorité ?',
 '[{"text":"Établir une zone d''exclusion de 100 m et évacuer le public","nextStep":1},{"text":"Tenter de fermer la vanne moi-même","nextStep":99},{"text":"Couvrir la bouteille avec une couverture humide","nextStep":99}]'::jsonb),
('ssiap2-hc-p1-q26', 1,
 'ÉTAPE 2 — Public éloigné. Action suivante ?',
 '[{"text":"Refroidir la bouteille à distance à l''eau pulvérisée (lance diffusée)","nextStep":2},{"text":"Approcher pour évaluer la pression","nextStep":99},{"text":"Attendre passivement la fin du sinistre","nextStep":99}]'::jsonb),
('ssiap2-hc-p1-q26', 2,
 'ÉTAPE 3 — Les pompiers arrivent. Rôle du SSIAP 2 ?',
 '[{"text":"Demander la cellule risques chimiques, remettre les plans, point de synthèse","nextStep":null},{"text":"Reprendre mes rondes habituelles","nextStep":null},{"text":"Quitter le site, mission terminée","nextStep":null}]'::jsonb);

commit;
