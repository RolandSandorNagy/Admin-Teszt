# Backend (CodeIgniter 4) – Admin teszt

Ez a mappa **nem tartalmazza** a CodeIgniter 4 `vendor/` könyvtárat.
A futtatáshoz egy *valódi* CI4 projektet hozz létre Composerrel, majd másold rá ezekből a fájlokból a megfelelőket.

## Követelmények
- PHP 8.1+ (ajánlott 8.2)
- Composer
- MySQL 8+
- PHP extensionök: intl, mbstring, json, curl, openssl, pdo_mysql

## Telepítés (ajánlott: PHP built-in + spark)
1) CI4 projekt létrehozása:
```bash
composer create-project codeigniter4/appstarter ci4-admin-test
```

2) Másold át ebbe a CI4 projektbe a tartalmat:
- `app/Controllers/LoginController.php`
- `app/Filters/AuthFilter.php`
- `app/Config/Routes.php` (felülírhatod vagy merge)
- A `Filters.php.example` alapján egészítsd ki a saját `app/Config/Filters.php` fájlt (alias: auth + globális csrf).
- `database.sql`-t futtasd le a MySQL-ben.

3) `.env` beállítás (CI4 rootban):
- másold: `env` -> `.env`
- állítsd be:
```
database.default.hostname = localhost
database.default.database = ci4_admin_test
database.default.username = root
database.default.password =
database.default.DBDriver  = MySQLi
app.baseURL = 'http://localhost:8080/'
```

4) Admin user létrehozás:
CI4-ben tetszőleges helyen futtasd:
```php
echo password_hash('Admin123!', PASSWORD_DEFAULT);
```
Majd:
```sql
INSERT INTO users (nickname, password_hash) VALUES ('admin', '<HASH>');
```

5) Indítás:
```bash
cd ci4-admin-test
php spark serve
```
Backend elérhető: `http://localhost:8080/`

## XAMPP / Apache
Igen, mehet XAMPP-pal is.

Lépések:
1) A CI4 projektet tedd a `xampp/htdocs/ci4-admin-test` alá
2) Apache vhost vagy DocumentRoot mutasson a `public/` mappára
   - nagyon fontos: CI4-nél a public legyen a webroot
3) Engedélyezd a mod_rewrite-ot (általában alapból megy), és legyen `AllowOverride All`.

## API végpontok
- POST `/api/login` (nickname, password)
- POST `/api/logout`
- GET `/api/menu` (auth szükséges)
- POST `/api/menu` (auth szükséges)

Siker/hiba esetén JSON választ kapsz:
- `{ ok: true, message: "..." }`
- `{ ok: false, message: "...", errors?: { field: msg } }`
