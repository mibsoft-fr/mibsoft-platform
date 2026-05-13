-- Auto-generated seed for SSIAP 1
begin;
-- 1. cc_modules
insert into public.cc_modules (id, level, title, subtitle, icon, color, display_order, is_active)
values ('ssiap1-box-1', 1, 'Le Feu', 'Combustion, classes, propagation', '🔥', 'from-red-500 to-orange-600', 0, true)
on conflict (id) do update set title=excluded.title, subtitle=excluded.subtitle, icon=excluded.icon, color=excluded.color, display_order=excluded.display_order, is_active=excluded.is_active;
insert into public.cc_modules (id, level, title, subtitle, icon, color, display_order, is_active)
values ('ssiap1-box-2', 1, 'ERP & IGH', 'Réglementation, classification, obligations', '🏛️', 'from-blue-600 to-indigo-700', 1, true)
on conflict (id) do update set title=excluded.title, subtitle=excluded.subtitle, icon=excluded.icon, color=excluded.color, display_order=excluded.display_order, is_active=excluded.is_active;
insert into public.cc_modules (id, level, title, subtitle, icon, color, display_order, is_active)
values ('ssiap1-box-3', 1, 'Moyens de Secours', 'SSI, extincteurs, RIA, colonnes sèches', '🧯', 'from-cyan-500 to-blue-600', 2, true)
on conflict (id) do update set title=excluded.title, subtitle=excluded.subtitle, icon=excluded.icon, color=excluded.color, display_order=excluded.display_order, is_active=excluded.is_active;
insert into public.cc_modules (id, level, title, subtitle, icon, color, display_order, is_active)
values ('ssiap1-box-4', 1, 'Évacuation & Organisation', 'Dégagements, rôles, exercices', '🚪', 'from-emerald-500 to-teal-600', 3, true)
on conflict (id) do update set title=excluded.title, subtitle=excluded.subtitle, icon=excluded.icon, color=excluded.color, display_order=excluded.display_order, is_active=excluded.is_active;
-- 2. cc_questions
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q1', 'ssiap1-box-1', 'scenario', 'Odeur suspecte', 'Quelle est votre PREMIÈRE action ?',
  'Lors d''une ronde de nuit, vous sentez une forte odeur de brûlé dans le couloir du 2ème étage. Vous approchez d''une porte et constatez qu''elle est chaude au toucher. Aucune fumée visible.', null, 'Porte chaude = feu violent possible derrière. On ne l''ouvre JAMAIS. On déclenche l''alarme en priorité puis on alerte le PC.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 0
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q2', 'ssiap1-box-1', 'quiz', 'Tétraèdre du feu', 'Quels sont les 4 éléments du tétraèdre du feu ?',
  null, null, 'Tétraèdre = combustible + comburant (O2) + énergie d''activation + réaction en chaîne. Supprimer l''un des 4 éteint le feu.',
  0, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 1
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q3', 'ssiap1-box-1', 'multiple-select', 'Facteurs de propagation', 'Quels facteurs ACCÉLÈRENT la propagation d''un incendie ? (plusieurs réponses)',
  null, null, 'Charge calorifique ✅, courants d''air ✅, géométrie ✅, air sec ✅. La couleur des murs n''a aucun impact sur la propagation ❌.',
  null, array[0,2,3,4]::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 2
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q4', 'ssiap1-box-1', 'find-intruder', 'Classe de feu inexistante', 'Parmi ces classes de feu, laquelle N''EXISTE PAS dans la nomenclature européenne actuelle ?',
  null, null, 'La classe E n''existe plus depuis la révision européenne. Classes valides : A (solides), B (liquides), C (gaz), D (métaux), F (huiles cuisson).',
  2, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 3
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q5', 'ssiap1-box-1', 'true-false', 'Fumée et mortalité', 'La fumée est la principale cause de décès lors d''un incendie, avant les brûlures directes.',
  null, null, 'VRAI — 80% des victimes meurent d''intoxication aux fumées (CO, HCN, CO2...) avant d''être atteintes par les flammes. Les fumées désorientation et provoquent la perte de conscience.',
  0, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 4
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q6', 'ssiap1-box-1', 'matching', 'Agents extincteurs', 'Associez chaque agent extincteur à son mode d''action principal :',
  null, null, 'Eau = refroidit la base. CO2 = chasse l''oxygène. Poudre = interrompt la réaction en chaîne. Mousse = double action couvrant + refroidissant.',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 5
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q7', 'ssiap1-box-1', 'sequence', 'Phases d''un incendie', 'Remettez dans l''ordre chronologique les phases de développement d''un incendie :',
  null, null, 'Naissance → Développement → Flashover (500°C au plafond) → Décrescence. Le flashover est le point de non-retour : tous les matériaux s''enflamment simultanément.',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 6
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q8', 'ssiap1-box-1', 'fill-blank', 'Réaction et résistance', 'Complétez ces deux notions fondamentales :',
  null, null, 'Réaction = comment le matériau se comporte face à une flamme (classement Euroclasses A à F). Résistance = durée en minutes/heures où la structure tient (REI 30, 60, 120...).',
  null, null::integer[],
  null::integer[], array['réaction au feu','résistance au feu']::text[],
  null::integer[], array['réaction au feu','résistance au feu','conductivité','inflammabilité','opacité','résistance mécanique']::text[],
  'La %1% d''un matériau évalue sa participation à la naissance et au développement du feu, tandis que la %2% évalue la durée pendant laquelle il conserve sa fonction.', null, null,
  null, null, 7
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q9', 'ssiap1-box-1', 'ranking', 'Résistance des matériaux', 'Classez ces matériaux du PLUS résistant au MOINS résistant face au feu :',
  null, null, 'Béton > Brique > Bois (carbonise mais reste porteur un moment) > Acier nu (perd 50% de sa résistance dès 400-600°C).',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 8
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q10', 'ssiap1-box-1', 'categories', 'Extincteur adapté', 'Classez ces agents extincteurs selon leur utilisation sur un feu d''origine électrique :',
  null, null, 'CO2 ✅ et Poudre ✅ = non conducteurs. Eau jet plein ❌, eau pulvérisée conductrice ❌, mousse ❌ = risque d''électrocution grave.',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 9
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q11', 'ssiap1-box-1', 'image-identify', 'Panneau triangulaire jaune', 'Ce panneau triangulaire jaune signale :',
  null, null, 'Triangle jaune ISO 7010 W012 = AVERTISSEMENT danger électrique. Présence de tension dangereuse. Ne jamais intervenir sans habilitation électrique.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  'electrical-hazard', 'ISO 7010 — W012', 10
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q12', 'ssiap1-box-1', 'decision', 'Découverte d''incendie', 'Arbre de décision — étape par étape :',
  'Vous êtes en patrouille. Vous découvrez de la fumée qui sort sous la porte d''un local technique. La porte est tiède. Vous êtes seul.', null, 'Alarme en 1er → Intervention si feu petit et sortie disponible → Abandon si le feu prend de l''ampleur. La vie prime sur les biens.',
  null, null::integer[],
  null::integer[], null::text[],
  array[1,1,1]::integer[], null::text[],
  null, null, null,
  null, null, 11
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q13', 'ssiap1-box-1', 'true-false', 'Backdraft vs Flashover', 'Le backdraft et le flashover sont deux noms différents pour désigner le même phénomène.',
  null, null, 'FAUX — Backdraft = explosion due à un apport soudain d''oxygène dans un local enfumé. Flashover = embrasement généralisé par montée en température (500°C au plafond). Deux phénomènes distincts et tous deux mortels.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 12
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b1-q14', 'ssiap1-box-1', 'scenario', 'Choix de l''extincteur', 'Quel extincteur utilisez-vous et pourquoi ?',
  'Dans la salle serveur, un câble électrique prend feu. Vous disposez d''un extincteur à eau pulvérisée non additif et d''un extincteur CO2. Les flammes font 40 cm de haut.', null, 'CO2 = agent non conducteur, idéal pour les locaux électriques/informatiques. L''eau conduit l''électricité → risque d''électrocution. Exception : eau pulvérisée avec additif anti-électrostatique (vérifier le marquage "feux électriques").',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 13
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q1', 'ssiap1-box-2', 'quiz', 'Classification ERP', 'Un ERP est classé selon deux critères principaux. Lesquels ?',
  null, null, 'Type = lettre selon l''activité (M=magasin, R=enseignement, O=hôtel...). Catégorie = de 1 à 5 selon l''effectif. Ces deux critères déterminent toutes les obligations réglementaires.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 0
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q2', 'ssiap1-box-2', 'scenario', 'Travaux et SSI', 'Quelle est la bonne conduite à tenir ?',
  'Des travaux de rénovation prévoient d''ouvrir une trémie de 0,5m² dans un plancher coupe-feu 1h30 pour faire passer des câbles. Le chef de chantier dit que c''est "un petit percement sans importance".', null, 'Toute modification impactant la sécurité incendie (structure CF, SSI) nécessite une autorisation préalable de la commission. Le permis de feu est obligatoire pour les travaux par points chauds.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 1
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q3', 'ssiap1-box-2', 'find-intruder', 'Type ERP inexistant', 'Parmi ces types d''ERP, lequel N''EXISTE PAS dans la réglementation française ?',
  null, null, 'Le type Z n''existe pas. Les vrais types vont de J à Y : J(personnes âgées), L(salles), M(magasins), N(restaurants), O(hôtels), P(dancings), R(enseignement), S(bibliothèques), T(expo), U(soins), V(culte), W(bureaux), X(sports), Y(musées).',
  2, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 2
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q4', 'ssiap1-box-2', 'true-false', 'IGH habitation', 'Un immeuble d''habitation est classé IGH dès que le plancher bas du dernier niveau habité dépasse 28 mètres.',
  null, null, 'FAUX — Seuil IGH habitation = 50 mètres. Le seuil de 28 m s''applique aux IGH à usage de bureaux, hôtels, établissements d''enseignement. Ces seuils conditionnent des exigences très renforcées.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 3
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q5', 'ssiap1-box-2', 'matching', 'Classes IGH', 'Associez chaque sigle IGH à son usage :',
  null, null, 'GHA=habitation (>50m), GHO=hôtels, GHW=bureaux, GHU=sanitaire, GHR=enseignement, GHS=archives, GHZ=mixte. Le code GH + lettre = type d''usage.',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 4
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q6', 'ssiap1-box-2', 'multiple-select', 'Obligations IGH', 'Quelles obligations sont SPÉCIFIQUES aux IGH ? (plusieurs réponses)',
  null, null, 'SSIAP 24h/24 ✅, compartimentage ✅, SSI cat.A ✅, colonnes humides ✅. L''exercice trimestriel n''est pas une obligation spécifique IGH — 2 fois/an en ERP courant.',
  null, array[0,1,2,4]::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 5
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q7', 'ssiap1-box-2', 'sequence', 'Instruction dossier ERP', 'Remettez dans l''ordre les étapes d''instruction d''une demande d''ouverture d''ERP :',
  null, null, 'Sans avis FAVORABLE de la commission, le maire ne peut pas délivrer l''autorisation. Un avis défavorable = fermeture administrative possible.',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 6
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q8', 'ssiap1-box-2', 'fill-blank', 'Compartimentage IGH', 'Complétez la règle de compartimentage des IGH :',
  null, null, 'Article GH 10 : 2 500 m² max et 3 niveaux max par compartiment. Les parois délimitatives doivent être CF 2h minimum.',
  null, null::integer[],
  null::integer[], array['2500','3']::text[],
  null::integer[], array['2500','3','5000','2','1000','4','1500','6']::text[],
  'Dans un IGH, chaque compartiment ne doit pas dépasser %1% m² de surface et %2% niveaux en superposition.', null, null,
  null, null, 7
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q9', 'ssiap1-box-2', 'ranking', 'Fréquence des visites de commission', 'Classez ces catégories d''ERP par fréquence de visite (de la plus fréquente à la moins fréquente) :',
  null, null, '1ère et 2ème cat. = annuelle. 3ème cat. = tous les 2 ans. 4ème cat. = tous les 3 ans. La 5ème catégorie est dispensée de passage en commission sauf lors de l''ouverture.',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 8
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q10', 'ssiap1-box-2', 'categories', 'Documents ERP', 'Classez ces documents selon leur caractère obligatoire en ERP :',
  null, null, 'Registre ✅, Notice ✅, Plans ✅ = obligatoires. Les catalogues et revues ont une valeur documentaire mais ne sont pas des obligations réglementaires.',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 9
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q11', 'ssiap1-box-2', 'image-identify', 'Panneau vert personnes', 'Ce pictogramme vert représente :',
  null, null, 'ISO 7010 E007 = Point de rassemblement. Lieu où tous les occupants doivent se regrouper après évacuation pour permettre le comptage et informer les secours.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  'assembly', 'ISO 7010 — E007', 10
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q12', 'ssiap1-box-2', 'decision', 'Registre non tenu', 'Quelle est la marche à suivre ?',
  'Vous prenez votre poste de SSIAP. En consultant le registre de sécurité, vous constatez qu''il n''a pas été rempli depuis 5 semaines et que plusieurs vérifications périodiques ne sont pas documentées.', null, 'Signaler → Rechercher les preuves existantes → Programmer les vérifications manquantes. La falsification de registre est une infraction pénale.',
  null, null::integer[],
  null::integer[], null::text[],
  array[1,1,0]::integer[], null::text[],
  null, null, null,
  null, null, 11
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q13', 'ssiap1-box-2', 'true-false', 'Permis de feu', 'Dans un ERP, le permis de feu peut être accordé verbalement si le responsable sécurité est présent.',
  null, null, 'FAUX — Le permis de feu (GN13) est TOUJOURS écrit, daté, signé des deux parties (donneur d''ordre + exécutant). Aucune exception. Un permis verbal n''a aucune valeur juridique.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 12
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q14', 'ssiap1-box-2', 'scenario', 'Commission de sécurité', 'Le directeur a-t-il raison ?',
  'La commission de sécurité émet un avis défavorable lors de la visite périodique d''un ERP de 1ère catégorie. Le directeur affirme que la commission "n''a pas le pouvoir de fermer".', null, 'La commission émet un avis (favorable ou défavorable). En cas d''avis défavorable, le maire PEUT prendre un arrêté de fermeture. C''est le maire qui décide, mais il engage sa responsabilité en maintenant ouvert un ERP dangereux.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 13
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b2-q15', 'ssiap1-box-2', 'image-identify', 'Flèche verte personnage', 'Ce panneau vert avec personnage et flèche indique :',
  null, null, 'ISO 7010 E003 = Direction vers une issue de secours. Ces panneaux jalonnent tout le cheminement d''évacuation. Ils doivent être visibles en permanence, de jour comme de nuit (rétro-éclairés ou luminescents).',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  'exit-direction', 'ISO 7010 — E003', 14
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q1', 'ssiap1-box-3', 'scenario', 'Alarme SSI — levée de doute', 'Quelle est la procédure correcte ?',
  'Le tableau de signalisation affiche "ALARME FEU — Zone 12 — Sous-sol parking" depuis 2 minutes. Vous regardez les caméras de surveillance : aucune fumée visible. Votre responsable vous demande de réarmer immédiatement "pour ne pas déranger".', null, 'Toute alarme = levée de doute obligatoire avant réarmement. Réarmer sans vérification = faute professionnelle grave pouvant engager la responsabilité pénale. L''ordre hiérarchique ne supplante pas la procédure réglementaire.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 0
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q2', 'ssiap1-box-3', 'quiz', 'Signification SSI', 'Que désigne l''acronyme SSI ?',
  null, null, 'SSI = Système de Sécurité Incendie (norme NF S 61-931). Il comprend le SDI (Système de Détection Incendie) et le SMSI (Système de Mise en Sécurité Incendie).',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 1
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q3', 'ssiap1-box-3', 'true-false', 'CO2 et feu de friture', 'Un extincteur CO2 peut être utilisé sur un feu de friture (classe F) car il étouffe les flammes.',
  null, null, 'FAUX — Le CO2 est DANGEREUX sur les feux de classe F. La pression du jet peut projeter l''huile bouillante et provoquer un embrasement violent (explosion d''huile). Seuls les extincteurs homologués pour classe F (à eau avec additif) conviennent.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 2
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q4', 'ssiap1-box-3', 'find-intruder', 'Ce qui n''est pas un DAS', 'Parmi ces équipements, lequel N''EST PAS un Dispositif Actionné de Sécurité (DAS) ?',
  null, null, 'Le DM (Déclencheur Manuel) est un dispositif d''ENTRÉE du SDI — il déclenche l''alarme. Les DAS sont des dispositifs de SORTIE du SMSI — ils agissent : portes CF, volets, clapets, exutoires de désenfumage.',
  2, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 3
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q5', 'ssiap1-box-3', 'matching', 'Extincteur adapté au feu', 'Associez chaque type de feu à l''extincteur le plus adapté :',
  null, null, 'Eau = refroidit les feux solides. CO2 = non conducteur pour l''électrique. Mousse = étouffement sur liquides. Poudre ABC = polyvalent mais salissant et dégrade le matériel électronique.',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 4
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q6', 'ssiap1-box-3', 'sequence', 'Catégories de SSI', 'Classez les catégories de SSI de la PLUS COMPLÈTE à la PLUS SIMPLE :',
  null, null, 'A (obligatoire IGH et ERP à sommeil important) → B → C → D (alarme + compartimentage partiel) → E (alarme seule). La catégorie A est la plus complète et la plus sûre.',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 5
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q7', 'ssiap1-box-3', 'multiple-select', 'Vérifications extincteurs', 'Quelles vérifications sont OBLIGATOIRES pour les extincteurs portatifs ? (plusieurs réponses)',
  null, null, 'Contrôle visuel mensuel ✅, vérif. annuelle agréée ✅, plombage et pression ✅. L''épreuve hydraulique est tous les 10 ans ❌. Le remplacement systématique tous les 3 ans n''est pas une obligation réglementaire ❌.',
  null, array[0,1,4]::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 6
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q8', 'ssiap1-box-3', 'fill-blank', 'Colonnes d''incendie', 'Complétez la distinction fondamentale :',
  null, null, 'Colonne sèche : obligatoire dès 18m de hauteur de plancher bas. Colonne humide : obligatoire en IGH et grands ERP. La colonne humide offre une intervention immédiate sans attendre les pompiers.',
  null, null::integer[],
  null::integer[], array['colonne sèche','colonne humide']::text[],
  null::integer[], array['colonne sèche','colonne humide','colonne montante','RIA','sprinkler','tuyau d''attaque']::text[],
  'La %1% est une canalisation vide alimentée en eau par les pompiers à l''arrivée. La %2% est maintenue sous pression en permanence par des surpresseurs avec des RIA à chaque étage.', null, null,
  null, null, 7
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q9', 'ssiap1-box-3', 'ranking', 'Ordre d''intervention extinction', 'Classez ces moyens d''extinction par ordre d''intervention (du PREMIER déclenché au DERNIER) :',
  null, null, 'Sprinkler (automatique dès le départ de feu) → Extincteur (feu naissant) → RIA (feu développé) → Colonne (feu important avec sapeurs-pompiers). Chaque moyen correspond à une ampleur croissante du sinistre.',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 8
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q10', 'ssiap1-box-3', 'categories', 'SDI ou SMSI', 'Classez ces équipements dans leur sous-système SSI :',
  null, null, 'SDI = Détecte et signale : détecteurs automatiques, DM, ECS, ECSAV. SMSI = Agit sur l''environnement : CMSI + tous les DAS (portes CF, volets, clapets, exutoires).',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 9
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q11', 'ssiap1-box-3', 'image-identify', 'Panneau rouge extincteur', 'Ce panneau carré rouge avec un extincteur blanc indique :',
  null, null, 'ISO 7010 F001 = Emplacement d''un extincteur. Carré rouge = matériel de lutte incendie. Il doit être visible à 15 mètres maximum. L''extincteur doit être accessible sans obstacle.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  'extinguisher', 'ISO 7010 — F001', 10
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q12', 'ssiap1-box-3', 'decision', 'Anomalie sprinkler', 'Procédure de gestion de la défaillance :',
  'Une alarme "Manque de pression réseau sprinkler" s''affiche sur le tableau de bord du PC sécurité. Il est 23h00, l''établissement est ouvert avec 150 personnes.', null, 'Alerter → Mesures compensatoires (rondes) → Traçabilité complète (main courante + registre + transmission à la relève). Le sprinkler en panne = risque majeur → surveillance renforcée.',
  null, null::integer[],
  null::integer[], null::text[],
  array[1,1,0]::integer[], null::text[],
  null, null, null,
  null, null, 11
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q13', 'ssiap1-box-3', 'quiz', 'Inhibition de zone SSI', 'Qu''est-ce qu''une "inhibition de zone" dans un SSI ?',
  null, null, 'Inhibition = mise hors service temporaire d''une zone (travaux, maintenance). Nécessite un niveau d''accès 2 minimum, une documentation écrite et des mesures compensatoires (rondes, surveillance humaine renforcée).',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 12
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q14', 'ssiap1-box-3', 'true-false', 'Test mensuel BAES', 'Un BAES (Bloc Autonome d''Éclairage de Sécurité) doit obligatoirement être testé tous les mois par l''exploitant.',
  null, null, 'VRAI — Le test mensuel (appui sur le bouton "test" : vérification de l''allumage) est obligatoire. Un contrôle annuel approfondi (autonomie, état de la batterie) doit être réalisé par un technicien qualifié.',
  0, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 13
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b3-q15', 'ssiap1-box-3', 'image-identify', 'Panneau RIA', 'Ce panneau rouge circulaire avec tuyau indique l''emplacement d''un :',
  null, null, 'RIA = Robinet d''Incendie Armé. Équipement de 2ème intervention composé d''un robinet, un dévidoir et un tuyau semi-rigide. Toujours en eau. Nécessite une formation avant utilisation. Portée 15-20 mètres.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  'ria', 'Panneau réglementaire RIA', 14
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q1', 'ssiap1-box-4', 'scenario', 'Serre-file face à un récalcitrant', 'Quelle est votre action correcte ?',
  'Lors d''une évacuation déclenchée par l''alarme, vous êtes serre-file au 3ème étage. Un cadre supérieur refuse d''évacuer et dit : "Je suis en réunion importante, c''est encore une fausse alarme".', null, 'Le serre-file tente de convaincre fermement. Si refus persistant : noter son identité, localisation précise, et en informer immédiatement le responsable d''évacuation et les pompiers à l''arrivée. Ne jamais abandonner sans signaler.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 0
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q2', 'ssiap1-box-4', 'quiz', 'Unité de passage', 'Quelle est la largeur d''une Unité de Passage (UP) réglementaire en ERP ?',
  null, null, '1 UP = 0,60 m. Les dégagements sont calculés en nombre d''UP selon l''effectif. Ex : une porte de 0,90 m = 1 UP. Une largeur de 1,40 m = 2 UP. Ces calculs garantissent un débit d''évacuation suffisant.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 1
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q3', 'ssiap1-box-4', 'find-intruder', 'Action correcte en évacuation', 'Lequel de ces comportements est CORRECT lors d''une évacuation d''urgence ?',
  null, null, 'Se rendre calmement au point de rassemblement ✅. Ascenseur ❌ (risque de coupure). Retourner ❌ (risque mortel). Ouvrir les portes CF ❌ (laissent passer le feu et la fumée, elles doivent RESTER FERMÉES).',
  2, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 2
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q4', 'ssiap1-box-4', 'true-false', 'Sens d''ouverture des portes', 'Une porte de sortie desservant plus de 50 personnes doit obligatoirement s''ouvrir dans le sens de l''évacuation.',
  null, null, 'VRAI — Article CO 44 : dès 50 personnes, porte obligatoirement dans le sens de la sortie pour éviter l''effet de bouchon lors d''une bousculade. En dessous de 50, les deux sens sont autorisés.',
  0, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 3
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q5', 'ssiap1-box-4', 'matching', 'Rôles lors de l''évacuation', 'Associez chaque acteur à sa mission principale lors de l''évacuation :',
  null, null, 'Guide-file = en tête de groupe. Serre-file = en queue, dernier sorti, portes fermées. SSIAP = interface avec les pompiers (plans, clés). Responsable = autorité de décision.',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 4
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q6', 'ssiap1-box-4', 'sequence', 'Procédure d''alerte', 'Remettez dans l''ordre les étapes de la procédure d''alerte en cas d''incendie découvert :',
  null, null, 'Découverte → Alarme (pour évacuer tout le monde) → Alerte secours (18/112) → Accueil des pompiers avec plan, clés, informations. L''alarme AVANT l''alerte externe.',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 5
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q7', 'ssiap1-box-4', 'multiple-select', 'Éclairage de sécurité', 'Quels équipements font partie du système d''éclairage de sécurité réglementaire ? (plusieurs réponses)',
  null, null, 'BAES ✅, éclairage d''ambiance/anti-panique ✅, source centralisée ✅. Néon secteur ❌ (s''éteint en coupure). BAAS ❌ = alarme sonore, pas éclairage.',
  null, array[0,2,3]::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 6
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q8', 'ssiap1-box-4', 'fill-blank', 'Autonomie éclairage', 'Complétez les exigences réglementaires sur l''éclairage de sécurité :',
  null, null, '1 heure minimum d''autonomie sur batteries intégrées (BAES). Allumage automatique dès coupure secteur. Permet l''évacuation en toute sécurité même lors d''une coupure électrique totale.',
  null, null::integer[],
  null::integer[], array['1','normale']::text[],
  null::integer[], array['1','normale','2','secours','3','principale']::text[],
  'L''éclairage de sécurité doit fonctionner au minimum %1% heure en cas de coupure et doit s''allumer automatiquement dès la perte de l''alimentation %2%.', null, null,
  null, null, 7
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q9', 'ssiap1-box-4', 'ranking', 'Phases de l''évacuation', 'Classez ces phases dans l''ordre chronologique correct d''une évacuation réussie :',
  null, null, 'Alarme → Évacuation ordonnée → Comptage (vérifier que personne ne manque) → Retour exclusivement après feu maître. Ne JAMAIS retourner sans autorisation des pompiers.',
  null, null::integer[],
  array[0,1,2,3]::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 8
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q10', 'ssiap1-box-4', 'categories', 'Actions lors de l''évacuation', 'Classez ces comportements lors de l''évacuation :',
  null, null, 'Déclencher le DM ✅, fermer les portes ✅ (ralentit le feu), rejoindre le point ✅. Ascenseur ❌, retour dans le bâtiment ❌ — ces deux comportements causent des décès chaque année.',
  null, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 9
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q11', 'ssiap1-box-4', 'image-identify', 'Équipement vert lumineux', 'Cet équipement avec pictogramme de sortie lumineux est un :',
  null, null, 'BAES = Bloc Autonome d''Éclairage de Sécurité. Batterie intégrée, autonomie 1h minimum. S''allume automatiquement sur coupure secteur. Test mensuel obligatoire par l''exploitant (bouton "test").',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  'baes', 'BAES — Bloc Autonome Éclairage Sécurité', 10
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q12', 'ssiap1-box-4', 'decision', 'Exercice d''évacuation décevant', 'Comment gérez-vous le retour d''expérience ?',
  'L''exercice d''évacuation annuel vient de se terminer : 14 minutes pour évacuer 180 personnes sur 3 étages. Le précédent exercice avait duré 7 minutes. Un goulot d''étranglement a été observé dans l''escalier B.', null, 'Débriefing immédiat → Analyse fine des causes → Compte-rendu complet au registre avec plan d''amélioration. L''exercice n''a de valeur que s''il génère des actions correctives.',
  null, null::integer[],
  null::integer[], null::text[],
  array[1,1,1]::integer[], null::text[],
  null, null, null,
  null, null, 11
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q13', 'ssiap1-box-4', 'true-false', 'Rôle du serre-file', 'Le serre-file doit laisser toutes les portes ouvertes derrière lui pour faciliter la circulation lors de l''évacuation.',
  null, null, 'FAUX — Le serre-file doit FERMER toutes les portes coupe-feu derrière lui. Une porte CF fermée ralentit la progression du feu et de la fumée de 30 à 120 minutes selon sa résistance. C''est une des actions les plus efficaces lors d''une évacuation.',
  1, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 12
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
insert into public.cc_questions (
  id, module_id, type, title, question, scenario, situation, explanation,
  correct_answer, correct_answers, correct_order, correct_blanks, correct_path,
  word_bank, sentence, image_url, video_url, image_key, image_desc,
  display_order
) values (
  'ssiap1-b4-q14', 'ssiap1-box-4', 'scenario', 'PMR coincée en hauteur', 'Quelle est la procédure correcte ?',
  'Lors de l''évacuation, vous croisez une collègue en fauteuil roulant au 4ème étage. L''ascenseur est neutralisé. Les escaliers sont inaccessibles pour elle.', null, 'EAS = Espace d''Attente Sécurisé, adjacent aux escaliers, protégé du feu. La PMR y attend les pompiers dans une zone sécurisée. Sa position DOIT être communiquée aux secours à l''arrivée. Porter une personne dans des escaliers peut blesser les deux parties.',
  2, null::integer[],
  null::integer[], null::text[],
  null::integer[], null::text[],
  null, null, null,
  null, null, 13
) on conflict (id) do update set
  type=excluded.type, title=excluded.title, question=excluded.question,
  scenario=excluded.scenario, situation=excluded.situation, explanation=excluded.explanation,
  correct_answer=excluded.correct_answer, correct_answers=excluded.correct_answers,
  correct_order=excluded.correct_order, correct_blanks=excluded.correct_blanks,
  correct_path=excluded.correct_path, word_bank=excluded.word_bank,
  sentence=excluded.sentence, image_url=excluded.image_url, video_url=excluded.video_url,
  image_key=excluded.image_key, image_desc=excluded.image_desc,
  display_order=excluded.display_order, updated_at=now();
