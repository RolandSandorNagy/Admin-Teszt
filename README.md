# Admin Teszt – CodeIgniter 4 + Vue 3

Egyszerű admin alkalmazás a megadott feladat specifikáció alapján (login + dinamikus, rekurzív menürendszer + MySQL feladatok).

## Fő funkciók

- Bejelentkezés (nickname + jelszó), siker/hiba üzenetek
- Belépés után admin felület
- Dinamikus, hierarchikus (többszintű) menüstruktúra
- Tetszőleges mélységű menüfa rekurzív felépítéssel és megjelenítéssel
- CSRF védelem SPA kompatibilis módon (token endpoint + axios interceptor)
- MySQL/MariaDB adatbázis sémák + dummy adatok + lekérdezések

## Technológia

- **Backend:** CodeIgniter 4 (PHP 8+)
- **Frontend:** Vue 3 + Vite
- **UI:** Bootstrap 5
- **Adatbázis:** MySQL / MariaDB

## Projekt struktúra

```text
backend/   # CodeIgniter 4 alkalmazás
frontend/  # Vue 3 alkalmazás
```

## Local futtatás – gyors indítás

1) **Adatbázis**
- Hozz létre egy adatbázist (pl. `ci4_admin_test`)
- Futtasd le: `backend/database.sql`

2) **Backend**
```bash
cd backend
composer install
cp env .env
# állítsd be az adatbázist a .env-ben
php spark serve
```
Backend: `http://localhost:8080`

3) **Frontend**
```bash
cd frontend
npm install
npm run dev
```
Frontend: `http://localhost:5173`

## Belépés

Alap felhasználó (ha a `database.sql`/setup szerint így hozod létre):
- nickname: `admin`
- password: `Admin123!`

> Megjegyzés: a user tábla `password_hash` mezőjébe **hash** kerül. Ha nem importáltál kész usert,
> generálj hash-t: `php -r "echo password_hash('Admin123!', PASSWORD_DEFAULT), PHP_EOL;"`

## CSRF (SPA)

A backend globális CSRF védelmet használ. SPA esetben a frontend a CSRF tokent a
`GET /api/csrf` endpointon kéri le, és minden nem-GET kéréshez elküldi `X-CSRF-TOKEN` headerben.

## API végpontok (röviden)

- `POST /api/login`
- `POST /api/logout`
- `GET /api/me`
- `GET /api/menu`
- `POST /api/menu`
- `GET /api/csrf`

## MySQL feladatok

A táblák, dummy adatok és az elvárt lekérdezések a `backend/database.sql` fájlban vannak (a fájl végén).
