# Frontend – Vue 3 + Vite

Vue 3 SPA, Bootstrap 5 UI-val, CodeIgniter 4 backend API-val.

## Követelmények
- Node.js 18+ (ajánlott 20)
- npm

## Indítás

```bash
npm install
npm run dev
```

Frontend: `http://localhost:5173`

## Proxy

A Vite dev server proxyzza az API hívásokat a backend felé:
- `/api/*` → `http://localhost:8080/api/*`

## Oldalak

- `/` – Login
- `/admin` – Admin felület (route guard: kijelentkezve loginra irányít)

## CSRF

SPA kompatibilis CSRF:
- `GET /api/csrf`-ről lekéri a tokent
- POST/PUT/PATCH/DELETE kéréseknél automatikusan elküldi `X-CSRF-TOKEN` headerben (axios interceptor)

## Belépés

- nickname: `admin`
- password: `Admin123!`
