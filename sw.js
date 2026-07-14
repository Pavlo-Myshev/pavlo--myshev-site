const CACHE='pm-assistant-v2';
const ASSETS=['./','./index.html','./manifest.webmanifest','./assets/pm-logo.jpeg','./assets/pavel-founder.jpeg'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS))));
self.addEventListener('fetch',e=>e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request))));
