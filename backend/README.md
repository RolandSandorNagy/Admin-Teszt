# Backend – CodeIgniter 4

CI4 alapú backend API a Vue frontendhez.

## Követelmények
- PHP 8.1+ (ajánlott 8.2)
- Composer
- MySQL/MariaDB
- PHP extensionök: intl, mbstring, curl, openssl, pdo_mysql

## Telepítés / indítás

```bash
composer install
cp env .env
# állítsd be az adatbázist a .env-ben
php spark serve
```

Backend: `http://localhost:8080`

## Adatbázis

- Importáld: `database.sql`
- Tartalmazza:
  - loginhoz szükséges táblák
  - menü táblák
  - MySQL feladathoz kért táblák + dummy adatok + lekérdezések

## CSRF (SPA)

A CSRF globálisan engedélyezett.
SPA klienshez a backend biztosít egy token endpointot:

- `GET /api/csrf` → `{ ok: true, token: "<csrf_hash>" }`

A kliens a tokent `X-CSRF-TOKEN` headerben küldi POST/PUT/PATCH/DELETE kérésekhez.

## API

- `POST /api/login` (nickname, password)
- `POST /api/logout`
- `GET /api/me`
- `GET /api/menu` (rekurzív menüfa)
- `POST /api/menu` (menüpont létrehozás validációval)
