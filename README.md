# CI4 + Vue – Admin teszt (interjú feladat)

A ZIP két mappát tartalmaz:
- `backend/` – CI4-be bemásolandó fájlok + SQL
- `frontend/` – Vue 3 (Vite) SPA

## Gyors ellenőrzés (local)
1) MySQL-ben futtasd: `backend/database.sql`
2) Hozz létre egy CI4 projektet Composerrel, majd másold be a `backend/app/*` fájlokat a CI4 projektedbe.
3) `.env`-ben állítsd be az adatbázist.
4) Indítsd a backendet: `php spark serve` (8080)
5) Frontend:
   - `cd frontend`
   - `npm install`
   - `npm run dev` (5173)

Belépés:
- nickname: `admin` (ha így szúrod be a usert)
- password: `Admin123!` (hash alapján)

## XAMPP
Igen, működik XAMPP-pal is, de a CI4 public webroot beállítás fontos (DocumentRoot → `public/`).
