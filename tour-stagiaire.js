// =============================================================================
// MIB Prévention — Tutoriel interactif de l'espace stagiaire (Driver.js)
// - Démarre automatiquement au premier passage, puis accessible via le bouton « Aide »
// - Saute les étapes dont l'élément cible est absent ou masqué
// =============================================================================

(function () {
  var TOUR_KEY = 'mib_tour_stagiaire_v1';

  // Étapes candidates ; chaque cible est filtrée si absente / masquée.
  function buildSteps() {
    var candidates = [
      {
        el: '#greeting-block',
        title: '👋 Bienvenue sur ton espace',
        desc: "C'est ton tableau de bord SSIAP. On fait le tour des fonctionnalités en quelques secondes.",
        side: 'bottom', align: 'start'
      },
      {
        el: '#kpi-grid',
        title: '📊 Tes indicateurs',
        desc: 'Retrouve en un coup d’œil ton nombre d’entraînements, ta moyenne et le nombre de quiz réussis (≥ 70%).',
        side: 'bottom', align: 'center'
      },
      {
        el: '#session-card',
        title: '🗓️ Ta session en cours',
        desc: 'Le détail de ta formation active : niveau, dates et formateur référent.',
        side: 'bottom', align: 'center'
      },
      {
        el: '#card-auto',
        title: '🎯 Auto-entraînement',
        desc: 'Lance des QCM SSIAP adaptés à ton niveau. Chaque session est corrigée et suivie dans tes indicateurs.',
        side: 'top', align: 'start'
      },
      {
        el: '#card-ssi',
        title: '🟡 SSI Auto-formation',
        desc: 'Des scénarios guidés pour maîtriser les systèmes de sécurité incendie.',
        side: 'top', align: 'start'
      },
      {
        el: '#outils-erp-section',
        title: '🧰 Outils ERP',
        desc: 'Calcule effectif admissible, dégagements et désenfumage — utiles en cours comme en révision.',
        side: 'top', align: 'center'
      },
      {
        el: '#tour-help-anchor',
        title: '❓ Besoin de revoir ce tuto ?',
        desc: 'Clique à tout moment sur le bouton « Aide » en haut de l’écran pour relancer cette visite guidée.',
        side: 'bottom', align: 'end'
      }
    ];

    var steps = [];
    candidates.forEach(function (c) {
      var node = document.querySelector(c.el);
      if (!node) return;
      if (node.classList && node.classList.contains('hidden')) return;
      if (node.offsetParent === null && getComputedStyle(node).position !== 'fixed') return;
      steps.push({
        element: c.el,
        popover: { title: c.title, description: c.desc, side: c.side, align: c.align }
      });
    });
    return steps;
  }

  window.startStagiaireTour = function (force) {
    if (!force && localStorage.getItem(TOUR_KEY)) return;
    if (!window.driver || !window.driver.js) { console.warn('Driver.js non chargé'); return; }

    var steps = buildSteps();
    if (!steps.length) return;

    var driver = window.driver.js.driver;
    var tour = driver({
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
    });
    tour.drive();
  };
})();
