// =============================================================================
// MIB Vigil — JS partagé pour les pages /legal/*.html
// - Injecte automatiquement un bouton "Imprimer" sur chaque doc
// - Sur le hub (index.html), ajoute le bouton "Imprimer tous les documents"
// =============================================================================

(function() {
  document.addEventListener('DOMContentLoaded', function() {
    // Détection : sommes-nous sur le hub (index.html) ou un doc ?
    var isHub = window.location.pathname.endsWith('/legal/') ||
                window.location.pathname.endsWith('/legal/index.html');

    if (isHub) {
      injectHubActions();
    } else {
      injectDocPrintButton();
    }
  });

  // ─── Bouton "Imprimer" sur un doc individuel ───
  function injectDocPrintButton() {
    var warning = document.querySelector('.legal-warning');
    if (!warning) return;

    var actions = document.createElement('div');
    actions.className = 'legal-actions';
    actions.innerHTML =
      '<a href="index.html" class="legal-print-btn" aria-label="Retour au référentiel">' +
        '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">' +
          '<line x1="19" y1="12" x2="5" y2="12"></line>' +
          '<polyline points="12 19 5 12 12 5"></polyline>' +
        '</svg>' +
        'Référentiel' +
      '</a>' +
      '<button type="button" class="legal-print-btn primary" onclick="window.print()" aria-label="Imprimer ce document">' +
        '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">' +
          '<polyline points="6 9 6 2 18 2 18 9"></polyline>' +
          '<path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>' +
          '<rect x="6" y="14" width="12" height="8"></rect>' +
        '</svg>' +
        'Imprimer' +
      '</button>';
    warning.parentNode.insertBefore(actions, warning.nextSibling);
  }

  // ─── Boutons d'action sur le hub (legal/index.html) ───
  function injectHubActions() {
    var warning = document.querySelector('.legal-warning');
    if (!warning) return;

    var actions = document.createElement('div');
    actions.className = 'legal-actions';
    actions.innerHTML =
      '<a href="print-all.html" target="_blank" class="legal-print-btn primary" aria-label="Imprimer tous les documents">' +
        '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">' +
          '<polyline points="6 9 6 2 18 2 18 9"></polyline>' +
          '<path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>' +
          '<rect x="6" y="14" width="12" height="8"></rect>' +
        '</svg>' +
        'Imprimer tous les documents' +
      '</a>';
    warning.parentNode.insertBefore(actions, warning.nextSibling);
  }
})();
