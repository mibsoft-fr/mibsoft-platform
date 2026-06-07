// =============================================================================
// MIBsoft — Tutoriel interactif de l'espace formateur
// - Démarre au premier passage (flag localStorage), rejouable via « Revoir le tutoriel »
// - Saute les étapes dont l'élément cible est absent ou masqué
// =============================================================================

(function () {
  var TOUR_KEY = 'mib_tour_formateur_v1';

  function buildSteps() {
    var candidates = [
      { el: '#nav-overview', title: '📊 Tableau de bord',
        desc: "Bienvenue dans votre espace formateur. On fait le tour des fonctionnalités en quelques secondes.",
        side: 'right', align: 'start' },
      { el: '#kpi-grid', title: '🔢 Vos indicateurs',
        desc: 'Sessions, stagiaires et entraînements suivis, en un coup d’œil.',
        side: 'bottom', align: 'center' },
      { el: '#nav-sessions', title: '📋 Sessions',
        desc: 'Organisez vos sessions, rattachez vos stagiaires et suivez leur avancement en temps réel.',
        side: 'right', align: 'start' },
      { el: '#nav-stats', title: '📈 Statistiques',
        desc: 'Visualisez la progression et les taux de réussite de vos groupes.',
        side: 'right', align: 'start' },
      { el: '#nav-questions', title: '❓ Questions',
        desc: 'Gérez la banque de questions utilisée dans les quiz et entraînements.',
        side: 'right', align: 'start' },
      { el: '#nav-avis', title: '💬 Avis & Retours',
        desc: 'Consultez les retours de vos stagiaires.',
        side: 'right', align: 'start' },
      { el: '#nav-outils-section', title: '🧰 Outils ERP',
        desc: 'Effectif, dégagements et désenfumage — utiles en cours comme en révision.',
        side: 'right', align: 'start' },
      { el: '#tour-help-anchor', title: '❓ Revoir ce tuto',
        desc: 'Relancez cette visite guidée à tout moment depuis ce bouton.',
        side: 'top', align: 'center' }
    ];

    var steps = [];
    candidates.forEach(function (c) {
      var node = document.querySelector(c.el);
      if (!node) return;
      if (node.classList && node.classList.contains('hidden')) return;
      if (node.offsetParent === null && getComputedStyle(node).position !== 'fixed') return;
      steps.push({ element: c.el, popover: { title: c.title, description: c.desc, side: c.side, align: c.align } });
    });
    return steps;
  }

  window.startFormateurTour = function (force) {
    if (!force && localStorage.getItem(TOUR_KEY)) return;
    if (!window.driver || !window.driver.js) { console.warn('Driver.js non chargé'); return; }
    var steps = buildSteps();
    if (!steps.length) return;
    var driver = window.driver.js.driver;
    driver({
      showProgress: true,
      progressText: '{{current}} / {{total}}',
      nextBtnText: 'Suivant',
      prevBtnText: 'Précédent',
      doneBtnText: 'Terminé',
      popoverClass: 'mib-tour',
      allowClose: true,
      overlayColor: 'rgba(15, 23, 42, 0.65)',
      steps: steps,
      onDestroyed: function () { localStorage.setItem(TOUR_KEY, '1'); }
    }).drive();
  };

  document.addEventListener('DOMContentLoaded', function () {
    setTimeout(function () {
      if (document.getElementById('nav-overview')) window.startFormateurTour(false);
    }, 1000);
  });
})();
