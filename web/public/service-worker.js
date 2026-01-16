const CACHE_NAME = 'eqd2-v1';
const ASSETS_TO_CACHE = [
    '/',
    '/index.html',
    '/manifest.json',
    '/favicon.svg',
    '/pwa-192x192.png',
    '/pwa-512x512.png'
];

// Install event - cache core assets
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(ASSETS_TO_CACHE);
        })
    );
    self.skipWaiting();
});

// Activate event - cleanup old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keyList) => {
            return Promise.all(
                keyList.map((key) => {
                    if (key !== CACHE_NAME) {
                        return caches.delete(key);
                    }
                })
            );
        })
    );
    self.clients.claim();
});

// Fetch event - cache first, then network
self.addEventListener('fetch', (event) => {
    // Navigation requests: try network, fallback to cache, then offline page (or index.html for SPA)
    if (event.request.mode === 'navigate') {
        event.respondWith(
            fetch(event.request).catch(() => {
                return caches.match('/index.html');
            })
        );
        return;
    }

    // Static assets: cache first
    event.respondWith(
        caches.match(event.request).then((response) => {
            return response || fetch(event.request).then((networkResponse) => {
                // Optional: Cache new requests dynamically
                // return caches.open(CACHE_NAME).then((cache) => {
                //   cache.put(event.request, networkResponse.clone());
                //   return networkResponse;
                // });
                return networkResponse;
            });
        })
    );
});
