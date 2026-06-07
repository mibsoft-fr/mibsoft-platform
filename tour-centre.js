// =============================================================================
// MIBsoft — Tutoriel interactif de l'espace responsable de centre
// - Démarre au premier passage (flag localStorage), rejouable via « Revoir le tutoriel »
// - Saute les étapes dont l'élément cible est absent ou masqué
// =============================================================================

(function () {
  var TOUR_KEY = 'mib_tour_centre_v1';

  function buildSteps() {
    var candidates = [
      { el: '#nav-dashboard', title: '📊 Tableau de bord',
        desc: "Bienvenue dans votre espace centre. On fait le tour des fonctionnalités en quelques secondes.",
        side: 'right', align: 'start' },
      { el: '#kpi-grid', title: '🔢 Vos indicateurs clés',
        desc: 'Formateurs, stagiaires, sessions et entraînements de votre centre, en un coup d’œil.',
        side: 'bottom', align: 'center' },
      { el: '#nav-formateurs', title: '👨‍🏫 Formateurs',
        desc: 'Invitez vos formateurs et gérez leurs accès. Chacun est rattaché à votre centre.',
        side: 'right', align: 'start' },
      { el: '#nav-sessions', title: '📋 Sessions',
        desc: 'Créez et suivez vos sessions de formation SSIAP et leurs participants.',
        side: 'right', align: 'start' },
      { el: '#nav-stats', title: '📈 Statistiques',
        desc: 'Analysez la progression et les taux de réussite pour piloter la qualité de vos formations.',
        side: 'right', align: 'start' },
      { el: '#nav-modules', title: '🧩 Mes modules',
        desc: 'Activez les modules et outils mis à disposition de vos formateurs et stagiaires.',
        side: 'right', align: 'start' },
      { el: '#nav-avis', title: '💬 Avis & Retours',
        desc: 'Consultez les retours de vos stagiaires sur les formations.',
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

  window.startCentreTour = function (force) {
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

  // Démarrage automatique au premier passage (après stabilisation de la page).
  document.addEventListener('DOMContentLoaded', function () {
    setTimeout(function () {
      if (document.getElementById('nav-dashboard')) window.startCentreTour(false);
    }, 1000);
  });
})();
