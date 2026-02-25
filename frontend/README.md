# Frontend (Vue 3 + Vite)

## Követelmények
- Node.js 18+ (ajánlott 20)
- npm

## Telepítés / futtatás
```bash
npm install
npm run dev
```

Böngésző: `http://localhost:5173`

A `vite.config.js` proxy miatt a `/api/*` hívások automatikusan a backend felé mennek:
- backend: `http://localhost:8080`
- frontend: `http://localhost:5173`

## Megjegyzés CSRF-hez
CI4 CSRF bekapcsolt állapotában POST-hoz token kell. Interjútesztnél két egyszerű opció:
1) CSRF-t csak a klasszikus formokra használod (nem SPA), vagy
2) SPA esetén beállítod, hogy a CSRF cookie-ból/response headerből felvegye a frontend, és küldje vissza headerben.

Ebben a minimal példában a hangsúly az auth + menü rekurzión van.
Ha a cégnél KÖTELEZŐ a CSRF az API-ra is, szólj és adok egy komplett CI4+Vue CSRF megoldást (cookie + axios interceptor).
