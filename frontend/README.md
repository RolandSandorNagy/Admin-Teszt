# Frontend – Vue 3 + Vite

Vue 3 SPA, amely a CodeIgniter 4 backend API-t használja.

## Követelmények
- Node.js 18+ (ajánlott 20)
- npm

## Telepítés / futtatás

```bash
npm install
npm run dev
```

Frontend: `http://localhost:5173`

A `vite.config.js` proxy továbbítja az API hívásokat a backend felé:
- frontend: `http://localhost:5173`
- backend: `http://localhost:8080`
- `/api/*` → backend

## Oldalak

- `/` – Login
- `/admin` – Admin felület (route guard: ha nincs session → visszairányít a loginra)
- Dinamikus oldalak: a menüből felvett URL-ek a frontendben dinamikus nézeten jelennek meg.

## CSRF

SPA kompatibilis CSRF:
- `GET /api/csrf`-ről lekéri a tokent
- Minden nem-GET kéréshez automatikusan hozzáadja `X-CSRF-TOKEN` headerben (axios interceptor)

## UI

Bootstrap 5 alap styling.
