/**
 * Service Worker pour Formation SSI - SSIAP
 * Permet le fonctionnement hors-ligne et la mise en cache
 */

const CACHE_NAME = 'ssi-formation-v2.8.0';
const CACHE_URLS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192x192.svg',
  './icons/icon-512x512.svg',
  'https://cdn.tailwindcss.com',
  'https://unpkg.com/firebase@10.7.1/firebase-app-compat.js',
  'https://unpkg.com/firebase@10.7.1/firebase-database-compat.js'
];

// Installation du Service Worker
self.addEventListener('install', (event) => {
  console.log('[SW] Installation en cours...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Mise en cache des ressources');
        // cache.addAll est all-or-nothing : une seule URL en 404 fait planter tout
        // l'install (cf. icons/ qui n'existe pas dans ssi-formation/ — pre-existing).
        // On utilise Promise.allSettled pour rendre l'install résilient.
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

  // Ignore les requêtes Firebase (besoin du réseau)
  if (event.request.url.includes('firebaseio.com') ||
      event.request.url.includes('googleapis.com')) {
    return;
  }

  // App shell (document HTML) : NETWORK-FIRST.
  // L'ancienne stratégie stale-while-revalidate servait l'index.html en cache
  // (donc l'ANCIENNE version) immédiatement après un déploiement, ne mettant le
  // cache à jour qu'en arrière-plan. Conséquence : les correctifs n'apparaissaient
  // pas tant que le SW servait le HTML périmé. On va désormais chercher la dernière
  // version sur le réseau et ne retomber sur le cache qu'en cas d'absence de réseau.
  if (event.request.mode === 'navigate' || event.request.destination === 'document') {
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

  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        // Retourne le cache si disponible
        if (cachedResponse) {
          // Mise à jour en arrière-plan (stale-while-revalidate)
          fetch(event.request)
            .then((response) => {
              if (response && response.status === 200) {
                caches.open(CACHE_NAME)
                  .then((cache) => {
                    cache.put(event.request, response);
                  });
              }
            })
            .catch(() => {});

          return cachedResponse;
        }

        // Sinon, fetch depuis le réseau
        return fetch(event.request)
          .then((response) => {
            // Ne cache que les réponses valides
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clone la réponse pour le cache
            const responseToCache = response.clone();
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });

            return response;
          })
          .catch(() => {
            // Mode hors-ligne - retourne une page d'erreur
            if (event.request.destination === 'document') {
              return caches.match('./index.html');
            }
            return new Response('Hors ligne', { status: 503 });
          });
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
