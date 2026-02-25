# Backend – CodeIgniter 4

CI4 alapú REST API a Vue frontendhez (login + menükezelés + MySQL feladat adatmodell).

## Követelmények

- PHP 8.1+ (ajánlott 8.2)
- Composer
- MySQL 8 / MariaDB

## Indítás

```bash
composer install
cp env .env
php spark serve
```

Alap URL: `http://localhost:8080`

## Konfiguráció (.env)

A `backend/.env` fájlban állítsd be a DB kapcsolatot, pl. (XAMPP):

```ini
database.default.hostname = localhost
database.default.database = ci4_admin_test
database.default.username = root
database.default.password =
database.default.DBDriver = MySQLi
database.default.port = 3306
```

## Adatbázis

Importáld: `database.sql`

A fájl tartalmaz:
- loginhoz és menühöz szükséges táblákat (`users`, `menus`)
- a MySQL feladathoz kért táblákat:
  - `tranzakciok`
  - `tranzakcio_elemek`
  - `tranzakcio_fizetesi_modok` (egy tranzakció több módon is fizethető)
  - `esemenyek`
  - `jegyek` (kapacitás = jegyek száma, státuszok ENUM)
- dummy adatokat
- a 4 kért lekérdezést (a fájl végén)

## Adatmodell magyarázat (röviden)

### users
Bejelentkezéshez szükséges tábla.
- `nickname` unique
- `password_hash` (bcrypt)
- `is_active`

### menus
Hierarchikus menü támogatás önhivatkozó `parent_id`-vel.
- `parent_id` -> `menus.id` (tetszőleges mélység)
- `sort_order` (azonos szülő alatt rendezés)
- `is_active`
Indexek: `(parent_id, sort_order)` a gyors rendezéshez.

### esemenyek + jegyek
- `esemenyek`: esemény metaadatok (név, időpont, helyszín)
- `jegyek`: eseményhez tartozó jegyek + státusz (`eladott`, `szabad`, `foglalt`, `nem_eladhato`)
A jegyek száma reprezentálja az esemény kapacitását, így számolható a kihasználtság.

### tranzakciok + tranzakcio_elemek + tranzakcio_fizetesi_modok
- `tranzakciok`: vásárlás fej (státusz, dátum, total)
- `tranzakcio_elemek`: tételek (pl. jegy)
- `tranzakcio_fizetesi_modok`: több fizetési mód támogatása (1 tranzakció -> több sor)

## CSRF (SPA)

A CSRF globálisan engedélyezett.
SPA esetben a frontend a tokent a `GET /api/csrf` végponton kéri le, és minden nem-GET kéréshez elküldi `X-CSRF-TOKEN` headerben.

## API (röviden)

- `GET  /api/csrf`
- `POST /api/login`
- `POST /api/logout`
- `GET  /api/me`
- `GET  /api/menu` (auth)
- `POST /api/menu` (auth)
