# Admin Teszt – CodeIgniter 4 + Vue 3

Egyszerű admin alkalmazás a megadott feladat specifikáció alapján: **login + rekurzív (tetszőleges mélységű) menürendszer + MySQL feladatok**.

## Fő funkciók

- Login (nickname + jelszó) siker/hiba (toast/growl) üzenetekkel
- Session alapú autentikáció
- Admin felület (védett route)
- Dinamikus, hierarchikus menü (rekurzív felépítés és megjelenítés)
- CSRF védelem SPA kompatibilis módon (`/api/csrf` + axios interceptor)
- MySQL/MariaDB adatmodell + dummy adatok + a kért lekérdezések

## Technológia

- **Backend:** CodeIgniter 4 (PHP 8+)
- **Frontend:** Vue 3 + Vite
- **UI:** Bootstrap 5
- **DB:** MySQL 8 / MariaDB

## Gyors kipróbálás (Local)

### 1) Adatbázis
1. Hozz létre egy adatbázist (pl. `ci4_admin_test`)
2. Importáld: `backend/database.sql`

> Megjegyzés: a `database.sql` tartalmazza a táblákat, dummy adatokat és a feladatban kért lekérdezéseket is (a fájl végén).

### 2) Backend indítás
```bash
cd backend
composer install
cp env .env
# .env-ben állítsd be a DB kapcsolatot
php spark serve
```

Backend: `http://localhost:8080`

#### DB beállítás példa (XAMPP / phpMyAdmin)
A `backend/.env` fájlban:
```ini
database.default.hostname = localhost
database.default.database = ci4_admin_test
database.default.username = root
database.default.password =
database.default.DBDriver = MySQLi
database.default.port = 3306
```

### 3) Admin felhasználó (admin / Admin123!)
A jelszó hash-elve van tárolva, ezért vagy:
- importálsz kész admin usert, **vagy**
- létrehozod manuálisan.

Hash generálás:
```bash
php -r "echo password_hash('Admin123!', PASSWORD_DEFAULT), PHP_EOL;"
```

Majd SQL (phpMyAdmin):
```sql
INSERT INTO users (nickname, password_hash, is_active)
VALUES ('admin', '<IDE_MASOLT_HASH>', 1);
```

### 4) Frontend indítás
```bash
cd frontend
npm install
npm run dev
```

Frontend: `http://localhost:5173`

## Belépési adatok

- nickname: `admin`
- password: `Admin123!`

## API végpontok (röviden)

- `GET  /api/csrf`
- `POST /api/login`
- `POST /api/logout`
- `GET  /api/me`
- `GET  /api/menu`
- `POST /api/menu`

## MySQL feladatok

A feladatban kért táblák (tranzakciók, fizetési módok, események, jegyek) a `backend/database.sql` fájlban vannak.
A 4 kért lekérdezés (tranzakciók száma fizetési mód szerint, kihasználtság, napi bevétel, top 3 esemény) a fájl végén található.
