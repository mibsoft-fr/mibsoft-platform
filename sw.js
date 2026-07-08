/**
 * Service Worker pour Formation SSI - SSIAP
 * Permet le fonctionnement hors-ligne et la mise en cache
 */

const CACHE_NAME = 'ssi-formation-v3.2.0';
const CACHE_URLS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192x192.svg',
  './icons/icon-512x512.svg',
  'https://cdn.tailwindcss.com'
];

// Installation du Service Worker
self.addEventListener('install', (event) => {
  console.log('[SW] Installation en cours...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Mise en cache des ressources');
        // Promise.allSettled au lieu de cache.addAll : un 404 sur une URL
        // ne fait plus planter tout l'install. Plus robuste face aux CDN intermittents.
        return Promise.allSettled(
          CACHE_URLS.map(url => cache.add(url).catch(err => {
            console.warn('[SW] Ressource non mise en cache:', url, err.message);
          }))
        );
      })
      .then(() => {
        console.log('[SW] Installation terminée');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('[SW] Erreur installation:', error);
      })
  );
});

// Activation du Service Worker
self.addEventListener('activate', (event) => {
  console.log('[SW] Activation en cours...');
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME) {
              console.log('[SW] Suppression ancien cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('[SW] Activation terminée');
        return self.clients.claim();
      })
  );
});

// Interception des requêtes
self.addEventListener('fetch', (event) => {
  // Ignore les requêtes non-GET
  if (event.request.method !== 'GET') {
    return;
  }

  // Ignore les requêtes Firebase / Supabase / API (besoin du réseau en direct)
  if (event.request.url.includes('firebaseio.com') ||
      event.request.url.includes('googleapis.com') ||
      event.request.url.includes('supabase.co')) {
    return;
  }

  // ── Pages HTML (navigation) : NETWORK-FIRST ──
  // Une appli qui se met à jour souvent NE doit PAS servir un HTML périmé. On va d'abord
  // chercher la dernière version en ligne ; le cache ne sert qu'en secours hors-ligne.
  // (Avant : stale-while-revalidate sur tout → un F5 reservait l'ancienne page après déploiement.)
  const isDoc = event.request.mode === 'navigate' || event.request.destination === 'document';
  if (isDoc) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          if (response && response.status === 200 && response.type === 'basic') {
            const copy = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
          }
          return response;
        })
        .catch(() => caches.match(event.request).then((c) => c || caches.match('./index.html')))
    );
    return;
  }

  // ── Ressources statiques (CSS/JS/CDN/images) : stale-while-revalidate ──
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          fetch(event.request)
            .then((response) => {
              if (response && response.status === 200) {
                caches.open(CACHE_NAME).then((cache) => cache.put(event.request, response));
              }
            })
            .catch(() => {});
          return cachedResponse;
        }

        return fetch(event.request)
          .then((response) => {
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            const responseToCache = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseToCache));
            return response;
          })
          .catch(() => new Response('Hors ligne', { status: 503 }));
      })
  );
});

// Gestion des messages
self.addEventListener('message', (event) => {
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
  }
});

// Notification de mise à jour disponible
self.addEventListener('message', (event) => {
  if (event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_NAME });
  }
});