-- 3. clear & repopulate sub-tables for these cc_questions
delete from public.cc_question_options        where question_id in ('ssiap1-b1-q1','ssiap1-b1-q2','ssiap1-b1-q3','ssiap1-b1-q4','ssiap1-b1-q5','ssiap1-b1-q6','ssiap1-b1-q7','ssiap1-b1-q8','ssiap1-b1-q9','ssiap1-b1-q10','ssiap1-b1-q11','ssiap1-b1-q12','ssiap1-b1-q13','ssiap1-b1-q14','ssiap1-b2-q1','ssiap1-b2-q2','ssiap1-b2-q3','ssiap1-b2-q4','ssiap1-b2-q5','ssiap1-b2-q6','ssiap1-b2-q7','ssiap1-b2-q8','ssiap1-b2-q9','ssiap1-b2-q10','ssiap1-b2-q11','ssiap1-b2-q12','ssiap1-b2-q13','ssiap1-b2-q14','ssiap1-b2-q15','ssiap1-b3-q1','ssiap1-b3-q2','ssiap1-b3-q3','ssiap1-b3-q4','ssiap1-b3-q5','ssiap1-b3-q6','ssiap1-b3-q7','ssiap1-b3-q8','ssiap1-b3-q9','ssiap1-b3-q10','ssiap1-b3-q11','ssiap1-b3-q12','ssiap1-b3-q13','ssiap1-b3-q14','ssiap1-b3-q15','ssiap1-b4-q1','ssiap1-b4-q2','ssiap1-b4-q3','ssiap1-b4-q4','ssiap1-b4-q5','ssiap1-b4-q6','ssiap1-b4-q7','ssiap1-b4-q8','ssiap1-b4-q9','ssiap1-b4-q10','ssiap1-b4-q11','ssiap1-b4-q12','ssiap1-b4-q13','ssiap1-b4-q14');
delete from public.cc_question_items          where question_id in ('ssiap1-b1-q1','ssiap1-b1-q2','ssiap1-b1-q3','ssiap1-b1-q4','ssiap1-b1-q5','ssiap1-b1-q6','ssiap1-b1-q7','ssiap1-b1-q8','ssiap1-b1-q9','ssiap1-b1-q10','ssiap1-b1-q11','ssiap1-b1-q12','ssiap1-b1-q13','ssiap1-b1-q14','ssiap1-b2-q1','ssiap1-b2-q2','ssiap1-b2-q3','ssiap1-b2-q4','ssiap1-b2-q5','ssiap1-b2-q6','ssiap1-b2-q7','ssiap1-b2-q8','ssiap1-b2-q9','ssiap1-b2-q10','ssiap1-b2-q11','ssiap1-b2-q12','ssiap1-b2-q13','ssiap1-b2-q14','ssiap1-b2-q15','ssiap1-b3-q1','ssiap1-b3-q2','ssiap1-b3-q3','ssiap1-b3-q4','ssiap1-b3-q5','ssiap1-b3-q6','ssiap1-b3-q7','ssiap1-b3-q8','ssiap1-b3-q9','ssiap1-b3-q10','ssiap1-b3-q11','ssiap1-b3-q12','ssiap1-b3-q13','ssiap1-b3-q14','ssiap1-b3-q15','ssiap1-b4-q1','ssiap1-b4-q2','ssiap1-b4-q3','ssiap1-b4-q4','ssiap1-b4-q5','ssiap1-b4-q6','ssiap1-b4-q7','ssiap1-b4-q8','ssiap1-b4-q9','ssiap1-b4-q10','ssiap1-b4-q11','ssiap1-b4-q12','ssiap1-b4-q13','ssiap1-b4-q14');
delete from public.cc_question_pairs          where question_id in ('ssiap1-b1-q1','ssiap1-b1-q2','ssiap1-b1-q3','ssiap1-b1-q4','ssiap1-b1-q5','ssiap1-b1-q6','ssiap1-b1-q7','ssiap1-b1-q8','ssiap1-b1-q9','ssiap1-b1-q10','ssiap1-b1-q11','ssiap1-b1-q12','ssiap1-b1-q13','ssiap1-b1-q14','ssiap1-b2-q1','ssiap1-b2-q2','ssiap1-b2-q3','ssiap1-b2-q4','ssiap1-b2-q5','ssiap1-b2-q6','ssiap1-b2-q7','ssiap1-b2-q8','ssiap1-b2-q9','ssiap1-b2-q10','ssiap1-b2-q11','ssiap1-b2-q12','ssiap1-b2-q13','ssiap1-b2-q14','ssiap1-b2-q15','ssiap1-b3-q1','ssiap1-b3-q2','ssiap1-b3-q3','ssiap1-b3-q4','ssiap1-b3-q5','ssiap1-b3-q6','ssiap1-b3-q7','ssiap1-b3-q8','ssiap1-b3-q9','ssiap1-b3-q10','ssiap1-b3-q11','ssiap1-b3-q12','ssiap1-b3-q13','ssiap1-b3-q14','ssiap1-b3-q15','ssiap1-b4-q1','ssiap1-b4-q2','ssiap1-b4-q3','ssiap1-b4-q4','ssiap1-b4-q5','ssiap1-b4-q6','ssiap1-b4-q7','ssiap1-b4-q8','ssiap1-b4-q9','ssiap1-b4-q10','ssiap1-b4-q11','ssiap1-b4-q12','ssiap1-b4-q13','ssiap1-b4-q14');
delete from public.cc_question_categories     where question_id in ('ssiap1-b1-q1','ssiap1-b1-q2','ssiap1-b1-q3','ssiap1-b1-q4','ssiap1-b1-q5','ssiap1-b1-q6','ssiap1-b1-q7','ssiap1-b1-q8','ssiap1-b1-q9','ssiap1-b1-q10','ssiap1-b1-q11','ssiap1-b1-q12','ssiap1-b1-q13','ssiap1-b1-q14','ssiap1-b2-q1','ssiap1-b2-q2','ssiap1-b2-q3','ssiap1-b2-q4','ssiap1-b2-q5','ssiap1-b2-q6','ssiap1-b2-q7','ssiap1-b2-q8','ssiap1-b2-q9','ssiap1-b2-q10','ssiap1-b2-q11','ssiap1-b2-q12','ssiap1-b2-q13','ssiap1-b2-q14','ssiap1-b2-q15','ssiap1-b3-q1','ssiap1-b3-q2','ssiap1-b3-q3','ssiap1-b3-q4','ssiap1-b3-q5','ssiap1-b3-q6','ssiap1-b3-q7','ssiap1-b3-q8','ssiap1-b3-q9','ssiap1-b3-q10','ssiap1-b3-q11','ssiap1-b3-q12','ssiap1-b3-q13','ssiap1-b3-q14','ssiap1-b3-q15','ssiap1-b4-q1','ssiap1-b4-q2','ssiap1-b4-q3','ssiap1-b4-q4','ssiap1-b4-q5','ssiap1-b4-q6','ssiap1-b4-q7','ssiap1-b4-q8','ssiap1-b4-q9','ssiap1-b4-q10','ssiap1-b4-q11','ssiap1-b4-q12','ssiap1-b4-q13','ssiap1-b4-q14');
delete from public.cc_question_category_items where question_id in ('ssiap1-b1-q1','ssiap1-b1-q2','ssiap1-b1-q3','ssiap1-b1-q4','ssiap1-b1-q5','ssiap1-b1-q6','ssiap1-b1-q7','ssiap1-b1-q8','ssiap1-b1-q9','ssiap1-b1-q10','ssiap1-b1-q11','ssiap1-b1-q12','ssiap1-b1-q13','ssiap1-b1-q14','ssiap1-b2-q1','ssiap1-b2-q2','ssiap1-b2-q3','ssiap1-b2-q4','ssiap1-b2-q5','ssiap1-b2-q6','ssiap1-b2-q7','ssiap1-b2-q8','ssiap1-b2-q9','ssiap1-b2-q10','ssiap1-b2-q11','ssiap1-b2-q12','ssiap1-b2-q13','ssiap1-b2-q14','ssiap1-b2-q15','ssiap1-b3-q1','ssiap1-b3-q2','ssiap1-b3-q3','ssiap1-b3-q4','ssiap1-b3-q5','ssiap1-b3-q6','ssiap1-b3-q7','ssiap1-b3-q8','ssiap1-b3-q9','ssiap1-b3-q10','ssiap1-b3-q11','ssiap1-b3-q12','ssiap1-b3-q13','ssiap1-b3-q14','ssiap1-b3-q15','ssiap1-b4-q1','ssiap1-b4-q2','ssiap1-b4-q3','ssiap1-b4-q4','ssiap1-b4-q5','ssiap1-b4-q6','ssiap1-b4-q7','ssiap1-b4-q8','ssiap1-b4-q9','ssiap1-b4-q10','ssiap1-b4-q11','ssiap1-b4-q12','ssiap1-b4-q13','ssiap1-b4-q14');
delete from public.cc_question_decision_steps where question_id in ('ssiap1-b1-q1','ssiap1-b1-q2','ssiap1-b1-q3','ssiap1-b1-q4','ssiap1-b1-q5','ssiap1-b1-q6','ssiap1-b1-q7','ssiap1-b1-q8','ssiap1-b1-q9','ssiap1-b1-q10','ssiap1-b1-q11','ssiap1-b1-q12','ssiap1-b1-q13','ssiap1-b1-q14','ssiap1-b2-q1','ssiap1-b2-q2','ssiap1-b2-q3','ssiap1-b2-q4','ssiap1-b2-q5','ssiap1-b2-q6','ssiap1-b2-q7','ssiap1-b2-q8','ssiap1-b2-q9','ssiap1-b2-q10','ssiap1-b2-q11','ssiap1-b2-q12','ssiap1-b2-q13','ssiap1-b2-q14','ssiap1-b2-q15','ssiap1-b3-q1','ssiap1-b3-q2','ssiap1-b3-q3','ssiap1-b3-q4','ssiap1-b3-q5','ssiap1-b3-q6','ssiap1-b3-q7','ssiap1-b3-q8','ssiap1-b3-q9','ssiap1-b3-q10','ssiap1-b3-q11','ssiap1-b3-q12','ssiap1-b3-q13','ssiap1-b3-q14','ssiap1-b3-q15','ssiap1-b4-q1','ssiap1-b4-q2','ssiap1-b4-q3','ssiap1-b4-q4','ssiap1-b4-q5','ssiap1-b4-q6','ssiap1-b4-q7','ssiap1-b4-q8','ssiap1-b4-q9','ssiap1-b4-q10','ssiap1-b4-q11','ssiap1-b4-q12','ssiap1-b4-q13','ssiap1-b4-q14');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q1', 0, 'Ouvrir la porte pour vérifier l''intérieur');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q1', 1, 'Ne pas ouvrir — déclencher l''alarme et alerter le PC de sécurité');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q1', 2, 'Chercher un extincteur avant tout');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q1', 3, 'Appeler vos collègues pour confirmation');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q2', 0, 'Combustible, comburant, énergie d''activation, réaction en chaîne');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q2', 1, 'Eau, air, terre, feu');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q2', 2, 'Flamme, fumée, chaleur, gaz');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q2', 3, 'Bois, oxygène, chaleur, vent');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q3', 0, 'La charge calorifique élevée');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q3', 1, 'La couleur des murs');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q3', 2, 'Les courants d''air et la ventilation');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q3', 3, 'La géométrie et la hauteur du local');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q3', 4, 'L''humidité de l''air faible');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q4', 0, 'Classe A — feux de solides');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q4', 1, 'Classe B — feux de liquides');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q4', 2, 'Classe E — feux d''installations électriques');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q4', 3, 'Classe F — feux d''huiles de cuisson');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q5', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q5', 1, 'Faux');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b1-q6', 0, 'Eau pulvérisée', 'Refroidissement');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b1-q6', 1, 'CO2', 'Étouffement (chasse O2)');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b1-q6', 2, 'Poudre ABC', 'Inhibition chimique');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b1-q6', 3, 'Mousse', 'Étouffement + refroidissement');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q7', 0, 'Feu naissant (< 1m²)');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q7', 1, 'Phase de développement (flammes vives)');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q7', 2, 'Embrasement généralisé — flashover');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q7', 3, 'Phase de décrescence');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q9', 0, 'Béton armé avec protection');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q9', 1, 'Brique réfractaire pleine');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q9', 2, 'Bois lamellé collé (carbonisation lente)');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b1-q9', 3, 'Acier nu sans protection');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b1-q10', 0, 'ok', '✅ Utilisable sur feu électrique');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b1-q10', 1, 'nok', '❌ INTERDIT sur feu électrique');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b1-q10', 0, 'CO2', 'ok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b1-q10', 1, 'Poudre ABC (sèche)', 'ok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b1-q10', 2, 'Eau jet plein', 'nok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b1-q10', 3, 'Eau pulvérisée conductrice', 'nok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b1-q10', 4, 'Mousse', 'nok');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q11', 0, 'Un moyen de lutte incendie à proximité');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q11', 1, 'Un danger électrique — zone à risque');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q11', 2, 'Un défibrillateur accessible');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q11', 3, 'Une coupure d''urgence électricité');
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b1-q12', 0, 'ÉTAPE 1 — Que faites-vous en premier ?', '[{"text":"Ouvrir pour voir l''étendue du feu","nextStep":99},{"text":"Déclencher l''alarme et appeler le PC sécurité","nextStep":1},{"text":"Prendre un extincteur avant tout","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b1-q12', 1, 'ÉTAPE 2 — La porte est tiède (pas chaude). Pouvez-vous intervenir ?', '[{"text":"Non, évacuer sans intervenir","nextStep":99},{"text":"Oui si feu naissant, sortie dans le dos, extincteur adapté","nextStep":2},{"text":"Oui toujours, c''est mon rôle","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b1-q12', 2, 'ÉTAPE 3 — L''extincteur est vide après 15 secondes, le feu progresse. Que faites-vous ?', '[{"text":"Continuer avec les mains","nextStep":null},{"text":"Abandonner l''intervention, évacuer, fermer la porte","nextStep":null},{"text":"Attendre les pompiers sur place","nextStep":null}]'::jsonb);
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q13', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q13', 1, 'Faux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q14', 0, 'L''eau pulvérisée — elle refroidit bien');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q14', 1, 'Le CO2 — non conducteur, adapté aux feux électriques');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q14', 2, 'Les deux ensemble pour plus d''efficacité');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b1-q14', 3, 'Ni l''un ni l''autre — évacuer sans intervenir');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q1', 0, 'La hauteur des bâtiments et leur surface');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q1', 1, 'L''activité exercée (type) et l''effectif maximal accueilli (catégorie)');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q1', 2, 'La date de construction et le nombre d''étages');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q1', 3, 'La commune et la distance aux secours');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q2', 0, 'Accepter les travaux — c''est effectivement mineur');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q2', 1, 'Exiger un permis de feu et une demande d''autorisation à la commission de sécurité avant tout début');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q2', 2, 'Autoriser à condition de reboucher immédiatement après');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q2', 3, 'Appeler les pompiers pour avis verbal');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q3', 0, 'Type M — Magasins et centres commerciaux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q3', 1, 'Type O — Hôtels et pensions de famille');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q3', 2, 'Type Z — Zones industrielles et entrepôts');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q3', 3, 'Type U — Établissements de soins');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q4', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q4', 1, 'Faux');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b2-q5', 0, 'GHA', 'Habitation');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b2-q5', 1, 'GHO', 'Hôtels et résidences');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b2-q5', 2, 'GHW', 'Bureaux');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b2-q5', 3, 'GHU', 'Établissements sanitaires');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q6', 0, 'Service de sécurité SSIAP 24h/24 et 7j/7');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q6', 1, 'Compartimentage maximum 2 500 m² sur 3 niveaux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q6', 2, 'SSI de catégorie A obligatoire');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q6', 3, 'Exercice d''évacuation trimestriel');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q6', 4, 'Colonnes en charge (humides) aux étages');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q7', 0, 'Dépôt du dossier (notice sécurité + plans)');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q7', 1, 'Instruction technique par les services');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q7', 2, 'Visite et avis de la commission de sécurité');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q7', 3, 'Délivrance de l''autorisation d''ouverture par le maire');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q9', 0, '1ère catégorie — visite annuelle');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q9', 1, '2ème catégorie — visite annuelle');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q9', 2, '3ème catégorie — visite tous les 2 ans');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b2-q9', 3, '4ème catégorie — visite tous les 3 ans');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b2-q10', 0, 'obligatoire', '📌 Obligatoire réglementairement');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b2-q10', 1, 'non', '💡 Utile mais non obligatoire');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b2-q10', 0, 'Registre de sécurité', 'obligatoire');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b2-q10', 1, 'Notice descriptive de sécurité', 'obligatoire');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b2-q10', 2, 'Plan de masse à jour', 'obligatoire');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b2-q10', 3, 'Catalogue équipements', 'non');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b2-q10', 4, 'Revue professionnelle incendie', 'non');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q11', 0, 'Une zone de repos pour le personnel');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q11', 1, 'Le point de rassemblement après évacuation');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q11', 2, 'Un vestiaire collectif');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q11', 3, 'Un accès réservé aux secours');
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b2-q12', 0, 'ÉTAPE 1 — Première action immédiate ?', '[{"text":"Remplir les dates manquantes rétrospectivement","nextStep":99},{"text":"Documenter l''état des lacunes et alerter la hiérarchie","nextStep":1},{"text":"Attendre la prochaine commission pour signaler","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b2-q12', 1, 'ÉTAPE 2 — Les rapports de vérification technique (extincteurs, SSI) sont absents.', '[{"text":"Inventer des données vraisemblables","nextStep":99},{"text":"Contacter les entreprises de maintenance pour obtenir les copies","nextStep":2},{"text":"Signaler à la commission sans attendre","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b2-q12', 2, 'ÉTAPE 3 — Une vérification annuelle d''extincteurs est dépassée de 2 mois.', '[{"text":"Programmer immédiatement la vérification et consigner dans le registre","nextStep":null},{"text":"Attendre que quelqu''un s''en aperçoive","nextStep":null},{"text":"Fermer l''établissement","nextStep":null}]'::jsonb);
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q13', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q13', 1, 'Faux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q14', 0, 'Oui — la commission ne fait que des recommandations');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q14', 1, 'Non — un avis défavorable peut entraîner une fermeture administrative par le maire');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q14', 2, 'Oui — seuls les tribunaux peuvent fermer un ERP');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q14', 3, 'Non — c''est la préfecture qui décide directement');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q15', 0, 'Le sens de circulation habituel');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q15', 1, 'La direction vers une issue de secours');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q15', 2, 'Le poste de premiers secours');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b2-q15', 3, 'L''accès au stationnement');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q1', 0, 'Réarmer comme demandé — c''est sûrement un défaut technique');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q1', 1, 'Refuser, effectuer une levée de doute physique et consigner l''événement');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q1', 2, 'Appeler les pompiers sans rien faire d''autre');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q1', 3, 'Inhiber la zone 12 pour éviter les fausses alarmes');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q2', 0, 'Service de Sécurité Incendie');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q2', 1, 'Système de Sécurité Incendie');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q2', 2, 'Surveillance et Sécurité des Installations');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q2', 3, 'Système de Signalisation Intégrée');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q3', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q3', 1, 'Faux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q4', 0, 'Porte coupe-feu à fermeture automatique');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q4', 1, 'Volet de désenfumage motorisé');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q4', 2, 'Déclencheur Manuel d''alarme (boîtier rouge)');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q4', 3, 'Clapet coupe-feu dans une gaine de ventilation');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b3-q5', 0, 'Feu de bois et papier (classe A)', 'Eau pulvérisée');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b3-q5', 1, 'Feu d''installation électrique', 'CO2');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b3-q5', 2, 'Feu de liquide (classe B)', 'Mousse');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b3-q5', 3, 'Feu polyvalent A+B+C', 'Poudre ABC');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q6', 0, 'Catégorie A : détection totale + toutes fonctions sécurité');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q6', 1, 'Catégorie B : détection partielle + toutes fonctions sécurité');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q6', 2, 'Catégorie C : alarme générale sans détection auto');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q6', 3, 'Catégorie E : alarme générale seule');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q7', 0, 'Contrôle visuel mensuel par l''exploitant');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q7', 1, 'Vérification technique annuelle par organisme agréé');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q7', 2, 'Épreuve hydraulique tous les 5 ans');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q7', 3, 'Remplacement automatique tous les 3 ans');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q7', 4, 'Vérification du plombage et de l''indicateur de pression');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q9', 0, 'Sprinkler — déclenchement automatique dès 68°C');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q9', 1, 'Extincteur portatif — première intervention humaine');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q9', 2, 'RIA DN19/25 — deuxième intervention humaine');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b3-q9', 3, 'Colonne sèche ou humide — intervention des sapeurs-pompiers');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b3-q10', 0, 'sdi', '🔍 SDI — Système de Détection');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b3-q10', 1, 'smsi', '⚡ SMSI — Mise en Sécurité');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b3-q10', 0, 'Détecteur optique de fumée', 'sdi');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b3-q10', 1, 'Déclencheur Manuel (DM)', 'sdi');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b3-q10', 2, 'CMSI (Centralisateur)', 'smsi');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b3-q10', 3, 'Volet de désenfumage', 'smsi');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b3-q10', 4, 'ECS (Équipement de Contrôle)', 'sdi');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b3-q10', 5, 'Porte coupe-feu motorisée', 'smsi');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q11', 0, 'Un local à risque d''incendie');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q11', 1, 'L''emplacement d''un extincteur portatif');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q11', 2, 'Un poste de premiers secours');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q11', 3, 'Une sortie de secours équipée');
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b3-q12', 0, 'ÉTAPE 1 — Première action ?', '[{"text":"Réarmer l''alarme et attendre le matin","nextStep":99},{"text":"Alerter la hiérarchie et contacter l''astreinte technique","nextStep":1},{"text":"Évacuer immédiatement l''établissement","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b3-q12', 1, 'ÉTAPE 2 — En attendant l''intervention technique (délai 30 min) ?', '[{"text":"Ne rien faire — 30 min c''est court","nextStep":99},{"text":"Mettre en place des rondes renforcées dans les zones concernées","nextStep":2},{"text":"Couper le réseau sprinkler pour éviter les faux déclenchements","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b3-q12', 2, 'ÉTAPE 3 — L''anomalie est consignée. Que faire avant de quitter votre poste ?', '[{"text":"Consigner dans le registre de sécurité et la main courante, transmettre à la relève","nextStep":null},{"text":"Mettre seulement un post-it sur l''écran","nextStep":null},{"text":"Rien — la maintenance a géré","nextStep":null}]'::jsonb);
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q13', 0, 'Le déclenchement volontaire d''une alarme pour test');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q13', 1, 'La désactivation temporaire d''une zone de détection pour travaux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q13', 2, 'La mise en service d''une nouvelle zone après installation');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q13', 3, 'La réinitialisation complète du système après alarme');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q14', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q14', 1, 'Faux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q15', 0, 'Extincteur portatif');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q15', 1, 'Robinet d''Incendie Armé (RIA)');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q15', 2, 'Poste de premiers secours');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b3-q15', 3, 'Point d''alimentation colonne sèche');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q1', 0, 'Le laisser — vous ne pouvez pas forcer un supérieur hiérarchique');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q1', 1, 'Tenter de le convaincre, si refus noter son identité et prévenir le responsable d''évacuation');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q1', 2, 'L''escorter physiquement de force');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q1', 3, 'Continuer sans lui — c''est son problème');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q2', 0, '0,40 m');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q2', 1, '0,60 m');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q2', 2, '0,80 m');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q2', 3, '1,00 m');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q3', 0, 'Prendre l''ascenseur pour gagner du temps');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q3', 1, 'Retourner chercher son manteau et son téléphone');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q3', 2, 'Se rendre calmement au point de rassemblement');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q3', 3, 'Ouvrir toutes les portes coupe-feu pour faciliter le passage');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q4', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q4', 1, 'Faux');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b4-q5', 0, 'Guide-file', 'Ouvre la marche et guide vers la sortie');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b4-q5', 1, 'Serre-file', 'Ferme la marche, vérifie les locaux, ferme les portes');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b4-q5', 2, 'Agent SSIAP', 'Coordonne l''évacuation et accueille les secours');
insert into public.cc_question_pairs (question_id, pair_index, left_text, right_text) values ('ssiap1-b4-q5', 3, 'Responsable d''évacuation', 'Décide et supervise l''ensemble du dispositif');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q6', 0, 'Découvrir ou constater le sinistre');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q6', 1, 'Déclencher le Déclencheur Manuel d''alarme le plus proche');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q6', 2, 'Alerter les sapeurs-pompiers (18 ou 112)');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q6', 3, 'Accueillir et guider les secours à leur arrivée');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q7', 0, 'BAES (Bloc Autonome d''Éclairage de Sécurité)');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q7', 1, 'Néon fluorescent standard alimenté secteur');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q7', 2, 'Éclairage d''ambiance anti-panique');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q7', 3, 'Source centralisée sur batteries avec luminaires déportés');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q7', 4, 'BAAS (Bloc Autonome d''Alarme Sonore)');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q9', 0, 'Déclenchement du signal d''alarme sonore');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q9', 1, 'Évacuation guidée des occupants par les guides-files');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q9', 2, 'Comptage et appel au point de rassemblement');
insert into public.cc_question_items (question_id, item_index, item_text) values ('ssiap1-b4-q9', 3, 'Retour autorisé uniquement par les sapeurs-pompiers');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b4-q10', 0, 'ok', '✅ À faire impérativement');
insert into public.cc_question_categories (question_id, category_index, category_id, category_label) values ('ssiap1-b4-q10', 1, 'nok', '🚫 Strictement interdit');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b4-q10', 0, 'Déclencher le DM en quittant son poste', 'ok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b4-q10', 1, 'Fermer la porte de son bureau derrière soi', 'ok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b4-q10', 2, 'Prendre l''ascenseur pour les étages supérieurs', 'nok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b4-q10', 3, 'Rejoindre le point de rassemblement désigné', 'ok');
insert into public.cc_question_category_items (question_id, item_index, item_text, correct_category) values ('ssiap1-b4-q10', 4, 'Retourner récupérer un document urgent', 'nok');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q11', 0, 'Détecteur de fumée optique');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q11', 1, 'Bloc Autonome d''Éclairage de Sécurité (BAES)');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q11', 2, 'Déclencheur manuel d''alarme');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q11', 3, 'Diffuseur sonore d''alarme incendie');
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b4-q12', 0, 'ÉTAPE 1 — Après l''exercice, que faites-vous en premier ?', '[{"text":"Féliciter quand même tout le monde","nextStep":99},{"text":"Réunir les guides-files et serres-files pour un débriefing à chaud","nextStep":1},{"text":"Appeler les pompiers pour signaler un dysfonctionnement","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b4-q12', 1, 'ÉTAPE 2 — Goulot d''étranglement dans l''escalier B : quelle analyse faites-vous ?', '[{"text":"C''est normal, les gens ne savent pas évacuer","nextStep":99},{"text":"Identifier la cause : largeur insuffisante, affectation de l''escalier C non communiquée, panique ?","nextStep":2},{"text":"Interdire cet escalier sans analyse","nextStep":99}]'::jsonb);
insert into public.cc_question_decision_steps (question_id, step_index, step_question, options) values ('ssiap1-b4-q12', 2, 'ÉTAPE 3 — Que consignez-vous dans le registre de sécurité ?', '[{"text":"Le temps total uniquement","nextStep":null},{"text":"Compte-rendu complet : temps, effectif, anomalies, analyse des causes, plan d''amélioration et mesures correctives","nextStep":null},{"text":"Rien — c''était un exercice, pas un vrai sinistre","nextStep":null}]'::jsonb);
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q13', 0, 'Vrai');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q13', 1, 'Faux');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q14', 0, 'La porter seul dans les escaliers malgré le risque');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q14', 1, 'La laisser — les pompiers s''en chargeront');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q14', 2, 'La conduire dans l''Espace d''Attente Sécurisé (EAS) le plus proche et signaler sa position aux secours');
insert into public.cc_question_options (question_id, option_index, option_text) values ('ssiap1-b4-q14', 3, 'Lui demander d''attendre que la fumée se dissipe');
commit;
